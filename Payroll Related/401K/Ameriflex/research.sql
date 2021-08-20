select * from person_bene_election where benefitsubclass in ('60','62','61','63', '6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
and current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'Y'
and benefitelection = 'E';
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2020-12-31 23:00:00' where feedid = 'Ameriflex_FLEX_Demographic_Election';
select * from benefit_plan_desc where benefitsubclass in ('60','62','61','63', '6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' );

select * from person_bene_election where benefitsubclass in ('60','62','61','63', '6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
and current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'Y'
and benefitelection = 'E' and benefitsubclass in 
(select benefitsubclass from benefit_plan_desc where  current_date between effectivedate and enddate and current_timestamp between createts and endts)
;
select distinct personid  from person_bene_election where benefitsubclass in ('60','62','61','63', '6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
and current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'Y'
and benefitelection = 'E' ;

select * from edi.edi_last_update where feedid = 'Ameriflex_FLEX_Payroll_Deduction'; 
update edi.edi_last_update set lastupdatets = '2021-06-01 19:16:40' where feedid = 'Ameriflex_FLEX_Payroll_Deduction'; 
--'2021-06-01 17:57:23'
2021/03/09 19:34:17

select * from person_names where lname like 'Sori%';
select * from cognos_pspay_etv_names_mv  where  etv_id like ('%V%');

select * from pspay_payment_detail where personid = '128' and check_date = '2021-01-28' 
and etv_id in ('VBA','VBB','VL1','VC1','VS1','VC0','VEH','VEK','VGA');

select * from person_bene_election where benefitsubclass in ('60','62','61','63', '6A','6AP','6B','6BP','67','6H','6J','6Y','6Z','1Y' )
and current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'Y'
and benefitelection = 'E' ;

select * from pspay_payment_detail where etv_id in ('VBA','VBB','VL1','VC1','VS1','VC0','VEH','VEK','VGA');