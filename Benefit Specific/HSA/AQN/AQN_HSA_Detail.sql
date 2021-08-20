select distinct
 pi.personid
,'B' ::char(1) as record_type
,'HB905714' ::char(9) as er_grp_nbr
,case when pe.emplstatus = 'T' then '3' else '1' end ::char(1) as status_field
,pi.identity ::char(9) as essn
,pne.fname ::char(18) as efname
,pne.mname ::char(1) as emname
,pne.lname ::char(18) as elname
,pae.streetaddress ::varchar(30) as eaddr1
,pae.streetaddress2 ::varchar(20) as eaddr2
,pae.city ::char(22) as ecity
,pae.stateprovincecode ::char(2) as estate
,pae.postalcode ::char(9) as ezip
,to_char(pe.empllasthiredate,'YYYYMMDD')::char(8) as emp_doh
,coalesce(ppcM.phoneno,ppcH.phoneno) ::char(10) as homephone
,ppcW.phoneno ::char(10) as workphone
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(60)  AS EMPLOYEE_EMAIL
,piE.identity ::char(17) as employeenbr
,'I' ::char(1) as cov_type
,' ' ::char(8) as HDHP_start_date
,case when pe.emplstatus = 'T' then to_char(pe.enddate,'YYYYMMDD')else null end  ::char(8) as termdate
,'Y' ::char(1) as HSA_affirmation
,pae.streetaddress ::varchar(30) as mailing_addr1
,pae.streetaddress2 ::varchar(20) as mailing_addr2
,pae.city ::char(22) as mailing_city
,pae.stateprovincecode ::char(2) as mailing_state
,pae.postalcode ::char(9) as mailing_zip
,'MC ' ::char(3) as card_type
,' ' ::char(206) as filler206
,'N' ::char(1) as wet_signature
,'N' ::char(1) as e_sign_id
,' ' ::char(10) as verif_id
,' ' ::char(16) as sub_grp_id
,' ' ::char(9) as filler9
,' ' ::char(7) as filler7


from person_identity pi

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_identity piE
  on piE.personid = pi.personid
 and current_timestamp between piE.createts and piE.endts
 and piE.identitytype = 'EmpNo'  
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('6Z')
 and benefitelection = 'E' 
 and selectedoption = 'Y' 
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts 

left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'  
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts

left join person_address pae
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts   

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts

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
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts


