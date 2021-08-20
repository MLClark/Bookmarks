select distinct

 pi.personid
,'0' as dependentid
,'T' ::char(1) as transtype  
,'E' ::char(1) as record_type
,pi.identity ::char(9) as essn
,' ' ::char(9) as member_ssn
,pne.fname ::char(30)  as fname
,pne.lname ::char(50)  as lname
--,to_char(pve.birthdate, 'yyyymmdd')::char(8) as dob
,' ' ::char(8) as dob
,' ' ::char(2) as depseqnbr
,CASE bpd.benefitplancode 
     WHEN 'Med-Bronze'  THEN '30540'
     WHEN 'Med-Gold'    THEN '30541'
     WHEN 'Med-Silver'  THEN '30542'
     WHEN 'Med-Iron'    THEN '33158'
END ::char(20) as benefitplancode

,'A' ::char(1) as enrollment_type
,CASE pe.emplevent 
      WHEN 'Hire'       THEN '01'
      WHEN 'PartFull'   THEN '04'
      WHEN 'FullPart'   THEN '04'
      WHEN 'Promo'      THEN '02'
      ELSE '04'
      END ::char(2) as enrollment_reason
      
  
,to_char(pbe_eff_cov.effectivedate,'yyyymmdd') ::char(8) as coverage_eff_date
,CASE when pbe_eff_cov.enddate != '2199-12-31' then to_char(pbe_eff_cov.enddate,'yyyymmdd') else null end ::char(8) coverage_term_date
,CASE when pbe_eff_cov.benefitelection = 'E' and pe.emplstatus = 'A' then '01' 
      when pbe_eff_cov.benefitelection = 'T' and pe.emplevent = 'FullPart' then '03' 
      when pbe_eff_cov.benefitelection = 'T' and pe.emplevent = 'InvTerm' then '14' 
      when pbe_eff_cov.benefitelection = 'T' and pe.emplevent = 'VolTerm' then '02' 
      when pbe_eff_cov.benefitelection = 'T' and pe.emplevent is null then '02'
      else '01' end ::char(2) as coverage_term_rsn
,' ' ::char(20) as filler_15
,' ' ::char(30) as filler_16
,' ' ::char(20) as filler_17
,' ' ::char(8) as filler_18
,' ' ::char(9) as fsa_er_pp_contrib
,' ' ::char(9) as fsa_ee_pp_contrib
,' ' ::char(9) as mult_annual_sal
,' ' ::char(9) as elec_bene_amt
,' ' ::char(9) as ee_monthly_prem  


from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'ABD_BRMS_Ongoing_Beneft_Changes'


---- pbe_eff_cov gets effective date of coverage prior to termination

LEFT JOIN person_bene_election pbe_eff_cov  
  ON pbe_eff_cov.personid = pI.personid
 AND pbe_eff_cov.benefitsubclass = '10'
 AND pbe_eff_cov.benefitelection IN ('E')
 AND DATE_PART('YEAR',pbe_eff_cov.effectivedate) = DATE_PART('YEAR',current_date)
 and pbe_eff_cov.enddate < '2199-12-30'
 and pbe_eff_cov.effectivedate < pbe_eff_cov.enddate
 

JOIN benefit_plan_desc bpd 
  ON bpd.benefitsubclass = pbe_eff_cov.benefitsubclass 
 AND bpd.enddate = '2199-12-31' 
 AND bpd.benefitplanid = pbe_eff_cov.benefitplanid

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND CURRENT_DATE BETWEEN pe.effectivedate AND pe.enddate
 AND CURRENT_TIMESTAMP BETWEEN pe.createts AND pe.endts
    
LEFT JOIN person_names pne 
  ON pne.personid = pi.personid
 AND CURRENT_DATE BETWEEN pne.effectivedate AND pne.enddate
 AND CURRENT_TIMESTAMP BETWEEN pne.createts AND pne.endts      

JOIN person_vitals pve 
  ON pve.personid = pi.personid 
 AND CURRENT_DATE BETWEEN pve.effectivedate AND pve.enddate
 AND CURRENT_TIMESTAMP BETWEEN pve.createts AND pve.endts    



 
where pi.identitytype = 'SSN'
  AND current_timestamp between pi.createts and pi.endts
  AND pbe_eff_cov.effectivedate >= elu.lastupdatets
  
  --AND PI.PERSONID = '3530'


 
order by "transtype" desc

