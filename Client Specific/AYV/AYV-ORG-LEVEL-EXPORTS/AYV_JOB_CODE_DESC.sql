select distinct
 SPLIT_PART(jd.jobcode,'-',1) ::char(5) AS job_code
,jobdesc ::char(50) AS job_desc

from job_desc jd
where current_date between jd.effectivedate and jd.enddate
  and current_timestamp between jd.createts and jd.endts
  
  order by job_code
  ;
  
  select * from job_desc jd
where current_date between jd.effectivedate and jd.enddate
  and current_timestamp between jd.createts and jd.endts