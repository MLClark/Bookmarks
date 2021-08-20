SELECT distinct  
 pie.personid
--,pbe.benefitplanid 
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype
,replace(pie.identity,'-','') :: char(9) as emp_ssn
--,replace(pid.identity,'-','') :: char(9) as dep_ssn
,case when bpd.benefitplancode in ('MSHSA') then 'CIGNA MEDICAL SILVER HSA'
      when bpd.benefitplancode in ('MGOLD') THEN 'CIGNA MEDICAL GOLD HSA'
      when bpd.benefitplancode in ('MBHSA') THEN 'CIGNA MEDICAL BRONZE HSA'
      when bpd.benefitplancode in ('DenBuyup','DBUDP') then 'CIGNA DENTAL BUY UP'
      when bpd.benefitplancode in ('DenBase','DBDP') then 'CIGNA DENTAL BASE'
      when bpd.benefitplancode in ('VisBuyup','VBUYUP','VBUDP') then 'VSP VISION BUY UP'
      when bpd.benefitplancode in ('VisBase','VBDP') then 'VSP VISION BASE'
      when bpd.benefitplancode in ('MEDFSA','DCFSA') then 'EBC FSA'
      else bpd.benefitplancode end :: varchar(50) as plan_name
,'4'||pdr.dependentid||'B' ::char(10) as sort_seq


FROM person_identity pie

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pie.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_bene_election pbe 
  on pbe.personid = pe.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','15','16','17')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E','T')

join person_dependent_relationship pdr
  on pdr.personid = pie.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('SP','C','NA','S','DP','D')
 
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

LEFT JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

WHERE pie.identitytype = 'SSN' 
  and current_timestamp between pie.createts and pie.endts
  and pe.effectivedate >= elu.lastupdatets::DATE 
  and pe.emplstatus = 'T'

UNION

SELECT distinct  
 pie.personid
--,pbe.benefitplanid 
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype
,replace(pie.identity,'-','') :: char(9) as emp_ssn
--,replace(pid.identity,'-','') :: char(9) as dep_ssn
,case when bpd.benefitplancode in ('MSHSA') then 'CIGNA MEDICAL SILVER HSA'
      when bpd.benefitplancode in ('MGOLD') THEN 'CIGNA MEDICAL GOLD HSA'
      when bpd.benefitplancode in ('MBHSA') THEN 'CIGNA MEDICAL BRONZE HSA'
      when bpd.benefitplancode in ('DenBuyup','DBUDP') then 'CIGNA DENTAL BUY UP'
      when bpd.benefitplancode in ('DenBase','DBDP') then 'CIGNA DENTAL BASE'
      when bpd.benefitplancode in ('VisBuyup','VBUYUP','VBUDP') then 'VSP VISION BUY UP'
      when bpd.benefitplancode in ('VisBase','VBDP') then 'VSP VISION BASE'
      when bpd.benefitplancode in ('MEDFSA','DCFSA') then 'EBC FSA'
      else bpd.benefitplancode end :: varchar(50) as plan_name
,'4'||pdr.dependentid||'B' ::char(10) as sort_seq


FROM person_identity pie

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pie.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_bene_election pbe 
  on pbe.personid = pe.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','15','16','17')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E','T')

join person_dependent_relationship pdr
  on pdr.personid = pie.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('SP','DP')
 
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

LEFT JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 
 
left join person_maritalstatus pm
  on pm.personid = pie.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 

WHERE pie.identitytype = 'SSN' 
  and current_timestamp between pie.createts and pie.endts
  and pe.emplstatus = 'A' and pm.maritalstatus = 'D' and pm.effectivedate >= elu.lastupdatets::DATE 

UNION

SELECT distinct  
 pie.personid
--,pbe.benefitplanid 
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype
,replace(pie.identity,'-','') :: char(9) as emp_ssn
--,replace(pid.identity,'-','') :: char(9) as dep_ssn
,case when bpd.benefitplancode in ('MSHSA') then 'CIGNA MEDICAL SILVER HSA'
      when bpd.benefitplancode in ('MGOLD') THEN 'CIGNA MEDICAL GOLD HSA'
      when bpd.benefitplancode in ('MBHSA') THEN 'CIGNA MEDICAL BRONZE HSA'
      when bpd.benefitplancode in ('DenBuyup','DBUDP') then 'CIGNA DENTAL BUY UP'
      when bpd.benefitplancode in ('DenBase','DBDP') then 'CIGNA DENTAL BASE'
      when bpd.benefitplancode in ('VisBuyup','VBUYUP','VBUDP') then 'VSP VISION BUY UP'
      when bpd.benefitplancode in ('VisBase','VBDP') then 'VSP VISION BASE'
      when bpd.benefitplancode in ('MEDFSA','DCFSA') then 'EBC FSA'
      else bpd.benefitplancode end :: varchar(50) as plan_name
,'4'||pdr.dependentid||'B' ::char(10) as sort_seq


FROM person_identity pie

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pie.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_bene_election pbe 
  on pbe.personid = pe.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','15','16','17')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E','T')

join person_dependent_relationship pdr
  on pdr.personid = pie.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('C','S','D')
 
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

LEFT JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

LEFT JOIN person_vitals pvd
  ON pvd.personid = pdr.dependentid 
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts 

WHERE pie.identitytype = 'SSN' 
  and current_timestamp between pie.createts and pie.endts
  and pe.emplstatus = 'A' and pvd.birthdate <= current_date::DATE - interval '26 years'
 -- and pie.personid = '879'


order by 1