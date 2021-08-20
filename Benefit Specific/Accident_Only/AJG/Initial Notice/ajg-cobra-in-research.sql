select benefitsubclass from comp_plan_benefit_plan where cobraplan = 'Y' group by 1;
select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from edi.edi_last_update;

insert into edi.edi_last_update (feedid,lastupdatets) values ('AJG_Cobra_Initial_Notice','2018-01-31 00:00:00');
update edi.edi_last_update set lastupdatets = '2018-02-01 00:00:00' where feedid = 'AJG_Cobra_Initial_Notice';
update edi.edi_last_update set lastupdatets = '2018-01-31 00:00:00' where feedid = 'AJG_Cobra_Initial_Notice';

select * from dependent_enrollment where benefitsubclass = '10' and dependentid in (select distinct dependentid from person_dependent_relationship where dependentrelationship = 'SP') 
and effectivedate >= '2018-09-01';
select * from person_employment where personid in ('9640','9722');
select * from person_bene_election where personid in ('9640','9722') and benefitsubclass in ('10','11','14','20','60');
select * from person_dependent_relationship where personid = '13194';
select * from person_names where lname like 'Gof%';

select distinct personid from person_bene_election where current_timestamp between createts and endts and effectivedate <= '2018-02-01' 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate
                         and personid in ('9640','9722')
                         
select * from person_names where lname like 'Payne%';                         