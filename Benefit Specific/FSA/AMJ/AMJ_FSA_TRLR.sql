select 
 active.record_type
,active.record_count + termed.record_count as record_count
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
  group by 1

) as active

join 
(

SELECT
'eligibility' :: char(12) as record_type
,count (pbe.personid) as record_count

from person_bene_election pbe
  
WHERE pbe.benefitsubclass in ('60', '61' )
  AND pbe.benefitelection in ('T')
  AND pbe.selectedoption = 'Y'---
  AND current_date between pbe.effectivedate and pbe.enddate 
  AND current_timestamp between pbe.createts and pbe.endts 
  and pbe.effectivedate >= current_date  - interval '30 days' 
  group by 1

) as termed on termed.record_type = active.record_type
