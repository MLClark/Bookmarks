select distinct
 pi.personid 
,pdr.dependentid 
,'D' ::char(1) as transcode
,'5930557' ::char(7) as custnbr
,pi.identity ::char(11) as empnbr
,' ' ::char(11) as filler11
,pid.identity ::char(9) as member_ssn 

,pnd.lname ::char(20) as member_lname
,pnd.fname ::char(12) as member_fname
,pnd.mname ::char(1)  as member_mi

,to_char(pvd.birthdate, 'MMDDYYYY')::char(8) as member_dob

,case when pmsd.maritalstatus = 'M' then 'M' 
      when pmsd.maritalstatus = 'S' then 'S' else 'U' end ::char(1) as member_maritalstatus

,pvd.gendercode ::char(1) as member_gender
,pdr.dependentrelationship 
,case when pdr.dependentrelationship in ('SP','NA','DP') then '01'
      when pdr.dependentrelationship in ('D','C','QC','S') then '02' end ::char(2) as member_relcode

,' ' ::char(8) as emp_doh
,' ' ::char(11) as personnel_id
,' ' ::char(1) as emp_smoker
,case when pdr.dependentrelationship = 'SP' and pvd.smoker = 'Y' then 'S' else 'N' end ::char(1) spouse_smoker

,' ' ::char(22) as filler22

,' ' ::char(1) as esurvivor
,' ' ::char(9) as e_suvivor_ssn
,' ' ::char(20) as esurvivor_lname
,' ' ::char(12) as esurvivor_fname
,' ' ::char(1) as eforeign_addr_ind

,' ' ::char(32) as ecareof
,' ' ::char(32) as eaddr
,' ' ::char(21) as ecity
,' ' ::char(2) as estate
,' ' ::char(9) as ezip

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
 and pbe.benefitsubclass in ('11','16','14','17')
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

left join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.personid = pi.personid
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
 
left join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnE.createts and pnD.endts
 and pnD.nametype = 'Dep'
 
left join person_vitals pvD
  on pvD.personid = pdr.dependentid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  

left join person_maritalstatus pmsd
  on pmsd.personid = pdr.dependentid
 and current_date between pmsd.effectivedate and pmsd.enddate
 and current_timestamp between pmsd.createts and pmsd.endts
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and de.selectedoption = 'Y'
  and de.benefitsubclass in ('11','16','14','17')  
  and pdr.dependentid is not null
  --and pi.personid = '4705'
  order by 1
  ;
  
  