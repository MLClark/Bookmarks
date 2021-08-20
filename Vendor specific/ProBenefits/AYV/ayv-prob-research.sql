--select * from person_names where lname like 'Davis%';
select * from person_bene_election where personid = '5976' and benefitsubclass in ('6Z','60','61','11','10')  and benefitelection <> 'W';
--select * from person_names where lname like 'Anderson%';
select * from person_bene_election where personid = '7316' and benefitsubclass in ('6Z','60','61','11','10') ;
--select * from person_names where lname like 'Johnson%';
select * from person_bene_election where personid = '6095' and benefitsubclass in ('6Z','60','61','11','10') ;

select * from person_bene_election where personid = '8111' and benefitsubclass in ('6Z','60','61','11','10') ;

select * from edi.edi_last_update ;
update edi.edi_last_update set lastupdatets = '2019-01-01 00:00:00' where feedid = 'AYV_ProBenefits_FSA_DCA'; 
select * from benefit_plan_desc where benefitsubclass in ('6Z','60','61','11','10') ;