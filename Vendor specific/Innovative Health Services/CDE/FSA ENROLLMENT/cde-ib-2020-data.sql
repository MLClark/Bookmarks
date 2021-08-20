select
 pi.personid ::int
,'ACTIVE EE' ::varchar(30) as qsource
,'IB' ::char(2) as recordtype
,'IHS' ::varchar(6) as tpaid
,'IHSSBS' ::varchar(9) as employerid
,pi.identity ::char(9) as employeeid
,pn.lname ::varchar(26) as lname
,pn.fname ::varchar(19) as fname
,pn.mname ::char(1) as mname
,ppch.phoneno ::varchar(19) as homephone
,ppcm.phoneno ::varchar(19) as mobilephone
,pa.streetaddress ::varchar(36) as addr1
,pa.streetaddress2 ::varchar(36) as addr2
,pa.city ::varchar(20) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(9) as zip
,pa.countrycode ::varchar(3) as country
,'1' ::char(1) as reimburse_method
,coalesce(pncw.url,pnch.url) ::varchar(100) as email
,case when pe.emplstatus = 'T' then '5' 
      when pe.emplstatus = 'A' then '2' end ::char(1) as employee_status 
,case when pv.gendercode = 'F' then '2'
      when pv.gendercode = 'M' then '1' else '0' end ::char(1) as gender
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob
,pi.identity ::char(9) as ssn
,'99991231'::char(8) as plan_year_start_date    

from person_identity pi

left join person_employment pe
  on pe.personid = pi.personid
 and current_timestamp between pe.createts and pe.endts
 and current_date between pe.effectivedate and pe.enddate
 
-- Pulls the max effectivedate within the specified plan year
-- Used benefitelection = 'E' filter in where clause to avoid pulling false positives (Elections were populating that are currently waived/termed, but had 'E' status within the plan year)
left join (select pbe.personid,pbe.benefitsubclass,pbe.benefitelection,pbe.selectedoption,pbe.eventdate,pbe.benefitplanid,pbe.benefitcoverageid,pbe.compplanid,
max(pbe.effectivedate) as effectivedate,max(pbe.enddate) as enddate,max(pbe.createts) as createts,
rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
from person_bene_election pbe
left join comp_plan_plan_year cppy 
  on cppy.compplanid = pbe.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and ?::date between cppy.planyearstart and cppy.planyearend
 where effectivedate < enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y'
 and pbe.effectivedate between cppy.planyearstart and cppy.planyearend
 group by 1,2,3,4,5,6,7,8) pbe on pbe.personid = pe.personid and pbe.rank = 1

 and pbe.personid not in 

 -- Logic to get NPM's since the last update and restrict them to the current plan year. They will become Active EE when the effectivedate < lastupdatets
(select distinct effcovdate.personid
       from (select pbe.personid,pbe.benefitsubclass,pbe.compplanid, min(pbe.createts) as createts, min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
             from person_bene_election pbe 
             where pbe.benefitsubclass in ('60','61') and pbe.effectivedate < pbe.enddate and current_timestamp between pbe.createts and pbe.endts
               and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' 
             group by 1,2,3 order by 1) effcovdate
       left join edi.edi_last_update elu on elu.feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'
	   left join comp_plan_plan_year cppy on cppy.compplanid = effcovdate.compplanid
	     and cppy.compplanplanyeartype = 'Bene'
 	     and ?::date between cppy.planyearstart and cppy.planyearend
       where effcovdate.min_effectivedate = effcovdate.max_effectivedate
         and effcovdate.max_effectivedate between cppy.planyearstart and cppy.planyearend 
         and (effcovdate.max_effectivedate >= elu.lastupdatets::DATE 
   	       or (effcovdate.createts > elu.lastupdatets and effcovdate.max_effectivedate < coalesce(elu.lastupdatets, '2017-01-01'))))

