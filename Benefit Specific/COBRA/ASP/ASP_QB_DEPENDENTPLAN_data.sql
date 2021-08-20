SELECT distinct  
 pie.personid
--,pbe.benefitplanid 
,'[QBDEPENDENTPLANINITIAL]' :: varchar(35) as recordtype
,replace(pie.identity,'-','') :: char(9) as emp_ssn
,case when bpd.benefitplandesc in ('Guardian Dental DHMO') then 'Dental- CalDental DHMO'
      when bpd.benefitplandesc in ('Guardian Dental PPO') then 'Dental- Standard PPO'
      when bpd.benefitplandesc in ('CA Traditional PPO') then 'Medical-PPO $20- $2,000 80/50'
      when bpd.benefitplandesc in ('HMO Full Network') THEN 'Medical-Access+HMO $20/$500/Admit -Full Network'
      when bpd.benefitplandesc in ('Traditional PPO') THEN 'Medical-PPO $20- $2,000 80/50'
      when bpd.benefitplandesc in ('HMO Trio ACO') then 'Medical-Access+HMO $20/$500/Admit-Trio ACO Network'  
      when bpd.benefitplandesc in ('MediExcel Cross Border HMO') then 'Medical - Value Plan 10'
      when bpd.benefitplandesc in ('Vision') then 'Vision- MES Vision'
      when bpd.benefitplandesc in ('PPO- H.S.A- CA and OOS') then 'Medical-H.S.A. $2,700 80/60'
      else bpd.benefitplandesc end :: varchar(50) as plan_name    
,6 as sort_seq



FROM person_identity pie

LEFT join edi.edi_last_update elu on elu.feedid = 'ASP_SHDR_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pie.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_bene_election pbe 
  on pbe.personid = pe.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','6Z')
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

WHERE pie.identitytype = 'SSN' 
  and current_timestamp between pie.createts and pie.endts
  and pe.effectivedate >= elu.lastupdatets::DATE 
  and pe.emplstatus = 'T'
  --and pi.personid = '1057'


order by pie.personid