-- Materialized View: public.cognos_pspaypayroll_persontaxelectionsbyyear_mv
/*
[Code: 0, SQL State: 2BP01]  ERROR: cannot drop materialized view cognos_pspaypayroll_persontaxelectionsbyyear_mv because other objects depend on it
  Detail: materialized view cognos_pspaypayrollregistertaxes_winter_mv depends on materialized view cognos_pspaypayroll_persontaxelectionsbyyear_mv
view cognos_pspaypayrollregistertaxes_winter depends on materialized view cognos_pspaypayrollregistertaxes_winter_mv
  Hint: Use DROP ... CASCADE to drop the dependent objects too.
*/  

DROP VIEW cognos_pspaypayrollregistertaxes_winter;
DROP MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_winter_mv;

DROP MATERIALIZED VIEW public.cognos_pspaypayroll_persontaxelectionsbyyear_mv;

CREATE MATERIALIZED VIEW public.cognos_pspaypayroll_persontaxelectionsbyyear_mv AS 
 SELECT DISTINCT date_part('year'::text, rpgd.periodpaydate) AS tlayear,
    taxrank.ttype_tax_code,
    taxrank.etvid_lookups,
    pte.taxid,
    pte.personid,
    taxrank.taxrank
   FROM runpayrollgetdates rpgd
     JOIN person_tax_elections pte ON ("overlaps"(rpgd.periodstartdate::timestamp with time zone, rpgd.periodenddate::timestamp with time zone, pte.effectivedate::timestamp with time zone, pte.enddate::timestamp with time zone) OR pte.effectivedate = rpgd.periodenddate) AND now() >= pte.createts AND now() <= pte.endts AND pte.effectivedate < pte.enddate
     JOIN ( SELECT ta.ttype_tax_code,
            ta.etvid_lookups,
            ta.taxid,
            pte_1.personid,
            max(pte_1.effectivedate) AS effectivedate,
            max(pte_1.createts) AS createts,
            rank() OVER (PARTITION BY pte_1.personid, ta.ttype_tax_code, ta.taxid ORDER BY (max(pte_1.effectivedate)) DESC) AS taxrank
           FROM tax_lookup_aggregators ta
             JOIN person_tax_elections pte_1 ON pte_1.taxid = ta.taxid
          WHERE pte_1.effectivedate < pte_1.enddate AND now() >= pte_1.createts AND now() <= pte_1.endts
          GROUP BY ta.ttype_tax_code, ta.etvid_lookups, ta.taxid, pte_1.personid) taxrank ON taxrank.taxrank = 1 AND taxrank.personid = pte.personid AND taxrank.taxid = pte.taxid AND pte.effectivedate = taxrank.effectivedate
WITH DATA;

ALTER TABLE public.cognos_pspaypayroll_persontaxelectionsbyyear_mv
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_pspaypayroll_persontaxelectionsbyyear_mv TO postgres;
GRANT SELECT ON TABLE public.cognos_pspaypayroll_persontaxelectionsbyyear_mv TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_pspaypayroll_persontaxelectionsbyyear_mv TO read_write;


-- Materialized View: public.cognos_pspaypayrollregistertaxes_winter_mv

-- DROP MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_winter_mv;

--select * from cognos_pspaypayrollregistertaxes_winter_mv;
CREATE MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_winter_mv AS 
 SELECT ph.personid,
    ph.paymentheaderid,
    ph.check_date,
    pp.pspaypayrollid,
    pd.etv_id,
    pd.etv_id::text || COALESCE('-'::text || pdd.etvname::text, ''::text) AS etvname,
    ((t.taxiddesc::text ||
        CASE
            WHEN COALESCE(cts.privateplan, 'N'::bpchar) = 'Y'::bpchar THEN ' - Private Plan'::text
            ELSE ''::text
        END))::character varying(128) AS taxiddesc,
    t.taxid,
    pd.etv_amount AS amount,
    pd.etype_hours AS hours,
    pd.etv_taxable_wage AS wage,
    ph.net_pay,
    ph.gross_pay,
    pd.etype_hours_ytd AS ytd_hrs,
    pd.etv_amount_ytd AS ytd_amount,
    pd.etv_taxable_wage_ytd AS ytd_wage,
        CASE
            WHEN pd.etv_code = 'ER'::bpchar THEN 'Y'::bpchar
            ELSE 'N'::bpchar
        END AS isemployer
   FROM pspay_payment_header ph
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar AND cp.companyparametervalue::text = 'PSPAY'::text
     JOIN pspay_payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND pd.etv_id::text ~~ 'T%'::text AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN runpayrollgetdates rpgd ON rpgd.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN pay_unit pu ON pu.payunitid = psp.payunitid AND now() >= pu.createts AND now() <= pu.endts
     LEFT JOIN pspaygroupearningdeductiondets pdd ON ph.group_key = pdd.group_key AND pd.etv_id::text = pdd.etv_id::text AND pdd.etorv = 'T'::text
     LEFT JOIN cognos_pspaypayroll_persontaxelectionsbyyear_mv pte ON pte.personid = ph.personid AND date_part('year'::text, rpgd.asofdate) = pte.tlayear AND pte.etvid_lookups @> ARRAY[pd.etv_id] AND pd.ttype_tax_code = pte.ttype_tax_code
     LEFT JOIN tax_lookup_aggregators tla ON pd.ttype_tax_code = tla.ttype_tax_code AND tla.etvid_lookups @> ARRAY[pd.etv_id]
     JOIN tax t ON t.taxid = tla.taxid AND t.taxid = pte.taxid
     LEFT JOIN company_tax_setup cts ON (pu.employertaxid::character varying::text = ANY (cts.feinlist::text[])) AND now() >= cts.createts AND now() <= cts.endts AND rpgd.asofdate >= cts.effectivedate AND rpgd.asofdate <= cts.enddate AND cts.taxid = tla.taxid
  WHERE pd.etv_id::text = 'T02'::text
