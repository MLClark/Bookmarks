---- ineligible dependents
SELECT distinct  
 pi.personid
,'[QB]' :: varchar(35) as recordtype
,'"Cresa Global, Inc"' :: varchar(100) as client_name
,'"Cresa Global, Inc"' :: varchar(50) as client_division_name
,null as salutation
,rtrim(ltrim(pnd.fname)) :: varchar(50) as emp_first_name
,rtrim(ltrim(pnd.mname)) :: char(1) as emp_middle_initial
,rtrim(pnd.lname) :: varchar(50) as emp_last_name
,replace(pid.identity,'-','') :: char(9) as emp_ssn
,null as indivi_id
,trim(coalesce(pncw.url,pnch.url,pnco.url)) ::varchar(100) as email
,replace(ppcw.phoneno,'-','') ::char(10) as w_phone
,coalesce(ppcm.phoneno,ppch.phoneno)::char(10) as o_phone
,rtrim(ltrim(pa.streetaddress)) :: varchar(50) as emp_address_1
,rtrim(ltrim(pa.streetaddress2)) :: varchar(50) as emp_address_2
,rtrim(ltrim(pa.city)) :: varchar(50) as emp_city
,rtrim(ltrim(pa.stateprovincecode)) :: varchar(50) as emp_state
,rtrim(ltrim(pa.postalcode))  :: varchar(35) as emp_zip
,case when pa.countrycode = 'US' then null else pa.countrycode end  :: varchar(50) as countrycode
,'T' ::char(1)   as premium_address_sameas_primary
,null as premium_address1
,null as premium_address2
,null as premium_city
,null as premium_state
,null as premium_zip
,null as premium_country
,pv.gendercode ::char(1) as gender_code
,to_char(pv.birthdate, 'MM/DD/YYYY')::char(10) as dob
,case when pv.smoker = 'Y' then 'YES'
      when pv.smoker = 'N' then 'NO' else 'UNKNOWN' end ::varchar(35) as tobacco_use
,'UNKNOWN' ::varchar(35) as employee_type
,'UNKNOWN' ::varchar(35) as employee_payroll_type
,null as years_of_service
,'COUPONBOOK' :: varchar(35) as premium_coupon_type
,'F' ::char(1) as uses_hctc
,'T' ::char(1) as active
,'F' ::char(1) as allow_member_sso
,null as benefit_group
,null as account_structure
,null as client_specific_data
,'1' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_bene_election pbe 
  on pbe.personid = pe.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E','T')
 -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','60','61') and benefitelection = 'E' and selectedoption = 'Y')

JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts

left JOIN person_address pa 
  ON pa.personid = pi.personid 
 AND pa.addresstype = 'Res'::bpchar 
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts	

left join person_vitals pv 
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 
 
LEFT JOIN person_net_contacts pncw
  ON pncw.personid = pi.personid
 AND pncw.netcontacttype = 'WRK'::bpchar
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts

LEFT JOIN person_net_contacts pncH 
  ON pncH.personid = pi.personid
 AND pncH.netcontacttype = 'HomeEmail'::bpchar
 and current_date between pncH.effectivedate and pncH.enddate
 and current_timestamp between pncH.createts and pncH.endts
	
LEFT JOIN person_net_contacts pnco 
  ON pnco.personid = pi.personid
 AND pnco.netcontacttype = 'OtherEmail'::bpchar
 and current_date between pnco.effectivedate and pnco.enddate
 and current_timestamp between pnco.createts and pnco.endts

LEFT JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid 
 AND ppcw.phonecontacttype = 'Work'::bpchar 
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts

LEFT JOIN person_phone_contacts ppch 
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home'::bpchar 
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts
 
LEFT JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid 
 AND ppcm.phonecontacttype = 'Mobile'::bpchar 
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts
 
join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 --and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('C','S','D')
 
LEFT JOIN person_vitals pvd
  ON pvd.personid = pdr.dependentid 
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts

 
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 --and current_date between de.effectivedate and de.enddate
 --and current_timestamp between de.createts and de.endts 
 and pvd.birthdate < de.effectivedate::date - interval '26 years'

left join person_identity pid
  on pid.personid = pdr.dependentid 
 and pid.identitytype = 'SSN'
 and current_timestamp between pid.createts and pid.endts


left JOIN person_names pnd
  ON pnd.personid = pdr.dependentid 
 AND pnd.nametype = 'Legal'::bpchar 
 AND current_date between pnd.effectivedate AND pnd.enddate 
 AND current_timestamp between pnd.createts AND pnd.endts

 
WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
 -- and pe.emplstatus = 'A' and pvd.birthdate < current_date::date - interval '26 years'
  
  order by 1
  ;
