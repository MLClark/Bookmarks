select distinct

 pi.personid
,'TERMED EE' ::varchar(30)
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
 and pba.eventeffectivedate >= elu.lastupdatets::date  
 and pba.eventname in ('TER','OAC','FTP')  

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 --and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
 and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1      

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                     
                                          
--- medical fsa
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1  


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') 
  and pe.benefitstatus in ('T','A')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  and pe.emplclass <> 'P'
  and pe.empleventdetcode <> 'Death'
  
  UNION 
 
 select distinct
 pi.personid
,'TERMED EE DEP' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'3' ::char(10) as sort_seq
,'QB' ::char(3) as recordtype
,to_char(greatest(pbemed.effectivedate, pbednt.effectivedate, pbevsn.effectivedate, pbemfsa.effectivedate, pe.effectivedate),'YYYY-MM-DD')::char(10) as event_date
,case when pe.emplevent = 'VolTerm' then 'Termination of Employment'
      when pe.emplevent = 'InvTerm' then 'Involuntary Termination of Employment'
      when pe.emplevent = 'Retire'  then 'Termination of Employment'
      else 'Termination of Employment' end ::char(50) as event_code
,left(pid.identity,3)||'-'||substring(pid.identity,4,2)||'-'||right(pid.identity,4) ::char(12) as ssn
,to_char(pvd.birthdate,'yyyy-mm-dd')::char(10) as dob
,pnd.fname ::char(25) as fname
,pnd.lname ::char(35) as lname
,pnd.mname ::char(1) as mname
,case when pdr.dependentrelationship in ('SP','DP','NA','X') then 'Spouse'
      when pdr.dependentrelationship in ('C','S','D','ND','NS','NC') then 'Dependent' else 'Other' end ::char(10) as relationship_code
,pa.streetaddress ::char(55) as addr1
,pa.streetaddress2::char(55) as addr2
,pa.city ::char(35) as city
,pa.stateprovincecode ::char(5) as state
,pa.postalcode ::char(15) as zipcode
,case when pa.countrycode = 'US' then 'USA' else pa.countrycode end ::char(3) as country
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
 and pba.eventeffectivedate >= elu.lastupdatets::date  
 and pba.eventname in ('TER','OAC','FTP')    

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 --and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','60')
 and pe.effectivedate - interval '1 day' <= pbe.effectivedate 
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1      

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                     
                                          
--- medical fsa
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1   

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
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') AND pe.empleventdetcode <> 'Death'
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )      

  UNION 
   
select distinct

 pi.personid
,'DECEASED EE DEP' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'3' ::char(10) as sort_seq
,'QB' ::char(3) as recordtype
,to_char(greatest(pbemed.effectivedate, pbednt.effectivedate, pbevsn.effectivedate, pbemfsa.effectivedate, pe.effectivedate),'YYYY-MM-DD')::char(10) as event_date
,'Death of the Employee' ::char(50) as event_code
,left(pid.identity,3)||'-'||substring(pid.identity,4,2)||'-'||right(pid.identity,4) ::char(12) as ssn
,to_char(pvd.birthdate,'yyyy-mm-dd')::char(10) as dob
,pnd.fname ::char(25) as fname
,pnd.lname ::char(35) as lname
,pnd.mname ::char(1) as mname
,'Dependent' ::char(10) as relationship_code
,coalesce(pad.streetaddress,pa.streetaddress) ::char(55) as addr1
,coalesce(pad.streetaddress2,pa.streetaddress2)::char(55) as addr2
,coalesce(pad.city,pa.city) ::char(35) as city
,coalesce(pad.stateprovincecode,pa.stateprovincecode) ::char(5) as state
,coalesce(pad.postalcode,pa.postalcode) ::char(15) as zipcode
,case when coalesce(pad.countrycode,pa.countrycode) = 'US' then 'USA' else coalesce(pad.countrycode,pa.countrycode) end ::char(3) as country

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
 and pba.eventeffectivedate >= elu.lastupdatets::date
 and pba.eventname in ('TER')     

join person_bene_election pbe 
  on pbe.personid = pba.personid
 and pbe.benefitsubclass in ('10','11','14','60')
 and pbe.selectedoption = 'Y' 
 and pe.effectivedate - interval '1 day' between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  

--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1      

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                     
                                          
--- medical fsa
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1    

join 
(select distinct personid, enddate, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('10','11','14','60')
   and enddate < '2199-12-30'
   and selectedoption = 'Y'
   and benefitelection = 'E'
   and date_part('year',enddate)=date_part('year',current_date)
   group by 1,2) maxpbe on maxpbe.personid = pe.personid and maxpbe.rank = 1

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.effectivedate >= maxpbe.effectivedate
 and current_timestamp between de.createts and de.endts
 
