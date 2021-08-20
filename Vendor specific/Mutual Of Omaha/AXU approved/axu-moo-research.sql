
select * from edi.edi_last_update;




update edi.edi_last_update set lastupdatets = '2020-12-29 07:02:43' where feedid = 'AXU_Mutual_Of_Omaha_Carrier_Export';




select * from person_bene_election where benefitsubclass = '21' and selectedoption = 'Y' and personid 
in (select personid from person_bene_election where benefitsubclass = '21' and selectedoption = 'Y' and benefitelection = 'W' and effectivedate = '2021-01-01' and personid 
in (select personid from person_bene_election where benefitsubclass = '21' and selectedoption = 'Y' and benefitelection = 'E' and effectivedate between '2020-01-01' and '2020-12-31'))
and effectivedate between '2020-01-01' and '2021-01-01'
;
select * from person_bene_election where current_timestamp between createts and endts and benefitsubclass in ('21') and benefitelection in ('T','W') and selectedoption = 'Y' and personid = '2493';



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
  where current_timestamp between createts and endts and benefitsubclass in ('21') and benefitelection in ('T','W') and selectedoption = 'Y' and effectivedate < enddate 
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T'))  
    and personid in (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or cppy.planyear = date_part('year',current_date - interval '1 year'))
                      where benefitsubclass in ('21') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year'))
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) w
join 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or cppy.planyear = date_part('year',current_date - interval '1 year'))
  where benefitsubclass in ('21') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate >= planyearstart 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) e on w.personid = e.personid and e.rank = 1 and )
  ;
  
  (select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe 
  where current_timestamp between createts and endts and benefitsubclass in ('21') and benefitelection in ('T','W') and selectedoption = 'Y' and current_date between effectivedate and enddate 
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T'))  
    and personid in (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or cppy.planyear = date_part('year',current_date - interval '1 year'))
                      where benefitsubclass in ('21') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year'))
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid )
  ;
  
  (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or cppy.planyear = date_part('year',current_date - interval '1 year'))
                      where benefitsubclass in ('21') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year'))
                      ;
  (select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or cppy.planyear = date_part('year',current_date - interval '1 year'))
  where benefitsubclass in ('21') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate >= planyearstart 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid )
  ;