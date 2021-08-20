/*
This sql generate both the add and term BRMS record for DEPENDENT benefit via union
The result set is sorted by transtype in desc sequence - client wants terms followed by adds
*/
select distinct

/*
This section generates the BRMS add record 
This is an DEPENDENT only record

This data should reflect current benefit coverage. 

The transaction type will always be A 
I'm assuming that the enrollment_type should also be A since this represents current coverage
*/

 pi.personid
,pdr.dependentid
,'A' ::char(1) as transtype
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
      
,to_char(pbe.effectivedate,'yyyymmdd') ::char(8) as coverage_eff_date

  
,CASE when pbe.enddate != '2199-12-31' then to_char(pbe.enddate,'yyyymmdd') else null end ::char(8) coverage_term_date
--,pe.emplevent
--,pe.emplstatus
,CASE when pbe.benefitelection = 'E' and pe.emplstatus = 'A' then '01' 
      when pbe.benefitelection = 'T' and pe.emplevent = 'InvTerm' then '14' 
      when pbe.benefitelection = 'T' and pe.emplevent = 'VolTerm' then '02' 
      when pbe.benefitelection = 'T' and pe.emplevent is null then '02'
      else ' ' end ::char(2) as coverage_term_rsn
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

LEFT JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass = '10'
 AND pbe.benefitelection IN ('E','W')

 AND CURRENT_DATE BETWEEN pbe.effectivedate AND pbe.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pbe.createts AND pbe.endts
 and pbe.effectivedate >= elu.lastupdatets 

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
  and pi.personid  in ('4030')


UNION


select distinct

/*
This section generates the termination of an DEPENDENT coverage. 
This is an Dependent only record

This data should not reflect current benefit coverage. 
This data should reflect prior benefit coverage.

The transaction type will always be T 
I'm assuming that the enrollment_type should also be T since this doesn't represent current coverage
*/

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

,' ' ::char(1) as enrollment_type

,CASE pe.emplevent 
      WHEN 'Hire'       THEN '01'
      WHEN 'PartFull'   THEN '04'
      WHEN 'FullPart'   THEN '04'
      WHEN 'Promo'      THEN '02'
      ELSE '04'
      END ::char(2) as enrollment_reason
      
  
,to_char(pbe.effectivedate,'yyyymmdd') ::char(8) as coverage_eff_date
,CASE when pbe.enddate != '2199-12-31' then to_char(pbe.enddate,'yyyymmdd') else null end ::char(8) coverage_term_date

,CASE when pbe.benefitelection = 'E' and pe.emplstatus = 'A' then '01' 
      when pbe.benefitelection = 'T' and pe.emplevent = 'InvTerm' then '14' 
      when pbe.benefitelection = 'T' and pe.emplevent = 'VolTerm' then '02' 
      when pbe.benefitelection = 'T' and pe.emplevent is null then '02'
      else ' ' end ::char(2) as coverage_term_rsn
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

LEFT JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass = '10'
 AND pbe.benefitelection IN ('E')
 ---AND pbe.enddate = '2199-12-31' 
 ---AND CURRENT_DATE BETWEEN pbe.effectivedate AND pbe.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pbe.createts AND pbe.endts
 and pbe.effectivedate >= elu.lastupdatets 

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
  and pi.personid  in ('4030')



order by "transtype" desc
