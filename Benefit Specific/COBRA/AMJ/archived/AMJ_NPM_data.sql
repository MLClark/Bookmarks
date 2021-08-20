select distinct

 pi.personid
,pe.effectivedate 
,pe.emplstatus
,'[NPM]' ::char(5) as npm
,replace(pi.identity,'-','') ::char(9) as emp_ssn 
,' ' ::char(1) as individual_identifier 
,'"Cresa Global, Inc"'  ::varchar(20) as client_name
,'"Cresa Global, Inc"'  ::varchar(20) as client_division_name
,pn.fname ::varchar(50) as fname
,pn.mname ::char(1) as mname
,pn.lname ::varchar(50) as lname
,pn.title ::varchar(35) as title
,pncw.url ::varchar(100) as email 
,replace(ppcw.phoneno,'-','') ::char(10) as phone
,replace(ppch.phoneno,'-','') ::char(10) as phone2
,pa.streetaddress ::varchar(50) as addr1
,pa.streetaddress2 ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(35) as zip
,case when pa.countrycode <> 'US' then pa.countrycode else ' ' end ::varchar(50)
,pv.gendercode ::char(1) as gender
,'Y' ::char(1) as uses_family_in_address
,'N' ::char(1) as waived_all_coverages
,'Y' ::char(1) as send_grn_notice
,to_char(pe.emplhiredate,'MM/DD/YYYY')::char(10) as hire_date


from person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_NPM'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','15','16','17','21','60','61')
 and pbe.benefitelection in ('T','E') 
 and pbe.selectedoption = 'Y' 
-- select benefitsubclass from comp_plan_benefit_plan where cobraplan = 'Y' group by 1;
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
 
left join person_net_contacts pncw
  on pncw.personid = pi.personid
 and pncw.netcontacttype = 'WRK'
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts

left join person_net_contacts pnch
  on pnch.personid = pi.personid
 and pnch.netcontacttype = 'HomeEmail'
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts 

left join person_phone_contacts ppcw 
  on ppcw.personid = pi.personid 
 and ppcw.phonecontacttype = 'Work'::bpchar 
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts

left join person_phone_contacts ppch
  on ppch.personid = pi.personid 
 and ppch.phonecontacttype = 'Home'::bpchar 
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and pe.effectivedate >= elu.lastupdatets::DATE 
  --and pi.personid = '748'
  ;

