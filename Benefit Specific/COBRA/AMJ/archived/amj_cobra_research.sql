select distinct benefitsubclass from comp_plan_benefit_plan
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and cobraplan = 'Y' order by 1
  ;
select * from benefit_plan_desc
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitsubclass in ('10','11','14','15','16','17','60','61')
  ;
select * from person_bene_election 
where current_timestamp between createts and endts
 -- and current_date between effectivedate and enddate
  and benefitsubclass in ('10','11','14','15','16','17','60','61')
  and selectedoption = 'Y'
  --and benefitelection = 'E'
  and personid = '851'
  ;
select * from benefit_coverage_desc  
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitcoverageid in (select benefitcoverageid from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts
  and benefitsubclass in ('10','11','14','15','16','17','60','61'))
  ;
select * from person_employment
 where current_timestamp between createts and endts
   and emplstatus = 'T'
   and effectivedate >= '2018-01-01'
   and personid in (select distinct personid from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts
   and benefitsubclass in ('10','11','14','15','16','17','60','61'))
   ;
 select distinct benefitplanid from person_bene_election 
  where current_timestamp between createts and endts and benefitsubclass in ('10','11','14','15','16','17','60','61')
    and selectedoption = 'Y' 
    and benefitelection = 'E'
    and personid = '1057'
    ;
select * from dependent_enrollment
where current_timestamp between createts and endts and personid = '879';
  --and current_date between effectivedate and enddate
  and dependentid = '1243'
  ;    
  
SELECT * from person_maritalstatus where personid = '1737';  
select * from person_names where personid = '1737';
select * from person_names where lname like 'Taylor%';

select * from person_names where personid in ('1242','1243');
select * from person_dependent_relationship  where dependentid in ('1242','1243');
select * from dependent_enrollment where dependentid in ('1242','1243');

select distinct pbe.personid 
  from person_bene_elections pbe.
 where current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and benefitsubclass in ('10','11','14','15','16','17','60','61')
   and selectedoption = 'Y'
   and benefitelection = 'E'