select * from payroll.staged_transaction where personid = '1632' and paycode = 'VB1';
select * from payroll.cognos_proposedpayrollregisterdeductions where personid = '4666' and etv_id = 'V21' and payscheduleperiodid in 
(select * from payroll.staged_transaction where personid = '4666' and paycode = 'V21');

select * from person_names where lname like 'Kling%';

select * from cognos_preview_payment_deductions_by_check_date limit 10; ---- Payroll Preview
select * from company_parameters cp where cp.companyparametername = 'PInt' ;

select * from payroll.cognos_proposedpayrollregisterdeductions where paymentheaderid is null 
select * from payroll.staged_transaction where personid = '73';


select * from batch_detail;