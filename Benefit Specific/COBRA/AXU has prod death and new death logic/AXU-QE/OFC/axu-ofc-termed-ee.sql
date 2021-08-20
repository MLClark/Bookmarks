select distinct
--- Split thisinto unions for each benefit because rows are being generated for waived benefits - can't change the case clauses to benefit specific values 
 pi.personid
,'MED TERMED EE' ::varchar(30) as qsource 
,'0' as dependentid
,'4' ::char(10) as sort_seq
,pn.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitsubclass = '10' then 'BCBS OF SC'
      when pbe.benefitsubclass = '11' then 'DELTA DENTAL'
      when pbe.benefitsubclass = '14' then 'PHYS EYECARE'
      when pbe.benefitsubclass = '60' then 'INFINISOURCE'
      end ::char(15) as plan_code
,case when pbe.benefitsubclass = '10' and bpdmed.benefitplandescshort like 'BCBS PLUS%' then 'MED B PLUS'  
      when pbe.benefitsubclass = '10' and bpdmed.benefitplandescshort like 'BCBS of%' then 'MED A CORE' 
      when pbe.benefitsubclass = '11' then 'DENTAL' 
      when pbe.benefitsubclass = '14' then 'VISION'
      when pbe.benefitsubclass = '60' then 'FSA'
      else null end ::char(15) as coverage_code     
,case when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid = 'EE' then 'SGL'
      when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid = 'F' then 'FAMILY'
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid = 'EE' then 'EE'      
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid in ('EC','EE & 1 Dep') then 'EE+1'
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid in ('EE & Deps','EC') then 'EE+2 OR MORE'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'EE' then 'SGL'      
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'ES' then 'EE+SPOUSE'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'F' then 'FAMILY'      
      when pbe.benefitsubclass = '60' then 'MONTHLY PREMIUM'
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '10' then to_char(pbemed.enddate,'YYYY-MM-DD')      
      when pbe.benefitsubclass = '11' then to_char(pbednt.enddate,'YYYY-MM-DD')
      when pbe.benefitsubclass = '14' then to_char(pbevsn.enddate,'YYYY-MM-DD')
      when pbe.benefitsubclass = '60' then to_char(pbemfsa.enddate,'YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pe.effectivedate,'YYYY-MM-DD')::char(10) as event_date   
,case when pbe.benefitsubclass = '60' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin      

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_address pa 
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts


join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10')
 and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)   

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

left join benefit_plan_desc bpdmed
  on bpdmed.benefitsubclass = pbemed.benefitsubclass
 and bpdmed.benefitplanid = pbemed.benefitplanid
 and current_date between bpdmed.effectivedate and bpdmed.enddate
 and current_timestamp between bpdmed.createts and bpdmed.endts            


--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                       
                         
