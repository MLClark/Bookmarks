select 
 'P20' as companyparametervalue
,p20.etv_id
,p20.etvname
,p20.isemployer
,sum(p20.amount) as amount
,sum(p20.hours) as hours
,sum(p20.net_pay) as net_pay
,sum(p20.gross_pay) as gross_pay
,sum(p20.ytd_amount) as ytd_amount
,sum(p20.ytd_wage) as ytd_wage



from 
(
 SELECT ph.personid,
    ph.paymentheaderid,
    pp.pspaypayrollid,
    pds.persondedsetuppid,
    pgs.persongarnishmentsetuppid,
    pd.paycode AS etv_id,
    pd.paycode::text || COALESCE('-'::text ||
        CASE
            WHEN gt.garntypedesc IS NOT NULL THEN gt.garntypedesc
            ELSE NULL::character varying
        END::text, '-'::text || pc.paycodeshortdesc::text, ''::text) AS etvname,
    pd.amount,
    pd.units AS hours,
    ph.net_pay,
    ph.gross_pay,
    pd.amount_ytd AS ytd_amount,
    pd.subject_wages_ytd AS ytd_wage,
        CASE
            WHEN pc.paycodetypeid = 6 THEN 'Y'::bpchar
            ELSE 'N'::bpchar
        END AS isemployer
   FROM payroll.payment_header ph
     JOIN payroll.payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND (pd.amount_ytd <> 0::numeric OR pd.units_ytd <> 0::numeric OR pd.amount <> 0::numeric OR pd.units <> 0::numeric)
     JOIN company_parameters ON company_parameters.companyparametername = 'PInt'::bpchar AND company_parameters.companyparametervalue::text = 'P20'::text
     JOIN payroll.pay_codes pc ON pc.paycode::text = pd.paycode::text AND ph.check_date >= pc.effectivedate AND ph.check_date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND pc.paycodetypeid in (3,6) --AND pc.uidisplay = 'Y'::bpchar 
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     LEFT JOIN person_deduction_setup pds ON ph.personid = pds.personid AND pds.etvid::text = pd.paycode::text AND psp.periodpaydate >= pds.effectivedate AND psp.periodpaydate <= pds.enddate AND now() >= pds.createts AND now() <= pds.endts
     
     ---- why are we using garnishment for deductions? Are these garnishment tables valid for P20?
     LEFT JOIN person_garnishment_setup pgs ON ph.personid = pgs.personid AND pgs.etvid::text = pd.paycode::text AND psp.periodpaydate >= pgs.effectivedate AND psp.periodpaydate <= pgs.enddate AND now() >= pgs.createts AND now() <= pgs.endts
     LEFT JOIN garnishment_type gt ON pgs.garnishmenttype = gt.garntype
) p20 --where p20.etv_id = 'V43' 
group by etv_id, etvname, isemployer order by etv_id, etvname, isemployer

