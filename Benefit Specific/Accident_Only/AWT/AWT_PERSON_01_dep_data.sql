---- accident for awt employee
select distinct
 pi.personid
,pdr.dependentid
--,pdr.dependentid
,'01' ::char(2) as record_type
,replace(pi.identity,'-','') ::char(9) as essn
--,case when pdr.dependentid is null then null else REPLACE(piDep.identity,'-','') end ::char(9) as person_unique_id
,' ' ::char(9) as person_unique_id
,'N' ::char(1) as is_proposed_insured
,'N' ::char(1) as is_employee
,'N' ::char(1) as is_policy_owner
,'Y' ::char(1) as is_dependent
--,b.dependentid
,case when b.dependentid is null then 'N' else 'Y' end ::char(1) as is_beneficiary
,' ' ::char(1) as beneficiary_type
,' ' ::char(1) as beneficiary_pct
---- left off here 
--,pdr.dependentrelationship

,case when pdr.dependentrelationship = 'S'  then '05'
      when pdr.dependentrelationship = 'D'  then '06'
      when pdr.dependentrelationship = 'C'  then '17'
      when pdr.dependentrelationship = 'SP' then '12'
      when pdr.dependentrelationship = 'DP' 
       and pae.stateprovincecode in ('CO','CT','DE','HI','IL','IA','ME','MD','MA','MN','NH','NJ','RI','VT','WA','DC') then '12' ELSE '35'
       END ::char(2) as rel_to_prime_insd
,case when pdr.dependentrelationship = 'S'  then '05'
      when pdr.dependentrelationship = 'D'  then '06'
      when pdr.dependentrelationship = 'C'  then '17'
      when pdr.dependentrelationship = 'SP' then '12'
      when pdr.dependentrelationship = 'DP' 
       and pae.stateprovincecode in ('CO','CT','DE','HI','IL','IA','ME','MD','MA','MN','NH','NJ','RI','VT','WA','DC') then '12' ELSE '35'
       END ::char(2) as rel_to_emp
,pnD.lname ::varchar(35) as last_name
,pnD.fname ::varchar(35) as first_name
,pnD.mname ::char(1) as mi
,coalesce(replace(piDep.identity,'-',''),'000000000') ::char(9) as person_ssn
,pve.gendercode ::char(1) as gender
,to_char(pvD.birthdate,'YYYYMMDD') ::char(8) as dob
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
,'2' ::char(1) as sort_seq

from person_identity pi

join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.effectivedate - interval '1 day' <> pbe.enddate
 and pbe.benefitsubclass in ('13')   --- note 23 is for their current add - needs to be removed 13 is for allstate
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
 and pae.addresstype = 'Res'
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts
 and pae.effectivedate - interval '1 day' <> pae.enddate
  
left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 and pe.effectivedate - interval '1 day' <> pe.enddate
 
--=======================================================--

join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 and pdr.effectivedate - interval '1 day' <> pdr.enddate

join dependent_relationship dr
  on dr.dependentrelationship = pdr.dependentrelationship
 and dr.coverageequiv is not null 

join person_identity piDep
  on piDep.personid = pdr.dependentid
 and piDep.identitytype in ('BID','SSN')
 and current_timestamp between piDep.createts and piDep.endts 
 
join person_names pnD
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnE.createts and pnD.endts
 and pnD.nametype = 'Dep'
 and pnd.effectivedate - interval '1 day' <> pnd.enddate

left join beneficiary b
  on b.personid = pi.personid
 and current_date between b.effectivedate and b.enddate
 and current_timestamp between b.createts and b.endts
 and b.effectivedate - interval '1 day' <> b.enddate
 and b.benefitsubclass in 
    (select benefitsubclass from beneficiary 
      where current_date between effectivedate and enddate
        and current_timestamp between createts and endts
        and benefitsubclass in ('13')   --- note 23 is for their current add - needs to be removed 13 is for allstate
      group by 1)
 
left join person_vitals pvD
  on pvD.personid = pdr.dependentid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  
 and pvd.effectivedate - interval '1 day' <> pvd.enddate 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pdr.dependentid is not null