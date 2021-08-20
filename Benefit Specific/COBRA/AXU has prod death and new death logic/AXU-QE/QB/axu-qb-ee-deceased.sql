select distinct

 pi.personid
,'DECEASED EE' ::varchar(30)
,'0' as dependentid
,'3' ::char(10) as sort_seq
,'QB' ::char(3) as recordtype
,to_char(greatest(pbemed.effectivedate, pbednt.effectivedate, pbevsn.effectivedate, pbemfsa.effectivedate, pe.effectivedate),'YYYY-MM-DD')::char(10) as event_date
,case when pe.empleventdetcode = 'Death' then 'Death of the Employee'
      when pe.emplevent = 'VolTerm' then 'Termination of Employment'
      when pe.emplevent = 'InvTerm' then 'Involuntary Termination of Employment'
      when pe.emplevent = 'Retire'  then 'Termination of Employment'
      else 'Termination of Employment' end ::char(50) as event_code
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(12) as ssn
,to_char(pv.birthdate,'yyyy-mm-dd')::char(10) as dob
,pn.fname ::char(25) as fname
,pn.lname ::char(35) as lname
,pn.mname ::char(1) as mname
,'Employee' ::char(10) as relationship_code
,pa.streetaddress ::char(55) as addr1
,pa.streetaddress2::char(55) as addr2
,pa.city ::char(35) as city
,pa.stateprovincecode ::char(5) as state
,pa.postalcode ::char(15) as zipcode
,case when pa.countrycode = 'US' then 'USA' else pa.countrycode end ::char(3) as country
,case when pdb.disabilitycode is not null then 'Yes' else 'NO ' end ::char(3) as disability_status

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

left join person_disability pdb
  on pdb.personid = pe.personid
 and current_date between pdb.effectivedate and pdb.enddate
 and current_timestamp between pdb.createts and pdb.endts

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
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid
                 ,max(effectivedate) as effectivedate, max(enddate) as enddate
                 ,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' 
              and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

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


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') 
  and pe.benefitstatus in ('T','A')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  and pe.emplclass <> 'P'
  and pe.empleventdetcode = 'Death'
  and pe.personid in 
  (
  select distinct
 pe.personid
 
from person_employment pe
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
   

where pe.empleventdetcode = 'Death'
  )
