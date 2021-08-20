select distinct
 pi.personid as group_personid
,pdrch.dependentid as dependentid
,coalesce(rankdep.depid,1) as key_rank
,'TERMED or DECEASED EE' ::varchar(30) as qsource
,'0' ::char(10) as sort_seq
,pi.identity ::char(9) as ssn
,pn.lname ::char(35) as lname
,pn.fname ::char(25) as fname
,pn.mname ::char(1)  as mname
,'"'||pa.streetaddress||'"' ::varchar(50) as addr1
,'"'||pa.streetaddress2||'"' ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,pv.gendercode ::char(1) as gender
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,to_char(pe.empllasthiredate,'mm/dd/yyyy')::char(10) as doh
,to_char(pba.eventeffectivedate,'mm/dd/yyyy')::char(10) as life_event_date
,case when pe.empleventdetcode = 'Death' then 'Death of Employee'
      when pe.emplevent = 'VolTerm' then 'Termination of Employment'
      when pe.emplevent = 'InvTerm' then 'Termination of Employment'
      when pe.emplevent = 'Retire'  then 'Termination of Employment'
      else 'Termination of Employment' end ::varchar(50) as qualifying_event
---------------------
----- MEDICAL   -----
---------------------  
--,pbemed.benefitsubclass 
--,pbemed.benefitplanid-- 6 Medical - Buy-Up 9 Medical - Base Plan
,case when pbemed.benefitsubclass = '10' and pbemed.benefitplanid = '6'  then 'Kaiser BuyUp $3000' --'Regence Buy-Up'
      when pbemed.benefitsubclass = '10' and pbemed.benefitplanid = '9'  then 'Kaiser Base $5000'  --'Regence Base' 
      when pbemed.benefitsubclass = '10' and pbemed.benefitplanid = '96' then 'Kaiser $2000'  --NEW for 2021 Medical BuyUp
      else ' ' end ::varchar(50) as medical_plan
,case when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragecodexid = 'EC' then 'Employee + Children'     
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragecodexid = 'ES' then 'Employee + Spouse'
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragecodexid = 'F'  then 'Family'   
      when pbemed.benefitsubclass = '10' and bcdmed.benefitcoveragecodexid = 'EE' then 'Employee Only' else ' ' end ::varchar(50) as medical_coverage
,case when pbemed.benefitsubclass = '10' then to_char(pbemed.enddate,'mm/dd/yyyy')else ' ' end ::char(10) as medical_end_date                
---------------------
----- DENTAL    -----     
---------------------
,case when pbednt.benefitsubclass = '11' then 'Dental' else ' ' end ::varchar(50) as dental_plan
,case when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragecodexid = 'EC' then 'Employee + Children'     
      when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragecodexid = 'ES' then 'Employee + Spouse'
      when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragecodexid = 'F'  then 'Family'   
      when pbednt.benefitsubclass = '11' and bcddnt.benefitcoveragecodexid = 'EE' then 'Employee Only' else ' ' end ::varchar(50) as dental_coverage
,case when pbednt.benefitsubclass = '11' then to_char(pbednt.enddate,'mm/dd/yyyy')else ' ' end ::char(10) as dental_end_date       
---------------------
----- VISION    -----
---------------------
,case when pbevsn.benefitsubclass = '14' then 'Vision' else ' ' end ::varchar(50) as vision_plan
,case when pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragecodexid = 'EC' then 'Employee + Children'     
      when pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragecodexid = 'ES' then 'Employee + Spouse'
      when pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragecodexid = 'F'  then 'Family'   
      when pbevsn.benefitsubclass = '14' and bcdvsn.benefitcoveragecodexid = 'EE' then 'Employee Only' else ' ' end ::varchar(50) as vision_coverage
,case when pbevsn.benefitsubclass = '14' then to_char(pbevsn.enddate,'mm/dd/yyyy')else ' ' end ::char(10) as vision_end_date  
---------------------
----- FSA       -----
---------------------
,case when pbemfsa.benefitsubclass = '60' then 'FSA' else ' ' end ::varchar(50) as fsa_plan
,case when pbemfsa.benefitsubclass = '60' and bcdmfsa.benefitcoveragecodexid = 'EC' then 'Employee + Children'     
      when pbemfsa.benefitsubclass = '60' and bcdmfsa.benefitcoveragecodexid = 'ES' then 'Employee + Spouse'
      when pbemfsa.benefitsubclass = '60' and bcdmfsa.benefitcoveragecodexid = 'F'  then 'Family'   
      when pbemfsa.benefitsubclass = '60' and bcdmfsa.benefitcoveragecodexid = 'EE' then 'Employee Only' else ' ' end ::varchar(50) as fsa_coverage
,case when pbemfsa.benefitsubclass = '60' then to_char(pbemfsa.enddate,'mm/dd/yyyy')else ' ' end ::char(10) as fsa_end_date  
,case when pbemfsa.benefitsubclass = '60' then pboc.employeerate else null end as ytd_fsa_amount
---------------------
----- SPOUSE    -----
---------------------
,pnsp.lname ::varchar(50) as sp_lname
,pnsp.fname ::varchar(50) as sp_fname
,pisp.identity ::char(9)  as sp_ssn
,to_char(pvsp.birthdate,'mm/dd/yyyy')::char(10) as sp_dob
---------------------
----- DEPENDENT -----
---------------------
,pnch.lname ::varchar(50) as ch_lname
,pnch.fname ::varchar(50) as ch_fname
,pich.identity ::char(9)  as ch_ssn
,to_char(pvch.birthdate,'mm/dd/yyyy')::char(10) as ch_dob
 
,elu.lastupdatets
from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'RBA_Sound_Admin_Cobra_QE_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

-- for termed ee's

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
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
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                       
                         
--- medical fsa
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1  
                                  
left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts
 
left join benefit_coverage_desc bcdmed
  on bcdmed.benefitcoverageid = pbemed.benefitcoverageid
 and current_date between bcdmed.effectivedate and bcdmed.enddate
 and current_timestamp between bcdmed.createts and bcdmed.endts

left join benefit_coverage_desc bcddnt
  on bcddnt.benefitcoverageid = pbednt.benefitcoverageid
 and current_date between bcddnt.effectivedate and bcddnt.enddate
 and current_timestamp between bcddnt.createts and bcddnt.endts

left join benefit_coverage_desc bcdvsn
  on bcdvsn.benefitcoverageid = pbevsn.benefitcoverageid
 and current_date between bcdvsn.effectivedate and bcdvsn.enddate
 and current_timestamp between bcdvsn.createts and bcdvsn.endts   

left join benefit_coverage_desc bcdmfsa
  on bcdmfsa.benefitcoverageid = pbemfsa.benefitcoverageid
 and current_date between bcdmfsa.effectivedate and bcdmfsa.enddate
 and current_timestamp between bcdmfsa.createts and bcdmfsa.endts    
 
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join personbenoptioncostl pboc
  on pboc.personid = pbemfsa.personid
 and pboc.costsby = 'A'
 and pboc.personbeneelectionpid = pbemfsa.personbeneelectionpid

-------------------------- 
----- SPOUSE DATA    -----
--------------------------
left join person_dependent_relationship pdrsp
  on pdrsp.personid = pbe.personid
 and pdrsp.dependentrelationship in ('SP','DP','NA')
 and current_date between pdrsp.effectivedate and pdrsp.enddate
 and current_timestamp between pdrsp.createts and pdrsp.endts

left join dependent_enrollment desp
  on desp.personid = pdrsp.personid
 and desp.dependentid = pdrsp.dependentid
 and desp.selectedoption = 'Y'
 and desp.benefitplanid = pbe.benefitplanid
 and desp.benefitsubclass = pbe.benefitsubclass
 and current_date >= desp.effectivedate 
 and current_timestamp between desp.createts and desp.endts  
 
left join person_identity pisp
  on pisp.personid = pdrsp.dependentid
 and pisp.identitytype = 'SSN'
 and current_timestamp between pisp.createts and pisp.endts
 
left join person_names pnsp
  on pnsp.personid = pdrsp.dependentid
 and pnsp.nametype = 'Dep'
 and current_date between pnsp.effectivedate and pnsp.enddate
 and current_timestamp between pnsp.createts and pnsp.endts
 
left join person_vitals pvsp
  on pvsp.personid = pdrsp.dependentid
 and current_date between pvsp.effectivedate and pvsp.enddate
 and current_timestamp between pvsp.createts and pvsp.endts

-------------------------- 
----- DEPENDENT DATA -----
--------------------------
left join person_dependent_relationship pdrch
  on pdrch.personid = pbe.personid
 and pdrch.dependentrelationship in ('S','D','C','NS','ND','NC')
 and current_date between pdrch.effectivedate and pdrch.enddate
 and current_timestamp between pdrch.createts and pdrch.endts

left join dependent_enrollment dech
  on dech.personid = pdrch.personid
 and dech.dependentid = pdrch.dependentid
 and dech.selectedoption = 'Y'
 and dech.benefitplanid = pbe.benefitplanid
 and dech.benefitsubclass = pbe.benefitsubclass
 and current_date >= dech.effectivedate 
 and current_timestamp between dech.createts and dech.endts  
 
left join person_identity pich
  on pich.personid = pdrch.dependentid
 and pich.identitytype = 'SSN'
 and current_timestamp between pich.createts and pich.endts
 
left join person_names pnch
  on pnch.personid = pdrch.dependentid
 and pnch.nametype = 'Dep'
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts
 
left join person_vitals pvch
  on pvch.personid = pdrch.dependentid
 and current_date between pvch.effectivedate and pvch.enddate
 and current_timestamp between pvch.createts and pvch.endts 
 
left JOIN (select distinct pdr.personid, pdr.dependentid, rank() over(partition by pdr.personid order by  pdr.dependentid asc) as depid
             from person_dependent_relationship pdr where pdr.dependentrelationship in ('S','D','C','NS','ND','NC') and current_date between pdr.effectivedate AND pdr.enddate
              and current_timestamp between pdr.createts AND pdr.endts) rankdep on rankdep.personid = pdrch.personid and rankdep.dependentid = pdrch.dependentid

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') 
  and pe.benefitstatus in ('T','A')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   