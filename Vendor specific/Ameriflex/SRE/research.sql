select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2021-04-10 00:00:00' where feedid = 'Ameriflex_FLEX_Payroll_Deduction';

select * from person_bene_election where personid = '1262' and current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'Y' and benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' ) and benefitelection IN ('E'); 
select * from person_names where lname like 'Pakled%';
select * from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'Y' and benefitsubclass in ('60','62','61','63','6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' ) and benefitelection IN ('E'); 
select * from benefit_plan_desc;