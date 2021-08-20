/* 
3 UNIONs 

DEP Waived and Termed
*/

select distinct
--- #1

 pi.personid
,pdr.dependentid
,'T' ::char(1) as transtype
,'D' ::char(1) as record_type
,pi.identity ::char(9) as essn
,piD.identity ::char(9) as member_ssn
,pnd.fname ::char(30) as fname
,pnd.lname ::char(50) as lname
,to_char(pvd.birthdate, 'yyyymmdd')::char(8) as dob
,substring(pdr.dependentid from 3 for 2)  as depseqnbr

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
--,CASE when pbe_eff_cov.enddate != '2199-12-31' then to_char(pbe_eff_cov.enddate,'yyyymmdd') else null end ::char(8) coverage_term_date
--,pbe_eff_cov.enddate
,CASE when pbe_eff_cov.enddate != '2199-12-31' then to_char(DATE_TRUNC('month', pbe_eff_cov.enddate) + interval '1 month' - interval '1 day','yyyymmdd') else null end ::char(8) coverage_term_date

,'01'::char(2) as coverage_term_rsn
,' ' ::char(20) as filler_15
,' ' ::char(30) as filler_16
,' ' ::char(20) as filler_17
,' ' ::char(8) as filler_18
,' ' ::char(9) as fsa_er_pp_contrib
,' ' ::char(9) as fsa_ee_pp_contrib
,' ' ::char(9) as mult_annual_sal
,' ' ::char(9) as elec_bene_amt
,' ' ::char(9) as ee_monthly_prem  
,'#1' AS DATASOURCE

from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'ABD_BRMS_Ongoing_Beneft_Changes'


LEFT JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass = '10'
 AND pbe.benefitelection IN ('T','W')
 ---AND pbe.enddate = '2199-12-31' 
 AND CURRENT_DATE BETWEEN pbe.effectivedate AND pbe.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pbe.createts AND pbe.endts
 and pbe.effectivedate > elu.lastupdatets 


LEFT JOIN person_bene_election pbe_eff_cov  
  ON pbe_eff_cov.personid = pI.personid
 AND pbe_eff_cov.benefitsubclass = '10'
 AND pbe_eff_cov.benefitelection IN ('E')
 ---AND pbe.enddate = '2199-12-31' 
 --AND CURRENT_DATE BETWEEN pbe_eff_cov.effectivedate AND pbe_eff_cov.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pbe_eff_cov.createts AND pbe_eff_cov.endts
 and pbe_eff_cov.effectivedate > elu.lastupdatets 


JOIN benefit_plan_desc bpd 
  ON bpd.benefitsubclass = pbe.benefitsubclass 
 AND bpd.enddate = '2199-12-31' 
 AND bpd.benefitplanid = pbe.benefitplanid

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND CURRENT_DATE BETWEEN pe.effectivedate AND pe.enddate
 AND CURRENT_TIMESTAMP BETWEEN pe.createts AND pe.endts
 
 
------- Dependents


left join person_dependent_relationship pdr 
  on pdr.personid = pi.personid
 AND CURRENT_DATE BETWEEN pdr.effectivedate AND pdr.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pdr.createts AND pdr.endts
 
left join person_identity pid 
  ON pid.personid = pdr.dependentid 
 AND pid.identitytype = 'SSN'::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pid.createts AND pid.endts  

left join dependent_enrollment de 
  on de.dependentid = pdr.dependentid 
 AND de.benefitsubclass = pbe.benefitsubclass
 AND CURRENT_DATE BETWEEN de.effectivedate AND de.enddate 
 AND CURRENT_TIMESTAMP BETWEEN de.createts AND de.endts 

left join person_names pnd 
  ON pnd.personid = pdr.dependentid
 AND CURRENT_DATE BETWEEN pnd.effectivedate AND pnd.enddate
 AND CURRENT_TIMESTAMP BETWEEN pnd.createts AND pnd.endts    
 
left join person_vitals pvd 
  ON pvd.personid = pdr.dependentid
 AND CURRENT_DATE BETWEEN pvd.effectivedate AND pvd.enddate
 AND CURRENT_TIMESTAMP BETWEEN pvd.createts AND pvd.endts  
 
 
