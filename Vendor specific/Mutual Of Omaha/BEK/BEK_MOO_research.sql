select * from person_names where lname like 'Motsch%';
select * from person_employment where personid = '305';
select * from person_address where personid = '330';
select * from person_compensation where personid = '305';

select * from person_bene_election where personid = '711' and benefitsubclass = '2Z';
case when substring(pa.postalcode from 6 for 1) = '-' then 'has dash' 
     when substring(pa.postalcode from 6 for 1) <> '-' then 'no dash' 
else 'no dash' end ::char(11) as zip
from person_address pa where personid = '330';

select * from benefit_plan_desc
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitsubclass in ('11','20','30','31','21','2Z','25')
  ;

select * from benefit_coverage_desc  ;
select benefitcoverageid from person_bene_election   
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and benefitsubclass in ('11','20','30','31','21','2Z','25')
  and benefitelection = 'E'
  and selectedoption = 'Y'  
  group by 1;


select * from person_bene_election   
where effectivedate >= '09-01-2018'
  and benefitsubclass in ('11','20','30','31','21','2Z','25')
  and benefitelection = 'E'
  and selectedoption = 'Y'  
  and personid = '256'
;

select * from person_dependent_relationship
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and personid in ('317');

select pbe.personid,bcd.benefitcoveragedesc,bcd.benefitcoverageid       
  from person_bene_election pbe
  join benefit_coverage_desc bcd
    on bcd.benefitcoverageid = pbe.benefitcoverageid
   and current_date between bcd.effectivedate and bcd.enddate
   and current_timestamp between bcd.createts and bcd.endts  
 where pbe.benefitsubclass in ('11')-- only time need to join on bcd is for dental 
   and pbe.benefitelection in ('E')
   and pbe.selectedoption = 'Y'
   and pbe.personid = '139'

   group by 1,2,3
   
   ;

select benefitcoveragedesc from benefit_coverage_desc group by 1;



select * from dependent_enrollment
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and personid = '300'
  and benefitsubclass in ('11','20','30','31','21','2Z','25')

select * from person_bene_election pbedent
join 
(
select personid, max(personbeneelectionpid) as personbeneelectionpid
  from person_bene_election   
 where current_timestamp between createts and endts
   and current_date between effectivedate and enddate
   and benefitelection = 'E'
   and selectedoption = 'Y'
   and benefitsubclass = '31'
   group by 1
) as maxpid on maxpid.personid = pbedent.personid and maxpid.personbeneelectionpid = pbedent.personbeneelectionpid

where current_timestamp between pbedent.createts and pbedent.endts
  and current_date between pbedent.effectivedate and pbedent.enddate
  and pbedent.benefitelection = 'E'
  and pbedent.selectedoption = 'Y'
  and pbedent.benefitsubclass = '31'
  and pbedent.personid = '287'
  ;


select personid, max(personbeneelectionpid) as maxpid
  from person_bene_election   
 where current_timestamp between createts and endts
   and current_date between effectivedate and enddate
   and benefitelection = 'E'
   and selectedoption = 'Y'
   and benefitsubclass = '31'
   and personid = '287'
   group by 1
   ;


(select distinct de.personid, de.dependentid, de.benefitsubclass, de.effectivedate, de.selectedoption, pdr.dependentrelationship, bcd.benefitcoveragedesc
              from dependent_enrollment de
              left join person_dependent_relationship pdr
                on pdr.personid = de.personid
               and pdr.dependentrelationship in ('D','C','S','DP','SP')
               and current_date between pdr.effectivedate and pdr.enddate
               and current_timestamp between pdr.createts and pdr.endts
              join person_bene_election pbe 
                on pbe.personid = de.personid
               and pbe.benefitsubclass = de.benefitsubclass                
               and current_date between pbe.effectivedate and pbe.enddate
               and current_timestamp between pbe.createts and pbe.endts
              join benefit_coverage_desc bcd
                on bcd.benefitcoverageid = pbe.benefitcoverageid
               and current_date between bcd.effectivedate and bcd.enddate
               and current_timestamp between bcd.createts and bcd.endts               
             where current_date between de.effectivedate and de.enddate
               and current_timestamp between de.createts and de.endts
               and de.benefitsubclass in ('11')
           );   
           
 and pbedent.benefitsubclass in ('11')
 and pbedent.benefitelection in ('E')
 and pbedent.selectedoption = 'Y'            
select * from benefit_coverage_desc ;
select pbe.personid,bcd.benefitcoveragedesc         
  from person_bene_election pbe
  join benefit_coverage_desc bcd
    on bcd.benefitcoverageid = pbe.benefitcoverageid
   and current_date between bcd.effectivedate and bcd.enddate
   and current_timestamp between bcd.createts and bcd.endts  
 where pbe.benefitsubclass = '11'
   and pbe.personid = '139'
   and pbe.benefitelection in ('E')
   and pbe.selectedoption = 'Y'
   group by 1,2
   ;


select * from person_bene_election 
where personid = '213'
  and selectedoption = 'Y'
  and benefitelection = 'E'
  and current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitsubclass in ('11','20','30','31','21','2Z','25')
  ;  
  