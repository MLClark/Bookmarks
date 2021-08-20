select distinct
 pi.personid 
,'emp dental data'::varchar(30) as qsource   
,'E' ::char(1) as transcode
---- start dental 11 columns 267 - 329
,'D ' ::char(2) as d_covcode
,to_char(pbe.effectivedate,'MMDDYYYY') ::char(8) as d_cov_start
,case when pbe.benefitelection = 'T' then to_char(pbe.effectivedate,'MMDDYYYY') 
      when pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY')
      else ' ' end ::char(8) as d_cov_end
,'5923955' ::char(7) as d_grp_nbr
,'0001' ::char(4) as d_sub_cd
,'0001' ::char(4) as d_branch
,pae.stateprovincecode ::char(2) as d_plan_cd
,pe.emplstatus ::char(1) ::char(1) as d_status
,bcd.benefitcoveragedesc
,pbe.benefitcoverageid
,case when bcd.benefitcoveragedesc = 'Employee Only' then '1'
      when bcd.benefitcoveragedesc in ('EE & 1 Dep or More','Employee + Children') then '2' 
      when bcd.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when bcd.benefitcoveragedesc in ('EE & Child(ren) + D/P Adult','EE&1+DPAdult &/or DPChild(ren)','EE&2+DPAdult &/or DPChild(ren)','EE&Child(ren) + DP Adult&DP Ch','Family') then '4'
      else ' ' end ::char(1) AS d_mbrs_covered
,' ' ::char(2) as d_cancel_rsn
,' ' ::char(1) as d_filler_306
,' ' ::char(8) as d_facility_id
,' ' ::char(15) as d_filler_315_329



from person_identity pi

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_address pae 
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('11')
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y' 
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid
 AND current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('A','R')--- A and R only valid coverage codes for this vendor's feed
  order by 1
  ;
  
  