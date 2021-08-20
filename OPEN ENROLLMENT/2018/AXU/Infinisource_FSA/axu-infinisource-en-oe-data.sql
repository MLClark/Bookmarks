select --distinct
 pi.personid
,'4A1032' :: char(6) as employer_code
,'EN' ::char(2) as record_type
,pi.identity :: char(9) as emp_ssn
,case when pbe.benefitsubclass = '60' then 'Health Care FSA' 
      when pbe.benefitsubclass = '61' then 'Dependent Care FSA'
 end :: char(35) as plan_name 
       
,to_char(pbe.effectivedate,'MMDDYYYY') ::char(8) as enroll_effective_date
,case when poc.employeerate > 0 then to_char(poc.employeerate,'9999D99') end :: char(8)as part_election_amt
,case when pe.emplclass = 'P' then to_char(pbe.effectivedate,'MMDDYYYY') else ' ' end ::char(8) as enroll_term_date
,null ::char(10) as employer_contrib_lvl
,case when poc.employercost > 0 then to_char(poc.employercost ,'9999D99') end :: char(8) as employer_contrib_amt
,'Debit Card' ::char(30) as primary_reimb
,null ::char(30) as alt_reimb
,null :: char(1) as enrolled_claims_exchng
,'Plan Year' :: char(20) as elec_amt_ind --
,null :: char(6) as HDHP_cov_level
,null :: char(8) as plan_yr_start_date
,null :: char(1) as termsand_condi_accepted
,null :: char(8) as date_term_condi_accepted
,null :: char(6) as time_termscondi_accepted
,null :: char(8) as change_date
,null :: char(1) as spend_down
,'2' as sort_seq

from person_identity pi

JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass in ('60', '61' )
 AND current_timestamp BETWEEN pbe.createts AND pbe.endts

LEFT JOIN personbenoptioncostl poc 
  ON poc.personid              = pbe.personid
 AND poc.personbeneelectionpid = pbe.personbeneelectionpid
 AND poc.costsby = 'P'

left join public.person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts

where pi.identitytype = 'SSN'
   and current_timestamp between pi.createts and pi.endts and pe.personid = '922'
   and case when ? = 'OE' then pbe.benefitelection =  'E' and pbe.effectivedate >= date_trunc('year', current_date + interval '1 year') and pbe.enddate >= '2199-12-30'
            when ? = 'FF' then pbe.benefitelection <> 'W' and current_date between pbe.effectivedate and pbe.enddate AND pbe.benefitelection IN ('T','E') AND pbe.enddate = '2199-12-31' and poc.employeerate <> 0
            end   