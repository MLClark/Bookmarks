select distinct
 pi.personid
,'PT' ::char(2) as record_type
,pi.identity ::varchar(9) as pt_import_id
,' ' ::varchar(20) as employer_code
,' ' ::varchar(15) as employee_nbr
,rtrim(pne.lname,' ') ::varchar(30) as elname
,rtrim(pne.fname,' ') ::varchar(30) as efname
,rtrim(pne.mname,' ') ::char(1) as emname
,pve.gendercode ::char(1) as egender
,coalesce(pmse.maritalstatus,'S') ::char(1) as maritalstatus
,' ' ::char(1) as mothers_maiden_name
,to_char(pve.birthdate,'MMDDYYYY')::char(8) as dob
,pi.identity ::char(9) as essn
,pae.streetaddress ::varchar(50) as eaddr1
,pae.streetaddress2 ::varchar(50) as eaddr2
,pae.streetaddress3 ::varchar(50) as eaddr3 
,pae.streetaddress4 ::varchar(50) as eaddr4
,pae.city ::varchar(30) as ecity
,pae.stateprovincecode ::char(2) as estate
,pae.postalcode ::char(10) as ezip
,pae.countrycode ::char(2) as ecountry
,ppcH.phoneno ::char(10) as homephone
,ppcW.phoneno ::char(10) as workphone
,substring(ppcW.phoneno,11,5) ::char(5) as workphone_ext
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(50)  AS EMPLOYEE_EMAIL
,' ' ::char(1) as username
,' ' ::char(1) as password
,to_char(pe.empllasthiredate,'MMDDYYYY')::char(8) as emp_doh
,' ' ::char(1) as division
,' ' ::char(1) as hours_per_week
,case when pe.emplclass = 'F' then 'Full Time' 
      when pe.emplclass = 'P' then 'Part Time'
      else ' ' end ::char(9) as employee_class
,'Bi Weekly' ::char(9) as payroll_freq
,to_char(pc.effectivedate,'MMDDYYYY') ::char(8) as payrollfreq_effdate
,case when pe.emplstatus = 'A' then 'Active'
      when pe.emplstatus = 'T' then 'Terminated'
      when pe.emplstatus = 'C' then 'Cobra' else ' ' end ::varchar(20) as part_status
,to_char(pe.effectivedate,'MMDDYYYY') ::char(8) as status_eff_date
,' ' ::char(1) as hold_payroll_ded
,' ' ::char(1) as hold_er_contrib
,' ' ::char(1) as incur_svcs
,' ' ::char(1) as final_pay_date
,' ' ::char(1) as final_contrib_date

      
 
from person_identity pi
 
left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'  
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts
 
left join person_maritalstatus pmse
  on pmse.personid = pi.personid
 and current_date between pmse.effectivedate and pmse.enddate
 and current_timestamp between pmse.createts and pmse.endts 
 
left join person_address pae
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts
  
left JOIN person_phone_contacts ppch ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'
left JOIN person_phone_contacts ppcw ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'   
left JOIN person_phone_contacts ppcb ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'      
left JOIN person_phone_contacts ppcm ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile' 
 
left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate 
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate      
LEFT JOIN person_net_contacts pnco ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.enddate  

LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts  
 
JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass in ('60', '61' )
 AND pbe.benefitelection IN ('T','E')
 AND pbe.enddate = '2199-12-31' 
 AND current_date BETWEEN pbe.effectivedate AND pbe.enddate 
 AND current_timestamp BETWEEN pbe.createts AND pbe.endts 

 where pi.identitytype = 'SSN'
   and current_timestamp between pi.createts and pi.endts
   --and pi.personid = '1004'