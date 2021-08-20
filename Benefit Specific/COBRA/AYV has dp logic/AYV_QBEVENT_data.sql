SELECT  distinct
 pi.personid
,pbe.benefitsubclass
,bpd.benefitplandesc
,bcd.benefitcoveragedesc
,'[QBPLANINITIAL]' :: varchar(35) as recordtype

,case when bpd.benefitplandesc in ('Dental - High','DP Dental High') then '"Dental - High Plan"'
      when bpd.benefitplandesc in ('Dental - Low','DP Dental Low') then '"Dental - Low Plan"'
      when bpd.benefitplandesc like 'HSA%'           then '"Medical - BB-WW MOD (2V) HSAs"'
      when bpd.benefitplandesc like ('UHC - AR-1L%') then '"Medical - AR-1L (2017 Choice Plus Adv)Rx 5U Medium"'
      when bpd.benefitplandesc like ('UHC - AR-1M%') then '"Medical - AR-1M (2017 Choice Plus Adv) Rx 5U Low"'
      when bpd.benefitplandesc like ('UHC - AR-YS%') then '"Medical - AR-YS (2017 Balanced) Rx 5U High"'
      when bpd.benefitplandesc in   ('Vision','DP Vision') then '"Vision - Guardian"'
      ELSE bpd.benefitplandesc end  ::varchar(100) as plan_name     

,case when bcd.benefitcoveragedesc in ('Employee Only') then 'EE'
      when bcd.benefitcoveragedesc in ('Employee + Spouse') then ('EE+SPOUSE')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep') then ('EE+CHILDREN')
      when bcd.benefitcoveragedesc in ('EE&Child(ren) + DP Adult&DP Ch','EE + 2 or more DP Adult/Child') then ('EE+FAMILY')
      when bcd.benefitcoveragedesc in ('Employee + Children','EE & 1 Dep','Family','DP Family') then ('EE+FAMILY')
      else bcd.benefitcoveragedesc end :: varchar(15) as coverage_level

,' ' ::char(1) as numberofunits
,'3A' ::char(10) as sort_seq
FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AYV_SHDR_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E' 
 and pbe.benefitsubclass in ('10','11','14','15','16','17','6Z')  --- 15,16,17 for domestic partner benefits
 AND pbe.effectivedate < pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','6Z') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
          
---- plan names and coverage should default to employee's when there's dp coverage                        
left JOIN person_bene_election pbedp 
  on pbedp.personid = pbe.personid 
 and pbedp.selectedoption = 'Y' 
 and pbedp.benefitsubclass in ('15','16','17')  --- 15,16,17 for domestic partner benefits
 AND pbedp.effectivedate < pbedp.enddate 
 AND current_timestamp between pbedp.createts AND pbedp.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbedp.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                           and benefitsubclass in ('15','16','17') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
                         
left join (select benefitplandesc, benefitsubclass, benefitplanid, max(effectivedate) as effectived, rank () OVER (PARTITION BY benefitplandesc ORDER BY MAX(effectivedate) DESC) AS RANK
             from benefit_plan_desc bpd where benefitsubclass in ('10','11','14','15','16','17','6Z') and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by 1,2,3) bpd on bpd.benefitplanid = pbe.benefitplanid and bpd.rank = 1
            
left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbe.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
 
left JOIN benefit_coverage_desc bcddp 
  on bcddp.benefitcoverageid = pbedp.benefitcoverageid 
 and current_date between bcddp.effectivedate and bcddp.enddate
 and current_timestamp between bcddp.createts and bcddp.endts  

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  and pe.emplstatus in ('R','T')
 
order by pi.personid, plan_name