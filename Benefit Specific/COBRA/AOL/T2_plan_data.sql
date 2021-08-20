SELECT distinct
-- QB record type 3 - Benefit Plan Assignment 
 pi.personid
,de.dependentid


,case when pbemed.benefitsubclass = '10' and bpdmed.benefitplancode = 'PPO'     then '910288  BLPPO50' 
      when pbednt.benefitsubclass = '11' and bpddnt.benefitplancode = 'Dental'  then '533123  BDPO3'
      when pbevsn.benefitsubclass = '14' and bpdvsn.benefitplancode = 'Vision'  then '533123  Bvision12'  
      when pbemed.benefitsubclass = '10' and bpdmed.benefitplancode = 'HSA'     then '910288  BLHSA30'  
      when pbemed.benefitsubclass = '10' and bpdmed.benefitplancode = 'HMO'     then '910288  BLHMO25'      
      else null end as sponsor_plans_022_038
  

,case when pbemed.benefitsubclass = '10' and bpdmed.benefitplancode = 'PPO'     then '2' 
      when pbednt.benefitsubclass = '11' and bpddnt.benefitplancode = 'Dental'  then '0'
      when pbevsn.benefitsubclass = '14' and bpdvsn.benefitplancode = 'Vision'  then '1'  
      when pbemed.benefitsubclass = '10' and bpdmed.benefitplancode = 'HSA'     then '4'  
      when pbemed.benefitsubclass = '10' and bpdmed.benefitplancode = 'HMO'     then '3'      
      else null end as sort_seq
      

,case when pbemed.benefitsubclass = '10' and bpdmed.benefitplancode in ('HSA','HMO','PPO') and bcdmed.benefitcoveragedesc in ('Employee Only') then 'A'
      when pbemed.benefitsubclass = '10' and bpdmed.benefitplancode in ('HSA','HMO','PPO') and bcdmed.benefitcoveragedesc in ('Employee + Spouse') then 'B'
      when pbemed.benefitsubclass = '10' and bpdmed.benefitplancode in ('HSA','HMO','PPO') and bcdmed.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then 'C'
      when pbemed.benefitsubclass = '10' and bpdmed.benefitplancode in ('HSA','HMO','PPO') and bcdmed.benefitcoveragedesc in ('Family') then 'D'      
      
      when pbednt.benefitsubclass = '11' and bpddnt.benefitplancode = 'Dental' and bcddnt.benefitcoveragedesc in ('Employee Only') then 'A'
      when pbednt.benefitsubclass = '11' and bpddnt.benefitplancode = 'Dental' and bcddnt.benefitcoveragedesc in ('EE & 1 Dep') then 'B'
      when pbednt.benefitsubclass = '11' and bpddnt.benefitplancode = 'Dental' and bcddnt.benefitcoveragedesc in ('Family') then 'C'
      
      when pbevsn.benefitsubclass = '14' and bpdvsn.benefitplancode = 'Vision' and bcdvsn.benefitcoveragedesc in ('Employee Only') then 'A'      
      when pbevsn.benefitsubclass = '14' and bpdvsn.benefitplancode = 'Vision' and bcdvsn.benefitcoveragedesc in ('Employee + Spouse') then 'B'
      when pbevsn.benefitsubclass = '14' and bpdvsn.benefitplancode = 'Vision' and bcdvsn.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then 'C'
      when pbevsn.benefitsubclass = '14' and bpdvsn.benefitplancode = 'Vision' and bcdvsn.benefitcoveragedesc in ('Family') then 'D'      

      else null end as plan_coverage_level_23

FROM person_identity pi
join edi.edi_last_update elu 
  on elu.feedid = 'AOL_COBRASimple_QB_Export'
  
JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 and pe.effectivedate >= elu.lastupdatets
   
join person_bene_election pbe 
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E','T')
 -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14') and benefitelection = 'E' and selectedoption = 'Y')


left join person_bene_election pbemed
  on pbemed.personid = pbe.personid
 and pbemed.benefitsubclass = '10'
 and pbemed.selectedoption = 'Y'
 
left join person_bene_election pbednt
  on pbednt.personid = pbe.personid
 and pbednt.benefitsubclass = '11'
 and pbednt.selectedoption = 'Y'
 
left join person_bene_election pbevsn
  on pbevsn.personid = pbe.personid
 and pbevsn.benefitsubclass = '14'
 and pbevsn.selectedoption = 'Y' 
 
left JOIN benefit_plan_desc bpdmed 
  on bpdmed.benefitsubclass = '10'
 AND current_date between bpdmed.effectivedate and bpdmed.enddate
 AND current_timestamp between bpdmed.createts and bpdmed.endts 
 
left JOIN benefit_plan_desc bpddnt
  on bpddnt.benefitsubclass = '11'
 AND current_date between bpddnt.effectivedate and bpddnt.enddate
 AND current_timestamp between bpddnt.createts and bpddnt.endts  

left JOIN benefit_plan_desc bpdvsn
  on bpdvsn.benefitsubclass = '14'
 AND current_date between bpdvsn.effectivedate and bpdvsn.enddate
 AND current_timestamp between bpdvsn.createts and bpdvsn.endts  
 
left JOIN benefit_coverage_desc bcdmed
  on bcdmed.benefitcoverageid = pbemed.benefitcoverageid 
 and current_date between bcdmed.effectivedate and bcdmed.enddate
 and current_timestamp between bcdmed.createts and bcdmed.endts  

left JOIN benefit_coverage_desc bcddnt
  on bcddnt.benefitcoverageid = pbednt.benefitcoverageid 
 and current_date between bcddnt.effectivedate and bcddnt.enddate
 and current_timestamp between bcddnt.createts and bcddnt.endts  

left JOIN benefit_coverage_desc bcdvsn
  on bcdvsn.benefitcoverageid = pbevsn.benefitcoverageid 
 and current_date between bcdvsn.effectivedate and bcdvsn.enddate
 and current_timestamp between bcdvsn.createts and bcdvsn.endts     

---- Dependents Data

left JOIN person_dependent_relationship pdrD
  on pdrD.personid = pbe.personid 
 AND current_date between pdrD.effectivedate AND pdrD.enddate 
 AND current_timestamp between pdrD.createts AND pdrD.endts 
 AND pdrD.dependentrelationship in ('SP', 'C', 'D', 'S')

LEFT JOIN person_names pnD
  ON pnD.personid = pdrD.dependentid 
 AND current_date between pnD.effectivedate AND pnD.enddate 
 AND current_timestamp between pnD.createts AND pnD.endts

LEFT JOIN person_identity piD
  ON piD.personid = pdrD.dependentid 
 AND piD.identitytype = 'SSN'::bpchar 
 AND current_timestamp between piD.createts AND piD.endts

join dependent_enrollment de 
  on de.personid = pdrd.personid
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts 
 and de.benefitsubclass in ('10','11','14')
 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('T','R')
  and pi.personid = '1913'
 
 
group by 1,2,3,4,5
order by 1,2
;

