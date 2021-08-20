select distinct
 pi.personid 
,'E' ::char(1) as transcode
---- start AD&D 21
,'AD' ::char(2) as ad_covcode
,to_char(pbe.effectivedate,'MMDDYYYY') ::char(8) as ad_cov_start
,case when pbe.benefitelection = 'T' then to_char(pbe.enddate,'MMDDYYYY') else ' ' end ::char(8) as ad_cov_end
,'5923955' ::char(7) as ad_grp_nbr
,'0001' ::char(4) as ad_sub_cd
,'0001' ::char(4) as ad_branch
,' ' ::char(2) as ad_filler_426_427
,pe.emplstatus ::char(1) as ad_status
,bcd.benefitcoveragedesc
,pbe.benefitcoverageid
,'1' ::char(1) AS ad_mbrs_covered
,' ' ::char(10) as ad_filler_430_439
,to_char(pbe.coverageamount, 'FM00000000') ::char(8) as ad_annual_benefit_amt
,case when pc.frequencycode = 'H' then 'H' else 'A' end ::char(1) as ad_salary_mode
,case when pc.frequencycode = 'H' then to_char(pc.compamount * 100,'FM0000000') 
      when pc.compamount > 100000.00 then to_char(pc.compamount * 10,'FM0000000')
      else to_char(pc.compamount * 100,'FM0000000') end ::char(8) as ad_salary_amount

from person_identity pi

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('21')
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
  