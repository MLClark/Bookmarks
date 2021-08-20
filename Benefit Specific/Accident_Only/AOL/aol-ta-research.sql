select * from benefit_plan_desc where benefitsubclass in ('1AC', 'CIV') 
and current_date between effectivedate and enddate and current_timestamp between createts and endts;

left join (SELECT personid, emplstatus, emplevent,  empleventdetcode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_employment pe1
            WHERE enddate > effectivedate 
                   AND current_timestamp BETWEEN createts AND endts
                   and emplstatus = 'L'
                   and enddate <= current_date
            GROUP BY personid, emplstatus, emplevent, empleventdetcode ) leavest on leavest.rank = 1 and leavest.personid = pe.personid

join (select distinct personid, benefitcoverageid, max(personbeneelectionpid) as personbeneelectionpid, 
             RANK() OVER (PARTITION BY personid ORDER BY max(personbeneelectionpid) DESC) AS RANK
        from person_bene_election where benefitelection = 'E' and benefitsubclass = 'CIV' 
         and current_timestamp between createts and endts
         and date_part('year',effectivedate)=date_part('year',current_date)  and benefitcoverageid is not null
       group by 1,2) as maxcomp on maxcomp.personid = pbe.personid     

136	2017-01-01	Critical Ill EE NonT 	No dependents - EE only            
139	2017-01-01	Critical Ill EE1 Tob 	No dependents - EE only
142	2017-01-01	Crit Ill EE1 NonTob 	All dependent children under age 26
145	2017-01-01	Crit Ill EE2 Tob    	All dependent children under age 26
148	2017-01-01	Crit Ill EE2 NonTob 	Spouse and All dependent children under age 26
112	2017-01-01	Critical Ill EE Tob 	Spouse and All dependent children under age 26

select * from person_bene_election where personid = '1907' and benefitsubclass = '1AC' 
--and current_date between effectivedate and enddate and current_timestamp between createts and endts
and benefitelection = 'E' and selectedoption = 'Y';
select * from benefit_plan_desc where benefitsubclass = 'CIV' and benefitplanid in ('148', '139');

select current_date - interval '26 years';

select distinct
 pbe.personid
,c.d_ind
 from person_bene_election pbe 


left join (select distinct pdr.personid, pdr.dependentrelationship, pdr.dependentid,'child' as d_ind
                      
  from person_dependent_relationship pdr
 where pdr.dependentrelationship in ('S','D','C')) c on c.personid = pbe.personid
 
 where pbe.benefitsubclass in ('CIV') and pbe.selectedoption = 'Y' and pbe.benefitelection in ('E') 
 and pbe.personid = '2001'
 ;

select * from person_bene_election where benefitsubclass in ('1AC', 'CIV') and selectedoption = 'Y' and benefitelection in ('E') and personid = '1907';
and current_date between effectivedate and enddate and current_timestamp between createts and endts

select distinct personid from person_bene_election where benefitsubclass in ('1AC', 'CIV') and selectedoption = 'Y' and benefitelection in ('E')
and current_date between effectivedate and enddate and current_timestamp between createts and endts;


(select distinct personid, benefitcoverageid, max(personbeneelectionpid) as personbeneelectionpid 
        from person_bene_election where benefitelection = 'E' and benefitsubclass = '1AC' 
         and current_timestamp between createts and endts
         and date_part('year',effectivedate)=date_part('year',current_date)  and benefitcoverageid is not null
         and personid = '1907'
       group by 1,2)


select personid, max(effectivedate) as effectivedate
from person_bene_election 
where current_timestamp between createts and endts
  and benefitelection = 'E'
  and selectedoption = 'Y'
  and benefitsubclass in ('10','11','14')
  and personid = '1897'
  group by 1;
  select * from person_bene_election where benefitsubclass in ('1AC', 'CIV') and selectedoption = 'Y' --and benefitelection in ('E')
--and current_date between effectivedate and enddate and current_timestamp between createts and endts
and personid = '1929';
select * from benefit_coverage_desc ;
select * from dependent_enrollment where personid = '2001';
select * from dependent_enrollment where benefitsubclass in ('1AC', 'CIV');
select * from benefit_plan_desc;
select * from person_bene_election where benefitsubclass in ('1AC') and selectedoption = 'Y'   and personid = '1929';
and current_date between effectivedate and enddate and current_timestamp between createts and endts

select distinct personid, benefitcoverageid, max(personbeneelectionpid) as personbeneelectionpid 
from person_bene_election where benefitelection = 'E' and benefitsubclass = '1AC' 
--and current_date between effectivedate and enddate
and current_timestamp between createts and endts
and personid = '2032' 
group by 1,2;
select * from person_bene_election where benefitsubclass in ('1AC', 'CIV') and selectedoption = 'Y'   and personid = '1996';
select * from person_names where personid = '1996';

select * from person_bene_election where benefitsubclass in ('1AC', 'CIV') and selectedoption = 'Y'   and personid = '1927';
select distinct personid, benefitcoverageid, max(personbeneelectionpid) as personbeneelectionpid 
from person_bene_election where benefitelection = 'E' and benefitsubclass in ('1AC', 'CIV')
--and current_date between effectivedate and enddate
and current_timestamp between createts and endts
and personid = '1927' 
group by 1,2;

select * from person_bene_election where benefitsubclass in ( 'CIV') and selectedoption = 'Y'   and personid = '2065';
select distinct personid, benefitcoverageid, max(personbeneelectionpid) as personbeneelectionpid 
from person_bene_election where benefitelection = 'E' and benefitsubclass in ('CIV')
--and current_date between effectivedate and enddate
and current_timestamp between createts and endts
and personid = '2065' 
group by 1,2;


select * from person_bene_election where benefitsubclass in ( '1AC') and selectedoption = 'Y'   and personid = '2001';
select distinct personid, benefitcoverageid, max(personbeneelectionpid) as personbeneelectionpid 
        from person_bene_election where benefitelection = 'E' and benefitsubclass = '1AC' 
         and current_timestamp between createts and endts and personid = '2001'
         and date_part('year',effectivedate)=date_part('year',current_date) and benefitcoverageid is not null
       group by 1,2