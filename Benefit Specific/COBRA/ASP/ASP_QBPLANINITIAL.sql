SELECT  distinct
 pi.personid

,'[QBPLANINITIAL]' :: varchar(35) as recordtype
,bpd.benefitplandesc 
--select * from benefit_plan_desc where current_timestamp between createts and endts and benefitsubclass = '14' and current_date between effectivedate and enddate
,case when bpd.benefitplandesc in ('Guardian Dental DHMO') then '"Dental- CalDental DHMO"'
      when bpd.benefitplandesc in ('Guardian Dental PPO') then '"Dental- Standard PPO"'
      when bpd.benefitplandesc in ('CA Traditional PPO') then '"Medical-PPO $20- $2,000 80/50"'
      when bpd.benefitplandesc in ('HMO Full Network') THEN '"Medical-Access+HMO $20/$500/Admit -Full Network"'
      when bpd.benefitplandesc in ('Traditional PPO') THEN '"Medical-PPO $20- $2,000 80/50"'
      when bpd.benefitplandesc in ('HDHP PPO') THEN '"Medical-H.S.A. $2,700 80/60"'
      when bpd.benefitplandesc in ('HMO Trio ACO') then '"Medical-Access+HMO $20/$500/Admit-Trio ACO Network"'  
      when bpd.benefitplandesc in ('MediExcel Cross Border HMO') then '"Medical - Value Plan 10"'
      when bpd.benefitplandesc in ('Vision') then '"Vision- MES Vision"'
      else bpd.benefitplandesc end :: varchar(50) as plan_name        
,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch') then ('EE+FAMILY')
      when bcd.benefitcoveragedesc in ('Family') then ('EE+FAMILY')
      else null end :: varchar(15) as coverage_level

,' ' ::char(1) as numberofunits
,'3A' ::char(10) as sort_seq



FROM person_identity pi

LEFT join edi.edi_last_update elu on elu.feedid = 'ASP_SHDR_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_bene_election pbe 
  on pbe.personid = pe.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','6Z')
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

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.effectivedate >= elu.lastupdatets::DATE 
  and pe.emplstatus = 'T'
  --and pi.personid = '862'

order by pi.personid 