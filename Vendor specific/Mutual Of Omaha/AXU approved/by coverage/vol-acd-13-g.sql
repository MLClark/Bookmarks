
(select 
 w.personid
,w.benefitsubclass
,w.benefitelection
,w.personbeneelectionpid
,e.coverageamount
,w.effectivedate
,w.enddate
,w.benefitcoverageid
,e.effectivedate as e_effectivedate
,e.enddate as e_enddate
,w.rank
from 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe 
  where current_timestamp between createts and endts and benefitsubclass in ('13') and benefitelection in ('T','W') and selectedoption = 'Y' and current_date between effectivedate and enddate   
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T'))
    and personid in (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and cppy.planyear = date_part('year',current_date)
                      where benefitsubclass in ('13') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year')) 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) w
join 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or cppy.planyear = date_part('year',current_date - interval '1 year'))
  where benefitsubclass in ('13') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate = planyearstart 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) e on w.personid = e.personid and e.rank = 1)
  ;
  
  (select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' 
   and (cppy.planyear = date_part('year',current_date) or cppy.planyear = date_part('year',current_date - interval '1 year'))
  where benefitsubclass in ('13') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate >= planyearstart 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid );
  
  select * from person_bene_election where benefitsubclass = '13' and personid = '846';
  
  select 