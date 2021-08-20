select distinct
 pi.personid 
,'5930557' ::char(7) as custnbr
,pie.identity ::char(11) as empnbr
,' ' ::char(11) as filler01
,pi.identity ::char(9) as essn
,coalesce(pidep.identity,null) ::char(9) as dssn
,pne.lname ::char(20) as e_lname
,pne.fname ::char(12) as e_fname
,pne.mname ::char(1) as e_mname
,pnD.lname ::char(20) as D_lname
,pnD.fname ::char(12) as D_fname
,pnD.mname ::char(1) as D_mname
,to_char(pve.birthdate, 'MMDDYYYY')::char(8) as edob
,to_char(pvd.birthdate, 'MMDDYYYY')::char(8) as ddob
,pmse.maritalstatus ::char(1) as e_maritalstatus
,pmsd.maritalstatus ::char(1) as d_maritalstatus
,pve.gendercode ::char(1) as e_gender
,pvd.gendercode ::char(1) as d_gender
,'00' ::char(2) as e_relcode
,case when pdr.dependentrelationship in ('SP','NA') then '01'
      when pdr.dependentrelationship in ('D','C','DP') then '02' end ::char(2) d_relcode
,to_char(pe.empllasthiredate,'MMDDYYYY') ::char(8) as doh
,' ' ::char(11) as person_id
,case when pve.smoker = 'Y' then 'S' else 'N' end ::char(1) as e_smoker
,case when pvd.smoker = 'Y' then 'S' else 'N' end ::char(1) as D_smoker
,' ' ::char(22) as filler2
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
---- start dental 11,16
,case when pbe.benefitsubclass in ('11','16') then 'D ' else ' ' end ::char(2) as dent_covcode
,case when pbe.benefitsubclass in ('11','16') then to_char(pbe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as dent_cov_start
,case when pbe.benefitsubclass in ('11','16') then to_char(pbe.enddate,'MMDDYYYY') else ' ' end ::char(8) as dent_cov_end
,case when pbe.benefitsubclass in ('11','16') then '5930557' else ' ' end ::char(7) as dent_grp_nbr
,case when pbe.benefitsubclass in ('11','16') then '0001' else ' ' end ::char(4) as dent_sub_cd
,case when pbe.benefitsubclass in ('11','16') and cpbp.cobraplan = 'Y' and pe.emplstatus <> 'A' then '1100' 
      when pbe.benefitsubclass in ('11','16') then '0001' else ' ' end ::char(4) as dent_branch
,case when pbe.benefitsubclass in ('11','16') then pae.stateprovincecode else ' ' end ::char(2) as dent_plan_cd
,case when pbe.benefitsubclass in ('11','16') then pbe.benefitelection else ' ' end ::char(1) as dent_status
,case when pbe.benefitsubclass in ('11','16') and bcd.benefitcoveragedesc = 'Employee Only' then '1'
      when pbe.benefitsubclass in ('11','16') and bcd.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbe.benefitsubclass in ('11','16') and bcd.benefitcoveragedesc = 'Family' then '4'
      when pbe.benefitsubclass in ('11','16') and bcd.benefitcoveragedesc = 'Employee + Children' then '2' 
      when pbe.benefitsubclass in ('11','16') then '1' else ' ' end ::char(1) AS dent_mbrs_covered
,case when pbe.benefitsubclass in ('11','16') and cpbp.cobraplan = 'Y' and pe.emplstatus <> 'A' then 'CE' else ' ' end ::char(2) dent_cancel_rsn
,' ' ::char(1) as filler3
,' ' ::char(8) as dent_fac_id
,' ' ::char(15) as filler4
---- start vision 14,17
,case when pbe.benefitsubclass in ('14','17') then 'VV' else ' ' end ::char(2) as vsn_covcode
,case when pbe.benefitsubclass in ('14','17') then to_char(pbe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as vsn_cov_start
,case when pbe.benefitsubclass in ('14','17') then to_char(pbe.enddate,'MMDDYYYY') else ' ' end ::char(8) as vsn_cov_end
,case when pbe.benefitsubclass in ('14','17') then '5930557' else ' ' end ::char(7) as vsn_grp_nbr
,case when pbe.benefitsubclass in ('14','17') then '0001' else ' ' end  ::char(4) as vsn_sub_cd
,case when pbe.benefitsubclass in ('14','17') and cpbp.cobraplan = 'Y' and pe.emplstatus <> 'A' then '1100' 
      when pbe.benefitsubclass in ('14','17') then '0001' else ' ' end ::char(4) as vsn_branch
,' ' ::char(1) as filler5
,case when pbe.benefitsubclass in ('14','17') then pbe.benefitelection else ' ' end ::char(1) as vsn_status
,case when pbe.benefitsubclass in ('14','17') and bcd.benefitcoveragedesc = 'Employee Only' then '1'
      when pbe.benefitsubclass in ('14','17') and bcd.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbe.benefitsubclass in ('14','17') and bcd.benefitcoveragedesc = 'Family' then '4'
      when pbe.benefitsubclass in ('14','17') and bcd.benefitcoveragedesc = 'Employee + Children' then '2' 
      when pbe.benefitsubclass in ('14','17') then '1' else ' ' end ::char(1) AS vsn_mbrs_covered
,case when pbe.benefitsubclass in ('14','17') and cpbp.cobraplan = 'Y' and pe.emplstatus <> 'A' then 'CE' else ' ' end ::char(2) vsn_cancel_rsn
,' ' ::char(23) as filler6

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
  --nd pi.personid in ('1266','1205','719','998')
  and pi.personid in ('1004')
  order by 1
  ;
  
  