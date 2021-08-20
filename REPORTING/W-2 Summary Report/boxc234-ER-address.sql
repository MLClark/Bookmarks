------------------------------------
----- boxc234 Employer Address -----
------------------------------------
         SELECT 
            boxc234.personid,
            boxc234.pagenum,
            boxc234.createts,
            boxc234.updatets,
            boxc234.printed,
            boxc234.taxformyear,
            boxc234.payunitid,
            boxc234.subbox,
            pu.employertaxid,
            btrim(boxc234.boxnumber) AS boxnumber,
            ((COALESCE(boxc234.irscode, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
            sum(boxc234.total) AS total,
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
                    tfd.subbox,
                    regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text) AS boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS irscode,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid AND tfd.subbox in (2,3,4)
                  WHERE btrim(tfd.box::text) ~~* 'c%'::text AND tfh.taxformtypeid = 1 
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box, tfd.subbox) boxc234
             JOIN pay_unit pu ON pu.payunitid = boxc234.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(boxc234.boxnumber)
          GROUP BY boxc234.personid, boxc234.payunitid, boxc234.taxformyear, pu.employertaxid, boxc234.boxnumber, boxc234.irscode, tfbd.boxdescription, boxc234.pagenum, boxc234.createts, boxc234.updatets, boxc234.printed, boxc234.subbox
