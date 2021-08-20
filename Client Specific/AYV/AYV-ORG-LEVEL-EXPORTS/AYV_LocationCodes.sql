select 
 locationcode ::char(5) as location
,locationdescription ::varchar(100) as location_description

from companylocations
where current_date between effectivedate and enddate
  --and current_timestamp between createts and endts