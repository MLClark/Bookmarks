
select * from person_names where lname like 'Bern%';
select * from person_employment where personid = '1852';

select * from person_bene_election where personid = '1852' and benefitsubclass in ('10','11','14','15','16','17','60','61')
and current_timestamp between createts and endts and selectedoption = 'Y' and effectivedate < enddate and benefitelection = 'E' 


(select distinct personid, enddate, personbenefitactionpid, min(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('10','11','14','15','16','17','60','61')
   and enddate < '2199-12-30'
   and benefitelection <> 'W'
   and selectedoption = 'Y'
   and personid = '1756'
   and current_timestamp between createts and endts
   and effectivedate < enddate
   group by 1,2,3)


select * from 

select * from system_event;
select * from employment_events;
select * from employment_event_detail where emplstatus in ('T','I');

select * from person_employment where personid = '1756';
select * from person_benefit_action where personid in ( '1756');


select distinct pba.personid, pn.name, pba.eventname, eed.eventname, pe.emplevent, pe.empleventdetcode, max(pba.eventeffectivedate) as effectivedate
  from person_benefit_action pba
  join edi.edi_last_update elu ON elu.feedid =  'AMJ_COBRA_EBC_QB'
  join person_employment pe 
    on pe.personid = pba.personid 
   and current_date between pe.effectivedate AND pe.enddate 
   and current_timestamp between pe.createts AND pe.endts
  join person_names pn
    on pn.personid = pba.personid
   and pn.nametype = 'Legal'
   and current_date between pn.effectivedate and pn.enddate
   and current_timestamp between pn.createts and pn.endts
  join employment_event_detail eed 
    on eed.benefitstatus in ('T','I')
   and eed.emplevent = pe.emplevent
  join person_bene_election pbe 
    on pbe.personid = pba.personid 
   and pbe.selectedoption = 'Y' 
   and pbe.benefitelection <> 'W'
   and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
   and pe.effectivedate - interval '1 day' between pbe.effectivedate and pbe.enddate
   and pbe.effectivedate < pbe.enddate
   and current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
   and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)    
 where pba.eventeffectivedate >= elu.lastupdatets::DATE 
    or (pe.effectivedate >= elu.lastupdatets::DATE 
    or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
   and pe.emplstatus = 'T'
   and pba.eventname not in ('COR','OE','HIR')
   
 group by pba.personid, pn.name, pba.eventname, eed.eventname, pe.emplevent, pe.empleventdetcode
 ;

