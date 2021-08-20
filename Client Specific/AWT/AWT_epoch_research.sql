select * from person_bene_election 
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and effectivedate >= '2018-01-01'
  and benefitsubclass = '21'
  and selectedoption = 'Y'
  and benefitelection = 'E';
  
select * from person_bene_election 
where personid = '7837'
  and benefitsubclass = '21';

select * from dxcompanyname
select * from person_dependent_relationship where personid = '7837';  
select * from person_names where personid in ('7837','8689');
select * from person_vitals where personid in ('7837','8689');

select * from dependent_enrollment 
where personid = '7199'
and benefitsubclass = '13';


select * from dependent_enrollment 
where personid in (select distinct personid from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts
and selectedoption = 'Y' and benefitelection = 'E' and  benefitsubclass = '13')
and benefitsubclass = '13';


(select distinct pbe.personid, pn.name, benefitcoverageid
   from person_bene_election pbe
   join person_names pn on pn.personid = pbe.personid 
   and pn.nametype = 'Legal' 
   and current_date between pn.effectivedate and pn.enddate
   and current_timestamp between pn.createts and pn.endts
    where current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts
    and selectedoption = 'Y' and benefitelection = 'E' and  benefitsubclass = '13' and benefitcoverageid <> '1')
    

select * from person_dependent_relationship
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and dependentid in 
  (select dependentid from dependent_enrollment 
   where current_timestamp between createts and endts
     and current_date between effectivedate and enddate
     and benefitsubclass in ('13'))
  ;
select * from benefit_plan_desc
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  ;  

select * from person_dependent_relationship
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and personid in 
  (select personid from person_bene_election
   where current_timestamp between createts and endts
     and current_date between effectivedate and enddate
     and benefitsubclass in ('13'))
  ;  
select count(distinct personid) as lowplan_count from person_bene_election  
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitsubclass = '13' and benefitplanid = '58'
  ;
select count(distinct personid)  as highplan_count from person_bene_election  
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitsubclass = '13' and benefitplanid = '61'
  ;  
select * from person_bene_election   
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitsubclass = '13' 
  and personid = '7106'
  ;
select personid, min(effectivedate) from person_bene_election   
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitsubclass = '13' 
  and personid = '7106'
  group by 1
  ;  
  
select * from person_names where personid = '7622';  