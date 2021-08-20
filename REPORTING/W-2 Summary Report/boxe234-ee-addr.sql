------------------------------------
----- boxe234 Employee Address -----
------------------------------------
         SELECT 
            boxe234.personid,
            boxe234.pagenum,
            boxe234.createts,
            boxe234.updatets,
            boxe234.printed,
            boxe234.taxformyear,
            boxe234.payunitid,
            pu.employertaxid,
            btrim(boxe234.boxnumber) AS boxnumber,
            ((COALESCE(boxe234.irscode, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
            sum(boxe234.total) AS total,
            ''::text AS state,
            ''::text AS stateid
           FROM ( SELECT 
                    tfh.personid, 
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text) AS boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS irscode,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid AND tfd.subbox in (2,3,4)
                  WHERE btrim(tfd.box::text) ~~* 'e%'::text AND tfh.taxformtypeid = 1 
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) boxe234
             JOIN pay_unit pu ON pu.payunitid = boxe234.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(boxe234.boxnumber)
          GROUP BY boxe234.personid, boxe234.payunitid, boxe234.taxformyear, pu.employertaxid, boxe234.boxnumber, boxe234.irscode, tfbd.boxdescription, boxe234.pagenum, boxe234.createts, boxe234.updatets, boxe234.printed
         