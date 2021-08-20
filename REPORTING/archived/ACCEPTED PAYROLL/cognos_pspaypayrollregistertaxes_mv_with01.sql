--CREATE MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_mv AS 
WITH pte AS
 (select distinct date_part('year',periodpaydate) as tlayear, taxrank.ttype_tax_code, taxrank.etvid_lookups, pte.taxid, pte.personid , taxrank.taxrank
       from runpayrollgetdates rpgd
       join person_tax_elections pte on ((rpgd.periodstartdate,rpgd.periodenddate) overlaps (pte.effectivedate, pte.enddate) or pte.effectivedate = rpgd.periodenddate)
           AND current_timestamp between pte.createts and pte.endts
           AND pte.effectivedate < pte.enddate
       join ( SELECT ta.ttype_tax_code, ta.etvid_lookups, ta.taxid, pte.personid
		, max(pte.effectivedate) as effectivedate, max(pte.createts) as createts
		,  rank() over (partition by personid, ta.ttype_tax_code order by max(effectivedate) desc) as taxrank
			FROM tax_lookup_aggregators ta
			JOIN person_tax_elections pte ON pte.taxid = ta.taxid
			WHERE pte.effectivedate < pte.enddate AND now() >= pte.createts AND now() <= pte.endts
			group by   ta.ttype_tax_code, ta.etvid_lookups, ta.taxid, pte.personid  ) taxrank  on taxrank.taxrank = 1 
				and taxrank.personid = pte.personid and taxrank.taxid = pte.taxid
				AND pte.effectivedate = taxrank.effectivedate
      where date_part('year',rpgd.asofdate) > date_part('year',current_date - interval '3 years')				
       
)
SELECT ph.personid,
 ph.paymentheaderid,
 pp.pspaypayrollid,
  cp.companyparametervalue,
 CASE WHEN cp.companyparametervalue = 'PSPAY' then pd.etv_id
 WHEN cp.companyparametervalue = 'P20' then payc.paycode END as etv_id,

 CASE WHEN cp.companyparametervalue = 'PSPAY' then pd.etv_id::text || COALESCE('-'::text || pdd.etvname::text, ''::text)
 WHEN cp.companyparametervalue = 'P20' then payc.paycode::text || COALESCE('-'::text || payc.paycodeshortdesc::text, ''::text) END as etvname,
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
 JOIN persongetdates pgdate ON pgdate.personid = ph.personid AND pgdate.tablename = 'PERSON_EMPLOYMENT'::text
 JOIN pspay_payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND pd.etv_id::text ~~ 'T%'::text 
    -- AND (pd.etv_id::bpchar <> ALL (ARRAY['TFB'::bpchar, 'TFC'::bpchar])) 
    AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
 JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
 JOIN runpayrollgetdates rpgd ON rpgd.payscheduleperiodid = psp.payscheduleperiodid
 JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
 JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
 JOIN personpayperiodgetdates pgd ON pgd.payscheduleperiodid = ph.payscheduleperiodid AND ph.personid = pgd.personid
 JOIN pay_unit pu ON pu.payunitid = psp.payunitid
 LEFT JOIN pspaygroupearningdeductiondets pdd ON ph.group_key = pdd.group_key AND pd.etv_id::text = pdd.etv_id::text AND pdd.etorv = 'T'::text
 JOIN pte ON pte.personid = ph.personid 
       AND date_part('year',rpgd.asofdate) = pte.tlayear
       AND pte.etvid_lookups @> ARRAY[pd.etv_id]
       AND pd.ttype_tax_code = pte.ttype_tax_code
 JOIN tax t ON t.taxid = pte.taxid
 LEFT JOIN tax_related_plan trp ON trp.taxidee = t.taxid AND rpgd.asofdate >= trp.effectivedate AND rpgd.asofdate <= trp.enddate AND now() >= trp.createts AND now() <= trp.endts
 LEFT JOIN company_tax_setup cts ON (pu.employertaxid::character varying::text = ANY (cts.feinlist::text[])) AND now() >= pu.createts AND now() <= pu.endts AND now() >= cts.createts AND now() <= cts.endts AND rpgd.asofdate >= cts.effectivedate AND rpgd.asofdate <= cts.enddate
  AND (cts.taxid = pte.taxid OR cts.taxid = trp.taxider)
 
 
 --JOIN payroll.taxmappaycodetoetvid tmap ON tmap.etv_id = pd.etv_id and tmap.ttype_tax_code = pd.ttype_tax_code
 --join payroll.pay_codes payc ON payc.paycode = tmap.new_paycode and pte.taxid = tmap.taxid
 
 join (
 select distinct
 pd.etv_id
,pd.personid
,pd.paymentheaderid
,pdd.etvname
,tmap.taxid
,tmap.ttype_tax_code
,tmap.new_paycode
,payc.paycode
,payc.paycodeshortdesc
from pspay_payment_header ph 
JOIN pspay_payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND pd.etv_id::text ~~ 'T%'::text 
 AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
LEFT JOIN pspaygroupearningdeductiondets pdd ON ph.group_key = pdd.group_key AND pd.etv_id::text = pdd.etv_id::text AND pdd.etorv = 'T'::text
join payroll.taxmappaycodetoetvid tmap ON tmap.etv_id = pd.etv_id and tmap.ttype_tax_code = pd.ttype_tax_code   
join payroll.pay_codes payc on payc.etvid_source = pd.etv_id 

      ) payc on payc.etv_id = pd.etv_id and payc.taxid = pte.taxid and payc.ttype_tax_code = pte.ttype_tax_code and payc.personid = pd.personid


 LEFT JOIN company_parameters cp on 1 = 1 and cp.companyparametername = 'PInt' 
