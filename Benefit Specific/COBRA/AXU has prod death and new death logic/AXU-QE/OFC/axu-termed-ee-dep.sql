select distinct

 pi.personid
,'DEP OFC Record' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'4' ::char(10) as sort_seq
,pnd.name
,'OFC' ::char(3) as recordtype
,case when pbemed.benefitsubclass = '10' then 'BCBS OF SC'
      when pbednt.benefitsubclass = '11' then 'DELTA DENTAL'
      when pbevsn.benefitsubclass = '14' then 'PHYS EYECARE'
      when pbemfsa.benefitsubclass = '60' then 'INFINISOURCE'
      end ::char(15) as plan_code
,case when pbemed.benefitsubclass = '10' and bpdmed.benefitplandescshort like 'BCBS PLUS%' then 'MED B PLUS'  
      when pbemed.benefitsubclass = '10' and bpdmed.benefitplandescshort like 'BCBS of%' then 'MED A CORE' 
      when pbednt.benefitsubclass = '11' then 'DENTAL' 
      when pbevsn.benefitsubclass = '14' then 'VISION'
      when pbemfsa.benefitsubclass = '60' then 'FSA'
      else null end ::char(15) as coverage_code 
,pbe.benefitcoverageid      
,case when pbemed.benefitsubclass = '10' and bcd.benefitcoveragecodexid = 'EE' then 'SGL'
      when pbemed.benefitsubclass = '10' and bcd.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbemed.benefitsubclass = '10' and bcd.benefitcoveragecodexid = 'F' then 'FAMILY'
      when pbednt.benefitsubclass = '11' and bcd.benefitcoveragecodexid = 'EE' then 'EE'      
      when pbednt.benefitsubclass = '11' and bcd.benefitcoveragecodexid in ('EC','EE & 1 Dep') then 'EE+1'
      when pbednt.benefitsubclass = '11' and bcd.benefitcoveragecodexid in ('EE & Deps','EC') then 'EE+2 OR MORE'
      when pbevsn.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'EE' then 'SGL'      
      when pbevsn.benefitsubclass = '14' and bcd.benefitcoveragecodexid in ('EE & 1 Dep','EE & Deps','EC') then 'EE+CHILD(REN)'
      when pbevsn.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'ES' then 'EE+SPOUSE'
      when pbevsn.benefitsubclass = '14' and bcd.benefitcoveragecodexid = 'F' then 'FAMILY'      
      when pbemfsa.benefitsubclass = '60' then 'MONTHLY PREMIUM'
      else null end ::char(15) as option_code
,to_char(greatest(pbemed.enddate,pbednt.enddate,pbevsn.enddate,pbemfsa.enddate),'YYYY-MM-DD')::char(10) as loss_of_coverage_date   
,to_char(pe.effectivedate,'YYYY-MM-DD')::char(10) as event_date   
,' ' ::char(7) as premium
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


join person_bene_election pbe 
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('10','11','14','60')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E' 
 and pbe.effectivedate - interval '1 day' <> pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
   -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)   

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
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1  


--- select dependentrelationship from  person_dependent_relationship group by 1;
join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts  

join dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 and de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date >= de.effectivedate 
 and current_timestamp between de.createts and de.endts          

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts                                  

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') 
  --and (pe.effectivedate >= elu.lastupdatets::DATE 
  -- or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  and (pe.effectivedate >= '2018-01-01'
   or (pe.createts > '2018-01-01' and pe.effectivedate <'2018-01-01' ))  