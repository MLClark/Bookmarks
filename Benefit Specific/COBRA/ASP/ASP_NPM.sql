select distinct

/*
The NPM file for COBRA should only include an employee that goes on one of COBRA eligible plans 
(Medical, Dental, Vision, HRA, Medical FSA) either as a new employee, new spouse of a covered employee or 
employee electing coverage for the first time at Open Enrollment. 
Do not provide information for anyone that is a new hire but not taking benefits or any information about dependents.
*/


 '[NPM]' ::char(5) as npm
,pi.identity ::char(9) as SSN
,' ' ::char(1) as indv_id
,'"Chef Works, Inc."' ::char(18) as client_name
,'"Chef Works, Inc."' ::char(18) as client_division_name
,rtrim(pne.fname) ::varchar(50) as fname
,pne.mname ::char(1) as mname
,pne.lname ::varchar(50) as lname
,pne.title ::varchar(35) as salutation
,rtrim(ltrim(pncw.url)) ::varchar(100) as email   
,ppcW.phoneno ::char(15) as phone
,' ' ::char(1) as phone2
,pae.streetaddress ::varchar(50) as addr1
,pae.streetaddress2 ::varchar(50) as addr2
,pae.city ::varchar(50) as city
,pae.stateprovincecode ::char(2) as state
,pae.postalcode ::varchar(35) as zip
,pae.countrycode ::varchar(50) as country
,pve.gendercode ::char(1) as gender
,'F' ::char(1) as usesfamilyinaddr
,'F' ::char(1)  as haswaivedallcovg
,'T' ::char(1)  as sendgrnotice



FROM person_identity pi
LEFT join edi.edi_last_update elu 
  on elu.feedid = 'ASP_SHDR_COBRA_NPM_Export'

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and benefitelection = 'E' 
 and selectedoption = 'Y' 
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
--and benefitsubclass in ('60','61')

JOIN comp_plan_benefit_plan cpbp 
  on cpbp.compplanid = pbe.compplanid 
 and pbe.benefitsubclass = cpbp.benefitsubclass 
 AND current_date between cpbp.effectivedate AND cpbp.enddate 
 AND current_timestamp between cpbp.createts AND cpbp.endts

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 --and pe.effectivedate >= elu.lastupdatets
 and pe.emplstatus in ('A')

left join edi.ediemployeebenefit eeb
  on eeb.personid = pbe.personid
 and current_date = eeb.asofdate
 and eeb.benefitsubclass = pbe.benefitsubclass  

LEFT JOIN person_identity piE 
  ON pi.personid = piE.personid 
 AND piE.identitytype = 'EmpNo' 
 AND current_timestamp between piE.createts AND piE.endts
 
LEFT JOIN person_identity piP
  ON pi.personid = piP.personid 
 AND piP.identitytype = 'PSPID' 
 AND current_timestamp between piP.createts AND piP.endts 
 
 
left JOIN edi.etl_employment_data ed 
  ON ed.personid = pi.personid AND ed.EMPLSTATUS in ('A') 
  
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


left JOIN person_employment pe_end
  ON pe_end.personid = pi.personid 
 and pe_end.enddate < '2199-12-31'

left join pers_pos pp on pp.personid = pi.personid
 and pp.enddate = pe_end.enddate

left join pos_org_rel por
  on por.positionid = pp.positionid

left join organization_code oc
  on oc.organizationid = por.organizationid  


WHERE pi.identitytype = 'SSN' 
  and cpbp.cobraplan = 'Y'
  and pbe.effectivedate > elu.lastupdatets 


--and pi.personid in ('1917', '1928','1966', '1982','1926')

order by 1,2