left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
left join person_phone_contacts ppcb
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'      
left join person_phone_contacts ppcm
  on ppcm.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'  
  

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts 
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts  
LEFT JOIN person_net_contacts pnco
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.endts   
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('T','R')
  and pbe.benefitelection in ('E') 


  UNION -----------------------------------------------------------------------------------------------------------------------------------
  

  select
 pi.personid ::int
,'ACTIVE EE TERMED ENROLLMENT' ::varchar(30) as qsource
,'IB' ::char(2) as recordtype
,'IHS' ::varchar(6) as tpaid
,'IHSSBS' ::varchar(9) as employerid
,pi.identity ::char(9) as employeeid
,pn.lname ::varchar(26) as lname
,pn.fname ::varchar(19) as fname
,pn.mname ::char(1) as mname
,ppch.phoneno ::varchar(19) as homephone
,ppcm.phoneno ::varchar(19) as mobilephone
,pa.streetaddress ::varchar(36) as addr1
,pa.streetaddress2 ::varchar(36) as addr2
,pa.city ::varchar(20) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(9) as zip
,pa.countrycode ::varchar(3) as country
,'1' ::char(1) as reimburse_method
,coalesce(pncw.url,pnch.url) ::varchar(100) as email
,case when pe.emplstatus = 'T' then '5' 
      when pe.emplstatus = 'A' then '2' end ::char(1) as employee_status 
,case when pv.gendercode = 'F' then '2'
      when pv.gendercode = 'M' then '1' else '0' end ::char(1) as gender
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob
,pi.identity ::char(9) as ssn
,'99991231'::char(8) as plan_year_start_date    

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_timestamp between pe.createts and pe.endts
 and current_date between pe.effectivedate and pe.enddate
 
left join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'T'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

 left join comp_plan_plan_year cppy 
  on cppy.compplanid = pbe.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and ?::date between cppy.planyearstart and cppy.planyearend
                          
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
left join person_phone_contacts ppcb
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'      
left join person_phone_contacts ppcm
  on ppcm.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'  
  

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts 
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts  
LEFT JOIN person_net_contacts pnco
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.endts   
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --ee must have elected coverage in current plan year and recently terminated enrollment
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts --and personid = '216'
                          and benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
  and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )  


  UNION -----------------------------------------------------------------------------------------------------------------------------------
  
select
 pi.personid ::int
,'TERMED EE' ::varchar(30) as qsource
,'IB' ::char(2) as recordtype
,'IHS' ::varchar(6) as tpaid
,'IHSSBS' ::varchar(9) as employerid
,pi.identity ::char(9) as employeeid
,pn.lname ::varchar(26) as lname
,pn.fname ::varchar(19) as fname
,pn.mname ::char(1) as mname
,ppch.phoneno ::varchar(19) as homephone
,ppcm.phoneno ::varchar(19) as mobilephone
,pa.streetaddress ::varchar(36) as addr1
,pa.streetaddress2 ::varchar(36) as addr2
,pa.city ::varchar(20) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(9) as zip
,pa.countrycode ::varchar(3) as country
,'1' ::char(1) as reimburse_method
,coalesce(pncw.url,pnch.url) ::varchar(100) as email
,'5' ::char(1) as employee_status 
,case when pv.gendercode = 'F' then '2'
      when pv.gendercode = 'M' then '1' else '0' end ::char(1) as gender
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob
,pi.identity ::char(9) as ssn
,'99991231'::char(8) as plan_year_start_date        

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and pe.effectivedate < pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'T'
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

 left join comp_plan_plan_year cppy 
  on cppy.compplanid = pbe.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and ?::date between cppy.planyearstart and cppy.planyearend

left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
left join person_phone_contacts ppcb
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'      
left join person_phone_contacts ppcm
  on ppcm.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'  
  

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts 
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts  
LEFT JOIN person_net_contacts pnco
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.endts   
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus <> 'A'
  and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
 
  UNION -----------------------------------------------------------------------------------------------------------------------------------

