SELECT distinct
-- QB record type 3 - Benefit Plan Assignment 
 pip.personid
,piS.identity AS e_ssn_001

,' ' ::char(1) AS e_addr2_041

,' ' ::char(1) as t1_eligible_for_medicaid_042
,'0' as t3_amt_paid_for_flex_bene_plan_043
,ppd.etv_id 
,ppd.etv_amount as t3_cover_amt_058
,' ' ::char(1) as doh_059
,' ' ::char(1) as t2_ind_id_060
,'F' ::char(1) as t1_include_fam_in_addr_098
,'F' ::char(1) as t1_ARRA_stimulous_180
,'F' ::char(1) as t1_print_and_dependents



from person_identity pip
join person_bene_election pbe
  on pbe.personid = pip.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','60','61')
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
  and pip.personid in ('1917', '1928','1966', '1982','1926')
  and ppd.etv_id in ('VBA','VBB','VBC','VBD','VBE')
  and cpbp.cobraplan = 'Y'
 

order by 1,2
-- 476

