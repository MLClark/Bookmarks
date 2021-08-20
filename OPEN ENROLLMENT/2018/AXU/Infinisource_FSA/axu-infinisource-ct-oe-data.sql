SELECT distinct --
 pi.personid
,'4A1032' :: char(6) as employer_code
,'CT' :: char(2) as record_type
,pip.identity :: char(9) as participant_id
,case when pbe.benefitsubclass = '60' then 'Health Care FSA' 
      when pbe.benefitsubclass = '61' then 'Dependent Care FSA' end :: char(35) as plan_name
   
--,trim(pip.identity)::varchar(20) as trankey
,to_char(ppd.check_date, 'MMDDYYYY')::char(8) as contribution_date

,case when trim(ppd.etv_code)= 'EE' and  ppd.etv_amount IS NOT NULL then 'Payroll Deduction' 
      when trim(ppd.etv_code) =  'ER' and  ppd.etv_amount IS NOT NULL then 'Employer Contribution' end  as contribution_desc
     
,CASE WHEN poc.costsby = 'P' THEN to_char(poc.employeerate,'99999D99') END :: char(9) as contribution_amount
,case when poc.costsby = 'P' then 'Actual' end :: char(6) as amount_type

,null :: char(7) as tax_year
,null :: char(500) as  notes
,null :: char(8) as  plan_year_start
,null :: char(8) as  plan_year_end
,null :: char(20) as  last_name
,null :: char(20) as first_name
,'3' as sort_seq

from person_identity pi

left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts

JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitelection IN ('E','T')  
 AND pbe.enddate = '2199-12-31' 
 AND current_date BETWEEN pbe.effectivedate AND pbe.enddate 
 AND current_timestamp BETWEEN pbe.createts AND pbe.endts

left JOIN pspay_payment_detail ppd 
 -- on ppd.individual_key = pi.identity
 on ppd.personid = pi.personid
 and ppd.etv_id in ('VBA','VBB')  
 AND ppd.check_date  = ? 
 and ppd.individual_key = pip.identity

LEFT JOIN personbenoptioncostl poc 
  ON poc.personid = pbe.personid
 AND poc.personbeneelectionpid = pbe.personbeneelectionpid
 AND poc.costsby = 'P'--IN ('M', 'A','P')

join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts

where pi.identitytype = 'SSN'
--pi.identitytype = 'PSPID'
  and ppd.etv_id in ('VBA','VBB')
  AND pbe.benefitsubclass in ('60', '61' )
  and current_timestamp between pi.createts and pi.endts
  and pbe.benefitplanid = bpd.benefitplanid
order by 1