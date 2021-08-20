
-- Debbie used this query to send to HMN to id changed positions

select distinct
 pe.personid
,pn.lname
,pn.fname
,pd.positiontitle
,pe.effectivedate as termination_date
,pe.emplstatus
,pj.jobid
,jd.flsacode as jd_flsacode
,pd.flsacode as pd_flsacode



,pp.effectivedate as pers_pos_eff_date
,pp.enddate as pers_pos_end_date
,pd.effectivedate as pos_desc_eff_date

,pp.positionid


,pd.enddate

from person_employment pe

join person_names pn
  on pn.personid = pe.personid 
 and pn.nametype = 'Legal' 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join pers_pos pp 
  on pp.personid = pe.personid
 and pp.effectivedate < pp.enddate 
 and current_timestamp between pp.createts and pp.endts
 
left join position_desc pd
  on pd.positionid = pp.positionid
 and pd.effectivedate < pd.enddate
 and current_timestamp between pd.createts and pd.endts           
          
left join position_job pj
  on pj.positionid = pp.positionid 
 and pj.effectivedate < pj.enddate 
 and current_timestamp between pj.createts and pj.endts

left join job_desc jd
  on jd.jobid = pj.jobid
 and jd.effectivedate < jd.enddate
 and current_timestamp between jd.createts and jd.endts

where current_date between pe.effectivedate and pe.enddate
  and current_timestamp between pe.createts and pe.endts
  and pe.emplstatus in ('T','R') --and pp.personid = '66216'
  and jd.flsacode = 'N' and jd.flsacode <> pd.flsacode
  
  order by lname, fname
  ; 

  
 select * from pers_pos where personid = '66216';

 select * from person_employment where personid = '66216';
 select * from position_desc where positionid in ('401883','401882') and effectivedate < enddate order by enddate;
 select * from position_job where positionid in ('401883','401882') and effectivedate < enddate order by enddate;
 select * from job_desc where jobid in ('69765','69780');