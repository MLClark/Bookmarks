select 
 active.record_type
,active.record_count as active
,termed.record_count as termed 
,case when termed.record_count is null then active.record_count else active.record_count + termed.record_count end as record_count
from
(

SELECT
'eligibility' :: char(12) as record_type
,count (pbe.personid) as record_count

from person_bene_election pbe
  
WHERE pbe.benefitsubclass in ('60', '61' )
  AND pbe.benefitelection in ('E')
  AND pbe.selectedoption = 'Y'---
  AND current_date between pbe.effectivedate and pbe.enddate 
  AND current_timestamp between pbe.createts and pbe.endts 
  and date_part('year',effectivedate)=date_part('year',current_date)
  group by 1

) as active

left join 
(

SELECT
'eligibility' :: char(12) as record_type
--,count (pbe.personid) as record_count
,count (pbe.personid) as record_count
from person_bene_election pbe
  
WHERE pbe.benefitsubclass in ('60', '61' )
  AND pbe.benefitelection in ('T')
  and pbe.effectivedate >= current_date  - interval '30 days' 
  and personid in 
  (select distinct personid from person_bene_election 
    where current_timestamp between createts and endts
      and current_date between effectivedate and enddate
      and date_part('year',effectivedate)=date_part('year',current_date)
      and benefitsubclass in ('60', '61' )
      and benefitelection = 'E')  
  group by 1

) as termed on termed.record_type = active.record_type
