select distinct
 pi.personid 
,'E' ::char(1) as transcode
---- start vision 14,17
,case when pbe.benefitsubclass in ('14','17') then 'VV' else ' ' end ::char(2) as vsn_covcode
,case when pbe.benefitsubclass in ('14','17') then to_char(pbe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as vsn_cov_start
,case when pbe.benefitsubclass in ('14','17') then to_char(pbe.enddate,'MMDDYYYY') else ' ' end ::char(8) as vsn_cov_end
,case when pbe.benefitsubclass in ('14','17') then '5930557' else ' ' end ::char(7) as vsn_grp_nbr
,case when pbe.benefitsubclass in ('14','17') then '0001' else ' ' end  ::char(4) as vsn_sub_cd
,case when pbe.benefitsubclass in ('14','17') and cpbp.cobraplan = 'Y' and pe.emplstatus <> 'A' then '1100' 
      when pbe.benefitsubclass in ('14','17') then '0001' else ' ' end ::char(4) as vsn_branch
,' ' ::char(1) as filler5
,case when pbe.benefitsubclass in ('11','16') and pbe.benefitelection = 'E' then 'A' 
      when pbe.benefitsubclass in ('11','16') and pbe.benefitelection = 'R' then 'R'
      else 'A' end ::char(1) as vsn_status
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
 and pbe.benefitsubclass in ('14','17')
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
  --and pi.personid in ('1004')
  and pbe.benefitsubclass in ('14','17')  
  order by 1
  ;
  
  