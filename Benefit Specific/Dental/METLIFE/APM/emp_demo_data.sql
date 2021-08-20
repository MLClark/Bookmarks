select distinct
-- Metlife Dental (11) Life (20) Vision (14)
 pi.personid 
,'E' ::char(1) as transcode
,'5923955' ::char(7) as custnbr 
,pbe.benefitsubclass
,pi.identity ::char(11) as empnbr
,' ' ::char(11) as filler11
,pi.identity ::char(9) as member_ssn 
,pne.lname ::char(20) as member_lname
,pne.fname ::char(12) as member_fname
,pne.mname ::char(1)  as member_mi
,to_char(pve.birthdate, 'MMDDYYYY')::char(8) as member_dob
,case when pmse.maritalstatus = 'M' then 'M' 
      when pmse.maritalstatus = 'S' then 'S' else 'U' end ::char(1) as member_maritalstatus
,pve.gendercode ::char(1) as member_gender
,'00' ::char(2) as member_relcode
,to_char(pe.empllasthiredate,'MMDDYYYY') ::char(8) as emp_doh
,' ' ::char(11) as personnel_id
,case when pve.smoker = 'Y' then 'S' else 'N' end ::char(1) as emp_smoker
,case when pdr.dependentrelationship = 'SP' and pvd.smoker = 'Y' then 'S' else 'N' end ::char(1) spouse_smoker
,' ' ::char(22) as filler22
,case when pe.emplstatus = 'D' then 'S' else ' ' ::char(1) end as esurvivor
,case when pe.emplstatus = 'D' then piDep.identity else ' ' end ::char(9) as e_suvivor_ssn
,case when pe.emplstatus = 'D' then pnD.lname else ' ' end ::char(20) as esurvivor_lname
,case when pe.emplstatus = 'D' then pnD.fname else ' ' end ::char(12) as esurvivor_fname
,case when pae.countrycode = 'US' then 'D' else 'F' end ::char(1) as eforeign_addr_ind
,rtrim(pne.fname|| ' ' || pne.lname) ::char(32) as ecareof
,pae.streetaddress ::char(32) as eaddr
,pae.city ::char(21) as ecity
,pae.stateprovincecode ::char(2) as estate
,replace(pae.postalcode,'-','') ::char(9) as ezip
       

from person_identity pi

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

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
 
LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_address pae 
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts
 
left join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('11','14','20')
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'
 


left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid
 AND current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts
 
left join comp_plan_benefit_plan cpbp 
 on cpbp.compplanid = pbe.compplanid 
and cpbp.benefitsubclass = pbe.benefitsubclass
AND current_date between cpbp.effectivedate AND cpbp.enddate 
AND current_timestamp between cpbp.createts AND cpbp.endts  

----- dependent data

left join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and pdr.dependentrelationship in ('D','C','DP','SP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

left join person_identity piDep
  on piDep.personid = pdr.dependentid
 and piDep.identitytype = 'SSN'
 and current_timestamp between piDep.createts and piDep.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnE.createts and pnD.endts
 and pnD.nametype = 'Dep'
 
left join person_vitals pvD
  on pvD.personid = piDep.personid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  

left join person_maritalstatus pmsd
  on pmsd.personid = pdr.dependentid
 and current_date between pmsd.effectivedate and pmsd.enddate
 and current_timestamp between pmsd.createts and pmsd.endts
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.benefitelection = 'E'
  and pbe.selectedoption = 'Y'
  and pbe.benefitsubclass in ('11','14','20')
  --nd pi.personid in ('1266','1205','719','998')
  --and pi.personid in ('1004')
  order by 1
  ;
  
  