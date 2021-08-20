select * from benefit_plan_desc where benefitsubclass in ('11','10','14','23');

select * from person_bene_election
where benefitsubclass in ('10','11','14')
 and personid = '440';
 
 select personid,benefitcoverageid,max(effectivedate) as effectivedate
  from person_bene_election 
 where benefitsubclass in ('10','11','14')
   --and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   and benefitelection = 'E' 
   and selectedoption = 'Y'  
   and personid = '440'    
   group by 1,2 ;
   
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2018-06-19 07:01:07' where feedid in ('BDF_IGOE_COBRA_NPM_EXPORT');

2018-06-19 07:01:07

select * from person_employment where personid in
(select distinct personid from person_bene_election 
 where benefitsubclass in ('10','11','14')
   and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   and benefitelection = 'E' 
   and selectedoption = 'Y'  )
and effectivedate >= '2018-04-01';   