------------------
-- PCSTD (30) Q --
------------------ 
--left join 
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
  where current_timestamp between createts and endts and benefitsubclass in ('30') and benefitelection in ('T','W') and selectedoption = 'Y' and current_date between effectivedate and enddate
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T'))     
    and personid in (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and cppy.planyear = date_part('year',current_date)
                      where benefitsubclass in ('30') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate = date_trunc('year',current_date - interval '1 year'))
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) w
join 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and cppy.planyear = date_part('year',current_date)
  where benefitsubclass in ('30') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and effectivedate >= date_trunc('year',current_date - interval '1 year')
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) e on w.personid = e.personid and e.rank = 1) --pbestd on pbestd.personid = pbe.personid and pbestd.rank = 1 
  --and pbestd.effectivedate::date >= elu.lastupdatets::date + interval '30 days' 