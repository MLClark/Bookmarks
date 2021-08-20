select * from pers_pos where personid = '6384';
select * from position_job where positionid = '3577';
select * from job_desc where jobid = '740' 
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;

select * from job_desc where jobid = '1122' 
and current_date between effectivedate and enddate 
--and current_timestamp between createts and endts;
;

select distinct
 pe.personid
,pp.positionid 
,pn.name

,jd.jobid
,jd.jobdesc
,jd.effectivedate
,jd.enddate
,jd.createts 
,jd.endts
from person_employment pe

join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join (select distinct positionid, jobid 
from position_job
where current_date between effectivedate and enddate 
  and current_timestamp between createts and endts
  order by 1) ajp on ajp.positionid = pp.positionid
  and ajp.jobid not in (select distinct jobid from job_desc 
                         where current_date between effectivedate and enddate 
                           and current_timestamp between createts and endts
                           and enddate >= '2199-12-30')
  

/*
join (select distinct jobid 
from job_desc 
where current_date between effectivedate and enddate
  and enddate = '2199-12-31'
  and endts::date <= '2199-12-30') ejts on ejts.jobid = ajp.jobid
join job_desc jd_time
  on jd_time.jobid = ejts.jobid    
*/  

join (select distinct jobid 
from job_desc 
where current_timestamp between createts and endts  
  and enddate < '2199-12-30') ejp on ejp.jobid = ajp.jobid
    

join job_desc jd
  on jd.jobid = ejp.jobid  
  

    
where pe.emplstatus = 'A'
  and current_date between pe.effectivedate and pe.enddate
  and current_timestamp between pe.createts and pe.endts  
  and jd.enddate < '2199-12-30'

union


select distinct
 pe.personid
,pp.positionid 
,pn.name

,jd.jobid
,jd.jobdesc
,jd.effectivedate
,jd.enddate
,jd.createts 
,jd.endts
from person_employment pe

join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join (select distinct positionid, jobid 
from position_job
where current_date between effectivedate and enddate 
  and current_timestamp between createts and endts
  order by 1) ajp on ajp.positionid = pp.positionid
  and ajp.jobid not in (select distinct jobid from job_desc 
                         where current_date between effectivedate and enddate 
                           and current_timestamp between createts and endts
                           and enddate >= '2199-12-30')
  


join (select distinct jobid 
from job_desc 
where current_date between effectivedate and enddate
  and enddate = '2199-12-31'
  and endts::date <= '2199-12-30') ejts on ejts.jobid = ajp.jobid
join job_desc jd
  on jd.jobid = ejts.jobid    
/*

join (select distinct jobid 
from job_desc 
where current_timestamp between createts and endts  
  and enddate < '2199-12-30') ejp on ejp.jobid = ajp.jobid
    

join job_desc jd_date
  on jd_date.jobid = ejp.jobid  
  
*/
    
where pe.emplstatus = 'A'
  and current_date between pe.effectivedate and pe.enddate
  and current_timestamp between pe.createts and pe.endts  
  and jd.endts::date <= '2199-12-30'
  --and pe.personid = '6134'
  order by 1  