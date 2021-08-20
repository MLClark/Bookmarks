
select * from company_parameters where companyparametername = 'PInt';
select distinct paycode from payroll.payment_detail where subject_wages_ytd <> 0;
select * from pspay_payment_detail where personid = '53' and paymentheaderid = 28230;
select * from payroll.payment_detail where personid = '53' and paymentheaderid = '28230';
select sum(etv_amount) from pspay_payment_detail where etv_id = 'TAZ';

select * from payroll.payment_detail where paycode like 'ER_SUTA%' and personid = '105';
select * from pspay_payment_detail where etv_id = 'TAZ' and personid = '105';
select * from person_names where personid = '105';


