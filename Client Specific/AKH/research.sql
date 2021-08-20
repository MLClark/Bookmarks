select * from person_names where lname like 'Young%';
select * from person_bene_election where personid = '7961' and current_date between effectivedate and enddate and current_timestamp between createts and endts and benefitsubclass in ('32','31','22','20','21','2Z','25'); 
--select * from person_compensation where personid = '9682';
      
      
select * from person_bene_election where benefitsubclass in ('20') and personid = '8529'
and benefitelection = 'E' and selectedoption = 'Y'
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts
;
   
select * from person_employment where person
select * from person_names where lname like 'Burge%';