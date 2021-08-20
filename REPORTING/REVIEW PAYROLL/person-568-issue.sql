select * from payroll.payrollregisterdeductions where personid = '568' and payscheduleperiodid = '782' and etv_id = 'VA5';
select * from payroll.payment_detail where personid = '568' and payscheduleperiodid = '782' and paycode = 'VA5';
/* 

issue is the ranking for personid 568 requires paymentdetailid from payroll.payment_detail to generate unique ranking
*/

(
 SELECT payrollregisterdeductions.payscheduleperiodid,
    payrollregisterdeductions.personid,
    payrollregisterdeductions.paymentheaderid,
    payrollregisterdeductions.pspaypayrollid,
    payrollregisterdeductions.persondedsetuppid,
    payrollregisterdeductions.persongarnishmentsetuppid,
    payrollregisterdeductions.etv_id,
    payrollregisterdeductions.etvname,
    0 AS amount,
    0 AS hours,
    0 AS rate,
    payrollregisterdeductions.net_pay,
    payrollregisterdeductions.gross_pay,
    payrollregisterdeductions.ytd_amount,
    payrollregisterdeductions.ytd_wage,
        CASE
            WHEN payrollregisterdeductions.isemployer THEN 'T'::text
            ELSE 'F'::text
        END AS isemployer,
    payrollregisterdeductions.paymenttype,
    payrollregisterdeductions.sequencenumber,
    rank() OVER (PARTITION BY payrollregisterdeductions.personid, payrollregisterdeductions.etv_id, payrollregisterdeductions.paymentheaderid ORDER BY (max(payrollregisterdeductions.sequencenumber)) DESC) AS rank
   FROM payroll.payrollregisterdeductions pr

  WHERE (payrollregisterdeductions.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid
                           FROM payroll.staged_transaction))))))
                           and payrollregisterdeductions.personid = '568' and payrollregisterdeductions.etv_id = 'VA5' and payrollregisterdeductions.payscheduleperiodid = '782'
                           
group by payrollregisterdeductions.payscheduleperiodid,
    payrollregisterdeductions.personid,
    payrollregisterdeductions.paymentheaderid,
    payrollregisterdeductions.pspaypayrollid,
    payrollregisterdeductions.persondedsetuppid,
    payrollregisterdeductions.persongarnishmentsetuppid,
    payrollregisterdeductions.etv_id,
    payrollregisterdeductions.etvname,
    payrollregisterdeductions.amount,
    payrollregisterdeductions.hours,
    payrollregisterdeductions.rate,
    payrollregisterdeductions.net_pay,
    payrollregisterdeductions.gross_pay,
    payrollregisterdeductions.ytd_amount,
    payrollregisterdeductions.ytd_wage,
    payrollregisterdeductions.isemployer,
    payrollregisterdeductions.paymenttype,
    payrollregisterdeductions.sequencenumber   
    )