--- medical fsa
left join   (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' 
              and effectivedate < enddate
              and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1  

left join personbenoptioncostl poc 
  on poc.personid = pbemfsa.personid
 and poc.personbeneelectionpid = pbemfsa.personbeneelectionpid
 and poc.costsby = 'M'            

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') 
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  and pe.empleventdetcode <> 'Death'
 
 UNION
 
 select distinct

 pi.personid
,'DNT TERMED EE' ::varchar(30) as qsource 
,'0' as dependentid
,'4' ::char(10) as sort_seq
,pn.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitsubclass = '10' then 'BCBS OF SC'
      when pbe.benefitsubclass = '11' then 'DELTA DENTAL'
      when pbe.benefitsubclass = '14' then 'PHYS EYECARE'
      when pbe.benefitsubclass = '60' then 'INFINISOURCE'
      end ::char(15) as plan_code
,case when pbe.benefitsubclass = '10' and bpdmed.benefitplandescshort like 'BCBS PLUS%' then 'MED B PLUS'  
      when pbe.benefitsubclass = '10' and bpdmed.benefitplandescshort like 'BCBS of%' then 'MED A CORE' 
      when pbe.benefitsubclass = '11' then 'DENTAL' 
      when pbe.benefitsubclass = '14' then 'VISION'
      when pbe.benefitsubclass = '60' then 'FSA'
      else null end ::char(15) as coverage_code     
,case when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid = 'EE' then 'SGL'
      when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid = 'F' then 'FAMILY'
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid = 'EE' then 'EE'      
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid in ('EC','EE & 1 Dep') then 'EE+1'
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid in ('EE & Deps','EC') then 'EE+2 OR MORE'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'EE' then 'SGL'      
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'ES' then 'EE+SPOUSE'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'F' then 'FAMILY'      
      when pbe.benefitsubclass = '60' then 'MONTHLY PREMIUM'
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '10' then to_char(pbemed.enddate,'YYYY-MM-DD')      
      when pbe.benefitsubclass = '11' then to_char(pbednt.enddate,'YYYY-MM-DD')
      when pbe.benefitsubclass = '14' then to_char(pbevsn.enddate,'YYYY-MM-DD')
      when pbe.benefitsubclass = '60' then to_char(pbemfsa.enddate,'YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pe.effectivedate,'YYYY-MM-DD')::char(10) as event_date   
,case when pbe.benefitsubclass = '60' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin      

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_address pa 
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts


join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('11')
 and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('11') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)   

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

left join benefit_plan_desc bpdmed
  on bpdmed.benefitsubclass = pbemed.benefitsubclass
 and bpdmed.benefitplanid = pbemed.benefitplanid
 and current_date between bpdmed.effectivedate and bpdmed.enddate
 and current_timestamp between bpdmed.createts and bpdmed.endts            


--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                       
                         
--- medical fsa
left join   (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' 
              and effectivedate < enddate
              and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1  

left join personbenoptioncostl poc 
  on poc.personid = pbemfsa.personid
 and poc.personbeneelectionpid = pbemfsa.personbeneelectionpid
 and poc.costsby = 'M'            

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') 
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  and pe.empleventdetcode <> 'Death'  
 
 UNION
 
 select distinct

 pi.personid
,'VSN TERMED EE' ::varchar(30) as qsource 
,'0' as dependentid
,'4' ::char(10) as sort_seq
,pn.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitsubclass = '10' then 'BCBS OF SC'
      when pbe.benefitsubclass = '11' then 'DELTA DENTAL'
      when pbe.benefitsubclass = '14' then 'PHYS EYECARE'
      when pbe.benefitsubclass = '60' then 'INFINISOURCE'
      end ::char(15) as plan_code
,case when pbe.benefitsubclass = '10' and bpdmed.benefitplandescshort like 'BCBS PLUS%' then 'MED B PLUS'  
      when pbe.benefitsubclass = '10' and bpdmed.benefitplandescshort like 'BCBS of%' then 'MED A CORE' 
      when pbe.benefitsubclass = '11' then 'DENTAL' 
      when pbe.benefitsubclass = '14' then 'VISION'
      when pbe.benefitsubclass = '60' then 'FSA'
      else null end ::char(15) as coverage_code     
,case when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid = 'EE' then 'SGL'
      when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid = 'F' then 'FAMILY'
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid = 'EE' then 'EE'      
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid in ('EC','EE & 1 Dep') then 'EE+1'
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid in ('EE & Deps','EC') then 'EE+2 OR MORE'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'EE' then 'SGL'      
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'ES' then 'EE+SPOUSE'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'F' then 'FAMILY'      
      when pbe.benefitsubclass = '60' then 'MONTHLY PREMIUM'
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '10' then to_char(pbemed.enddate,'YYYY-MM-DD')      
      when pbe.benefitsubclass = '11' then to_char(pbednt.enddate,'YYYY-MM-DD')
      when pbe.benefitsubclass = '14' then to_char(pbevsn.enddate,'YYYY-MM-DD')
      when pbe.benefitsubclass = '60' then to_char(pbemfsa.enddate,'YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pe.effectivedate,'YYYY-MM-DD')::char(10) as event_date   
,case when pbe.benefitsubclass = '60' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin      

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_address pa 
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts


join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('14')
 and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('14') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)   

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

left join benefit_plan_desc bpdmed
  on bpdmed.benefitsubclass = pbemed.benefitsubclass
 and bpdmed.benefitplanid = pbemed.benefitplanid
 and current_date between bpdmed.effectivedate and bpdmed.enddate
 and current_timestamp between bpdmed.createts and bpdmed.endts            


--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                       
                         
--- medical fsa
left join   (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' 
              and effectivedate < enddate
              and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1  

left join personbenoptioncostl poc 
  on poc.personid = pbemfsa.personid
 and poc.personbeneelectionpid = pbemfsa.personbeneelectionpid
 and poc.costsby = 'M'            

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') 
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  and pe.empleventdetcode <> 'Death'     
 
 UNION
 
 select distinct

 pi.personid
,'FSA TERMED EE' ::varchar(30) as qsource 
,'0' as dependentid
,'4' ::char(10) as sort_seq
,pn.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitsubclass = '10' then 'BCBS OF SC'
      when pbe.benefitsubclass = '11' then 'DELTA DENTAL'
      when pbe.benefitsubclass = '14' then 'PHYS EYECARE'
      when pbe.benefitsubclass = '60' then 'INFINISOURCE'
      end ::char(15) as plan_code
,case when pbe.benefitsubclass = '10' and bpdmed.benefitplandescshort like 'BCBS PLUS%' then 'MED B PLUS'  
      when pbe.benefitsubclass = '10' and bpdmed.benefitplandescshort like 'BCBS of%' then 'MED A CORE' 
      when pbe.benefitsubclass = '11' then 'DENTAL' 
      when pbe.benefitsubclass = '14' then 'VISION'
      when pbe.benefitsubclass = '60' then 'FSA'
      else null end ::char(15) as coverage_code     
,case when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid = 'EE' then 'SGL'
      when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbe.benefitsubclass = '10' and bcd.benefitcoveragecodexid = 'F' then 'FAMILY'
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid = 'EE' then 'EE'      
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid in ('EC','EE & 1 Dep') then 'EE+1'
      when pbe.benefitsubclass = '11' and bcd.benefitcoveragecodexid in ('EE & Deps','EC') then 'EE+2 OR MORE'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'EE' then 'SGL'      
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'ES' then 'EE+SPOUSE'
      when pbe.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'F' then 'FAMILY'      
      when pbe.benefitsubclass = '60' then 'MONTHLY PREMIUM'
      else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '10' then to_char(pbemed.enddate,'YYYY-MM-DD')      
      when pbe.benefitsubclass = '11' then to_char(pbednt.enddate,'YYYY-MM-DD')
      when pbe.benefitsubclass = '14' then to_char(pbevsn.enddate,'YYYY-MM-DD')
      when pbe.benefitsubclass = '60' then to_char(pbemfsa.enddate,'YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pe.effectivedate,'YYYY-MM-DD')::char(10) as event_date   
,case when pbe.benefitsubclass = '60' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin      

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_address pa 
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts


join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('60')
 and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)   

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

left join benefit_plan_desc bpdmed
  on bpdmed.benefitsubclass = pbemed.benefitsubclass
 and bpdmed.benefitplanid = pbemed.benefitplanid
 and current_date between bpdmed.effectivedate and bpdmed.enddate
 and current_timestamp between bpdmed.createts and bpdmed.endts            


--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                       
                         
--- medical fsa
left join   (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' 
              and effectivedate < enddate
              and current_timestamp between createts and endts 
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1  

left join personbenoptioncostl poc 
  on poc.personid = pbemfsa.personid
 and poc.personbeneelectionpid = pbemfsa.personbeneelectionpid
 and poc.costsby = 'M'            

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') 
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  and pe.empleventdetcode <> 'Death'