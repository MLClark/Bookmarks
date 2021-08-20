SELECT  distinct
 pi.personid

,'[QBPLANINITIAL]' :: varchar(35) as recordtype
--select * from benefit_plan_desc where current_timestamp between createts and endts and benefitsubclass = '14' and current_date between effectivedate and enddate
,case when bpd.benefitplancode in ('MEDFSA','DCFSA') then 'EBC FSA'
      when bpd.benefitplancode in ('DenBase','DBDP') then 'CIGNA DENTAL BASE'
      when bpd.benefitplancode in ('DenBuyup','DBUDP') then 'CIGNA DENTAL BUY UP'
      when bpd.benefitplancode in ('MBHSA') THEN 'CIGNA MEDICAL BRONZE HSA'
      when bpd.benefitplancode in ('MGOLD') THEN 'CIGNA MEDICAL GOLD HSA'
      when bpd.benefitplancode in ('MSHSA') then 'CIGNA MEDICAL SILVER HSA'  
      when bpd.benefitplancode in ('VisBuyup','VBUYUP','VBUDP') then 'VSP VISION BUY UP'
      when bpd.benefitplancode in ('VisBase','VBDP') then 'VSP VISION BASE'
      else bpd.benefitplancode end :: varchar(50) as plan_name    

,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch') then ('EE+FAMILY')
	  when bcd.benefitcoveragedesc in ('Family') then ('EE+FAMILY')
      else null end :: varchar(15) as coverage_level

,'' ::char(1) as numberofunits
,'3'||pi.personid ::char(10) as sort_seq



FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_bene_election pbe 
  on pbe.personid = pe.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','15','16','17')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E','T')

JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 

left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 

join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('C','NA','S','D')
 
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts 

LEFT JOIN person_vitals pvd
  ON pvd.personid = pdr.dependentid 
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts
 
WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A' and pvd.birthdate <= elu.lastupdatets::DATE - interval '26 years'
 -- and pie.personid = '879'