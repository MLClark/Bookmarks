SELECT distinct  
 pi.personid
--,pdr.dependentid
--,pbe.benefitplanid 
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype
,case when bpd.benefitplandesc = 'Anthem HMO Plan' then '"Anthem BC Value Select HMO (Narrow Network) CA"'
      when bpd.benefitplandesc = 'Anthem PPO Plan' and pa.stateprovincecode =  'CA' then '"Anthem Blue Cross Classic PPO (CA)"'
      when bpd.benefitplandesc = 'Anthem PPO Plan' and pa.stateprovincecode <> 'CA' then '"Anthem Blue Cross Classic PPO (Non-CA Resident)"'
      when bpd.benefitplandesc = 'Anthem DHMO Plan' then '"Anthem Blue Cross Dental Net (HMO - CA Only)"'
      when bpd.benefitplandesc = 'Anthem DPO Plan'  then '"Anthem Blue Cross Dental Prime & Complete"'
      when bpd.benefitplandesc = 'Anthem Vision plan' then '"Anthem Blue Cross Blue View Vision Plan"'
      when bpd.benefitplandesc = 'Anthem Vision Plan' then '"Anthem Blue Cross Blue View Vision Plan"'      
      ELSE bpd.benefitplandesc end  ::varchar(100) as plan_name     
,'4A'||pi.personid||'B' ::char(10) as sort_seq

FROM person_identity pi
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BDF_IGOE_QB_EXPORT'
JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
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