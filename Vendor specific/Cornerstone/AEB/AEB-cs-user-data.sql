select distinct 
/*
This sql builds data for 6 files sent to cornerstone.
The fields defined as ou_ will be grouped in the kettle script and unique values written to each file
*/
 pi.personid
,la.locationid
,pl.locationid
---------------------------------------
----- START OU FILE DATA SECTION ------
---------------------------------------
,pp.positionid ::varchar(20) as ou_position_id --- file ou position - unique key the id's the position
,pd.positiontitle ::varchar(100) as ou_position_name --- file ou position - descriptive position name
,coalesce(jd.jobid,'3') ::varchar(50) as ou_grade_id --- file ou grade col ou id - unique key that id's the grade - this client does not use salary grade
,jd.jobcode ::varchar(20) as ou_grade_name --- file ou grade col ou name - descriptive name for job position - all jobs default to all jobs
,oco.organizationid ::char(10) as ou_cost_center_id --- file ou cost center - unique key that id's cost center - in this case the div org code matches venders cost centers
,oco.organizationdesc ::varchar(30) as ou_cost_center_name --- file ou cost center - descriptive cost center name
,lc.locationid ::varchar(50) as ou_location_id --- file ou location - unique key that id's the location 
,lc.locationdescription ::varchar(60) as ou_location_name --- file ou location - descriptive location name
,pa.countrycode ::char(2) as ou_location_country
,coalesce(tz.timezoneabbr,'EST') ::char(5) as ou_location_timezone 
,occc.organizationid ::varchar(10) as ou_division_id --- file ou division - unique key id's the division - this client expects cost cent value as division
,occc.orgcode ::varchar(50) as ou_division_name --- file ou division - descriptive division name



----------------------------------------
----- START USER DATA FILE SECTION -----
----------------------------------------
,pie.identity ::char(10) as user_id
,' ' ::char(1) as local_system_id
,pncw.url ::varchar(100) as userid
,'TRUE' ::char(4) as active
,' ' ::char(1) as absent
,'TRUE'::char(4) as allow_reconciliation
,' ' ::char(1) as prefix
,pn.fname ::varchar(40) as fname
,pn.mname ::char(1) as mname
,pn.lname ::varchar(40) as lname
,' ' ::char(1) as suffix
,pncw.url ::varchar(100) as email 
,ppcw.phoneno as workphone
,' ' ::char(1) as homephone 
,' ' ::char(1) as cellphone  
,' ' ::char(1) as fax  
,pa.countrycode ::char(2) as country_code
,' ' ::char(1) as line1
,' ' ::char(1) as line2
,' ' ::char(1) as mail_stop
,' ' ::char(1) as city
,' ' ::char(1) as state
,' ' ::char(1) as zip

,occc.organizationid ::varchar(10) as division_id
,lc.locationid ::varchar(50) as location_id
,pp.positionid ::varchar(20) as positionid
,' ' ::char(1) as cost_center
,coalesce(jd.jobid,'3') ::varchar(50) as grade

,to_char(pe.empllasthiredate,'yyyy-mm-dd')::char(10) as last_hire_date
,to_char(pe.emplhiredate,'yyyy-mm-dd')::char(10) as original_hire_date

,'1' ::char(1) as requires_approval

,' ' ::char(1) as approval_id
--,ppmd.current_manager 
--,ppmd.mgrpositionid 
--,ppm.positionid
--,ppm.personid
,piem.identity as managers_id
,' ' ::char(1) as gender
,' ' ::char(1) as ethnicity
,' ' ::char(1) as language
,coalesce(tz.timezoneabbr,'EST') as timezone
,' ' ::char(1) as compensation_currency
,' ' ::char(1) as exempt
,' ' ::char(1) as status
,' ' ::char(1) as OU1
,' ' ::char(1) as OU2
,' ' ::char(1) as CF1
,' ' ::char(1) as CF2
,' ' ::char(1) as CF3

from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

join person_employment pe
  on pe.personid = pi.personid 
 and pe.emplstatus in ('A','L')
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join (select personid, url, enddate, max(effectivedate) as effectivedate, max(createts) as createts,  RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
             from person_net_contacts where netcontacttype = 'WRK' and effectivedate < enddate and current_timestamp between createts and endts
            group by personid, url, enddate)  pncw  on pncw.personid = pi.personid and pncw.rank = 1

left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate  

left join person_phone_contacts ppch 
  on ppch.personid = pe.personid 
 and ppch.phonecontacttype = 'Home'
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts

left join person_phone_contacts ppcm 
  on ppcm.personid = pe.personid 
 and ppcm.phonecontacttype = 'Mobile'
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts
 
left join person_phone_contacts ppcw
  on ppcw.personid = pe.personid 
 and ppcw.phonecontacttype = 'Work'
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  

left join pers_pos pp 
  on pp.personid = pe.personid 
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts   

left join person_locations pl
  on pl.personid = pe.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts 

left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts
 
left join pay_unit pu on pu.payunitid = ppl.payunitid 

left join pos_org_rel por 
  on por.positionid = pp.positionid 
 and por.posorgreltype = 'Member'
 and current_date between por.effectivedate and por.enddate
 and current_timestamp between por.createts and por.endts

left join pos_org_rel porb
  on porb.positionid = pp.positionid 
 and porb.posorgreltype = 'Budget'
 and current_date between porb.effectivedate and porb.enddate
 and current_timestamp between por.createts and porb.endts 

left join organization_code occc
  on occc.organizationid = porb.organizationid 
 and occc.organizationtype in ('CC')
 and current_date between occc.effectivedate and occc.enddate 
 and current_timestamp between occc.createts and occc.endts  
                   
left join organization_code oco 
  on oco.organizationid = por.organizationid 
 and current_date between oco.effectivedate and oco.enddate 
 and current_timestamp between oco.createts and oco.endts
 
left join location_codes lc
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts

left join (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode) pd on pd.positionid = pp.positionid and pd.rank = 1
            


left join position_job pj
  on pj.positionid = pp.positionid
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts
 
left join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts 
  
left join location_address la
  on la.locationid = pl.locationid 
 and current_date between la.effectivedate and la.enddate 
 and la.timezoneid is not null
 
left join time_zones tz on tz.timezoneid = la.timezoneid

left join posposmanagerdetail ppmd
  on ppmd.positionid = pd.positionid
 and current_date between ppmd.effectivedate and ppmd.enddate
 and current_timestamp between ppmd.createts and ppmd.endts

left join pers_pos ppm
  on ppm.positionid = ppmd.mgrpositionid 
 and current_date between ppm.effectivedate and ppm.enddate
 and current_timestamp between ppm.createts and ppm.endts

left join person_identity piem
  on piem.personid = ppm.personid
 and piem.identitytype = 'EmpNo'
 and current_timestamp between piem.createts and piem.endts 
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
