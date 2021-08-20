select benefitsubclass from comp_plan_benefit_plan
where current_date between effectivedate and enddate
and current_timestamp between createts and endts
and cobraplan = 'Y'
group by 1;
select * from benefit_plan_desc where benefitsubclass in ('10','11','14')and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from person_bene_election where benefitsubclass in ('10','11','14') and personid = '5242';

select * from person_names where lname like 'Trac%';


select * from person_employment where personid = '5183';
select * from person_bene_election where benefitsubclass in ('10','11','14') and benefitelection <> 'W' and selectedoption = 'Y'and personid = '5183';
                          

select personid, effectivedate, benefitelection, benefitsubclass from person_bene_election where benefitsubclass in ('10','11','14') and current_date between effectivedate and enddate and current_timestamp between createts and endts
and benefitelection in ('E') and selectedoption = 'Y' group by 1,2,3,4 order by 1 ;
select * from person_names where personid = '5120';
select * from benefit_plan_desc 
where current_date between effectivedate and enddate and current_timestamp between createts and endts and benefitsubclass in ('10','11','14') ;
select * from person_bene_election where benefitsubclass in ('10') and benefitplanid in ('21') and benefitelection = 'E';
select * from person_bene_election where benefitsubclass in ('14') and personid = '5170';
select * from edi.edi_last_update ;

           (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in ('10','11','14') and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts 
              and personid = '5242'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) 