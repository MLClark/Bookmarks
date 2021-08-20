-----------------------------
----- boxa Employee SSN -----
-----------------------------
         SELECT 
            boxa.personid,
            boxa.pagenum,
            boxa.createts,
            boxa.updatets,
            boxa.printed,
            boxa.taxformyear,
            boxa.payunitid,
            pu.employertaxid,
            btrim(boxa.boxnumber) AS boxnumber,
            ((COALESCE(boxa.irscode, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
            sum(boxa.total) AS total,
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
                  WHERE btrim(tfd.box::text) ~~* 'a%'::text AND tfh.taxformtypeid = 1 
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) boxa
             JOIN pay_unit pu ON pu.payunitid = boxa.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(boxa.boxnumber)
          GROUP BY boxa.personid, boxa.payunitid, boxa.taxformyear, pu.employertaxid, boxa.boxnumber, boxa.irscode, tfbd.boxdescription, boxa.pagenum, boxa.createts, boxa.updatets, boxa.printed
