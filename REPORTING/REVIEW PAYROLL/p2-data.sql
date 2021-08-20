 SELECT 
    p21.payscheduleperiodid,
    'P2' as qsource,
    p21.personid,
    p21.paymentheaderid,
    p21.pspaypayrollid,
    p21.personearnsetuppid,
    p21.etv_id AS etv_id,
    p21.etvname as etvname,
    sum(p21.amount) AS amount,
    sum(p21.hours) AS hours,
    sum(p21.rate) as rate,
    sum(p21.net_pay) as net_pay,
    sum(p21.gross_pay) gross_pay,
    p22.ytd_hrs AS ytd_hrs,
    p22.ytd_amount AS ytd_amount,
    p22.ytd_wage AS ytd_wage,
    p21.paymenttype,
    p21."coalesce"
    from 
 
 (SELECT p2.payscheduleperiodid,     
    'P2' as qsource,
    p2.personid,
    p2.paymentheaderid,
    p2.pspaypayrollid,
    p2.personearnsetuppid,
    p2.etv_id,
    p2.etvname,
    p2.amount as amount,
    p2.hours as hours,
    p2.rate as rate,
    p2.net_pay,
    p2.gross_pay,
    p2.ytd_hrs,
    p2.ytd_amount,
    p2.ytd_wage,
    p2.paymenttype,
    p2.sequencenumber AS "coalesce",
    rank() over (partition by p2.personid, p2.etv_id, pspaypayrollid order by max(p2.paymentheaderid) desc) as rank
   FROM payroll.payrollregisterearnings p2
  WHERE (p2.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid
                           FROM payroll.staged_transaction))))))
                           and p2.personid = '677' and p2.etv_id = 'E01'--and p2.paymentheaderid in ('17283')
                           group by p2.payscheduleperiodid, qsource, p2.personid, p2.paymentheaderid, p2.pspaypayrollid, p2.personearnsetuppid, p2.etv_id, p2.etvname,p2.amount, p2.hours, p2.rate, p2.net_pay, p2.gross_pay, p2.ytd_hrs, p2.ytd_amount, p2.ytd_wage, p2.paymenttype, p2.sequencenumber
) p21           

left join 

 (SELECT p2.payscheduleperiodid,     
    'P2YTD' as qsource,
    p2.personid,
    p2.paymentheaderid,
    p2.pspaypayrollid,
    p2.personearnsetuppid,
    p2.etv_id,
    p2.etvname,
    0 as amount,
    0 as hours,
    0 as rate,
    0 as net_pay,
    0 as gross_pay,
    p2.ytd_hrs,
    p2.ytd_amount,
    p2.ytd_wage,
    p2.paymenttype,
    p2.sequencenumber AS "coalesce",
    rank() over (partition by p2.personid, p2.etv_id, paymentheaderid order by max(p2.paymentdetailid) desc) as rank
   FROM payroll.payrollregisterearnings p2
  WHERE (p2.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid
                           FROM payroll.staged_transaction))))))
                           and p2.personid = '677' and p2.etv_id = 'E01' --and p2.paymentheaderid in ('17283')
                           group by p2.payscheduleperiodid, qsource, p2.personid, p2.paymentheaderid, p2.pspaypayrollid, p2.personearnsetuppid, p2.etv_id, p2.etvname,p2.amount, p2.hours, p2.rate, p2.net_pay, p2.gross_pay, p2.ytd_hrs, p2.ytd_amount, p2.ytd_wage, p2.paymenttype, p2.sequencenumber, paymentdetailid
) p22 on p22.personid = p21.personid and p22.etv_id = p21.etv_id and p22.rank = 1
group by   1,2,3,4,5,6,7,8,14,15,16,17,18   
;    
    