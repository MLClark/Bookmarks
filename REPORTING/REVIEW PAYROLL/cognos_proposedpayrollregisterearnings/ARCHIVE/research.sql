select * from person_names where lname like 'Cab%';
select * from payroll.staged_transaction where rate <> 0;
select * from person_names where personid = '1627';

select * from payroll.cognos_proposedpayrollregisterearnings where payscheduleperiodid = '973'
order by payscheduleperiodid, personid, etv_id;

select * from payroll.proposedpayrollregisterearnings where payscheduleperiodid = '973'
order by payscheduleperiodid, personid, etv_id;
select * FROM payroll.payrollregisterdeductions;

select * from payroll.staged_transaction where paycode = 'E01';

select * from payroll.cognos_proposedpayrollregisterearnings where paymentheaderid is null and paymenttypedesc <> 'Normal';

select * from payroll.staged_transaction where personid = '387' and paycode = 'E61';

select * from payroll.personperiodpayments where personid = '1122';

select * from payroll.cognos_proposedpayrollregisterearnings where personid = '1122' and etv_id = 'E61';
select * from payroll.payment_detail where personid = '1122' and paycode = 'E61' and paymentheaderid = 56795;