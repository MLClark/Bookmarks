select * from person_bene_election where current_timestamp between createts and endts and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('10','11','14','60') and effectivedate >='2021-01-01';
select * from person_names where personid = '2038';

select * from benefit_plan_desc where benefitsubclass in ('10');
select * from person_bene_election where personid = '1319' and current_date between effectivedate and enddate and current_timestamp between createts and endts and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('10','11','14','60');



select * from edi.edi_last_update
--INSERT into edi.edi_last_update (feedid,lastupdatets) values ('RBA_Sound_Admin_Cobra_QE_Export','2018-10-01 00:00:00');
update edi.edi_last_update set lastupdatets = '2019-01-01 00:00:00' where feedid = 'RBA_Sound_Admin_Cobra_QE_Export';


select * from comp_plan_benefit_plan where cobraplan = 'Y';
select * from benefit_plan_desc;  
select * from person_benefit_action where eventname = 'TER';
select * from person_employment where personid in 
(select personid from person_bene_election where current_timestamp between createts and endts and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('10','11','14','60')
group by 1)
and emplstatus = 'T';
select * from person_bene_election where current_timestamp between createts and endts and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('10','11','14','60');
select benefitcoverageid from person_bene_election where current_timestamp between createts and endts and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('10','11','14','60') group by 1;
select * from benefit_coverage_desc where benefitcoverageid in 
(select benefitcoverageid from person_bene_election where current_timestamp between createts and endts and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('10','11','14','60') group by 1);


select * from personbenoptioncostl where personid = 


(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid)