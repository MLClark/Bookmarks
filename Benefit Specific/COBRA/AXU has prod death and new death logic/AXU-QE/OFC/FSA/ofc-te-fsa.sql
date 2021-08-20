 select distinct

 pi.personid
,'FSA TERMED EE' ::varchar(30) as qsource 
,'0' as dependentid
,'4' ::char(10) as sort_seq
,bpd.benefitplandescshort 
,pbe.benefitplanid
,pbe.benefitoptionid
,pbe.personbeneelectionpid
,pn.name
,'OFC' ::char(3) as recordtype
,case when pbe.benefitsubclass = '60' then 'INFINISOURCE' end ::char(15) as plan_code
,case when pbe.benefitsubclass = '60' then 'FSA' else null end ::char(15) as coverage_code     
,case when pbe.benefitsubclass = '60' then 'MONTHLY PREMIUM' else null end ::char(15) as option_code
,case when pbe.benefitsubclass = '60' then to_char(pbe.effectivedate - interval '1 day','YYYY-MM-DD') end ::char(10) as loss_of_coverage_date  
,to_char(pe.effectivedate,'YYYY-MM-DD')::char(10) as event_date 
,case when pbe.benefitsubclass = '60' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium  
,case when pbe.benefitsubclass = '60' then cast(poc.employeerate as dec(18,2)) else null end  ::char(7) as premium_not_used
,' ' ::char(2) as day_due
,' ' ::char(10) as waiting_period_begin
,' ' ::char(10) as coverage_begin      

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')    

join person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('60')
 and pbe.benefitelection <> 'W'
 and pbe.effectivedate < pbe.enddate
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts AND pbe.endts
 -- to be qualified for cobra EE must have acively participated in qualifying health care plan prior to their last day of employment
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

left join (select personid,personbeneelectionpid,benefitoptionid,max(createts) as createts, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
             from person_bene_election where current_timestamp between createts and endts and benefitsubclass in ('60') 
              and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate --and personid = '915'
            group by 1,2,3) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1               

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts            

left join personbenoptioncostl poc
  on poc.personid = pbemed.personid
 and poc.benefitoptionid = pbemed.benefitoptionid
 and poc.personbeneelectionpid = pbemed.personbeneelectionpid
 and poc.costsby = 'M'          

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') 
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  and pe.empleventdetcode <> 'Death'