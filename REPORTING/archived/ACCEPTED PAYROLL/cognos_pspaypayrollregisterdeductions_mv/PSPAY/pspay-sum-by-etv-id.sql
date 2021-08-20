select 
 'PSPAY' as companyparametervalue
,pspay.etv_id
,pspay.etvname
,pspay.isemployer
,sum(pspay.amount) as amount
,sum(pspay.hours) as hours
,sum(pspay.net_pay) as net_pay
,sum(pspay.gross_pay) as gross_pay
,sum(pspay.ytd_amount) as ytd_amount
,sum(pspay.ytd_wage) as ytd_wage



from 
(
 SELECT ph.personid,
    ph.paymentheaderid,
    pp.pspaypayrollid,
    pds.persondedsetuppid,
    pgs.persongarnishmentsetuppid,
    pd.etv_id,
    pd.etv_id::text || COALESCE('-'::text ||
        CASE
            WHEN gt.garntypedesc IS NOT NULL THEN gt.garntypedesc
            ELSE NULL::character varying
        END::text, '-'::text || pdd.etvname::text, ''::text) AS etvname,/**/
    pd.etv_amount AS amount,
    pd.etype_hours AS hours,
    ph.net_pay,
    ph.gross_pay,
    pd.etv_amount_ytd AS ytd_amount,
    pd.etv_taxable_wage_ytd AS ytd_wage,
        CASE
            WHEN pd.etv_code = 'ER'::bpchar THEN 'Y'::bpchar
            ELSE 'N'::bpchar
        END AS isemployer
   FROM pspay_payment_header ph
     JOIN pspay_payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND pd.etv_id::text ~~ 'V%'::text AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric)
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     LEFT JOIN pspaygroupearningdeductiondets pdd ON ph.group_key = pdd.group_key AND pd.etv_id::text = pdd.etv_id::text AND pdd.etorv = 'V'::text
     LEFT JOIN person_deduction_setup pds ON ph.personid = pds.personid AND pds.etvid::text = pd.etv_id::text AND psp.periodpaydate >= pds.effectivedate AND psp.periodpaydate <= pds.enddate AND now() >= pds.createts AND now() <= pds.endts
     LEFT JOIN person_garnishment_setup pgs ON ph.personid = pgs.personid AND pgs.etvid::text = pd.etv_id::text AND psp.periodpaydate >= pgs.effectivedate AND psp.periodpaydate <= pgs.enddate AND now() >= pgs.createts AND now() <= pgs.endts
     LEFT JOIN garnishment_type gt ON pgs.garnishmenttype = gt.garntype
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar and cp.companyparametervalue::text = 'P20'::text
) pspay --where pspay.etv_id = 'V45' 
group by etv_id, etvname, isemployer order by etv_id, etvname, isemployer
