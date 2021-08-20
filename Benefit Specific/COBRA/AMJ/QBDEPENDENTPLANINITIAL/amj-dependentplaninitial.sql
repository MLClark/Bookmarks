SELECT distinct  
 pi.personid
,pdr.dependentid
,'DEPENDENT TERMED EE' ::varchar(30) as qsource
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype
,replace(pi.identity,'-','') :: char(9) as emp_ssn
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


FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 
join 
(select distinct personid, enddate, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('10','11','14','15','16','17','60','61')
   and enddate < '2199-12-30'
   and selectedoption = 'Y'
   and benefitelection = 'E'
   and date_part('year',enddate)=date_part('year',current_date)
   group by 1,2) maxpbe on maxpbe.personid = pe.personid and maxpbe.rank = 1


JOIN person_bene_election pbe 
  on pbe.personid = pe.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
 and pbe.effectivedate < pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.effectivedate >= maxpbe.effectivedate
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

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  and pe.emplstatus = 'T' and pe.empleventdetcode <> 'Death'
  and date_part('year',pbe.planyearenddate) = date_part('year',current_date)

UNION 

SELECT distinct  
 pi.personid
,pdr.dependentid
,'DEPENDENT EE DEATH' ::varchar(30) as qsource
--,pbe.benefitplanid 
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype
,replace(pi.identity,'-','') :: char(9) as emp_ssn
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


FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 
join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 --and de.effectivedate > de.enddate
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

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  and date_part('year',pbe.planyearenddate) = date_part('year',current_date)
  and pe.emplstatus = 'T' and pe.empleventdetcode = 'Death' and pdr.dependentrelationship <> ('SP')

order by 1,2