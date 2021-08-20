select distinct

/*
This section generates the BRMS add record 
This is an employee only record

This data should reflect current benefit coverage. 

The transaction type will always be A 
I'm assuming that the enrollment_type should also be A since this represents current coverage
*/

 pi.personid
,'0' as dependentid
,'A' ::char(1) as transtype
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

 
,to_char(pbe.effectivedate,'yyyymmdd') ::char(8) as coverage_eff_date

,CASE when pbe.benefitelection = 'T' and pbe.enddate != '2199-12-31' then to_char(pbe.enddate,'yyyymmdd') else null end ::char(8) coverage_term_date
--,pe.emplevent
--,pe.emplstatus
,CASE when pbe.benefitelection = 'E' and pe.emplstatus = 'A' then '01' 
      when pbe.benefitelection = 'T' and pe.emplevent = 'FullPart' then '03' 
      when pbe.benefitelection = 'T' and pe.emplevent = 'InvTerm' then '14' 
      when pbe.benefitelection = 'T' and pe.emplevent = 'VolTerm' then '02' 
      when pbe.benefitelection = 'T' and pe.emplevent is null then '02'
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

LEFT JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass = '10'
 AND pbe.benefitelection IN ('E')
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
  AND pbe.effectivedate >= elu.lastupdatets
  --and pi.personid  in ('4030')

order by "transtype" desc




