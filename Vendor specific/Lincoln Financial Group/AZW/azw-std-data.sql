select distinct
 pi.personid
,pie.identity ::char(9) as empno 
,to_char(pbe.effectivedate,'mm/dd/yyyy')::char(10) as change_date
,' ' as dep_change_date
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date
,pn.fname ::varchar(50) as fname
,pn.lname ::varchar(50) as lname
,pn.mname ::char(1) as mname
,pi.identity ::char(9) as ssn
,pv.gendercode ::char(1) as gender
,to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as dob
,to_char(pbe.effectivedate,'mm/dd/yyyy')::char(10) as commit_date
,pd.positiontitle ::varchar(50) as occupation
,pp.scheduledhours as hours_per_week
,pc.compamount as salary_amt
,pc.frequencycode as salary_code
,to_char(pc.effectivedate,'mm/dd/yyyy')::char(10) as salary_eff_date
,pa.streetaddress ::varchar(50) as addr1
,pa.streetaddress2 ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,' ' ::char(4) as zip_plus

,ppch.phoneno ::char(14) as homephone
,ppcw.phoneno ::char(15) as workphone
,' ' as extension

,coalesce(pnc.url,pnch.url) ::varchar(100) AS email
,to_char(pe.emplhiredate,'mm/dd/yyyy')::char(10) as bene_elig_date
,to_char(pe.empllasthiredate,'mm/dd/yyyy')::char(10) as sub_date_of_elig
,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,' ::char(91) as ac_thru_do
,',,,,,,,,,,'::char(10) as basic_life_section
,',,,,,,,,,,,,,,,,,,,,,,,,' as 

 
from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('30')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection = 'E'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts 

left join person_bene_election pbestd
  on pbestd.personid = pi.personid
 and pbestd.benefitsubclass in ('30')
 and pbestd.benefitelection in ('E')
 and pbestd.selectedoption = 'Y' 
 and current_date between pbestd.effectivedate and pbestd.enddate
 and current_timestamp between pbestd.createts and pbestd.endts

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 

left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 

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
  on ppch.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'         
  
left join person_net_contacts pnc 
  on pnc.personid = pi.personid 
 and pnc.netcontacttype = 'WRK'::bpchar 
 and current_date between pnc.effectivedate and pnc.enddate
 and current_timestamp between pnc.createts and pnc.enddate 
-- select * from person_net_contacts
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate  
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 