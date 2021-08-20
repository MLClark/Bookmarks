select distinct
 pi.personid
,'DIVORCED DEP' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'3' ::char(10) as sort_seq
,'QB' ::char(3) as recordtype
,to_char(greatest(pbemed.effectivedate, pbednt.effectivedate, pbevsn.effectivedate, pbemfsa.effectivedate, pe.effectivedate),'YYYY-MM-DD')::char(10) as event_date
,'Divorce/Legal Separation' ::char(50) as event_code
,left(pid.identity,3)||'-'||substring(pid.identity,4,2)||'-'||right(pid.identity,4) ::char(12) as ssn
,to_char(pvd.birthdate,'yyyy-mm-dd')::char(10) as dob
,pnd.fname ::char(25) as fname
,pnd.lname ::char(35) as lname
,pnd.mname ::char(1) as mname
,'Spouse' ::char(10) as relationship_code
,pad.streetaddress ::char(55) as addr1
,pad.streetaddress2::char(55) as addr2
,pad.city ::char(35) as city
,pad.stateprovincecode ::char(5) as state
,pad.postalcode ::char(15) as zipcode
,case when pad.countrycode = 'US' then 'USA' else pa.countrycode end ::char(3) as country
,case when pdb.disabilitycode is not null then 'Yes' else 'NO ' end ::char(3) as disability_status

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

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('DIV')    

join person_bene_election pbe 
  on pbe.personid = pba.personid
 and pbe.benefitsubclass in ('10','11','14','60')
 and pbe.selectedoption = 'Y' 
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  
                         
 ----------------------------------------------------------------------
 ---- Don't look for pe.effectivedate - 1 day when dealing with ID ----
 ----------------------------------------------------------------------
/*
For cobra - need to make sure that they had elected benefit coverage on their last day of employment 
(effectivedate - 1 day of term record) is between the effectivedate 
and enddate of the person_bene_election row with benefitelection = 'E' 
*/

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

join person_identity pid
  on pid.personid = pdr.dependentid
 and pid.identitytype = 'SSN'
 and current_timestamp between pid.createts and pid.endts 
 
left join person_vitals pvd
  on pvd.personid = pdr.dependentid
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts
 
LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

left join person_address pad 
  on pad.personid = pdr.dependentid 
 and pad.addresstype = 'Res'
 and current_date between pad.effectivedate and pad.enddate
 and current_timestamp between pad.createts and pad.endts 

left join person_disability pdb
  on pdb.personid = pdr.dependentid 
 and current_date between pdb.effectivedate and pdb.enddate
 and current_timestamp between pdb.createts and pdb.endts
 
join person_maritalstatus pm
  on pm.personid = pbe.personid 
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts                          

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('A') 
  and pm.maritalstatus = 'D'    
  and pdr.dependentrelationship in ('SP','DP','NA','X') 