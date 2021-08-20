SELECT  distinct
 pi.personid

,'[QBPLANINITIAL]' :: varchar(35) as recordtype
,pa.stateprovincecode
,bpd.benefitplandesc
--select * from benefit_plan_desc where current_timestamp between createts and endts and benefitsubclass = '14' and current_date between effectivedate and enddate
,case when bpd.benefitplandesc = 'Anthem Select HMO'  then '"Anthem BC Value Select HMO (Narrow Network) CA"'
      when bpd.benefitplandesc = 'Anthem Classic PPO' and pa.stateprovincecode =  'CA' then '"Anthem Blue Cross Classic PPO (CA)"'
      when bpd.benefitplandesc = 'Anthem Classic PPO' and pa.stateprovincecode <> 'CA' then '"Anthem Blue Cross Classic PPO (Non-CA Resident)"'
      when bpd.benefitplandesc = 'Anthem Dental HMO'  then '"Anthem Blue Cross Dental Net (HMO - CA Only)"'
      when bpd.benefitplandesc = 'Anthem Dental PPO'  then '"Anthem Blue Cross Dental Prime & Complete"'
      when bpd.benefitplandesc = 'Anthem Vision plan' then '"Anthem Blue Cross Blue View Vision Plan"'
      when bpd.benefitplandesc = 'Anthem Vision Plan' then '"Anthem Blue Cross Blue View Vision Plan"'      
      ELSE ' ' end  ::varchar(100) as plan_name    

,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch') then ('EE+FAMILY')
      when bcd.benefitcoveragedesc in ('Family') then ('EE+FAMILY')
      else null end :: varchar(15) as coverage_level

,' ' ::char(1) as numberofunits
,'3A' ::char(10) as sort_seq


,'0' as dependentid
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
 and pbe.benefitelection in ('T', 'E')
 and pbe.benefitsubclass in ('10','11','14')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14') and benefitelection = 'E' and selectedoption = 'Y') 

--- losing coverage if person's plan started in 2017
left join ( select personid,benefitcoverageid,max(effectivedate) as effectivedate
  from person_bene_election 
 where benefitsubclass in ('10')
   --and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   and benefitelection = 'E' 
   and selectedoption = 'Y'   
   group by 1,2) as maxmed on maxmed.personid = pbe.personid

left join ( select personid,benefitcoverageid,max(effectivedate) as effectivedate
  from person_bene_election 
 where benefitsubclass in ('11')
   --and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   and benefitelection = 'E' 
   and selectedoption = 'Y'  
  -- and personid = '122'    
   group by 1,2) as maxdnt on maxdnt.personid = pbe.personid

left join ( select personid,benefitcoverageid,max(effectivedate) as effectivedate
  from person_bene_election 
 where benefitsubclass in ('14')
   --and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   and benefitelection = 'E' 
   and selectedoption = 'Y'  
 --  and personid = '122'    
   group by 1,2) as maxvsn on maxvsn.personid = pbe.personid 
   


JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts 


 
 
left JOIN benefit_coverage_desc bcdm 
  on bcdm.benefitcoverageid = maxmed.benefitcoverageid 
 and current_date between bcdm.effectivedate and bcdm.enddate
 and current_timestamp between bcdm.createts and bcdm.endts 
left JOIN benefit_coverage_desc bcdd
  on bcdd.benefitcoverageid = maxdnt.benefitcoverageid 
 and current_date between bcdd.effectivedate and bcdd.enddate
 and current_timestamp between bcdd.createts and bcdd.endts  
left JOIN benefit_coverage_desc bcdv 
  on bcdv.benefitcoverageid = maxvsn.benefitcoverageid 
 and current_date between bcdv.effectivedate and bcdv.enddate
 and current_timestamp between bcdv.createts and bcdv.endts  
  
JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = coalesce( pbe.benefitcoverageid,maxvsn.benefitcoverageid,maxdnt.benefitcoverageid,maxmed.benefitcoverageid)
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
 
 
WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.effectivedate >= elu.lastupdatets::DATE 
  and pe.emplstatus = 'T'
  --and pi.personid = '862'

order by pi.personid 