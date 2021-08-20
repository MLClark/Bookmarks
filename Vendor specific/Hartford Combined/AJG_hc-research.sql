select * from person_bene_election


select * from person_bene_election
where benefitsubclass IN ( '1W')
  and personid = '9740'
  and current_date between effectivedate and enddate
  and current_timestamp between createts and endts;

select * from benefit_plan_desc where benefitsubclass IN ( '1W','13' )

select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ( '1W','13','30','31') and benefitelection = 'E' and selectedoption = 'Y'
                           and personid = '9734';


select * from pers_pos where personid = '9734'
--and current_date between effectivedate and enddate
and current_timestamp between createts and endts
;
select * from person_employment where personid = '9734';


select * from edi.etl_employment_term_data where personid = '9734' 
 

select * from benefit_plan_desc  
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitsubclass IN ( '1W','13','30','31' )
  ;
select distinct dependentid from dependent_enrollment 
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and personid = '9707' and benefitsubclass in ('1W','13')
  ;

select distinct dependentid from dependent_enrollment 
where current_timestamp between createts and endts
  and personid = '9707' and benefitsubclass in ('1W','13')
  ;
    
    
    
select * from pers_pos where personid = '10431' and persposrel = 'Occupies'
--and current_date between effectivedate  and enddate 
and current_timestamp between createts and endts;

select * from person_dependent_relationship  
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and personid = '9740';
select * from person_bene_election
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitsubclass IN ( '1W','13' )
  and personid = '9740';
  
select * from person_bene_election
where benefitsubclass IN ( '1W','13','30','31' )
  and personid = '9740';
    
select * from person_bene_election
where benefitsubclass IN ( '13' )
  and personid = '9932';
    
select * from dependent_enrollment where benefitsubclass = '13' and personid = '9707' and dependentid = '11235';

select distinct
 de.personid
,de.dependentid
,de.effectivedate 
,pv.birthdate
,CASE WHEN PV.BIRTHDATE <= CURRENT_DATE - INTERVAL '26 YEARS' THEN 'A' ELSE ' ' END AS DEP_STATUS
,max(de.enddate) enddate
from dependent_enrollment de
left join person_vitals pv
  on pv.personid = de.dependentid
 and current_timestamp between de.createts and de.endts 
where de.benefitsubclass = '13'
  and de.enddate < '2199-12-30'
  and de.dependentid = '11238'
  group by 1,2,3,4,5
  ;
 
select * from person_names where lname like 'Anaya%'; 
select * from person_names where personid = '9658';
 
select distinct
 de.personid
,de.dependentid
from dependent_enrollment de
join person_dependent_relationship pdr
  on pdr.personid = de.personid
 and pdr.dependentrelationship in ('D','S','C')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
left join person_vitals pv
  on pv.personid = de.dependentid
 and current_timestamp between de.createts and de.endts 
where de.benefitsubclass = '13'
  and de.enddate < '2199-12-30'
  and pv.birthdate <= current_date - interval '26 years'
  and de.dependentid = '11238'

  ; 
 
select * from person_names where personid = '11235';

select * from benefit_coverage_desc
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  ;  
select * from person_vitals where personid = '11235';
select * from person_maritalstatus where maritalstatus = 'D';
select * from person_names where personid = '10489';
select * from dependent_event;
select * from persondependentdetails;

select * from dependentstatus;
select * from psdependentbenefit;