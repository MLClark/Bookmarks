-- dkc 
select * from person_names where lname like 'Hart%';
select * from cognos_pspaypayrollregistertaxes_mv where personid = '110';

select * from pspay_payment_detail where personid = '110' and check_date = '2020-10-08' and etv_id like 'T%';


select * from tax where taxid = '502256';

select * from tax_lookup_aggregators where ttype_tax_code = '420000';

select * from pspay_payment_detail where personid = '110' and check_date = '2020-10-08' and etv_id = 'T03';
select * from pspay_payment_detail where personid = '110' and check_date = '2020-09-24' and etv_id = 'T03';
select * from pspay_payment_detail where personid = '110' and check_date = '2020-09-10' and etv_id = 'T03';

select * from payroll.payment_detail where personid = '110' and check_date = '2020-10-08' and paycode = 'SIT';
select * from payroll.payment_detail where personid = '110' and check_date = '2020-09-24' and paycode = 'SIT';
select * from payroll.payment_detail where personid = '110' and check_date = '2020-09-10' and paycode = 'SIT';




where pd.personid = '110' and pd.paymentheaderid in ('103966','103851','101675')

Issue missing payments for check_date = '2020-09-10' - paymentheaderid = '101675'

select * from pspay_payment_header where paymentheaderid = '101675';
select * from pay_schedule_period where payscheduleperiodid = '20';
select * from runpayrollgetdates where payscheduleperiodid = '20';
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid = '20'; -- no payscheduleperiodid
select * from pspay_payroll where pspaypayrollid = '20'; -- no pspaypayrollid

first run of payroll was 9/22 - so prior history is lost.