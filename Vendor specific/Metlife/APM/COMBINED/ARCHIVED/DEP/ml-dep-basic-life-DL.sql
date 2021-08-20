select distinct
 pi.personid 
,pdr.dependentid 
---- start Dependent Basic Life ??
,'DL' ::char(2) as dl_covcode
,to_char(pbe.effectivedate,'MMDDYYYY') ::char(8) as dl_cov_start
,case when pbe.benefitelection = 'T' then to_char(pbe.enddate,'MMDDYYYY') else ' ' end ::char(8) as dl_cov_end
,'5923955' ::char(7) as dl_grp_nbr
,'0001' ::char(4) as dl_sub_cd
,'0001' ::char(4) as dl_branch
,' ' ::char(2) as dl_filler_615_616
,pe.emplstatus ::char(1) as dl_status
,bcd.benefitcoveragedesc
,pbe.benefitcoverageid
,'?' ::char(1) AS dl_mbrs_covered
,' ' ::char(10) as dl_filler_619_628
,to_char(pbe.coverageamount, 'FM00000000') ::char(8) as dl_annual_benefit_amt
,' ' ::char(10) as dl_filler_637_644

from person_identity pi
 
JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('??') 
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'

left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid
 AND current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 
join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.personid = pbe.personid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
  
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and de.selectedoption = 'Y'
  and pdr.dependentid is not null
  and pe.emplstatus <> 'T'
  order by 1
  ;
  
  