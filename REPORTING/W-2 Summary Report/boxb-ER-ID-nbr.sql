-----------------------------------------------
----- boxb Employer Identification Number -----
-----------------------------------------------
         SELECT 
            boxb.personid,
            boxb.pagenum,
            boxb.createts,
            boxb.updatets,
            boxb.printed,
            boxb.taxformyear,
            boxb.payunitid,
            pu.employertaxid,
            btrim(boxb.boxnumber) AS boxnumber,
            ((COALESCE(boxb.irscode, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
            sum(boxb.total) AS total,
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
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid AND tfd.subbox = 0
                  WHERE btrim(tfd.box::text) ~~* 'b%'::text AND tfh.taxformtypeid = 1 
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) boxb
             JOIN pay_unit pu ON pu.payunitid = boxb.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(boxb.boxnumber)
          GROUP BY boxb.personid, boxb.payunitid, boxb.taxformyear, pu.employertaxid, boxb.boxnumber, boxb.irscode, tfbd.boxdescription, boxb.pagenum, boxb.createts, boxb.updatets, boxb.printed
