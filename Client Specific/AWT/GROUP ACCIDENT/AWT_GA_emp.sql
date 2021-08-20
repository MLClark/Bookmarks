---- accident for awt employee
select distinct
 pi.personid
--,'00' ::char(2) as dependentid
,'01' ::char(2) as record_type
,replace(pi.identity,'-','') ::char(9) as essn
,' ' ::char(1) as person_unique_id
,'Y' ::char(1) as is_proposed_insured
,'Y' ::char(1) as is_employee
,'Y' ::char(1) as is_policy_owner
,'N' ::char(1) as is_dependent
,'N' ::char(1) as is_beneficiary
,' ' ::char(1) as beneficiary_type
,' ' ::char(1) as beneficiary_pct
,'14' ::char(2) as rel_to_prime_insd
,'14' ::char(2) as rel_to_emp
,pne.lname ::varchar(35) as last_name
,pne.fname ::varchar(35) as first_name
,pne.mname ::char(1) as mi
,replace(pi.identity,'-','') ::char(9) as person_ssn
,pve.gendercode ::char(1) as gender
,to_char(pve.birthdate,'YYYYMMDD') ::char(8) as dob
,' ' ::char(1) as home_number
,' ' ::char(1) as marital_status
,' ' ::char(1) as height
,' ' ::char(1) as weight
,pae.streetaddress ::varchar(71) as street_address
,pae.city ::varchar(20) as city
,pae.stateprovincecode ::char(2) as state
,pae.postalcode ::char(5) as zip
,'EPOCH Senior Living' ::varchar(35) as employer_name
,to_char(pe.effectivedate,'YYYYMMDD') ::char(8) as doh
,' ' ::char(1) as rehire_date
,' ' ::char(1) as plant
,'Y' ::char(1) as active_at_work
,' ' ::char(1) as rsn_not_active
,' ' ::char(1) as emp_id
,' ' ::char(1) as annual_salary
,' ' ::char(1) as occupation
,' ' ::char(1) as job_title
,' ' ::char(1) as email
,' ' ::char(1) as remarks
,' ' ::char(1) as plan_code1
,' ' ::char(1) as plan_code2
,' ' ::char(1) as plan_code3
,' ' ::char(1) as plan_code4
,' ' ::char(1) as plan_code5
,' ' ::char(1) as plan_code6
,' ' ::char(1) as plan_code7
,' ' ::char(1) as plan_code8
,' ' ::char(1) as plan_code9
,' ' ::char(1) as plan_code10
,'1' ::char(1) as sort_seq

from person_identity pi

join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.effectivedate - interval '1 day' <> pbe.enddate
 and pbe.benefitsubclass in ('13')   
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T', 'E' )

left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts
 and pne.effectivedate - interval '1 day' <> pne.enddate
 
left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts 
 and pve.effectivedate - interval '1 day' <> pve.enddate

left join person_address pae
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts
 and pae.effectivedate - interval '1 day' <> pae.enddate
 
left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 and pe.effectivedate - interval '1 day' <> pe.enddate
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 