SELECT distinct  
 pi.personid
,'000000000' ::char(12) as dependentid
,'TERMED EE' ::varchar(30) as qsource  
,'[QB]' :: varchar(35) as recordtype
,'Epoch Senior Living LLC 31753'  ::varchar(100) as client_name
,'Epoch Senior Living LLC' ::varchar(50) as client_division_name
,' ' ::char(1) as salutation
,case when pe.emplevent = 'InvTerm' and pe.empleventdetcode = 'Death' then coalesce(pnd.fname,pnd.fname) else pne.fname end ::varchar(50) as fname
,case when pe.emplevent = 'InvTerm' and pe.empleventdetcode = 'Death' then coalesce(pnd.mname,pne.mname) else pne.mname end ::char(1) as mname
,case when pe.emplevent = 'InvTerm' and pe.empleventdetcode = 'Death' then coalesce(pnd.lname,pne.lname) else pne.lname end  ::varchar(50) as lname
,case when pe.emplevent = 'InvTerm' and pe.empleventdetcode = 'Death' then coalesce(pid.identity,pi.identity) else pi.identity end ::char(9) as SSN
,' ' ::char(1) as indv_id

,rtrim(ltrim(pncw.url)) ::varchar(100) as email 
,ppcW.phoneno ::char(15) as phone
,' ' ::char(1) as phone2
,pae.streetaddress ::varchar(50) as addr1
,pae.streetaddress2 ::varchar(50) as addr2
,pae.city ::varchar(50) as city
,pae.stateprovincecode ::char(2) as state
,pae.postalcode ::varchar(35) as zip
,case when pae.countrycode = 'US' then ' ' else pae.countrycode end ::varchar(50) as country

,'T' ::char(1) as PremiumAddressSameAsPrimary
,' ' ::char(1) as PremiumAddress1
,' ' ::char(1) as PremiumAddress2
,' ' ::char(1) as PremiumCity
,' ' ::char(1) as PremiumState
,' ' ::char(1) as PremiumZip
,' ' ::char(1) as PremiumCountry

,pve.gendercode ::char(1) as gender
,to_char(pve.birthdate, 'MM/dd/YYYY')::char(10) as dob
,case when pve.smoker = 'Y' then 'YES'
      when pve.smoker = 'N' then 'NO'
      else 'UNKNOWN' end ::varchar(35) as smoker
,CASE pe.emplclass 
      WHEN 'F' THEN 'FTE'
      WHEN 'P' THEN 'PTE'
      ELSE 'UNKNOWN' end ::varchar(35) as employeetype
,pd.flsacode      
,case when pd.flsacode = 'E' then 'EXEMPT'
      when pd.flsacode = 'N' then 'NONEXEMPT'
      ELSE 'UNKNOWN' end ::varchar(35) as EmployeePayrollType
,' ' ::char(1) as years_of_service
,'COUPONBOOK' ::varchar(35) AS PremiumCouponType    
,'F' ::char(1) as UsesHCTC
,'T' ::char(1) as active
,'F' ::char(1) as allow_member_sso
,' ' ::char(1) as benefitgroup
,' ' ::char(1) as account_structure
,' ' ::char(1) as client_specific_data
,'1A' ::char(10) as sort_seq


FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

left join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11','60','61')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
  
LEFT JOIN person_identity piE 
  ON pi.personid = piE.personid 
 AND piE.identitytype = 'EmpNo' 
 AND current_timestamp between piE.createts AND piE.endts
 
LEFT JOIN person_identity piP
  ON pi.personid = piP.personid 
 AND piP.identitytype = 'PSPID' 
 AND current_timestamp between piP.createts AND piP.endts 
  
LEFT JOIN person_names pne 
  ON pne.personid = pi.personid 
 AND pne.nametype = 'Legal'::bpchar 
 AND current_date between pne.effectivedate AND pne.enddate 
 AND current_timestamp between pne.createts AND pne.endts
 
LEFT JOIN person_address pae 
  ON pae.personid = pi.personid 
 AND pae.addresstype = 'Res'::bpchar 
 AND current_date between pae.effectivedate AND pae.enddate 
 AND current_timestamp between pae.createts AND pae.endts

LEFT JOIN person_phone_contacts ppch 
 ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'
LEFT JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'   
LEFT JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'      
LEFT JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'  
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.enddate 

 
LEFT JOIN person_vitals pvE 
  ON pvE.personid = pi.personid 
 AND current_date between pvE.effectivedate AND pvE.enddate 
 AND current_timestamp between pvE.createts AND pvE.endts


----------------------------------------------
left join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and pdr.dependentrelationship in ('SP','DP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 
left join person_names pnd
  on pnd.personid = pdr.dependentid
 and pnd.nametype = 'Dep'
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts
 
left join person_identity pid
  on pid.personid = pdr.dependentid
 and pid.identitytype = 'SSN'
 and current_date between pid.createts and pid.endts

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )
  and pe.emplstatus in ('R','T')
  and pi.personid = '7203'