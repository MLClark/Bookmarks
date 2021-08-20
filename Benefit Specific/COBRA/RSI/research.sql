select * from person_bene_election where benefitsubclass in ('10','11','14','1Y')
--and current_date between effectivedate 
--and enddate and current_timestamp between createts and endts
and personid = '607';


select * from person_bene_election where benefitsubclass in ('1Y')
--and current_date between effectivedate 
--and enddate and current_timestamp between createts and endts
and personid = '607';

 (select * from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','1Y') 
                         and benefitelection = 'E' and selectedoption = 'Y'
                         and date_part('year',planyearenddate) = date_part('year',current_date) 
                         and personid = '607');


         
         
select * from person_employment where personid = '1929';
select * from dependent_enrollment where personid = '607'
and benefitsubclass in ('10','11','14','1Y')
and current_timestamp between createts and endts

select * from person_names where personid = '2124';
select * from person_names where lname like 'Peterson%';
select * from edi.edi_last_update;

---- select * from edi.edi_last_update ;    
---- update edi.edi_last_update set lastupdatets = '2018-06-19 06:01:02' where feedid in ('RSI_DBS_COBRA_QB_Feed'); 
---- 2018-06-19 06:01:02
              
'2017-11-14 06:01:20'
'2017-12-12 06:01:30'
'2018-01-02 06:02:48'
'2018-01-09 06:02:03'
'2018-02-27 06:00:35'
'2018-03-06 06:00:09'

select * from benefit_plan_desc
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitsubclass in ('10','11','14','1Y')
  ;

select * from benefit_coverage_desc
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  ;  
select * from person_names where lname like 'Pale%';
select * from person_bene_election 
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitsubclass in ('10','11','14','1Y')
  and personid in ('2113')
  ;
select * from person_employment   
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and personid in ('1169')
  ;
select * from person_dependent_relationship 
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and personid in ('2113')
  ; 
select * from dependent_enrollment  
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and personid in ('2113')
  ; 
  