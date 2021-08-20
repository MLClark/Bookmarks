/*
View based on w2viewsummarytotals - added personid, pagenum, createts, updatets and printed flag.

Ask Debbie about how to handle street address IE Employer Address - lots of garbage 
subbox 4 could be an address or a control number - how to determine which? 
Should we add the subbox number to the extracted column list?


select * from w2viewsummarytotals;
Using Case insensitive pattern matching
~~ is equivalent to LIKE
~~* is equivalent to ILIKE
!~~ is equivalent to NOT LIKE
!~~* is equivalent to NOT ILIKE

*/
SELECT 
    t.personid,
    t.trankey,
    t.pagenum,  ---- form number
    t.createts, ---- date created
    t.updatets, ---- date approved Only display a value here if the printed flag on tax_form_header='Y', otherwise leave blank
    t.printed,  ---- needed for displaying updatets
    t.taxformyear,
    t.payunitid,
    t.employertaxid,
    t.box,
    t.total,
    t.state,
    t.stateid,
    t.boxnumber
FROM (SELECT 
            x.personid,
            x.trankey,
            x.pagenum,
            x.createts,
            x.updatets,
            x.printed,
            
            x.taxformyear,
            x.payunitid,
            pu.employertaxid,
            x.boxnumber,
            (btrim(x.boxnumber) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
            sum(x.total) AS total,
            ''::text AS state,
            ''::text AS stateid
           FROM ( SELECT 
                    tfh.personid,
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    tfd.box::text as boxnumber,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                  WHERE (btrim(tfd.box::text) = ANY (ARRAY['1'::text, '2'::text, '3'::text, '4'::text, '5'::text, '6'::text, '7'::text, '8'::text, '9'::text, '10'::text, '11'::text])) AND tfh.taxformtypeid = 1
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) x
             JOIN pay_unit pu ON pu.payunitid = x.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(x.boxnumber)
          GROUP BY x.personid, x.trankey, x.taxformyear, x.payunitid, pu.employertaxid, x.boxnumber, tfbd.boxdescription, x.pagenum, x.createts, x.updatets, x.printed

      UNION
-----------------------------
----- boxa Employee SSN -----
-----------------------------
         SELECT 
            boxa.personid,
            boxa.trankey,
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
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    tfd.box::text as boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS irscode,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid AND tfd.subbox = 0
                  WHERE btrim(tfd.box::text) ~~* 'a%'::text AND tfh.taxformtypeid = 1 
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) boxa
             JOIN pay_unit pu ON pu.payunitid = boxa.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(boxa.boxnumber)
          GROUP BY boxa.personid, boxa.trankey, boxa.payunitid, boxa.taxformyear, pu.employertaxid, boxa.boxnumber, boxa.irscode, tfbd.boxdescription, boxa.pagenum, boxa.createts, boxa.updatets, boxa.printed

      UNION
-----------------------------------------------
----- boxb Employer Identification Number -----
-----------------------------------------------
         SELECT 
            boxb.personid,
            boxb.trankey,
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
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    tfd.box::text as boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS irscode,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid AND tfd.subbox = 0
                  WHERE btrim(tfd.box::text) ~~* 'b%'::text AND tfh.taxformtypeid = 1 
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) boxb
             JOIN pay_unit pu ON pu.payunitid = boxb.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(boxb.boxnumber)
          GROUP BY boxb.personid, boxb.trankey, boxb.payunitid, boxb.taxformyear, pu.employertaxid, boxb.boxnumber, boxb.irscode, tfbd.boxdescription, boxb.pagenum, boxb.createts, boxb.updatets, boxb.printed
      
      UNION 
-------------------------------
----- boxc1 Employer Name -----
-------------------------------
         SELECT 
            boxc1.personid,
            boxc1.trankey,
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
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    tfd.box::text as boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS irscode,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid AND tfd.subbox = 1
                  WHERE btrim(tfd.box::text) ~~* 'c%'::text AND tfh.taxformtypeid = 1 
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) boxc1
             JOIN pay_unit pu ON pu.payunitid = boxc1.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(boxc1.boxnumber)
          GROUP BY boxc1.personid, boxc1.trankey, boxc1.payunitid, boxc1.taxformyear, pu.employertaxid, boxc1.boxnumber, boxc1.irscode, tfbd.boxdescription, boxc1.pagenum, boxc1.createts, boxc1.updatets, boxc1.printed
      
      UNION
