select * from dependent_enrollment 
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitsubclass in ('10','11','14','6Z')
  ;
select * from benefit_plan_desc
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitsubclass in ('10','11','14','6Z')
  ;  