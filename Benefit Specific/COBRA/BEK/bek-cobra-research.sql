select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2018-06-19 00:00:00' where feedid in ('BEK_ProBenefits_QE_Export');

select * from person_names where personid = '243';
select * from person_names where lname like 'Nath%';
select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate
                         and personid = '289';

select * from person_dependent_relationship where personid = '289';  

select * from person_bene_election
where current_timestamp between createts and endts 
  and benefitsubclass in  ('10','11','14','60')
  and selectedoption = 'Y' and effectivedate < enddate
  and personid in ('317');    
  
     
  and personid in ('266','186','289');                                         

                         
select * from person_employment where personid = '186';                                               

(select personid, benefitsubclass, coverageamount, benefitplanid, benefitelection, benefitcoverageid, enddate, max(effectivedate) as effectivedate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
   from person_bene_election 
  where benefitsubclass in ('11')
    and benefitelection in ('E')
    and selectedoption = 'Y' 
    and effectivedate < enddate
    and current_timestamp between createts and endts
    and personid = '329'
     group by 1,2,3,4,5,6,7);
     
SELECT * FROM person_bene_election where      