select * from benefit_plan_desc where benefitsubclass in ('10','11','14','60','61') ;
  
  select * from comp_plan_benefit_plan where cobraplan = 'Y';
  
select personid, effectivedate from person_bene_election where benefitsubclass in ('10','11','14','60') and effectivedate >= '2018-09-01'
and current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'Y' and benefitelection = 'E' group by 1,2;

select * from person_bene_election where benefitsubclass in ('10','11','14','60') 
and selectedoption = 'Y' and benefitelection = 'E'
and personid = '805';

select * from person_event_election where personid = 

select * from person_employment where personid = '820';

select * from dependent_enrollment where benefitsubclass in ('10','11','14','60','61')
and current_timestamp between createts and endts and selectedoption = 'Y' ;
select * from edi.edi_last_update;

'2018-09-28 00:00:00'
insert into edi.edi_last_update (feedid,lastupdatets) values ('AXU_Infinisource_Cobra_QE_Export','2018-02-01 00:00:00');
update edi.edi_last_update set lastupdatets = '2018-10-02 00:00:00' where feedid = 'AXU_Infinisource_Cobra_NE_Export';

2018-10-23 07:03:08
select 
 newcovdate.personid
,newcovdate.benefitsubclass
,newcovdate.min_effectivedate
from 

(
select 
 pbe.personid 
,pbe.benefitsubclass
,min(pbe.effectivedate) as min_effectivedate
,max(pbe.effectivedate) as max_effectivedate
from person_bene_election pbe
where pbe.benefitsubclass in ('10','11','14','60')
  and selectedoption = 'Y' and benefitelection = 'E'
  group by 1,2
) newcovdate
left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
where effcovdate.min_effectivedate = effcovdate.max_effectivedate
  and effcovdate.min_effectivedate >= elu.lastupdatets
;
(
select 
 pbe.personid 
,pbe.benefitsubclass
,min(pbe.effectivedate) as min_effectivedate
,max(pbe.effectivedate) as max_effectivedate
from person_bene_election pbe
where pbe.benefitsubclass in ('10','11','14','60')
  and selectedoption = 'Y' and benefitelection = 'T'
  group by 1,2
) termcovdate



select * from person_bene_election where personid = '2299' and benefitsubclass in ('10','11','14','60') and selectedoption = 'Y' and benefitelection = 'E';