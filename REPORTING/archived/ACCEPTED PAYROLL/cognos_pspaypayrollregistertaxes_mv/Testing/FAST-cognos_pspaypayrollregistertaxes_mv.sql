--- Fast Version
--CREATE MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_mv AS 

SELECT ph.personid,
ph.paymentheaderid,
pp.pspaypayrollid,
pd.etv_id as etv_id,
payc.paycode::text || COALESCE('-'::text || payc.paycodeshortdesc::text, ''::text) as etvname,
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
pte.persontaxelectionpid,
CASE
WHEN pd.etv_code = 'ER'::bpchar THEN true
ELSE false
END AS isemployer
FROM pspay_payment_header ph
JOIN persongetdates pgdate ON pgdate.personid = ph.personid AND pgdate.tablename = 'PERSON_EMPLOYMENT'::text
JOIN pspay_payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND pd.etv_id::text ~~ 'T%'::text AND (pd.etv_id::bpchar <> ALL (ARRAY['TFB'::bpchar, 'TFC'::bpchar])) AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
JOIN runpayrollgetdates rpgd ON rpgd.payscheduleperiodid = psp.payscheduleperiodid
JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
JOIN personpayperiodgetdates pgd ON pgd.payscheduleperiodid = ph.payscheduleperiodid AND ph.personid = pgd.personid
JOIN pay_unit pu ON pu.payunitid = psp.payunitid
LEFT JOIN pspaygroupearningdeductiondets pdd ON ph.group_key = pdd.group_key AND pd.etv_id::text = pdd.etv_id::text AND pdd.etorv = 'T'::text
LEFT JOIN tax_lookup_aggregators tla ON pd.ttype_tax_code = tla.ttype_tax_code AND tla.etvid_lookups @> ARRAY[pd.etv_id]
JOIN tax t ON t.taxid = tla.taxid
JOIN person_tax_elections pte ON pte.taxid = t.taxid AND pte.personid = ph.personid AND GREATEST(pgdate.mineffectivedate, 'now'::text::date) >= pte.effectivedate AND GREATEST(pgdate.mineffectivedate, 'now'::text::date) <= pte.enddate AND now() >= pte.createts AND now() <= pte.endts
LEFT JOIN tax_related_plan trp ON trp.taxidee = t.taxid AND rpgd.asofdate >= trp.effectivedate AND rpgd.asofdate <= trp.enddate AND now() >= trp.createts AND now() <= trp.endts
LEFT JOIN company_tax_setup cts ON (pu.employertaxid::character varying::text = ANY (cts.feinlist::text[])) AND now() >= pu.createts AND now() <= pu.endts AND now() >= cts.createts AND now() <= cts.endts AND rpgd.asofdate >= cts.effectivedate AND rpgd.asofdate <= cts.enddate AND (cts.taxid = tla.taxid OR cts.taxid = trp.taxider)
JOIN payroll.taxmappaycodetoetvid tmap ON tmap.etv_id = pd.etv_id and tmap.ttype_tax_code = pd.ttype_tax_code
join payroll.pay_codes payc ON payc.paycode = tmap.new_paycode and pte.taxid = tmap.taxid
LEFT JOIN company_parameters cp on cp.companyparametername = 'PInt' AND cp.companyparametervalue = 'P20'

where pd.personid = '110' and pd.paymentheaderid in ('103966','103851','101675')

;

select * from pspay_payment_header where paymentheaderid = '101675';
select * from pay_schedule_period where payscheduleperiodid = '20';
select * from runpayrollgetdates where payscheduleperiodid = '20';
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid = '20';
select * from pspay_payroll where pspaypayrollid