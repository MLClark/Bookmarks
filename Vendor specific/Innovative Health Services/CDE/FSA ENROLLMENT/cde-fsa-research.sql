select * from person_bene_election where benefitsubclass in ('60','61') and selectedoption = 'Y' --and benefitelection = 'E' 
and effectivedate < enddate 
and current_timestamp between createts and endts
and personid = '216';

select * from person_bene_election where benefitsubclass = '61' and selectedoption = 'Y' and benefitelection = 'E' 
and current_date between effectivedate and enddate and current_timestamp between effectivedate and enddate 


select * from person_employment where personid = '199';
select * from person_names where personid = '339';
select * from person_names where lname like 'CAL%';
select * from person_bene_election where benefitsubclass in ('60','61') and selectedoption = 'Y' and benefitelection = 'E' and personid in ('1443');
select emplevent from person_employment group by 1;
select * from person_employment where emplevent = 'Hire';
select * from person_benefit_action where eventname = 'HIR';
select * from person_benefit_action where personid in (select personid from person_employment where emplevent = 'Hire' and effectivedate >= '2018-01-01') and benefitsubclass in ('60','61');
select * from person_employment where personid = '199';
INSERT into edi.edi_last_update (feedid,lastupdatets) values ('CDE_Innovative_Health_Services_FSADC_Enroll_Export','2018-05-01 00:00:00');

select * from edi.edi_last_update;
select * from person_bene_election where benefitsubclass in ('60','61') and selectedoption = 'Y' and benefitelection = 'E' and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from person_employment where personid = '123';

select * from person_bene_election where personid = '199' and benefitsubclass in ('60','61');
select * from personbenoptioncostl where personid = '199' and costsby = 'A' and personbeneelectionpid = '49160';

select * from person_bene_election where benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y' ;

(select pbe.personid,pbe.benefitsubclass, min(pbe.createts) as createts, min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
                from person_bene_election pbe 
                left join edi.edi_last_update elu on elu.feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'
               where pbe.benefitsubclass in ('60','61')
                 and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' 
                 and pbe.effectivedate >= elu.lastupdatets
               group by 1,2)
               
               
               
               update edi.edi_last_update set lastupdatets = '2019-04-07 07:01:37' where feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'; -----2019-04-23 06:02:52