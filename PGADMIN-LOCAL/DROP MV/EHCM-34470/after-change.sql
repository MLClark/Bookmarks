-- Materialized View: public.cognos_payment_deductions_by_check_date_mv

-- DROP MATERIALIZED VIEW public.cognos_payment_deductions_by_check_date_mv;

CREATE MATERIALIZED VIEW public.cognos_payment_deductions_by_check_date_mv AS 
(
         SELECT ppds.individual_key,
            ppds.check_date,
            ppds.check_number,
            ppds.payment_number::character(5) AS payment_number,
            ppds.etv_code,
            etv.etv_name,
            ppds.etv_id,
            ppds.etv_amount,
            ppds.etv_taxable_wage,
            ppds.etype_hours,
            ppds.etype_rate,
            ppds.ttype_tax_code,
            ppds.group_key AS payunitxid,
            ppds.last_updt_dt,
            ppds.ttypetaxpct,
            ppds.personid,
            ppds.paymentheaderid,
            ppds.arrears_taken,
            ppds.arrears_balance,
            pph.state_dn03_code,
            "left"(ppds.ttype_tax_code::text, 2) AS federalstateid,
            "right"(ppds.ttype_tax_code::text, 4) AS taxjurisdictionid,
            ppds.etv_amount_ytd,
            ppds.etv_amount_q1td,
            ppds.etv_amount_q2td,
            ppds.etv_amount_q3td,
            ppds.etv_amount_q4td
           FROM pspay_payment_detail ppds
             JOIN pspay_payment_header pph ON pph.paymentheaderid = ppds.paymentheaderid AND (pph.payrollfinal = 'Y'::bpchar OR pph.payrollfinal IS NULL)
             LEFT JOIN cognos_pspay_etv_names etv ON ppds.etv_id::text = etv.etv_id::text AND ppds.group_key = etv.group_key
          WHERE date_part('year'::text, ppds.check_date) >= (date_part('year'::text, 'now'::text::date) - 2::double precision) AND "left"(ppds.etv_id::text, 1) = 'V'::text AND (ppds.etv_id::bpchar <> ALL (ARRAY['VAY'::bpchar, 'VAX'::bpchar, 'VAZ'::bpchar]))
        UNION ALL
         SELECT ppds.individual_key,
            ppds.check_date,
            ppds.check_number,
            ppds.payment_number::character(5) AS payment_number,
            ppds.etv_code,
            etv.etv_name,
            ppds.etv_id,
            ppds.etv_amount,
            ppds.etv_taxable_wage,
            ppds.etype_hours,
            ppds.etype_rate,
            ppds.ttype_tax_code,
            ppds.group_key AS payunitxid,
            ppds.last_updt_dt,
            ppds.ttypetaxpct,
            ppds.personid,
            ppds.paymentheaderid,
            ppds.arrears_taken,
            ppds.arrears_balance,
            pph.state_dn03_code,
            "left"(ppds.ttype_tax_code::text, 2) AS federalstateid,
            "right"(ppds.ttype_tax_code::text, 4) AS taxjurisdictionid,
            ppds.etv_amount_ytd,
            ppds.etv_amount_q1td,
            ppds.etv_amount_q2td,
            ppds.etv_amount_q3td,
            ppds.etv_amount_q4td
           FROM pspay_payment_detail_archive ppds
           JOIN pspay_payment_header_archive pph ON pph.paymentheaderid = ppds.paymentheaderid AND (pph.payrollfinal = 'Y'::bpchar OR pph.payrollfinal IS NULL)
           LEFT JOIN cognos_pspay_etv_names etv ON ppds.etv_id::text = etv.etv_id::text AND ppds.group_key = etv.group_key
          WHERE date_part('year'::text, ppds.check_date) >= (date_part('year'::text, 'now'::text::date) - 2::double precision) AND "left"(ppds.etv_id::text, 1) = 'V'::text AND (ppds.etv_id::bpchar <> ALL (ARRAY['VAY'::bpchar, 'VAX'::bpchar, 'VAZ'::bpchar]))
) UNION
 SELECT pi.identity AS individual_key,
    ppds.check_date,
    pph.check_number,
    pph.sequencenumber::character(5) AS payment_number,
        CASE
            WHEN pc.paycodetypeid = ANY (ARRAY[6, 8]) THEN 'ER'::text
            ELSE 'EE'::text
        END AS etv_code,
    pc.paycodeshortdesc AS etv_name,
    pc.paycode AS etv_id,
    ppds.amount AS etv_amount,
    ppds.subject_wages AS etv_taxable_wage,
    ppds.units AS etype_hours,
    ppds.rate AS etype_rate,
    ''::bpchar AS ttype_tax_code,
    dx.companycode::text || pu.payunitxid::text AS payunitxid,
    COALESCE(ppds.updatets, ppds.createts) AS last_updt_dt,
    ''::bpchar AS ttypetaxpct,
    ppds.personid,
    ppds.paymentheaderid,
    NULL::numeric AS arrears_taken,
    NULL::numeric AS arrears_balance,
    ''::bpchar AS state_dn03_code,
    ''::text AS federalstateid,
    ''::text AS taxjurisdictionid,
    ppds.amount_ytd AS etv_amount_ytd,
    ppds.amount_q1td AS etv_amount_q1td,
    ppds.amount_q2td AS etv_amount_q2td,
    ppds.amount_q3td AS etv_amount_q3td,
    ppds.amount_q4td AS etv_amount_q4td
   FROM payroll.payment_detail ppds
     JOIN payroll.payment_header pph ON pph.paymentheaderid = ppds.paymentheaderid
     JOIN person_identity pi ON pi.personid = pph.personid AND pi.identitytype = 'PSPID'::bpchar 
      and current_timestamp between pi.createts and pi.endts  --<<<-- csd-46858
     JOIN pay_unit pu ON pph.payunitid = pu.payunitid
     JOIN dxcompanyname dx ON dx.companyid = pu.companyid
     JOIN payroll.pay_codes pc ON pc.paycode::text = ppds.paycode::text AND pc.uidisplay = 'Y'::bpchar AND pph.check_date >= pc.effectivedate AND pph.check_date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[6])) AND pc.paycode::text ~~ '%-ER'::text
  WHERE date_part('year'::text, ppds.check_date) >= (date_part('year'::text, 'now'::text::date) - 2::double precision)
WITH DATA;

ALTER TABLE public.cognos_payment_deductions_by_check_date_mv
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_check_date_mv TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_payment_deductions_by_check_date_mv TO read_write;
GRANT SELECT ON TABLE public.cognos_payment_deductions_by_check_date_mv TO read_only;
