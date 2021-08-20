select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2018-08-15 05:00:26' where feedid = 'AOL_COBRASimple_QB_Export';
select * from person_employment where personid = '1913';

select * from comp_plan_benefit_plan where cobraplan = 'Y';

select * from person_employment where emplstatus = 'T' and effectivedate >= '2018-01-01' and personid in 
(select personid from person_bene_election where benefitsubclass in ('10','11','14','60','61') and benefitelection = 'E'
     and current_timestamp between createts and endts);
select * from person_bene_election where benefitsubclass in ('10','11','14','60','61') and personid = '2047';


select * from benefit_plan_desc where benefitsubclass in ('10','11','14','60','61');

select * from person_names where lname like 'Chavez%';
select * from person_employment where personid = '1986';