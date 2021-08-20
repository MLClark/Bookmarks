SELECT distinct
-- QB record type 3 - Benefit Plan Assignment 
-- adding the sort_seq to sort each record based on sort order of other record types.

---- premium amounts are listed in fields 43-47. 
--  FSA total monthly contribution should appear in field 43 only (not payroll deductions). Please remove all other premiums from the report 
 pip.personid
,pe.effectivedate
,pe.emplstatus
,piS.identity AS e_ssn_001
,case when ppd.etv_id = 'VBA' then 60 end as sort_seq
,ppd.etv_id 
,cast(ppd.etv_amount as dec (18,2))





from person_identity pip
join edi.edi_last_update elu 
  on elu.feedid = 'AOL_COBRASimple_QB_Export'
  
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
  ON pe.personid = pip.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 and pe.effectivedate >= elu.lastupdatets
 and pe.emplstatus in ('T','R')


where pip.identitytype = 'PSPID'
  and current_timestamp between pip.createts and pip.endts
  and ppd.etv_id in ('VBA')
  and cpbp.cobraplan = 'Y'
 

order by 1,2,3
;