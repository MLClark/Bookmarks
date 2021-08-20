SELECT distinct
-- QB record type 3 - Benefit Plan Assignment 
 pip.personid
,piS.identity AS e_ssn_001
,null as filler_002
,null AS e_lname_003
,null AS e_fname_004
,null AS e_mname_005

,null as clientkey_006
,null as deptkey_007
,null as e_sex_008
,null as e_title_009
,'COVERAGE'    as e_relation_010
,null as d_ssn_011

,null as e_dob_012
,null as first_day_after_LOCdate_013
,null as cobra_event_date_014
,null as qb_event_code_015

,null AS e_addr_016
,null as e_city_017
,null as e_state_018
,null as e_zip_019

,null AS e_phone_020
,null as employeenbr_021



from person_identity pip
join person_bene_election pbe
  on pbe.personid = pip.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14')
 and pbe.benefitelection in ('T')  
 and pbe.selectedoption = 'Y'     
LEFT JOIN person_identity piS 
  ON piS.personid = piP.personid 
 AND piS.identitytype = 'SSN' 
 AND current_timestamp between piS.createts AND piS.endts 
left join benefit_plan_desc bpd 
  on bpd.benefitsubclass = pbe.benefitsubclass
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts 
left join pspay_payment_detail ppd
  on ppd.individual_key = pip.identity
 and ppd.check_date::date >= pbe.effectivedate::date

LEFT JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitsubclass 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 

JOIN comp_plan_benefit_plan cpbp 
 on cpbp.compplanid = pbe.compplanid 
and pbe.benefitsubclass = cpbp.benefitsubclass 
AND current_date between cpbp.effectivedate AND cpbp.enddate 
AND current_timestamp between cpbp.createts AND cpbp.endts
JOIN person_employment pe 
 ON pe.personid = piP.personid 
AND current_date between pe.effectivedate AND pe.enddate 
AND current_timestamp between pe.createts AND pe.endts

 
LEFT JOIN edi.edi_last_update lu on lu.feedid = 'AOL_COBRASimple_COBRA_Employee'

where pip.identitytype = 'PSPID'
  and current_timestamp between pip.createts and pip.endts
  --and pip.personid in ('1928') 
  --and pip.personid in ('1917', '1928','1966', '1982','1926')
  and ppd.etv_id in ('VBA','VBB','VBC','VBD','VBE')
  and cpbp.cobraplan = 'Y'
 

order by 1,2
-- 476

