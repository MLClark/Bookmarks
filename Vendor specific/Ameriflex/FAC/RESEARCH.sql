select * from edi.edi_last_update;
select * from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');
19:51:53

2021/03/09 16:17:47.056000000

select * from edi.lookup_schema;
select * from edi.lookup ;

select * from company_parameters where companyparametername = 'PInt';

select * from person_bene_election where benefitsubclass = '1Y' and current_date between effectivedate and enddate and current_timestamp between createts and endts and benefitelection = 'E';
select * from payroll.pay_codes where current_date between effectivedate and enddate and current_timestamp between createts and endts and paycode like ('VEk%');

select * from payroll.pay_code_types  ;

select * from payroll.payment_detail where check_date >= '2021-01-01' and paycode in ( select value1 as paycode from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Payroll_Deduction'));

update edi.edi_last_update set lastupdatets = '2021-04-05 19:51:53'  where feedid = 'Ameriflex_FLEX_Payroll_Deduction'; --2021-04-05 18:51:51
update edi.edi_last_update set lastupdatets = '2021-03-27'  where feedid = 'Ameriflex_FLEX_Payroll_Deduction'; --2021-04-05 18:51:51

select * from pspay_payroll where pspaypayrollstatusid = 4 ;
select * from pspay_payroll_pay_sch_periods where pspaypayrollid = '318';
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid = '301';
select * from payroll.payment_header where payscheduleperiodid = '301';
select * from payroll.payment_detail where paymentheaderid in (select paymentheaderid from payroll.payment_header where payscheduleperiodid = '301');

select * from payroll.pay_codes where current_date between effectivedate and enddate
 and current_timestamp between createts and endts and paycode like ('VBB%');


select * from person_bene_election where personid = '538' and current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'Y' and benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' ) and benefitelection IN ('E'); 
select * from person_names where lname like 'Santana%';
select * from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'Y' and benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' ) and benefitelection IN ('E'); 
