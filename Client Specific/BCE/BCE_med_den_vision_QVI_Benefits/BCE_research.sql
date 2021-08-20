Jacquelin Carrillo Mendoza has EE+SP coverage for her Dental and Vision

select * from person_bene_election where benefitsubclass in ('10','11','14') and personid = '2044'
and current_date between effectivedate and enddate and current_timestamp between createts and endts and effectivedate >= '2018-09-01'
and selectedoption = 'Y' and benefitelection = 'E';

select * from person_dependent_relationship where personid = '2057';
select * from benefit_coverage_desc 
where current_date between effectivedate and enddate and benefitcoverageid in ('1','2','3')
  and current_timestamp between createts and endts; 
  
select * from dependent_enrollment where personid = '2057' and benefitsubclass in ('10','11','14')
and current_date between effectivedate and enddate and current_timestamp between createts and endts and effectivedate >= '2018-09-01'

select * from person_employment where personid = '3787';
select * from person_bene_election where benefitsubclass in ('10','11','14') and personid = '3787';

select * from person_benefit_action where personid = '3787';

select * from benefit_plan_desc
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts;
SELECT * FROM person_bene_election
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitelection = 'T'
  and benefitsubclass in ('10','11','14');
SELECT * FROM person_bene_election
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitelection = 'E'
  and benefitsubclass in ('14')
  and personid = '740';
  
select * from person_names where lname like 'Erceg%';  
select * from benefit_coverage_desc 
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts; 
  
select * from dependent_enrollment 
where benefitsubclass in ('10','11','14')  
  
  
SELECT benefitsubclass,benefitcoverageid FROM person_bene_election
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitelection = 'E'
  and benefitsubclass in ('10','11','14')
  and personid = '740';  
  
select * from dependent_enrollment where personid = '411';
select * from person_bene_election where personid in ('2037') and benefitsubclass in ('10','11','14')
and current_date between effectivedate and enddate and current_timestamp between createts and endts
and selectedoption = 'Y'


select * from person_dependent_relationship where personid = '411';
select * from person_names where personid in ('1610','411');
select * from dependent_enrollment where personid = '411';

select * from person_bene_election where personid in ('1610','411') and benefitsubclass in ('10')
  and current_date between effectivedate and enddate and current_timestamp between createts and endts;  
  

select * from person_dependent_relationship where personid = '2047';  
select * from dependent_enrollment where personid = '2047' and benefitsubclass in ('10','11','14');