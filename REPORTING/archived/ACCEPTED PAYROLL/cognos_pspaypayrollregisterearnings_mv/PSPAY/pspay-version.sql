 --CREATE MATERIALIZED VIEW public.cognos_pspaypayrollregisterearnings_mv AS 
 
 SELECT ph.personid,
    ph.paymentheaderid,
    pp.pspaypayrollid,
    pes.personearnsetuppid,
    pd.etv_id,
    pd.etv_id::text || COALESCE('-'::text || pdd.etvname::text, ''::text) AS etvname,
    pd.etv_amount AS amount,
    pd.etype_hours AS hours,
    pd.etype_rate AS rate,
    ph.net_pay,
    ph.gross_pay,
    pd.etype_hours_ytd AS ytd_hrs,
    pd.etv_amount_ytd AS ytd_amount,
    pd.etv_taxable_wage_ytd AS ytd_wage
   FROM pspay_payment_header ph
     JOIN pspay_payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND pd.etv_code = 'EE'::bpchar AND pd.etv_id::text ~~ 'E%'::text AND (pd.etv_amount_ytd <> 0::numeric OR pd.etype_hours_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etype_hours <> 0::numeric)
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     LEFT JOIN pspaygroupearningdeductiondets pdd ON ph.group_key = pdd.group_key AND pd.etv_id::text = pdd.etv_id::text AND pdd.etorv = 'E'::text
     LEFT JOIN person_earning_setup pes ON ph.personid = pes.personid AND pes.etvid::text = pd.etv_id::text AND psp.periodpaydate >= pes.effectivedate AND psp.periodpaydate <= pes.enddate AND now() >= pes.createts AND now() <= pes.endts
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar and cp.companyparametervalue::text = 'P20'::text
     WHERE PD.ETV_ID = 'E01'  AND PD.PERSONID = '118' AND PD.PAYMENTHEADERID = '4336' ORDER BY PERSONID, PAYMENTHEADERID, PSPAYPAYROLLID