select
 pi.personid ::int
,'NEW EE' ::varchar(30) as qsource
,'IB' ::char(2) as recordtype
,'IHS' ::varchar(6) as tpaid
,'IHSSBS' ::varchar(9) as employerid
,pi.identity ::char(9) as employeeid
,pn.lname ::varchar(26) as lname
,pn.fname ::varchar(19) as fname
,pn.mname ::char(1) as mname
,ppch.phoneno ::varchar(19) as homephone
,ppcm.phoneno ::varchar(19) as mobilephone
,pa.streetaddress ::varchar(36) as addr1
,pa.streetaddress2 ::varchar(36) as addr2
,pa.city ::varchar(20) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(9) as zip
,pa.countrycode ::varchar(3) as country
,'1' ::char(1) as reimburse_method
,coalesce(pncw.url,pnch.url) ::varchar(100) as email
,'1' ::char(1) as employee_status  	-- Need to pull absolutely new enrollments for type 1 data
,case when pv.gendercode = 'F' then '2'
      when pv.gendercode = 'M' then '1' else '0' end ::char(1) as gender
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob
,pi.identity ::char(9) as ssn
,'99991231'::char(8) as plan_year_start_date   


from person_identity pi

left join person_employment pe
  on pe.personid = pi.personid
 and pe.effectivedate < pe.enddate
 and current_timestamp between pe.createts and pe.endts

-- Pulls the max effectivedate within the specified plan year
-- Used benefitelection = 'E' filter in where clause to avoid pulling false positives (Elections were populating that are currently waived/termed, but had 'E' status within the plan year)
left join (select pbe.personid,pbe.benefitsubclass,pbe.benefitelection,pbe.selectedoption,pbe.eventdate,pbe.benefitplanid,pbe.benefitcoverageid,pbe.compplanid,
max(pbe.effectivedate) as effectivedate,max(pbe.enddate) as enddate,max(pbe.createts) as createts,
rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
from person_bene_election pbe
left join comp_plan_plan_year cppy 
  on cppy.compplanid = pbe.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and ?::date between cppy.planyearstart and cppy.planyearend
 where effectivedate < enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y'
 and pbe.effectivedate between cppy.planyearstart and cppy.planyearend
 group by 1,2,3,4,5,6,7,8) pbe on pbe.personid = pe.personid and pbe.rank = 1

 and pbe.personid in 

 -- Logic to get NPM's since the last update and restrict them to the current plan year. They will become Active EE when the effectivedate < lastupdatets
(select distinct effcovdate.personid
       from (select pbe.personid,pbe.benefitsubclass,pbe.compplanid, min(pbe.createts) as createts, min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
             from person_bene_election pbe 
             where pbe.benefitsubclass in ('60','61') and pbe.effectivedate < pbe.enddate and current_timestamp between pbe.createts and pbe.endts
               and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' 
             group by 1,2,3 order by 1) effcovdate
       left join edi.edi_last_update elu on elu.feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'
	   left join comp_plan_plan_year cppy on cppy.compplanid = effcovdate.compplanid
	     and cppy.compplanplanyeartype = 'Bene'
 	     and ?::date between cppy.planyearstart and cppy.planyearend
       where effcovdate.min_effectivedate = effcovdate.max_effectivedate
         and effcovdate.max_effectivedate between cppy.planyearstart and cppy.planyearend 
         and (effcovdate.max_effectivedate >= elu.lastupdatets::DATE 
   	       or (effcovdate.createts > elu.lastupdatets and effcovdate.max_effectivedate < coalesce(elu.lastupdatets, '2017-01-01'))))

left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
left join person_phone_contacts ppcb
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'      
left join person_phone_contacts ppcm
  on ppcm.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'  
  

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts 
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts  
LEFT JOIN person_net_contacts pnco
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.endts   
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('T','R')
  and pbe.benefitelection in ('E') 
  
order by personid, lname, plan_year_start_date ASC, employeeid
