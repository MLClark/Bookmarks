select distinct
 pi.personid
,'ACTIVE EE TERMED DEP' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'4' ::char(10) as sort_seq
,pbe.effectivedate
,pnd.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitsubclass = '10' then 'BCBS OF SC'
      when pbe.benefitsubclass = '11' then 'DELTA DENTAL'
      when pbe.benefitsubclass = '14' then 'PHYS EYECARE'
      when pbe.benefitsubclass = '60' then 'INFINISOURCE'
      end ::char(15) as plan_code
,case when pbe.benefitsubclass = '10' and pbe.benefitplanid in ('12','15','146') then 'MED B PLUS'  
      when pbe.benefitsubclass = '10' and pbe.benefitplanid in ('6','9','143') then 'MED A CORE' 
      when pbe.benefitsubclass = '11' then 'DENTAL' 
      when pbe.benefitsubclass = '14' then 'VISION'
      when pbe.benefitsubclass = '60' then 'FSA'
      else null end ::char(15) as coverage_code     
,case when pbe.benefitsubclass = '10' and bcdmed.benefitcoveragecodexid = 'EE' then 'SGL'
      when pbe.benefitsubclass = '10' and bcdmed.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbe.benefitsubclass = '10' and bcdmed.benefitcoveragecodexid = 'F' then 'FAMILY'
      when pbe.benefitsubclass = '11' and bcddnt.benefitcoveragecodexid = 'EE' then 'EE'      
      when pbe.benefitsubclass = '11' and bcddnt.benefitcoveragecodexid in ('EC','EE & 1 Dep') then 'EE+1'
      when pbe.benefitsubclass = '11' and bcddnt.benefitcoveragecodexid in ('EE & Deps','EC') then 'EE+2 OR MORE'
      when pbe.benefitsubclass = '14' and bcdvsn.benefitcoveragecodexid = 'EE' then 'SGL'      
      when pbe.benefitsubclass = '14' and bcdvsn.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbe.benefitsubclass = '14' and bcdvsn.benefitcoveragecodexid = 'ES' then 'EE+SPOUSE'
      when pbe.benefitsubclass = '14' and bcdvsn.benefitcoveragecodexid = 'F' then 'FAMILY'      
      when pbe.benefitsubclass = '60' then 'MONTHLY PREMIUM'
      else null end ::char(15) as option_code
,to_char(coalesce(pbemed.enddate,pbednt.enddate,pbevsn.enddate),'YYYY-MM-DD') ::char(10) as loss_of_coverage_date 
,to_char(coalesce(pbemed.effectivedate,pbednt.effectivedate,pbevsn.effectivedate),'YYYY-MM-DD')::char(10) as event_date   
,case when pbe.benefitsubclass = '60' then cast(pocmfsa.employeerate as dec(18,2)) else null end  ::char(7) as premium  
,case when pbe.benefitsubclass = '60' then cast(pocmfsa.employeerate as dec(18,2)) 
      when pbe.benefitsubclass = '10' then cast(pocmed.employeerate as dec(18,2)) 
      when pbe.benefitsubclass = '11' then cast(pocdnt.employeerate as dec(18,2))
      when pbe.benefitsubclass = '14' then cast(pocvsn.employeerate as dec(18,2))
      else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin     

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_address pa 
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

join person_bene_election pbe 
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('10','11','14','60')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E' 
 and pbe.effectivedate - interval '1 day' <> pbe.enddate
 and pbe.benefitcoverageid > '1'
 and current_timestamp between pbe.createts and pbe.endts
   -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)   

join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts



--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

left join benefit_plan_desc bpdmed
  on bpdmed.benefitsubclass = pbemed.benefitsubclass
 and bpdmed.benefitplanid = pbemed.benefitplanid
 and current_date between bpdmed.effectivedate and bpdmed.enddate
 and current_timestamp between bpdmed.createts and bpdmed.endts   

left join benefit_coverage_desc bcdmed
  on bcdmed.benefitcoverageid = pbemed.benefitcoverageid
 and current_date between bcdmed.effectivedate and bcdmed.enddate
 and current_timestamp between bcdmed.createts and bcdmed.endts
      

--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     

left join benefit_coverage_desc bcddnt
  on bcddnt.benefitcoverageid = pbednt.benefitcoverageid
 and current_date between bcddnt.effectivedate and bcddnt.enddate
 and current_timestamp between bcddnt.createts and bcddnt.endts
 
--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                       
                
left join benefit_coverage_desc bcdvsn
  on bcdvsn.benefitcoverageid = pbevsn.benefitcoverageid
 and current_date between bcdvsn.effectivedate and bcdvsn.enddate
 and current_timestamp between bcdvsn.createts and bcdvsn.endts
                          
--- medical fsa
left join   (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' 
              and effectivedate < enddate
              and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1  

left join benefit_coverage_desc bcdfsa
  on bcdfsa.benefitcoverageid = pbemfsa.benefitcoverageid
 and current_date between bcdfsa.effectivedate and bcdfsa.enddate
 and current_timestamp between bcdfsa.createts and bcdfsa.endts
 
left join personbenoptioncostl pocmed
  on pocmed.personid = pbemed.personid
 and pocmed.personbeneelectionpid = pbemed.personbeneelectionpid
 and pocmed.costsby = 'M'    
left join personbenoptioncostl pocdnt
  on pocdnt.personid = pbednt.personid
 and pocdnt.personbeneelectionpid = pbednt.personbeneelectionpid
 and pocdnt.costsby = 'M'   
left join personbenoptioncostl pocvsn
  on pocvsn.personid = pbevsn.personid
 and pocvsn.personbeneelectionpid = pbevsn.personbeneelectionpid
 and pocvsn.costsby = 'M'   
left join personbenoptioncostl pocmfsa
  on pocmfsa.personid = pbemfsa.personid
 and pocmfsa.personbeneelectionpid = pbemfsa.personbeneelectionpid
 and pocmfsa.costsby = 'M'    

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pbe.personid
 and current_timestamp between de.createts and de.endts
 and de.dependentid in 
 ( select distinct de.dependentid as dependentid
    from dependent_enrollment de 
    join person_names pne
      on pne.personid = de.personid
     and pne.nametype = 'Legal'
     and current_date between pne.effectivedate and pne.enddate
     and current_timestamp between pne.createts and pne.endts
    join person_names pnd
      on pnd.personid = de.dependentid
     and pnd.nametype = 'Dep'
     and current_date between pnd.effectivedate and pnd.enddate
     and current_timestamp between pnd.createts and pnd.endts    
    join person_vitals pvd
      on pvd.personid = de.dependentid
     and current_date between pvd.effectivedate and pvd.enddate
     and current_timestamp between pvd.createts and pvd.endts 
    join person_dependent_relationship pdr
      on pdr.personid = de.personid
     and pdr.dependentid = de.dependentid
     and current_date between pdr.effectivedate and pdr.enddate
     and current_timestamp between pdr.createts and pdr.endts
    join person_employment pe
      on pe.personid = de.personid
     and current_date between pe.effectivedate and pe.enddate
     and current_timestamp between pe.createts and pe.endts
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in ('10','11','14','60')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','60')
    --and pdr.dependentrelationship in ('S','D','C','NC','NS','ND')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
    and date_part('year',de.enddate)=date_part('year',current_date)
   -- and pe.personid = '9707'
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.benefitsubclass in ('10','11','14','60')-- and de.dependentid = '1964'
       --and pdr.dependentrelationship in ('S','D','C','NC','NS','ND')
   )
)     


 

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.effectivedate::date >= elu.lastupdatets::date