where pi.identitytype = 'SSN'
  AND current_timestamp between pi.createts and pi.endts
  AND pbe.effectivedate >= elu.lastupdatets 
  and pdr.dependentid is not null
  and de.benefitsubclass = '10'


union 


select distinct
----- #2


 pi.personid
,pdr.dependentid
,'T' ::char(1) as transtype
,'D' ::char(1) as record_type
,pi.identity ::char(9) as essn
,piD.identity ::char(9) as member_ssn
,pnd.fname ::char(30) as fname
,pnd.lname ::char(50) as lname
,to_char(pvd.birthdate, 'yyyymmdd')::char(8) as dob
,substring(pdr.dependentid from 3 for 2)  as depseqnbr

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
--,CASE when pbe_eff_cov.enddate != '2199-12-31' then to_char(pbe_eff_cov.enddate,'yyyymmdd') else null end ::char(8) coverage_term_date
--,pbe_eff_cov.enddate
,CASE when pbe_eff_cov.enddate != '2199-12-31' then to_char(DATE_TRUNC('month', pbe_eff_cov.enddate) + interval '1 month' - interval '1 day','yyyymmdd') else null end ::char(8) coverage_term_date

,'01'::char(2) as coverage_term_rsn
,' ' ::char(20) as filler_15
,' ' ::char(30) as filler_16
,' ' ::char(20) as filler_17
,' ' ::char(8) as filler_18
,' ' ::char(9) as fsa_er_pp_contrib
,' ' ::char(9) as fsa_ee_pp_contrib
,' ' ::char(9) as mult_annual_sal
,' ' ::char(9) as elec_bene_amt
,' ' ::char(9) as ee_monthly_prem  
,'#2' AS DATASOURCE


from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'ABD_BRMS_Ongoing_Beneft_Changes'




LEFT JOIN person_bene_election pbe_eff_cov  
  ON pbe_eff_cov.personid = pI.personid
 AND pbe_eff_cov.benefitsubclass = '10'
 AND pbe_eff_cov.benefitelection IN ('E')
 AND pbe_eff_cov.enddate < '2199-12-30'
 --AND CURRENT_DATE BETWEEN pbe_eff_cov.effectivedate AND pbe_eff_cov.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pbe_eff_cov.createts AND pbe_eff_cov.endts
 and pbe_eff_cov.effectivedate > elu.lastupdatets 


JOIN benefit_plan_desc bpd 
  ON bpd.benefitsubclass = pbe_eff_cov.benefitsubclass
 AND bpd.enddate = '2199-12-31' 
 AND bpd.benefitplanid = pbe_eff_cov.benefitplanid

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND CURRENT_DATE BETWEEN pe.effectivedate AND pe.enddate
 AND CURRENT_TIMESTAMP BETWEEN pe.createts AND pe.endts
 
 
------- Dependents


left join person_dependent_relationship pdr 
  on pdr.personid = pi.personid
 AND CURRENT_DATE BETWEEN pdr.effectivedate AND pdr.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pdr.createts AND pdr.endts
 
left join person_identity pid 
  ON pid.personid = pdr.dependentid 
 AND pid.identitytype = 'SSN'::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pid.createts AND pid.endts  

left join dependent_enrollment de 
  on de.dependentid = pdr.dependentid 
 AND de.benefitsubclass = pbe_eff_cov.benefitsubclass
 AND CURRENT_DATE BETWEEN de.effectivedate AND de.enddate 
 AND CURRENT_TIMESTAMP BETWEEN de.createts AND de.endts 

left join person_names pnd 
  ON pnd.personid = pdr.dependentid
 AND CURRENT_DATE BETWEEN pnd.effectivedate AND pnd.enddate
 AND CURRENT_TIMESTAMP BETWEEN pnd.createts AND pnd.endts    
 
left join person_vitals pvd 
  ON pvd.personid = pdr.dependentid
 AND CURRENT_DATE BETWEEN pvd.effectivedate AND pvd.enddate
 AND CURRENT_TIMESTAMP BETWEEN pvd.createts AND pvd.endts  
 
 
where pi.identitytype = 'SSN'
  AND current_timestamp between pi.createts and pi.endts
  AND pbe_eff_cov.effectivedate >= elu.lastupdatets 
  and pdr.dependentid is not null
  and de.benefitsubclass = '10'
  --and pi.personid = '3407'
  and pbe_eff_cov.enddate is not null



