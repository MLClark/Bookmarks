select
 'P20' as companyparametervalue
,p20.paycode
,sum(p20.amount) as amount
,sum(p20.hours) as hours
,sum(p20.rate) as rate
,sum(p20.net_pay) as net_pay
,sum(p20.gross_pay) as gross_pay
,sum(p20.ytd_hrs) as ytd_hrs
,sum(p20.ytd_amount) as ytd_amount
,sum(p20.ytd_wage) as ytd_wage

from 

(
 SELECT ph.personid,
    ph.paymentheaderid,
    pp.pspaypayrollid,
    pes.personearnsetuppid,
    pd.paycode,
    pd.paycode::text || COALESCE('-'::text || pdd.etvname::text, ''::text) AS etvname,
    pd.amount AS amount,
    pd.units AS hours,
    pd.rate AS rate,
    ph.net_pay,
    ph.gross_pay,
    pd.units_ytd AS ytd_hrs,
    pd.amount_ytd AS ytd_amount,
    pd.subject_wages_ytd AS ytd_wage
   FROM PAYROLL.payment_header ph
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
    

     JOIN PAYROLL.payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND (pd.amount_ytd <> 0::numeric OR pd.units_ytd <> 0::numeric OR pd.amount <> 0::numeric OR pd.units <> 0::numeric) --AND pd.etv_code = 'EE'::bpchar not sure how to apply this 
      AND ((pd.paycode in (select distinct etvid as paycode from  person_earning_setup where current_date between effectivedate and enddate and current_timestamp between createts and endts))
       or  (pd.paycode in (select distinct paycode from payroll.pay_codes where paycodetypeid in (1,2) and current_date between effectivedate and enddate and current_timestamp between createts and endts)))
      
     JOIN pay_unit pu ON pu.payunitid = ph.payunitid AND current_timestamp between pu.createts and pu.endts  ----- added current_timestamp 
     
     LEFT JOIN pspaygroupearningdeductiondets pdd ON pu.payunitdesc = pdd.group_key AND pd.paycode::text = pdd.etv_id::text AND pdd.etorv = 'E'::text
     LEFT JOIN person_earning_setup pes ON ph.personid = pes.personid AND pes.etvid::text = pd.paycode::text AND psp.periodpaydate >= pes.effectivedate AND psp.periodpaydate <= pes.enddate AND now() >= pes.createts AND now() <= pes.endts
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar and cp.companyparametervalue::text = 'P20'::text
     ) p20 
     group by paycode, companyparametervalue order by paycode