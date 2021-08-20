select * from payroll.payment_header where payscheduleperiodid = '100';
select * from payroll.staged_transaction where  payscheduleperiodid = '100' and  personid = '1075';
select * from payroll.staged_transaction where  paycodeaffiliationid = '1117';

select * from payroll.payrollregisterdeductions where personid = '1075';
select distinct personid, payscheduleperiodid, paymentheaderid, etv_id, paycodeaffiliationid from payroll.payrollregisterdeductions where personid = '1075' and paycodeaffiliationid is not null;

( SELECT payrollregisterdeductions.payscheduleperiodid,
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
    0 AS net_pay,
    0 AS gross_pay,
    0 AS ytd_amount,
    0 AS ytd_wage,
        CASE
            WHEN payrollregisterdeductions.isemployer THEN 'T'::text
            ELSE 'F'::text
        END AS isemployer,
    payrollregisterdeductions.paymenttype,
    payrollregisterdeductions.sequencenumber,
    payrollregisterdeductions.paycodeaffiliationid,
    payrollregisterdeductions.enroll_in_catchup
        
   FROM payroll.payrollregisterdeductions
  WHERE payrollregisterdeductions.personid = '1075' and (payrollregisterdeductions.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid
                           FROM payroll.staged_transaction))))))
                           );