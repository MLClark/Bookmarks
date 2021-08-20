select distinct
---- this is for spouse's NPM record
 pi.personid
,'[NPM]' ::char(5) as npm
,replace(pid.identity,'-','') ::char(9) as emp_ssn 
,replace(pi.identity,'-','') ::char(9) as individual_identifier 
,'"Strategic Link Consulting, LC"' :: varchar(100) as client_name
,'"SLC - Strategic Link Consulting"' :: varchar(50) as client_division_name
,pnd.fname ::varchar(50) as fname
,pnd.mname ::char(1) as mname
,pnd.lname ::varchar(50) as lname
,pnd.title ::varchar(35) as title
,pncw.url ::varchar(100) as email 
,replace(ppcw.phoneno,'-','') ::char(10) as phone
,replace(ppch.phoneno,'-','') ::char(10) as phone2
,pa.streetaddress ::varchar(50) as addr1
,pa.streetaddress2 ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state,pa.postalcode ::varchar(35) as zip
,case when pa.countrycode <> 'US' then pa.countrycode else ' ' end ::varchar(50) as country
,pvd.gendercode ::char(1) as gender
,'F' ::char(1) as uses_family_in_address
,'F' ::char(1) as waived_all_coverages
,'T' ::char(1) as send_grn_notice
,'2'::char(10) as sort_seq


from person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AYV_SHDR_COBRA_NPM_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','15')
 and pbe.benefitelection in ('E') 
 and pbe.selectedoption = 'Y'
 
------ dependents - for NPM pull only spouses no children

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('SP','DP') 
 
JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

JOIN person_vitals pvd
  ON pvd.personid = pdr.dependentid 
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts

JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts 

left join person_net_contacts pncw
  on pncw.personid = pdr.personid
 and pncw.netcontacttype = 'WRK'
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts

left join person_net_contacts pnch
  on pnch.personid = pdr.personid
 and pnch.netcontacttype = 'HomeEmail'
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts 

left join person_phone_contacts ppcw 
  on ppcw.personid = pdr.personid
 and ppcw.phonecontacttype = 'Work'::bpchar 
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts

left join person_phone_contacts ppch
  on ppch.personid = pdr.personid 
 and ppch.phonecontacttype = 'Home'::bpchar 
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts  

join person_address pa 
  on pa.personid = pdr.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and pbe.benefitelection in ('E') 
  ;

