select sum(amount) from payroll.staged_transaction where asofdate = '2021-03-04' and paycode = 'VBC-ER';
select sum(amount) from payroll.cognos_proposedpayrollregisterdeductions where etv_id = 'VBC-ER' and payscheduleperiodid in  
(select payscheduleperiodid from payroll.staged_transaction where paycode = 'VBC-ER' and asofdate = '2021-03-04'); 


select * from payroll.staged_transaction where asofdate = '2021-03-04' and paycode = 'VBC-ER';
select * from payroll.cognos_proposedpayrollregisterdeductions where etv_id = 'VBC-ER' and payscheduleperiodid in  
(select payscheduleperiodid from payroll.staged_transaction where paycode = 'VBC-ER' and asofdate = '2021-03-04'); 




select * from payroll.cognos_proposedpayrollregisterearnings where etv_id  = 'EEL' and payscheduleperiodid in  
(select payscheduleperiodid from payroll.staged_transaction where paycode like 'EEL%' and asofdate = '2021-03-04')
and personid in (select personid from person_names where lname like 'Abernathy%')
;
select * from payroll.cognos_proposedpayrollregistertaxes where payscheduleperiodid in  
(select payscheduleperiodid from payroll.staged_transaction where paycode like 'EEL%' and asofdate = '2021-03-04')
and personid in (select personid from person_names where lname like 'Abernathy%')
select * from person_names where personid = '3530';
select * from payroll.cognos_proposedpayrollregistertaxes where personid = '3530';

select * from payroll.staged_transaction;
select * from person_names where lname like 'Abram%';