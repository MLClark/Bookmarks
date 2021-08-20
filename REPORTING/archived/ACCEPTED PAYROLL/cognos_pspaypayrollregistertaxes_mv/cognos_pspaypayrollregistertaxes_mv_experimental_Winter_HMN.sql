/*
CREATE MATERIALIZED VIEW public.cognos_pspaypayroll_persontaxelectionsbyyear_mv AS

select distinct date_part('year',periodpaydate) as tlayear, taxrank.ttype_tax_code, taxrank.etvid_lookups, pte.taxid, pte.personid , taxrank.taxrank
    from runpayrollgetdates rpgd
    join person_tax_elections pte on ((rpgd.periodstartdate,rpgd.periodenddate) overlaps (pte.effectivedate, pte.enddate) or pte.effectivedate = rpgd.periodenddate)
           AND current_timestamp between pte.createts and pte.endts
           AND pte.effectivedate < pte.enddate
    join ( SELECT ta.ttype_tax_code, ta.etvid_lookups, ta.taxid, pte.personid, max(pte.effectivedate) as effectivedate, max(pte.createts) as createts,  rank() over (partition by personid, ta.ttype_tax_code, ta.taxid order by max(effectivedate) desc) as taxrank
                                                FROM tax_lookup_aggregators ta            JOIN person_tax_elections pte ON pte.taxid = ta.taxid WHERE pte.effectivedate < pte.enddate AND now() >= pte.createts AND now() <= pte.endts
                                                   group by ta.ttype_tax_code, ta.etvid_lookups, ta.taxid, pte.personid  ) taxrank  on taxrank.taxrank = 1 and taxrank.personid = pte.personid and taxrank.taxid = pte.taxid AND pte.effectivedate = taxrank.effectivedate



WITH NO DATA
;                                                   

*/

--DROP VIEW IF EXISTS public.cognos_pspaypayrollregistertaxes_winter;
--DROP MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_winter_mv;

--CREATE MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_winter_mv AS 

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
     JOIN pspay_payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND pd.etv_id::text ~~ 'T%'::text AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN runpayrollgetdates rpgd ON rpgd.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN pay_unit pu ON pu.payunitid = psp.payunitid AND now() >= pu.createts AND now() <= pu.endts
     LEFT JOIN pspaygroupearningdeductiondets pdd ON ph.group_key = pdd.group_key AND pd.etv_id::text = pdd.etv_id::text AND pdd.etorv = 'T'::text
     LEFT JOIN cognos_pspaypayroll_persontaxelectionsbyyear_mv pte ON pte.personid = ph.personid AND date_part('year'::text, rpgd.asofdate) = pte.tlayear AND pte.etvid_lookups @> ARRAY[pd.etv_id] AND pd.ttype_tax_code = pte.ttype_tax_code
     LEFT JOIN tax_lookup_aggregators tla ON pd.ttype_tax_code = tla.ttype_tax_code AND tla.etvid_lookups @> ARRAY[pd.etv_id]
     JOIN tax t ON t.taxid = tla.taxid and t.taxid = pte.taxid
     LEFT JOIN company_tax_setup cts ON (pu.employertaxid::character varying::text = ANY (cts.feinlist::text[])) AND now() >= cts.createts AND now() <= cts.endts AND rpgd.asofdate >= cts.effectivedate AND rpgd.asofdate <= cts.enddate AND cts.taxid = tla.taxid
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar AND cp.companyparametervalue::text = 'PSPAY'::text

     where pd.etv_id = 'T02' 
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
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar AND cp.companyparametervalue::text = 'PSPAY'::text   
     
     where pd.etv_id <> 'T02'  
/*
WITH NO DATA;


CREATE OR REPLACE VIEW public.cognos_pspaypayrollregistertaxes AS 
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
   */
