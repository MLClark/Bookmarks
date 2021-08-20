select * from payroll.staged_transaction where personid = '92' and paycode = 'VB5';

select * from payroll.cognos_proposedpayrollregisterdeductions where personid = '92' and etv_id = 'VB5' and payscheduleperiodid = 744;

select * from person_names where personid = '92';
select * from person_names where lname like 'Clay%';

select * from payroll.staged_transaction where personid = '283' and paycode = 'E01';

select * from payroll.cognos_proposedpayrollregisterdeductions where personid = '283' and etv_id = 'E01' and payscheduleperiodid = 744;
