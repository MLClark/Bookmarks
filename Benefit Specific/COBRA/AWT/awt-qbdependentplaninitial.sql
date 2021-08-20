SELECT distinct  
 pi.personid
,pdr.dependentid
--,pbe.benefitplanid 
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype
,case when bpd.benefitplandesc = 'Dental - High' then '"Dental - High Plan"'
      when bpd.benefitplandesc = 'Dental - Low' then '"Dental - Low Plan"'
      when bpd.benefitplandesc = ' ' then '"Flex - ProBenefits"'
      when bpd.benefitplandesc = 'UHC - AR-1L' then '"Medical - AR-1L (2017 Choice Plus Adv)Rx 5U Medium"'
      when bpd.benefitplandesc = 'UHC - AR-1M' then '"Medical - AR-1M (2017 Choice Plus Adv) Rx 5U Low"'
      when bpd.benefitplandesc = 'UHC - AR-YS' then '"Medical - AR-YS (2017 Balanced) Rx 5U High"'
      when bpd.benefitplandesc = 'Vision' then '"Vision - Guardian"'
      ELSE bpd.benefitplandesc end  ::varchar(50) as plan_name    
,'4A'||pdr.dependentid||'B' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11','14')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14') and benefitelection = 'E' and selectedoption = 'Y') 

join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 AND pdr.dependentrelationship in ('SP','C','NA','S','DP','D')
 
 -- select * from dependent_enrollment where personid = '6094';
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitsubclass = pbe.benefitsubclass
 --and current_date between de.effectivedate and de.enddate
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
  and pe.effectivedate >= elu.lastupdatets::DATE 
  and pe.emplstatus = 'T'
  --and pi.personid = '6094'


order by pi.personid