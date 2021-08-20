select distinct
 pi.personid
,'A1' as sort_seq
,'M' ::char(1) as record_type
,to_char(pbe.effectivedate,'YYYY-MM-DD')::char(10) as mbr_cov_eff_date
,rtrim(pne.lname,' ') ::char(20) as mbr_lname
,rtrim(pne.fname,' ') ::char(18) as mbr_fname
,rtrim(pne.mname,' ') ::char(01) as mbr_mname
,rtrim(pae.streetaddress,' ')  ::char(30) as addr1
,rtrim(pae.streetaddress2,' ') ::char(30) as addr2
,rtrim(pae.streetaddress3,' ') ::char(30) as addr3
,rtrim(pae.city,' ') ::char(25) as city
,rtrim(pae.stateprovincecode,' ') ::char(2) as state
,rtrim(pae.postalcode,' ') ::char(12) as zip
,pi.identity ::char(11) as mbr_nbr
,to_char(pv.birthdate,'YYYY-MM-DD') ::char(10) as dob
,coalesce(ppch.phoneno,ppcm.phoneno) ::char(10) as homephone
,ppcW.phoneno ::char(10) as workphone
,substring(ppcW.phoneno,11,5) ::char(5) as workphone_ext
/*
Group # 47554

Coverage Codes:

11 / 57 - Individual Legal = $16.95

12 / 51 - Individual IDShield = $8.95

13 / 63 - Individual Legal + Individual IDShield = $25.90

FN / 60 - Family Legal = $18.95

30 / 54 - Family IDShield = $18.95

32 / 66 - Family Legal + Family IDShield = $33.90
*/
,'47554' ::char(7) as mbr_grp_nbr

,case when pbe.benefitplanid = '57' then '11'
      when pbe.benefitplanid = '51' then '12'
      when pbe.benefitplanid = '63' then '13'
      when pbe.benefitplanid = '60' then 'FN'
      when pbe.benefitplanid = '54' then '30'
      when pbe.benefitplanid = '66' then '32' else ' ' end ::char(2) as mbr_cov_code
,pie.identity ::char(15) as empid      
,pe.emplstatus ::char(1) as activity
,rtrim(coalesce(pncw.url,pnch.url,pnco.url),null) ::varchar(50)  AS email_addr

,case when pe.emplstatus = 'T' then to_char(pe.enddate,'YYYY-MM-DD') else ' ' end ::char(10) as termdate
,case when pe.emplstatus = 'T' then 'G'
      when pe.emplstatus = 'D' then 'B' else null end ::char(1) as term_rsn
,' ' ::char(10) as billing_div_code   
,case when pc.frequencycode = 'H' then '52'
      when pc.frequencycode = 'A' then '24' else '26' end ::char(2) as mbr_pay_period

  
from person_identity pi

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpID'
 and current_timestamp between pie.createts and pie.endts
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts  

left join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'
 
left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts 

left join person_address pae
  on pae.personid = pi.personid
 and pae.addresstype = 'Res'
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts
 
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

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.benefitsubclass in ('2W')