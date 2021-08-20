select distinct
 pi.personid 
,'E' ::char(1) as transcode
---- start Supplimental Basic Life 21
,'OP' ::char(2) as op_covcode
,to_char(pbe.effectivedate,'MMDDYYYY') ::char(8) as op_cov_start
,case when pbe.benefitelection = 'T' then to_char(pbe.enddate,'MMDDYYYY') else ' ' end ::char(8) as op_cov_end
,'5923955' ::char(7) as op_grp_nbr
,'0001' ::char(4) as op_sub_cd
,'0001' ::char(4) as op_branch
,' ' ::char(2) as op_filler_678_679
,pe.emplstatus ::char(1) as op_status
,'1' ::char(1) AS op_mbrs_covered
,' ' ::char(10) as op_filler_682_691
,to_char(pbe.coverageamount, 'FM00000000') ::char(8) as op_annual_benefit_amt
,case when pc.frequencycode = 'H' then 'H' else 'A' end ::char(1) as op_salary_mode
,case when pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pc.compamount > 100000.00 then to_char(pc.compamount * 10,'FM0000000')
      else to_char(pc.compamount * 100,'FM0000000') end ::char(8) as op_salary_amount

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
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('21')
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y' 
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts

left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid
 AND current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts
 
left join comp_plan_benefit_plan cpbp 
 on cpbp.compplanid = pbe.compplanid 
and cpbp.benefitsubclass = pbe.benefitsubclass
AND current_date between cpbp.effectivedate AND cpbp.enddate 
AND current_timestamp between cpbp.createts AND cpbp.endts  


 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('A','R')--- A and R only valid coverage codes for this vendor's feed
  order by 1
  ;
  
  