------------------------------------
----- boxc234 Employer Address -----
------------------------------------
         SELECT 
            boxc234.personid,
            boxc234.trankey,
            boxc234.pagenum,
            boxc234.createts,
            boxc234.updatets,
            boxc234.printed,
            boxc234.taxformyear,
            boxc234.payunitid,
            pu.employertaxid,
            btrim(boxc234.boxnumber) AS boxnumber,
            ((COALESCE(boxc234.irscode, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
            sum(boxc234.total) AS total,
            ''::text AS state,
            ''::text AS stateid
           FROM ( SELECT 
                    tfh.personid, 
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    tfd.box::text as boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS irscode,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid AND tfd.subbox in (2,3,4)
                  WHERE btrim(tfd.box::text) ~~* 'c%'::text AND tfh.taxformtypeid = 1 
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) boxc234
             JOIN pay_unit pu ON pu.payunitid = boxc234.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(boxc234.boxnumber)
          GROUP BY boxc234.personid, boxc234.trankey, boxc234.payunitid, boxc234.taxformyear, pu.employertaxid, boxc234.boxnumber, boxc234.irscode, tfbd.boxdescription, boxc234.pagenum, boxc234.createts, boxc234.updatets, boxc234.printed

      UNION
------------------------------------------------
----- boxe1 Employee Last Name, First Name -----
------------------------------------------------
         SELECT 
            boxe1.personid,
            boxe1.trankey,
            boxe1.pagenum,
            boxe1.createts,
            boxe1.updatets,
            boxe1.printed,
            boxe1.taxformyear,
            boxe1.payunitid,
            pu.employertaxid,
            btrim(boxe1.boxnumber) AS boxnumber,
            ((COALESCE(boxe1.irscode, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
            sum(boxe1.total) AS total,
            ''::text AS state,
            ''::text AS stateid
           FROM ( SELECT 
                    tfh.personid, 
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    tfd.box::text as boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS irscode,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid AND tfd.subbox = 1
                  WHERE btrim(tfd.box::text) ~~* 'e%'::text AND tfh.taxformtypeid = 1 
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) boxe1
             JOIN pay_unit pu ON pu.payunitid = boxe1.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(boxe1.boxnumber)
          GROUP BY boxe1.personid, boxe1.trankey, boxe1.payunitid, boxe1.taxformyear, pu.employertaxid, boxe1.boxnumber, boxe1.irscode, tfbd.boxdescription, boxe1.pagenum, boxe1.createts, boxe1.updatets, boxe1.printed
      
      UNION
------------------------------------
----- boxe234 Employee Address -----
------------------------------------
         SELECT 
            boxe234.personid,
            boxe234.trankey,
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
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    tfd.box::text as boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS irscode,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid AND tfd.subbox in (2,3,4)
                  WHERE btrim(tfd.box::text) ~~* 'e%'::text AND tfh.taxformtypeid = 1 
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) boxe234
             JOIN pay_unit pu ON pu.payunitid = boxe234.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(boxe234.boxnumber)
          GROUP BY boxe234.personid, boxe234.trankey, boxe234.payunitid, boxe234.taxformyear, pu.employertaxid, boxe234.boxnumber, boxe234.irscode, tfbd.boxdescription, boxe234.pagenum, boxe234.createts, boxe234.updatets, boxe234.printed
         
      UNION
         
         SELECT 
            box12.personid,
            box12.trankey,
            box12.pagenum,
            box12.createts,
            box12.updatets,
            box12.printed,
            box12.taxformyear,
            box12.payunitid,
            pu.employertaxid,
            btrim(box12.boxnumber) AS boxnumber,
            (((btrim(box12.boxnumber) || ' '::text) || COALESCE(box12.irscode, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
            sum(box12.total) AS total,
            ''::text AS state,
            ''::text AS stateid
           FROM ( SELECT 
                    tfh.personid, 
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    tfd.box::text as boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS irscode,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                  WHERE btrim(tfd.box::text) ~~* '12%'::text AND tfh.taxformtypeid = 1
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) box12
             JOIN pay_unit pu ON pu.payunitid = box12.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(box12.boxnumber)
          GROUP BY box12.personid, box12.trankey, box12.payunitid, box12.taxformyear, pu.employertaxid, box12.boxnumber, box12.irscode, tfbd.boxdescription, box12.pagenum, box12.createts, box12.updatets, box12.printed

      UNION
 
         SELECT 
            box14.personid, 
            box14.trankey,
            box14.pagenum,
            box14.createts,
            box14.updatets,
            box14.printed, 
            box14.taxformyear,
            pu.payunitid,
            pu.employertaxid,
            btrim(box14.boxnumber) AS boxnumber,
            (btrim(box14.boxnumber) || ' '::text) || btrim(box14.label) AS box,
            sum(box14.total) AS total,
            ''::text AS state,
            ''::text AS stateid
           FROM ( SELECT 
                    tfh.personid,
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    tfd.box::text as boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS label,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                  WHERE btrim(tfd.box::text) ~~* '14%'::text AND tfh.taxformtypeid = 1
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) box14
             JOIN pay_unit pu ON pu.payunitid = box14.payunitid
          GROUP BY box14.personid, box14.trankey, pu.payunitid, box14.taxformyear, pu.employertaxid, box14.boxnumber, box14.label, box14.pagenum, box14.createts, box14.updatets, box14.printed

      UNION

         SELECT 
            sub1617.personid, 
            sub1617.trankey,
            sub1617.pagenum,
            sub1617.createts,
            sub1617.updatets,
            sub1617.printed,
            sub1617.taxformyear,
            sub1617.payunitid,
            sub1617.employertaxid,
            sub1617.boxnumber,
            sub1617.box,
            sum(sub1617.total) AS total,
            sub1617.state,
            sub1617.stateid
           FROM ( SELECT 
                    tfh.personid,
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformyear,
                    pu.payunitid,
                    pu.employertaxid,
                    tfd.box::text as boxnumber,
                    (btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
                    sum(tfd.dollarsvalue) AS total,
                    btrim(tfd1.alphavalue::text) AS state,
                    btrim(tfd2.alphavalue::text) AS stateid
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                     JOIN pay_unit pu ON pu.payunitid = tfh.payunitid
                     JOIN tax_form_detail tfd1 ON tfd1.taxformhdrid = tfh.taxformhdrid AND tfd1.subbox = 1 AND tfd1.box::text ~~* '15A%'::text
                     JOIN tax_form_detail tfd2 ON tfd2.taxformhdrid = tfh.taxformhdrid AND tfd2.subbox = 2 AND tfd2.box::text ~~* '15A%'::text AND tfd1.box::text = tfd2.box::text
                     LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text))
                  WHERE (btrim(tfd.box::text) ~~* '16A%'::text OR btrim(tfd.box::text) ~~* '17A%'::text) AND tfh.taxformhdrid = tfd1.taxformhdrid AND tfd1.alphavalue IS NOT NULL AND tfh.taxformhdrid = tfd2.taxformhdrid AND tfd2.alphavalue IS NOT NULL AND tfh.taxformtypeid = 1
                  GROUP BY tfh.personid, tfh.trankey, pu.payunitid, pu.employertaxid, tfh.taxformyear, tfd.box, tfd1.alphavalue, tfd2.alphavalue, tfbd.boxdescription, tfh.pagenum, tfh.createts, tfh.updatets, tfh.printed

                UNION
 
                  SELECT 
                    tfh.personid,
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformyear,
                    pu.payunitid,
                    pu.employertaxid,
                    tfd1.box::text as boxnumber,
                    (btrim(regexp_replace(btrim(tfd1.box::text), '[A-Z]'::text, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
                    sum(tfd.dollarsvalue) AS total,
                    btrim(tfd1.alphavalue::text) AS state,
                    btrim(tfd2.alphavalue::text) AS stateid
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                     JOIN pay_unit pu ON pu.payunitid = tfh.payunitid
                     JOIN tax_form_detail tfd1 ON tfd1.taxformhdrid = tfh.taxformhdrid AND tfd1.subbox = 1 AND tfd1.box::text ~~* '15B%'::text
                     JOIN tax_form_detail tfd2 ON tfd2.taxformhdrid = tfh.taxformhdrid AND tfd2.subbox = 2 AND tfd2.box::text ~~* '15B%'::text AND tfd1.box::text = tfd2.box::text
                     LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text))
                  WHERE (btrim(tfd.box::text) ~~* '16B%'::text OR btrim(tfd.box::text) ~~* '17B%'::text) AND tfh.taxformhdrid = tfd1.taxformhdrid AND tfd1.alphavalue IS NOT NULL AND tfh.taxformhdrid = tfd2.taxformhdrid AND tfd2.alphavalue IS NOT NULL AND tfh.taxformtypeid = 1
                  GROUP BY tfh.personid, tfh.trankey, pu.payunitid, pu.employertaxid, tfh.taxformyear, tfd1.box, tfd1.alphavalue, tfd2.alphavalue, tfbd.boxdescription, tfh.pagenum, tfh.createts, tfh.updatets, tfh.printed) sub1617
          GROUP BY sub1617.personid, sub1617.trankey, sub1617.payunitid, sub1617.employertaxid, sub1617.taxformyear, sub1617.boxnumber, sub1617.box, sub1617.state, sub1617.stateid, sub1617.pagenum, sub1617.createts, sub1617.updatets, sub1617.printed
 
       UNION

         SELECT 
            sub1819.personid,
            sub1819.trankey,
            sub1819.pagenum,
            sub1819.createts,
            sub1819.updatets,
            sub1819.printed,
            sub1819.taxformyear,
            sub1819.payunitid,
            sub1819.employertaxid,
            sub1819.boxnumber,
            sub1819.box,
            sum(sub1819.total) AS total,
            sub1819.state,
            sub1819.stateid
           FROM ( SELECT 
                    tfh.personid,
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformyear,
                    pu.payunitid,
                    pu.employertaxid,
                    tfd1.box::text as boxnumber,
                    (btrim(regexp_replace(btrim(tfd1.box::text), '[A-Z]'::text, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
                    sum(tfd.dollarsvalue) AS total,
                    btrim(tfd1.alphavalue::text) AS state,
                    ''::text AS stateid
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                     JOIN pay_unit pu ON pu.payunitid = tfh.payunitid
                     JOIN tax_form_detail tfd1 ON tfd1.taxformhdrid = tfh.taxformhdrid AND tfd1.subbox = 0 AND tfd1.box::text ~~* '20A%'::text
                     LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text))
                  WHERE (btrim(tfd.box::text) ~~* '18A%'::text OR btrim(tfd1.box::text) ~~* '19A%'::text) AND tfd.taxformhdrid = tfd1.taxformhdrid AND tfd1.alphavalue IS NOT NULL AND tfh.taxformtypeid = 1
                  GROUP BY tfh.personid, tfh.trankey, tfh.taxformyear, pu.payunitid, pu.employertaxid, tfd1.box, tfbd.boxdescription, tfd1.alphavalue, tfh.pagenum, tfh.createts, tfh.updatets, tfh.printed

                UNION

                 SELECT 
                    tfh.personid,
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets,
                    tfh.printed,
                    tfh.taxformyear,
                    pu.payunitid,
                    pu.employertaxid,
                    tfd1.box::text as boxnumber,
                    (btrim(regexp_replace(btrim(tfd1.box::text), '[A-Z]'::text, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
                    sum(tfd.dollarsvalue) AS total,
                    btrim(tfd1.alphavalue::text) AS state,
                    ''::text AS stateid
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                     JOIN pay_unit pu ON pu.payunitid = tfh.payunitid
                     JOIN tax_form_detail tfd1 ON tfd1.taxformhdrid = tfh.taxformhdrid AND tfd1.subbox = 0 AND tfd1.box::text ~~* '20B%'::text
                     LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text))
                  WHERE (btrim(tfd.box::text) ~~* '18B%'::text OR btrim(tfd.box::text) ~~* '19B%'::text) AND tfd.taxformhdrid = tfd1.taxformhdrid AND tfd1.alphavalue IS NOT NULL AND tfh.taxformtypeid = 1
                  GROUP BY tfh.personid, tfh.trankey, tfh.taxformyear, pu.payunitid, pu.employertaxid, tfd1.box, tfbd.boxdescription, tfd1.alphavalue, tfh.pagenum, tfh.createts, tfh.updatets, tfh.printed) sub1819
          GROUP BY sub1819.taxformyear, sub1819.trankey, sub1819.payunitid, sub1819.employertaxid, sub1819.boxnumber, sub1819.box, sub1819.state, sub1819.stateid, sub1819.personid, sub1819.pagenum, sub1819.createts, sub1819.updatets, sub1819.printed

     UNION

         SELECT 
            sub.personid,
            sub.trankey,
            sub.pagenum,
            sub.createts,
            sub.updatets,
            sub.printed,
            sub.taxformyear,
            sub.payunitid,
            pu.employertaxid,
            btrim(sub.boxnumber) AS boxnumber,
            (btrim(sub.boxnumber) || ' '::text) ||
                CASE
                    WHEN sub.subbox = 1 THEN 'Statutory Employee'::text
                    WHEN sub.subbox = 2 THEN 'Retirement Plan'::text
                    WHEN sub.subbox = 3 THEN 'Third Party Sick Pay'::text
                    ELSE ''::text
                END AS box,
            sum(sub.total) AS total,
            ''::text AS state,
            ''::text AS stateid
           FROM ( SELECT 
                    tfh.personid,
                    tfh.trankey,
                    tfh.pagenum,
                    tfh.createts,
                    tfh.updatets, 
                    tfh.printed,
                    tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    btrim(tfd.box::text) AS boxnumber,
                    tfd.subbox,
                    count(tfd.alphavalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                  WHERE btrim(tfd.box::text) = '13'::text AND tfh.taxformtypeid = 1 AND btrim(tfd.alphavalue::text) ~~* 'X'::text
                  GROUP BY tfh.personid, tfh.trankey, tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box, tfd.subbox) sub
             JOIN pay_unit pu ON pu.payunitid = sub.payunitid
          GROUP BY sub.personid, sub.trankey, pu.employertaxid, sub.payunitid, sub.taxformyear, sub.boxnumber, sub.subbox, sub.pagenum, sub.createts, sub.updatets, sub.printed) t
  ORDER BY t.personid, t.boxnumber, t.state;