UNION
 SELECT ph.personid,
    ph.paymentheaderid,
    ph.check_date,
    pp.pspaypayrollid,
    pd.etv_id,
    pd.etv_id::text || COALESCE('-'::text || pdd.etvname::text, ''::text) AS etvname,
    ((t.taxiddesc::text ||
        CASE
            WHEN COALESCE(cts.privateplan, 'N'::bpchar) = 'Y'::bpchar THEN ' - Private Plan'::text
            ELSE ''::text
        END))::character varying(128) AS taxiddesc,
    t.taxid,
    pd.etv_amount AS amount,
    pd.etype_hours AS hours,
    pd.etv_taxable_wage AS wage,
    ph.net_pay,
    ph.gross_pay,
    pd.etype_hours_ytd AS ytd_hrs,
    pd.etv_amount_ytd AS ytd_amount,
    pd.etv_taxable_wage_ytd AS ytd_wage,
        CASE
            WHEN pd.etv_code = 'ER'::bpchar THEN 'Y'::bpchar
            ELSE 'N'::bpchar
        END AS isemployer
   FROM pspay_payment_header ph
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar AND cp.companyparametervalue::text = 'PSPAY'::text
     JOIN pspay_payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND pd.etv_id::text ~~ 'T%'::text AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN runpayrollgetdates rpgd ON rpgd.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN pay_unit pu ON pu.payunitid = psp.payunitid AND now() >= pu.createts AND now() <= pu.endts
     LEFT JOIN tax_lookup_aggregators tla ON pd.ttype_tax_code = tla.ttype_tax_code AND tla.etvid_lookups @> ARRAY[pd.etv_id]
     JOIN tax t ON t.taxid = tla.taxid
     LEFT JOIN pspaygroupearningdeductiondets pdd ON ph.group_key = pdd.group_key AND pd.etv_id::text = pdd.etv_id::text AND pdd.etorv = 'T'::text
     LEFT JOIN cognos_pspaypayroll_persontaxelectionsbyyear_mv pte ON pte.personid = ph.personid AND date_part('year'::text, rpgd.asofdate) = pte.tlayear AND pte.etvid_lookups @> ARRAY[pd.etv_id] AND pd.ttype_tax_code = pte.ttype_tax_code
     LEFT JOIN company_tax_setup cts ON (pu.employertaxid::character varying::text = ANY (cts.feinlist::text[])) AND now() >= cts.createts AND now() <= cts.endts AND rpgd.asofdate >= cts.effectivedate AND rpgd.asofdate <= cts.enddate AND cts.taxid = tla.taxid
  WHERE pd.etv_id::text <> 'T02'::text
WITH DATA;

ALTER TABLE public.cognos_pspaypayrollregistertaxes_winter_mv
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_pspaypayrollregistertaxes_winter_mv TO postgres;
GRANT SELECT ON TABLE public.cognos_pspaypayrollregistertaxes_winter_mv TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_pspaypayrollregistertaxes_winter_mv TO read_write;

-- View: public.cognos_pspaypayrollregistertaxes_winter

-- DROP VIEW public.cognos_pspaypayrollregistertaxes_winter;

CREATE OR REPLACE VIEW public.cognos_pspaypayrollregistertaxes_winter AS 
 SELECT cognos_pspaypayrollregistertaxes_winter_mv.personid,
    cognos_pspaypayrollregistertaxes_winter_mv.paymentheaderid,
    cognos_pspaypayrollregistertaxes_winter_mv.pspaypayrollid,
    cognos_pspaypayrollregistertaxes_winter_mv.etv_id,
    cognos_pspaypayrollregistertaxes_winter_mv.etvname,
    cognos_pspaypayrollregistertaxes_winter_mv.taxiddesc,
    cognos_pspaypayrollregistertaxes_winter_mv.taxid,
    cognos_pspaypayrollregistertaxes_winter_mv.amount,
    cognos_pspaypayrollregistertaxes_winter_mv.hours,
    cognos_pspaypayrollregistertaxes_winter_mv.wage,
    cognos_pspaypayrollregistertaxes_winter_mv.net_pay,
    cognos_pspaypayrollregistertaxes_winter_mv.gross_pay,
    cognos_pspaypayrollregistertaxes_winter_mv.ytd_hrs,
    cognos_pspaypayrollregistertaxes_winter_mv.ytd_amount,
    cognos_pspaypayrollregistertaxes_winter_mv.ytd_wage,
    cognos_pspaypayrollregistertaxes_winter_mv.isemployer
   FROM cognos_pspaypayrollregistertaxes_winter_mv;

ALTER TABLE public.cognos_pspaypayrollregistertaxes_winter
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_pspaypayrollregistertaxes_winter TO postgres;
GRANT SELECT ON TABLE public.cognos_pspaypayrollregistertaxes_winter TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_pspaypayrollregistertaxes_winter TO read_write;