union


select distinct
-----#3

 pi.personid
,pdr.dependentid
,'T' ::char(1) as transtype
,'D' ::char(1) as record_type
,pi.identity ::char(9) as essn
,piD.identity ::char(9) as member_ssn
,pnd.fname ::char(30) as fname
,pnd.lname ::char(50) as lname
,to_char(pvd.birthdate, 'yyyymmdd')::char(8) as dob
,substring(pdr.dependentid from 3 for 2)  as depseqnbr

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
--,CASE when pbe_eff_cov.enddate != '2199-12-31' then to_char(pbe_eff_cov.enddate,'yyyymmdd') else null end ::char(8) coverage_term_date
--,pbe_eff_cov.enddate
,CASE when pbe_eff_cov.enddate != '2199-12-31' then to_char(DATE_TRUNC('month', pbe_eff_cov.enddate) + interval '1 month' - interval '1 day','yyyymmdd') else null end ::char(8) coverage_term_date

,'01'::char(2) as coverage_term_rsn
,' ' ::char(20) as filler_15
,' ' ::char(30) as filler_16
,' ' ::char(20) as filler_17
,' ' ::char(8) as filler_18
,' ' ::char(9) as fsa_er_pp_contrib
,' ' ::char(9) as fsa_ee_pp_contrib
,' ' ::char(9) as mult_annual_sal
,' ' ::char(9) as elec_bene_amt
,' ' ::char(9) as ee_monthly_prem  
,'#3' AS DATASOURCE

from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'ABD_BRMS_Ongoing_Beneft_Changes'




LEFT JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass = '10'
 AND pbe.benefitelection IN ('T','W')
 ---AND pbe.enddate = '2199-12-31' 
 AND CURRENT_DATE BETWEEN pbe.effectivedate AND pbe.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pbe.createts AND pbe.endts
 and pbe.effectivedate > elu.lastupdatets 

---- pbe_eff_cov gets effective date of coverage prior to termination

LEFT JOIN person_bene_election pbe_eff_cov  
  ON pbe_eff_cov.personid = pI.personid
 AND pbe_eff_cov.benefitsubclass = '10'
 AND pbe_eff_cov.benefitelection IN ('E')
 AND CURRENT_TIMESTAMP BETWEEN pbe_eff_cov.createts AND pbe_eff_cov.endts
 and pbe_eff_cov.effectivedate > elu.lastupdatets 



JOIN benefit_plan_desc bpd 
  ON bpd.benefitsubclass = pbe_eff_cov.benefitsubclass
 AND bpd.enddate = '2199-12-31' 
 AND bpd.benefitplanid = pbe_eff_cov.benefitplanid

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND CURRENT_DATE BETWEEN pe.effectivedate AND pe.enddate
 AND CURRENT_TIMESTAMP BETWEEN pe.createts AND pe.endts
 
 
------- Dependents


left join person_dependent_relationship pdr 
  on pdr.personid = pi.personid
 AND CURRENT_DATE BETWEEN pdr.effectivedate AND pdr.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pdr.createts AND pdr.endts
 
left join person_identity pid 
  ON pid.personid = pdr.dependentid 
 AND pid.identitytype = 'SSN'::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pid.createts AND pid.endts  

left join dependent_enrollment de 
  on de.dependentid = pdr.dependentid 
 AND de.benefitsubclass = pbe_eff_cov.benefitsubclass
 AND CURRENT_DATE BETWEEN de.effectivedate AND de.enddate 
 AND CURRENT_TIMESTAMP BETWEEN de.createts AND de.endts 

left join person_names pnd 
  ON pnd.personid = pdr.dependentid
 AND CURRENT_DATE BETWEEN pnd.effectivedate AND pnd.enddate
 AND CURRENT_TIMESTAMP BETWEEN pnd.createts AND pnd.endts    
 
left join person_vitals pvd 
  ON pvd.personid = pdr.dependentid
 AND CURRENT_DATE BETWEEN pvd.effectivedate AND pvd.enddate
 AND CURRENT_TIMESTAMP BETWEEN pvd.createts AND pvd.endts  
 
 
where pi.identitytype = 'SSN'
  AND current_timestamp between pi.createts and pi.endts
  AND pbe.effectivedate >= elu.lastupdatets



order by "transtype" desc
