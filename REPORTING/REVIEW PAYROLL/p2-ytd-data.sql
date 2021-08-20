 select 
    p2.payscheduleperiodid,     
    'P2YTD' as qsource,
    p2.personid,
    p2.paymentheaderid,
    p2.pspaypayrollid,
    p2.personearnsetuppid,
    p2.etv_id,
    p2.etvname,
    p2.amount,
    p2.hours,
    p2.rate,
    p2.net_pay,
    p2.gross_pay,
    p2.ytd_hrs as ytd_hrs,
    p2.ytd_amount as ytd_amount,
    p2.ytd_wage as ytd_wage,
    p2.paymenttype,
    "coalesce"
    from 


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
                           and p2.personid = '677' and p2.etv_id = 'E01' and p2.paymentheaderid in ('17283')
                           group by p2.payscheduleperiodid, qsource, p2.personid, p2.paymentheaderid, p2.pspaypayrollid, p2.personearnsetuppid, p2.etv_id, p2.etvname,p2.amount, p2.hours, p2.rate, p2.net_pay, p2.gross_pay, p2.ytd_hrs, p2.ytd_amount, p2.ytd_wage, p2.paymenttype, p2.sequencenumber, paymentdetailid
) p2 where p2.rank = 1
--group by p2.payscheduleperiodid, qsource, p2.personid, p2.paymentheaderid, p2.pspaypayrollid, p2.personearnsetuppid, p2.etv_id, p2.etvname, p2.net_pay, p2.gross_pay, p2.hours, p2.amount, p2.rate, p2.paymenttype, "coalesce"   
;
select * from  payroll.payrollregisterearnings where personid = '677' and etv_id = 'E01' and paymentheaderid = '17283';