LEFT JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

LEFT JOIN person_vitals pvd
  ON pvd.personid = pdr.dependentid 
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts 

left join person_address pad 
  on pad.personid = pdr.dependentid 
 and pad.addresstype = 'Res'
 and current_date between pad.effectivedate and pad.enddate
 and current_timestamp between pad.createts and pad.endts  

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('T','R') AND pe.empleventdetcode = 'Death'
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
     
  /* DEATH EVENTS - EE must have surviving dependents to get included on QE file  */
  and pe.personid in   

(  select distinct pe.personid
 
        from person_employment pe
        join person_benefit_action pba
          on pba.personid = pe.personid
         and pba.eventeffectivedate >= elu.lastupdatets::date  
         and pba.eventname in ('TER')    
        
        JOIN person_bene_election pbe 
          on pbe.personid = pba.personid 
        -- and pbe.personbenefitactionpid = pba.personbenefitactionpid  
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
   
   UNION 
      
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
,coalesce(pad.streetaddress,pa.streetaddress) ::char(55) as addr1
,coalesce(pad.streetaddress2,pa.streetaddress2)::char(55) as addr2
,coalesce(pad.city,pa.city) ::char(35) as city
,coalesce(pad.stateprovincecode,pa.stateprovincecode) ::char(5) as state
,coalesce(pad.postalcode,pa.postalcode) ::char(15) as zipcode
,case when coalesce(pad.countrycode,pa.countrycode) = 'US' then 'USA' else coalesce(pad.countrycode,pa.countrycode) end ::char(3) as country
,case when pdb.disabilitycode is not null then 'Yes' else 'NO ' end ::char(3) as disability_status
from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_QE_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventeffectivedate >= elu.lastupdatets::date  
 and pba.eventname in ('DIV') 
 
join person_bene_election pbe 
  on pbe.personid = pba.personid
 --and pbe.personbenefitactionpid = pba.personbenefitactionpid    
 and pbe.benefitsubclass in ('10','11','14','60')
 and pbe.selectedoption = 'Y' 
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  

--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1      

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                     
                                          
--- medical fsa
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1   

left join person_address pa 
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
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

left join person_identity pid
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
 
left join person_maritalstatus pm
  on pm.personid = pbe.personid 
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts                              
                         
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('A') 
  and pdr.dependentrelationship in ('SP','DP','NA','X') 
  and pbe.effectivedate::date >= elu.lastupdatets::date
  
  UNION
  
select distinct
 pi.personid
,'ACTIVE EE TERMED DEP' ::varchar(30) as qsource 
,pdr.dependentid as dependentid
,'3' ::char(10) as sort_seq
,'QB' ::char(3) as recordtype
,to_char(greatest(pbemed.effectivedate, pbednt.effectivedate, pbevsn.effectivedate, pbemfsa.effectivedate, pe.effectivedate),'YYYY-MM-DD')::char(10) as event_date
,'Dependent Ceasing to be Dep' ::char(50) as event_code
,left(pid.identity,3)||'-'||substring(pid.identity,4,2)||'-'||right(pid.identity,4) ::char(12) as ssn
,to_char(pvd.birthdate,'yyyy-mm-dd')::char(10) as dob
,pnd.fname ::char(25) as fname
,pnd.lname ::char(35) as lname
,pnd.mname ::char(1) as mname
,'Dependent' ::char(10) as relationship_code
,coalesce(pad.streetaddress,pa.streetaddress) ::char(55) as addr1
,coalesce(pad.streetaddress2,pa.streetaddress2)::char(55) as addr2
,coalesce(pad.city,pa.city) ::char(35) as city
,coalesce(pad.stateprovincecode,pa.stateprovincecode) ::char(5) as state
,coalesce(pad.postalcode,pa.postalcode) ::char(15) as zipcode
,case when coalesce(pad.countrycode,pa.countrycode) = 'US' then 'USA' else coalesce(pad.countrycode,pa.countrycode) end ::char(3) as country

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
 and pba.eventeffectivedate >= elu.lastupdatets::date
 and pba.eventname in ('TER','DepAge')     
 
join person_bene_election pbe 
  on pbe.personid = pba.personid
 and pbe.benefitsubclass in ('10','11','14','60')
 and pbe.selectedoption = 'Y' 
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)   
                         
--- medical
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1 

--- dental
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1      

--- vision
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1                     
                                          
--- medical fsa
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts --and personid = '10146'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid) pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1    

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


left join person_identity pid
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

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.effectivedate::date >= elu.lastupdatets::date

  order by personid, ssn


   