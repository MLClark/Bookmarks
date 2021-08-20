-------------------------------
----- boxc1 Employer Name -----
-------------------------------
         SELECT 
            boxc1.personid,
            boxc1.pagenum,
            boxc1.createts,
            boxc1.updatets,
            boxc1.printed,
            boxc1.taxformyear,
            boxc1.payunitid,
            pu.employertaxid,
            btrim(boxc1.boxnumber) AS boxnumber,
            ((COALESCE(boxc1.irscode, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
            sum(boxc1.total) AS total,
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
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid --AND tfd.subbox = 1
                  WHERE btrim(tfd.box::text) ~~* 'b%'::text AND tfh.taxformtypeid = 1 
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) boxb1
             JOIN pay_unit pu ON pu.payunitid = boxc1.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(boxc1.boxnumber)
          GROUP BY boxc1.personid, boxc1.payunitid, boxc1.taxformyear, pu.employertaxid, boxc1.boxnumber, boxc1.irscode, tfbd.boxdescription, boxc1.pagenum, boxc1.createts, boxc1.updatets, boxc1.printed
      