select * from person_employment where emplstatus = 'T' and effectivedate >= '2018-01-01';

select * from person_names where nametype = 'Legal' 
  and current_date between effectivedate and enddate and current_timestamp between createts and endts and personid in      
(select personid from person_bene_election where benefitsubclass in ('10','11','14','15','16','17','60','61') 
  and current_date between effectivedate and enddate and current_timestamp between createts and endts
  and selectedoption = 'Y' and benefitelection in ('E') and personid in 
(select personid from person_employment where emplstatus = 'T' and effectivedate >= '2018-01-01' group by 1) group by 1)
;
select * from person_employment where emplstatus = 'T' and effectivedate >= '2018-01-01' and personid = '1760';
select * from person_bene_election where benefitsubclass in ('10','11','14','15','16','17','60','61') 
  and current_date between effectivedate and enddate and current_timestamp between createts and endts
  and selectedoption = 'Y' and benefitelection in ('E','T') and personid = '1760';
  
  select * from comp_plan_benefit_plan where cobraplan = 'Y';