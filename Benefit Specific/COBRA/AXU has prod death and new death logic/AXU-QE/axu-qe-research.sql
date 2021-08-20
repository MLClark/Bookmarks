
select * from person_benefit_action where personid = '918' and eventname IN ('TER','DIV','DepAge','OAC')
join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in  ('TER','DIV','DepAge','OAC')

select * from person_bene_election where personid = '2176' and benefitsubclass in ('10','11','14','60');
select * from person_benefit_action where personid = '2176' and eventname in ('TER');
select * from person_bene_election where personid = '2176' and personbenefitactionpid = '1071' and benefitsubclass in ('10','11','14','60');
select * from dependent_enrollment where personid = '918';
select * from benefit_plan_desc where benefitsubclass in ('10');

select * from person_bene_election where personid = '915' and benefitsubclass in ('10');

select * from personbenoptioncostl where personid = '915' and costsby = 'M' and benefitoptionid = '12544' 
update edi.edi_last_update set lastupdatets = '2019-03-12 07:00:04' where feedid = 'AXU_Infinisource_Cobra_QE_Export'; --2019-03-12 07:00:04

(select personid,personbeneelectionpid,benefitoptionid,max(createts) as createts, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
             from person_bene_election where current_timestamp between createts and endts and benefitsubclass in ('60') 
              and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate and personid = '915'
            group by 1,2,3)
            

 select 
  pe.personid
 ,pe.effectivedate
 ,pe.emplstatus
 ,pbe.benefitelection
 ,pbe.benefitsubclass
 ,pbe.selectedoption
 ,pbe.effectivedate
 ,pbe.enddate
 ,cppy.planyearstart
 ,cppy.planyearend
 
   from person_employment pe 
   join comp_plan_plan_year cppy 
     on cppy.compplanplanyeartype = 'Bene'
   join person_bene_election pbe
     on pbe.personid = pe.personid
    and current_date between pbe.effectivedate and pbe.enddate
    and current_date <= pbe.planyearenddate
    --and ((pbe.effectivedate, pbe.enddate) overlaps (cppy.planyearstart, cppy.planyearend) OR cppy.planyearstart IS NULL) 
   
 where pe.personid = '836' and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y' and pe.emplstatus = 'T';


(select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid,max(pbe.effectivedate) as pbe_effectivedate, max(pbe.enddate) as pbe_enddate,RANK() OVER (PARTITION BY pbe.personid ORDER BY MAX(pbe.effectivedate) DESC) AS RANK
  from person_bene_election pbe join person_employment pe on pe.personid = pbe.personid and pe.benefitstatus = 'A' 
 where pbe.benefitsubclass = '10' and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.personid = '2176'  
   and pe.enddate            
 group by 1, 2, 3, 4, 5, 6);
            
select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.effectivedate, pbe.enddate
  from person_bene_election pbe where pbe.benefitsubclass = '10' and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.personid = '2176'
           
            
select * from person_employment where personid = '2176';            

select personid, benefitelection, selectedoption, effectivedate, enddate, eventdate from person_bene_election where benefitsubclass = '10' and benefitelection = 'W' and personid = '2176';
select personid, benefitelection, selectedoption, effectivedate, enddate, eventdate from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and personid = '2176';
select personid, benefitelection, selectedoption, effectivedate, enddate, eventdate from person_bene_election where benefitsubclass = '10' and benefitelection = 'T' and personid = '2176';

--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1         
--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     
--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                       
--- medical fsa
left join   (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1  





select * from person_names where lname like 'Hump%';
select * from person_names where personid = '2242';
select * from person_dependent_relationship where dependentid = '2242';
select * from person_maritalstatus where personid = '873';

select * from person_benefit_action where personid = '787';
select * from person_employment where personid = '787';
select * from pers_pos where personid = '787';
select * from dependent_enrollment where personid = '804';
select * from person_bene_election where personid = '787' and benefitsubclass in ('10','11','14','60') and selectedoption = 'Y' and benefitelection = 'E';

select * from person_benefit_action where personid = '787';



select * from person_benefit_action where personid = '795';
update person_benefit_action set eventname = 'FTP' where personid = '795';
select * from person_employment where personid = '787';
select * from person_employment where personid = '795';
select * from pers_pos where personid = '795';


select * from person_names where personid = '918';
select * from dependent_enrollment where personid = '918';
select * from person_bene_election where personid = '795' and benefitsubclass in ('10','11','14','60') and selectedoption = 'Y' and benefitelection = 'E';

select * from person_benefit_action where personid = '795';


select distinct
 pe.personid
 
from person_employment pe
join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
 and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
 
join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

join dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 and de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date >= de.effectivedate 
 and current_timestamp between de.createts and de.endts 
   

where pe.empleventdetcode = 'Death'

select * from person_names where lname like 'Hump%';

SELECT * from person_benefit_action where personid = '2176';



select * from edi.edi_last_update;
insert into edi.edi_last_update (feedid,lastupdatets) values ('AXU_Infinisource_Cobra_NE_Export','2018-01-01 00:00:00');
insert into edi.edi_last_update (feedid,lastupdatets) values ('AXU_Infinisource_Cobra_QE_Export','2018-01-01 00:00:00');

update edi.edi_last_update set lastupdatets = '2018-09-01 00:00:00' where feedid = 'AXU_Infinisource_Cobra_QE_Export'

select * from personbenoptioncostl where personid = '1005' and personbeneelectionpid = '19612';
select * from person_bene_election where personid = '1005' and benefitsubclass in ('60');
select * from person_bene_election where personid = '2177' and benefitsubclass in ('14');
select * from person_bene_election where personid = '2177' and benefitsubclass in ('11');
select * from person_bene_election where personid = '2177' and benefitsubclass in ('10');

 (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' 
              and effectivedate < enddate
              and current_timestamp between createts and endts and personid = '2177'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid)
            ;
(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts and personid = '2177'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid)
            ;            
            
select * from person_employment where personid = '775';
select * from person_benefit_action where personid = '2177';            

 (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '61' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts and personid = '2177'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid)
            
            ;            

select * from benefit_plan_desc where benefitsubclass in ('10','11','14','60','61') ;
select * from benefit_coverage_desc;
select * from person_bene_election where benefitsubclass in ('10','11','14','60','61') and personid = '876';
select * from person_employment where emplstatus = 'T' and effectivedate >= '2018-09-01';
SELECT * FROM person_names where personid = '876';

(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts and personid = '1017'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid)


(select distinct personid from person_bene_election where current_timestamp between createts and endts and personid = '906'
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)             