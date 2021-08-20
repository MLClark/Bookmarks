SELECT distinct
-- QB record type 3 - Benefit Plan Assignment 
 pip.personid

,case when PBE.benefitsubclass = '10' then '10' 
      when PBE.benefitsubclass = '11' then '11'
      when PBE.benefitsubclass = '14' then '14' else null end ::char(2) as planused

--,de.benefitsubclass

,case when PBE.benefitsubclass = '10' and eeb.benefitplancode = 'PPO'     then '910288  BLPPO50' 
      when PBE.benefitsubclass = '11' and eeb.benefitplancode = 'Dental'  then '533123  BDPO3'
      when PBE.benefitsubclass = '14' and eeb.benefitplancode = 'Vision'  then '533123  Bvision12'  
      when PBE.benefitsubclass = '10' and eeb.benefitplancode = 'HSA'     then '910288  BLHSA30'  
      when PBE.benefitsubclass = '10' and eeb.benefitplancode = 'HMO'     then '910288  BLHMO25'      
      else null end as sponsor_plans_022
  

,case when PBE.benefitsubclass = '10' and eeb.benefitplancode = 'PPO'     then '2' 
      when PBE.benefitsubclass = '11' and eeb.benefitplancode = 'Dental'  then '0'
      when PBE.benefitsubclass = '14' and eeb.benefitplancode = 'Vision'  then '1'  
      when PBE.benefitsubclass = '10' and eeb.benefitplancode = 'HSA'     then '4'  
      when PBE.benefitsubclass = '10' and eeb.benefitplancode = 'HMO'     then '3'      
      else null end as sort_seq
      

,case when PBE.benefitsubclass = '10' and eeb.benefitplancode in ('HSA','HMO','PPO') and eeb.coverageleveldesc = 'Employee Only' then 'A'
      when PBE.benefitsubclass = '10' and eeb.benefitplancode in ('HSA','HMO','PPO') and eeb.coverageleveldesc in ('Employee + Spouse') then 'B'
      when PBE.benefitsubclass = '10' and eeb.benefitplancode in ('HSA','HMO','PPO') and eeb.coverageleveldesc in ('Employee + Children','EE & 1 Dep') then 'C'
      when PBE.benefitsubclass = '10' and eeb.benefitplancode in ('HSA','HMO','PPO') and eeb.coverageleveldesc in ('Family') then 'D'      
      
      when PBE.benefitsubclass = '11' and eeb.benefitplancode = 'Dental' and eeb.coverageleveldesc = 'Employee Only' then 'A'
      when PBE.benefitsubclass = '11' and eeb.benefitplancode = 'Dental' and eeb.coverageleveldesc = 'EE & 1 Dep' then 'B'
      when PBE.benefitsubclass = '11' and eeb.benefitplancode = 'Dental' and eeb.coverageleveldesc = 'Family' then 'C'
      
      when PBE.benefitsubclass = '14' and eeb.benefitplancode = 'Vision' and eeb.coverageleveldesc = 'Employee Only' then 'A'      
      when PBE.benefitsubclass = '14' and eeb.benefitplancode = 'Vision' and eeb.coverageleveldesc in ('Employee + Spouse') then 'B'
      when PBE.benefitsubclass = '14' and eeb.benefitplancode = 'Vision' and eeb.coverageleveldesc in ('Employee + Children','EE & 1 Dep') then 'C'
      when PBE.benefitsubclass = '14' and eeb.benefitplancode = 'Vision' and eeb.coverageleveldesc in ('Family') then 'D'      

      else null end as plan_coverage_level_23


from person_identity pip

join edi.edi_last_update elu 
  on elu.feedid = 'AOL_COBRASimple_QB_Export'
  
join person_bene_election pbe
  on pbe.personid = pip.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14')
 and pbe.benefitelection in ('T')  
 and pbe.selectedoption = 'Y'     

join edi.ediemployeebenefit eeb
  on eeb.personid = pbe.personid
 and eeb.benefitsubclass = pbe.benefitsubclass
 and current_date = eeb.asofdate
 
LEFT JOIN person_identity piS 
  ON piS.personid = piP.personid 
 AND piS.identitytype = 'SSN' 
 AND current_timestamp between piS.createts AND piS.endts 
left join benefit_plan_desc bpd 
  on bpd.benefitsubclass = pbe.benefitsubclass
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts 

LEFT JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitsubclass 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 

JOIN comp_plan_benefit_plan cpbp 
  on cpbp.compplanid = pbe.compplanid 
 and pbe.benefitsubclass = cpbp.benefitsubclass 
 AND current_date between cpbp.effectivedate AND cpbp.enddate 
 AND current_timestamp between cpbp.createts AND cpbp.endts

JOIN person_employment pe 
  ON pe.personid = pip.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 and pe.effectivedate >= elu.lastupdatets
 and pe.emplstatus in ('T','R')



where pip.identitytype = 'PSPID'
  and current_timestamp between pip.createts and pip.endts

  and pbe.benefitsubclass in ('10','11','14')
  and cpbp.cobraplan = 'Y'

group by 1,2,3,4,5
--,6,7,8
order by 1,2
-- 476

