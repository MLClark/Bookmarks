select * from person_names where lname like 'Abramo%';
select * from person_names where personid = '214';


-- cd_payroll_taxes_name taxes
select group_key, etv_id, deduction_name 
from pspay_group_deductions 
join company_parameters on 1 = 1 and companyparametername = 'PInt' and companyparametervalue = 'PSPAY'
where substr(etv_id,1,1) = 'T'
  AND CURRENT_TIMESTAMP BETWEEN createts and endts
union
select dx.companycode || pu.payunitxid as group_key, pc.paycode as etv_id, pc.paycodeshortdesc as deduction_name
from payroll.pay_codes pc
join payroll.pay_code_types pct on pc.paycodetypeid = pct.paycodetypeid
     AND paycodetypedesc in ('Employee Taxes','Employer Tax')
join pay_unit pu on 1 = 1
join dxcompanyname dx on dx.companyid = pu.companyid     
join company_parameters on 1 = 1 and companyparametername = 'PInt' and companyparametervalue = 'P20'
where current_date between pc.effectivedate and pc.enddate 
  and current_timestamp between pc.createts and pc.endts
;
select * from payroll.taxmappaycodetoetvid;

select * from company_parameters where companyparametername = 'PInt';

--CREATE MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_mv AS 
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

;
