select distinct
 pi.personid
,'[QBPLAN]' ::CHAR(8) as cobraid
--,ltrim(bpd.benefitplandesc,' ')::varchar(50) as plan_name
,case when bpd.benefitplandesc = 'Guardian Dental PPO' then '"Dental- Standard PPO"'
      when bpd.benefitplandesc = 'Guardian Dental DHMO' then '"Dental- CalDental DHMO"'
      when bpd.benefitplandesc = 'CA Traditional PPO' then '"Medical-PPO $20- $2,000 80/50"'
      when bpd.benefitplandesc = 'HMO Full Network' then '"Medical-Access+HMO $20/$500/Admit -Full Network"'   
      when bpd.benefitplandesc = 'Traditional PPO' then '"Medical-PPO $20- $2,000 80/50"'
      when bpd.benefitplandesc = 'HMO Trio ACO' then '"Medical-Access+HMO $20/$500/Admit-Trio ACO Network"'     
      when bpd.benefitplandesc = 'MediExcel Cross Border HMO' then '"Medical - Value Plan 10"'         
      when bpd.benefitplandesc = 'Vision' then '"Vision- MES Vision"'
      when bpd.benefitplandesc = ' HDHP (H.S.A) PPO' then '"Medical-H.S.A. $2,700 80/60"'
      else bpd.benefitplandesc end  ::varchar(50) as plan_name  

,TO_CHAR(date_trunc('MONTH',pe.effectivedate) + INTERVAL '2 MONTH','YYYYMMDD')::DATE AS start_date
,' ' ::char(1) as end_date
,case when bcd.benefitcoveragedesc = 'Family' then 'EE+FAMILY'
      when bcd.benefitcoveragedesc = 'Employee Only' then 'EE'
      when bcd.benefitcoveragedesc = 'Employee + Children' then 'EE+CHILDREN'
      when bcd.benefitcoveragedesc = 'Employee + Spouse' then 'EE+SPOUSE'
      else 'EE' end ::varchar(35) as coverage_level
,' ' ::char(1) as first_day_of_cobra
,' ' ::char(1) as last_day_of_cobra
,' ' ::char(1) as cobra_duration_months
,' ' ::char(1) as days_to_elect
,' ' ::char(1) as days_to_make_first_payment
,' ' ::char(1) as days_to_make_sub_payments
,' ' ::char(1) as election_postmark_date
,' ' ::char(1) as last_date_rate_notified
,' ' ::char(1) as number_of_units
,'T' ::char(1) as send_plan_changed_letter
,' ' ::char(1) as plan_bundle_name

,3 as sort_seq

      

 
from person_identity pi

LEFT join edi.edi_last_update elu on elu.feedid = 'ASP_SHDR_COBRA_QB_Export' 

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11','14','6Z')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','6Z') and benefitelection = 'E' and selectedoption = 'Y')
 
join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts
  
left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.effectivedate >= elu.lastupdatets::DATE 
  and pe.emplstatus = 'T'

order by  pi.personid

