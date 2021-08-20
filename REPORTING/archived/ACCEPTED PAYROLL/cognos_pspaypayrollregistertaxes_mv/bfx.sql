-- Materialized View: public.cognos_pspaypayrollregistertaxes_mv

-- DROP MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_mv;

--CREATE MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_mv AS 
 WITH pte AS (
         SELECT DISTINCT date_part('year'::text, rpgd_1.periodpaydate) AS tlayear,taxrank.ttype_tax_code,taxrank.etvid_lookups,pte_1.taxid,pte_1.personid,taxrank.taxrank
           FROM runpayrollgetdates rpgd_1
             JOIN person_tax_elections pte_1 ON ("overlaps"(rpgd_1.periodstartdate::timestamp with time zone, rpgd_1.periodenddate::timestamp with time zone, pte_1.effectivedate::timestamp with time zone, pte_1.enddate::timestamp with time zone) 
               OR pte_1.effectivedate = rpgd_1.periodenddate) AND now() >= pte_1.createts AND now() <= pte_1.endts AND pte_1.effectivedate < pte_1.enddate
             JOIN ( SELECT ta.ttype_tax_code,ta.etvid_lookups,ta.taxid,pte_2.personid,max(pte_2.effectivedate) AS effectivedate,max(pte_2.createts) AS createts,
                    rank() OVER (PARTITION BY pte_2.personid, ta.ttype_tax_code ORDER BY (max(pte_2.effectivedate)) DESC) AS taxrank
                     FROM tax_lookup_aggregators ta
                     JOIN person_tax_elections pte_2 ON pte_2.taxid = ta.taxid
                    WHERE pte_2.effectivedate < pte_2.enddate AND now() >= pte_2.createts AND now() <= pte_2.endts
                    GROUP BY ta.ttype_tax_code, ta.etvid_lookups, ta.taxid, pte_2.personid) taxrank ON taxrank.taxrank = 1 AND taxrank.personid = pte_1.personid AND taxrank.taxid = pte_1.taxid AND pte_1.effectivedate = taxrank.effectivedate
          WHERE date_part('year'::text, rpgd_1.asofdate) > date_part('year'::text, 'now'::text::date - '3 years'::interval)
        )
 SELECT ph.personid,
    ph.paymentheaderid,
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
     JOIN pspay_payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND pd.etv_id::text ~~ 'T%'::text AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN runpayrollgetdates rpgd ON rpgd.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN pay_unit pu ON pu.payunitid = psp.payunitid AND now() >= pu.createts AND now() <= pu.endts
     LEFT JOIN pspaygroupearningdeductiondets pdd ON ph.group_key = pdd.group_key AND pd.etv_id::text = pdd.etv_id::text AND pdd.etorv = 'T'::text  
     JOIN pte ON pte.personid = ph.personid AND date_part('year'::text, rpgd.asofdate) = pte.tlayear AND pte.etvid_lookups @> ARRAY[pd.etv_id] AND pd.ttype_tax_code = pte.ttype_tax_code
     --LEFT JOIN person_tax_elections pte ON pte.personid = pd.personid AND 'now'::text::date >= pte.effectivedate AND 'now'::text::date <= pte.enddate AND now() >= pte.createts AND now() <= pte.endts AND pte.taxid = tla.taxid AND pte.effectivedate = tla.effectivedate
     JOIN tax t ON t.taxid = pte.taxid
     LEFT JOIN tax_related_plan trp ON trp.taxidee = t.taxid AND rpgd.asofdate >= trp.effectivedate AND rpgd.asofdate <= trp.enddate AND now() >= trp.createts AND now() <= trp.endts
     LEFT JOIN company_tax_setup cts ON (pu.employertaxid::character varying::text = ANY (cts.feinlist::text[])) AND now() >= pu.createts AND now() <= pu.endts AND now() >= cts.createts AND now() <= cts.endts AND rpgd.asofdate >= cts.effectivedate AND rpgd.asofdate <= cts.enddate AND (cts.taxid = pte.taxid OR cts.taxid = trp.taxider)
     LEFT JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar and  cp.companyparametervalue = 'PSPAY'
     where pd.etv_id = 'T02'
     and ph.paymentheaderid in 
     (select paymentheaderid from pspay_payment_header where payscheduleperiodid in (select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));
     

/*
WITH DATA;

ALTER TABLE public.cognos_pspaypayrollregistertaxes_mv
  OWNER TO skybotsu;
GRANT ALL ON TABLE public.cognos_pspaypayrollregistertaxes_mv TO skybotsu;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_pspaypayrollregistertaxes_mv TO read_write;
GRANT SELECT ON TABLE public.cognos_pspaypayrollregistertaxes_mv TO read_only;
*/