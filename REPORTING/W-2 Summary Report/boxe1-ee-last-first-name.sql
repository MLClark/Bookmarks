-- View: public.cognos_w2_data

-- DROP VIEW public.cognos_w2_data;

--CREATE OR REPLACE VIEW public.cognos_w2_data AS 
 SELECT tfh.taxformhdrid,
    tfh.personid,
    tfh.payunitid,
    tfh.pagenum,
    tfh.trankey,
    tfh.taxformyear,
    tfh.taxformtypeid,
    tfh.printed,
    tfh.createts,
    tfh.updatets,
    tfd1.box::text AS boxnumber,
    COALESCE((tfd1.box::text ||
        CASE
            WHEN tyfbd.boxdescription IS NOT NULL THEN ','::text
            ELSE ''::text
        END) || tyfbd.boxdescription::text, tfd1.box::text) AS box,
    tfd1.subbox,
    tfd2.subbox AS subbox2,
    COALESCE(NULLIF(btrim(tfd1.alphavalue::text), ''::text), NULLIF(btrim(tfd2.alphavalue::text), ''::text)) AS alphavalue,
    COALESCE(NULLIF(tfd1.dollarsvalue, 0::numeric), NULLIF(tfd2.dollarsvalue, 0::numeric), 0::numeric) AS dollarsvalue,
    COALESCE(NULLIF(btrim(tfd1.oldalphavalue::text), ''::text), NULLIF(btrim(tfd2.oldalphavalue::text), ''::text)) AS oldalphavalue,
    COALESCE(NULLIF(tfd1.olddollarsvalue, 0::numeric), NULLIF(tfd2.olddollarsvalue, 0::numeric), 0::numeric) AS olddollarsvalue
   FROM tax_form_header tfh
     JOIN tax_form_detail tfd1 ON tfh.taxformhdrid = tfd1.taxformhdrid
     LEFT JOIN tax_form_box_desc tyfbd ON (btrim(tfd1.box::text) ~ similar_escape(tyfbd.box::text || '[A-Z]'::text, NULL::text) OR btrim(tfd1.box::text) = tyfbd.box::text) AND tyfbd.taxformtypeid = tfh.taxformtypeid AND tfh.createts >= tyfbd.effectivedate AND tfh.createts <= tyfbd.enddate AND now() >= tyfbd.createts AND now() <= tyfbd.endts
     LEFT JOIN tax_form_detail tfd2 ON tfh.taxformhdrid = tfd2.taxformhdrid AND tfd2.box::text = tfd1.box::text AND tfd2.subbox > tfd1.subbox AND (tfd2.box::text ~~* '12%'::text OR tfd2.box::text ~~* '14%'::text)
  WHERE 1 = 1 AND (tfd1.box::text !~~* '12%'::text OR tfd1.subbox = 1) AND (tfd1.box::text !~~* '14%'::text OR tfd1.subbox = 1) AND tfh.personid <> '000000000000'::bpchar AND COALESCE(btrim(tfh.personid::text), ''::text) <> ''::text
  ORDER BY tfh.personid, tfh.taxformhdrid, tfd1.box, tfd1.subbox;
/*
ALTER TABLE public.cognos_w2_data
  OWNER TO skybotsu;
GRANT ALL ON TABLE public.cognos_w2_data TO skybotsu;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_w2_data TO read_write;
GRANT SELECT ON TABLE public.cognos_w2_data TO read_only;
*/
