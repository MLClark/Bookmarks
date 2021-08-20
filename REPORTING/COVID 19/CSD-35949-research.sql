--select * from company_tax_setup_federal;
select * from covid_credit_detail where paymentheaderid = '10822';
select * from pspay_payment_header where paymentheaderid = '10822';
select * from person_names where personid = '3593';
select * from pspay_payment_detail where personid = '3593' and etv_id in ('EDH', 'EDI', 'EEL');


select personid, paymentheaderid, etv_id, etv_amount, check_date from pspay_payment_detail where etv_id in ('EDH', 'EDI', 'EEL');
select * from covid_credit_detail where etv_id in ('EDH', 'EDI', 'EEL');

select * from pspay_payment_detail where personid = '3317' and etv_id in ('EDH', 'EDI', 'EEL');


select * from covid_credit_detail where paymentheaderid = '2894';