-- View: public.w2viewsummarytotals

-- DROP VIEW public.w2viewsummarytotals;

--CREATE OR REPLACE VIEW public.w2viewsummarytotals AS 
 SELECT t.taxformyear,
    t.payunitid,
    t.employertaxid,
    t.box,
    t.total,
    t.state,
    t.stateid,
    t.boxnumber
   FROM ( SELECT x.taxformyear,
            x.payunitid,
            pu.employertaxid,
            x.boxnumber,
            (btrim(x.boxnumber) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
            sum(x.total) AS total,
            ''::text AS state,
            ''::text AS stateid
           FROM ( SELECT tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text) AS boxnumber,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                  WHERE (btrim(tfd.box::text) = ANY (ARRAY['1'::text, '2'::text, '3'::text, '4'::text, '5'::text, '6'::text, '7'::text, '8'::text, '9'::text, '10'::text, '11'::text])) AND tfh.taxformtypeid = 1
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) x
             JOIN pay_unit pu ON pu.payunitid = x.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(x.boxnumber)
          GROUP BY x.taxformyear, x.payunitid, pu.employertaxid, x.boxnumber, tfbd.boxdescription
        UNION
         SELECT boxb.taxformyear,
            pu.payunitid,
            pu.employertaxid,
            btrim(boxb.boxnumber) AS boxnumber,
            (btrim(boxb.boxnumber) || ' '::text) || btrim(boxb.label) AS box,
            sum(boxb.total) AS total,
            ''::text AS state,
            ''::text AS stateid
           FROM ( SELECT tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text) AS boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS label,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                  WHERE btrim(tfd.box::text) ~~* 'b%'::text AND tfh.taxformtypeid = 1
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) boxb
             JOIN pay_unit pu ON pu.payunitid = boxb.payunitid
          GROUP BY pu.payunitid, boxb.taxformyear, pu.employertaxid, boxb.boxnumber, boxb.label          
        UNION
         SELECT box12.taxformyear,
            box12.payunitid,
            pu.employertaxid,
            btrim(box12.boxnumber) AS boxnumber,
            (((btrim(box12.boxnumber) || ' '::text) || COALESCE(box12.irscode, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
            sum(box12.total) AS total,
            ''::text AS state,
            ''::text AS stateid
           FROM ( SELECT tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text) AS boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS irscode,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                  WHERE btrim(tfd.box::text) ~~* '12%'::text AND tfh.taxformtypeid = 1
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) box12
             JOIN pay_unit pu ON pu.payunitid = box12.payunitid
             LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(box12.boxnumber)
          GROUP BY box12.payunitid, box12.taxformyear, pu.employertaxid, box12.boxnumber, box12.irscode, tfbd.boxdescription
        UNION
         SELECT box14.taxformyear,
            pu.payunitid,
            pu.employertaxid,
            btrim(box14.boxnumber) AS boxnumber,
            (btrim(box14.boxnumber) || ' '::text) || btrim(box14.label) AS box,
            sum(box14.total) AS total,
            ''::text AS state,
            ''::text AS stateid
           FROM ( SELECT tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text) AS boxnumber,
                    string_agg(btrim(tfd.alphavalue::text), ''::text) AS label,
                    sum(tfd.dollarsvalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                  WHERE btrim(tfd.box::text) ~~* '14%'::text AND tfh.taxformtypeid = 1
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box) box14
             JOIN pay_unit pu ON pu.payunitid = box14.payunitid
          GROUP BY pu.payunitid, box14.taxformyear, pu.employertaxid, box14.boxnumber, box14.label
        UNION
         SELECT sub1617.taxformyear,
            sub1617.payunitid,
            sub1617.employertaxid,
            sub1617.boxnumber,
            sub1617.box,
            sum(sub1617.total) AS total,
            sub1617.state,
            sub1617.stateid
           FROM ( SELECT tfh.personid,
                    tfh.taxformyear,
                    pu.payunitid,
                    pu.employertaxid,
                    btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text)) AS boxnumber,
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
                  GROUP BY tfh.personid, pu.payunitid, pu.employertaxid, tfh.taxformyear, (regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text)), tfd1.alphavalue, tfd2.alphavalue, tfbd.boxdescription
                UNION
                 SELECT tfh.personid,
                    tfh.taxformyear,
                    pu.payunitid,
                    pu.employertaxid,
                    btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text)) AS boxnumber,
                    (btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
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
                  GROUP BY tfh.personid, pu.payunitid, pu.employertaxid, tfh.taxformyear, (regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text)), tfd1.alphavalue, tfd2.alphavalue, tfbd.boxdescription) sub1617
          GROUP BY sub1617.payunitid, sub1617.employertaxid, sub1617.taxformyear, sub1617.boxnumber, sub1617.box, sub1617.state, sub1617.stateid
        UNION
         SELECT sub1819.taxformyear,
            sub1819.payunitid,
            sub1819.employertaxid,
            sub1819.boxnumber,
            sub1819.box,
            sum(sub1819.total) AS total,
            sub1819.state,
            sub1819.stateid
           FROM ( SELECT tfh.personid,
                    tfh.taxformyear,
                    pu.payunitid,
                    pu.employertaxid,
                    btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text)) AS boxnumber,
                    (btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
                    sum(tfd.dollarsvalue) AS total,
                    btrim(tfd1.alphavalue::text) AS state,
                    ''::text AS stateid
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                     JOIN pay_unit pu ON pu.payunitid = tfh.payunitid
                     JOIN tax_form_detail tfd1 ON tfd1.taxformhdrid = tfh.taxformhdrid AND tfd1.subbox = 0 AND tfd1.box::text ~~* '20A%'::text
                     LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text))
                  WHERE (btrim(tfd.box::text) ~~* '18A%'::text OR btrim(tfd.box::text) ~~* '19A%'::text) AND tfd.taxformhdrid = tfd1.taxformhdrid AND tfd1.alphavalue IS NOT NULL AND tfh.taxformtypeid = 1
                  GROUP BY tfh.personid, tfh.taxformyear, pu.payunitid, pu.employertaxid, (btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text))), tfbd.boxdescription, tfd1.alphavalue
                UNION
                 SELECT tfh.personid,
                    tfh.taxformyear,
                    pu.payunitid,
                    pu.employertaxid,
                    btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text)) AS boxnumber,
                    (btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text)) || ' '::text) || COALESCE(btrim(tfbd.boxdescription::text), ''::text) AS box,
                    sum(tfd.dollarsvalue) AS total,
                    btrim(tfd1.alphavalue::text) AS state,
                    ''::text AS stateid
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                     JOIN pay_unit pu ON pu.payunitid = tfh.payunitid
                     JOIN tax_form_detail tfd1 ON tfd1.taxformhdrid = tfh.taxformhdrid AND tfd1.subbox = 0 AND tfd1.box::text ~~* '20B%'::text
                     LEFT JOIN tax_form_box_desc tfbd ON tfbd.box::text = btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text))
                  WHERE (btrim(tfd.box::text) ~~* '18B%'::text OR btrim(tfd.box::text) ~~* '19B%'::text) AND tfd.taxformhdrid = tfd1.taxformhdrid AND tfd1.alphavalue IS NOT NULL AND tfh.taxformtypeid = 1
                  GROUP BY tfh.personid, tfh.taxformyear, pu.payunitid, pu.employertaxid, (btrim(regexp_replace(btrim(tfd.box::text), '[A-Z]'::text, ''::text))), tfbd.boxdescription, tfd1.alphavalue) sub1819
          GROUP BY sub1819.taxformyear, sub1819.payunitid, sub1819.employertaxid, sub1819.boxnumber, sub1819.box, sub1819.state, sub1819.stateid
        UNION
         SELECT sub.taxformyear,
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
           FROM ( SELECT tfh.taxformhdrid,
                    tfh.taxformyear,
                    tfh.payunitid,
                    btrim(tfd.box::text) AS boxnumber,
                    tfd.subbox,
                    count(tfd.alphavalue) AS total
                   FROM tax_form_header tfh
                     JOIN tax_form_detail tfd ON tfd.taxformhdrid = tfh.taxformhdrid
                  WHERE btrim(tfd.box::text) = '13'::text AND tfh.taxformtypeid = 1 AND btrim(tfd.alphavalue::text) ~~* 'X'::text
                  GROUP BY tfh.taxformhdrid, tfh.taxformyear, tfh.payunitid, tfd.box, tfd.subbox) sub
             JOIN pay_unit pu ON pu.payunitid = sub.payunitid
          GROUP BY pu.employertaxid, sub.payunitid, sub.taxformyear, sub.boxnumber, sub.subbox) t
  ORDER BY (t.boxnumber::integer), t.state;
/*
ALTER TABLE public.w2viewsummarytotals
  OWNER TO postgres;
GRANT ALL ON TABLE public.w2viewsummarytotals TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.w2viewsummarytotals TO read_write;
GRANT SELECT ON TABLE public.w2viewsummarytotals TO read_only;
*/
