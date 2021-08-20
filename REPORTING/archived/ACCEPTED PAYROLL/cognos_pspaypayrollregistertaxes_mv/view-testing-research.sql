select sum(etv_amount) from pspay_payment_detail where etv_id = 'T02' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where processfinaldate is not null ));


select sum(amount) from cognos_pspaypayrollregistertaxes_winter_mv  where etv_id = 'T02' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where processfinaldate is not null ));


select * from payroll.payment_detail  where  personid = '4510' and paycode = 'V45' AND paymentheaderid = '15050';

select * from pspay_payment_detail  where  personid = '4510' and etv_id = 'V45' AND paymentheaderid = '15050';


select * from payroll.payment_header where personid = '4510' and paymentheaderid = '15050';
select * from pspay_payment_header where personid = '4510' and paymentheaderid = '15050';

select * from payroll.pay_codes where paycode in ('VA3');
select * from payroll.pay_code_types;
SELECT * FROM PERSON_DEDUCTION_SETUP WHERE PERSONID = '120' ;


select * from person_names where personid = '177';

select * from person_earning_setup where personid in ('75');


select * from company_parameters where companyparametername = 'PInt';

select * from payroll.pay_codes where paycode in ('VA3');
select * from person_garnishment_setup where etvid in ('VA3');
select * from pspaygroupearningdeductiondets where etv_id = 'VA3' and etorv = 'V' and group_key <> '$$$$$' order by etv_id ;
select * from garnishment_type;

select 296/2

select * from payroll.payment_detail  where  personid = '4510' and paycode = 'V45' AND paymentheaderid = '15050';
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