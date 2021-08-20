SELECT distinct  
 pi.personid
,pe.emplstatus 
,'TERMED EE' ::varchar(30) as qsource 
,'[QBEVENT]' :: VARchar(35) as recordtype
,case when pe.emplstatus = 'T' and pe.empleventdetcode = 'Death' then 'DEATH'
      when pe.emplstatus = 'T' and pe.emplevent = 'VolTerm' then 'TERMINATION'
      when pe.emplstatus = 'T' and pe.emplevent = 'InvTerm' then 'INVOLUNTARYTERMINATION'
      when pe.emplstatus = 'A' and pe.emplevent = 'FullPart' then 'REDUCTIONINHOURS-STATUSCHANGE'
      when pe.emplstatus = 'A' and pe.emplevent = 'LvReturn' then 'REDUCTIONINHOURS-ENDOFLEAVE'
      else pe.emplevent end ::varchar(35) as event_type 
,to_char(pe.effectivedate,'MM/DD/YYYY') ::char(10) as eventdate
,TO_CHAR(coalesce(pbee.effectivedate,pbe.effectivedate),'MM/DD/YYYY') ::char(10) as enrollmentdate
,replace(pi.identity,'-',''):: char(9) as emp_ssn

,pn.fname||' '||pn.lname ::varchar(100) as empname
,' ' ::char(1) as secondeventoriginalfdoc
,'2A' ::char(10) as sort_seq


FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid =  'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 
join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('TER')   

JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
 
left JOIN 
(select distinct personid, enddate, personbenefitactionpid, min(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('10','11','14','15','16','17','60','61')
   and enddate < '2199-12-30'
   and benefitelection <> 'W'
   and selectedoption = 'Y'
   and current_timestamp between createts and endts
   and effectivedate < enddate
   group by 1,2,3)
 pbee on pbee.personid = pba.personid and pbee.rank = 1

LEFT JOIN person_names pn 
  ON pn.personid = pe.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  and pe.emplstatus = 'T'

UNION


SELECT distinct  
 pi.personid
,pe.emplstatus

,'ACTIVE EE TERMED DEP' ::varchar(30) as qsource
,'[QBEVENT]' :: VARchar(35) as recordtype

,case when pm.maritalstatus = 'D' then 'DIVORCELEGALSEPARATION'
      else 'INELIGIBLEDEPENDENT' end ::varchar(35) as event_type
      
,case when pm.maritalstatus = 'D' then to_char(pm.effectivedate,'MM/DD/YYYY')
      ELSE to_char(coalesce(pbeend.enddate,de.enddate),'MM/DD/YYYY') END ::char(10) as eventdate
     
,TO_CHAR(coalesce(pbee.effectivedate,pbe.effectivedate),'MM/DD/YYYY') ::char(10) as enrollmentdate

,replace(pi.identity,'-',''):: char(9) as emp_ssn

,pn.fname||' '||pn.lname ::varchar(100) as empname
,' ' ::char(1) as secondeventoriginalfdoc
,'1A'||de.dependentid ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_benefit_action pba
  on pba.personid = pe.personid
 and pba.eventname in ('DepAge','OAC','DIV','FSC') 
 
JOIN person_bene_election pbe 
  on pbe.personid = pba.personid 
 and pbe.personbenefitactionpid = pba.personbenefitactionpid  
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.effectivedate < pbe.enddate 
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
 
left join 
(select distinct personid, min(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY min(effectivedate) asc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('10','11','14','15','16','17','60','61')
   and enddate < '2199-12-30'
   and benefitelection = 'E'
   and benefitcoverageid > '1'
   group by 1)    as pbee on pbee.personid = pe.personid and pbee.rank = 1   

left join 
(select distinct personid, min(enddate) as enddate,
  RANK() OVER (PARTITION BY personid ORDER BY min(effectivedate) asc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('10','11','14','15','16','17','60','61')
   and enddate < '2199-12-30'
   and benefitelection = 'E'
   and benefitcoverageid > '1'
   group by 1)    as pbeend on pbeend.personid = pe.personid and pbee.rank = 1    

LEFT JOIN person_names pn 
  ON pn.personid = pe.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 and current_timestamp between de.createts and de.endts
 and de.dependentid in 
  ( select distinct de.dependentid as dependentid
    from dependent_enrollment de 
    join person_names pne
      on pne.personid = de.personid
     and pne.nametype = 'Legal'
     and current_date between pne.effectivedate and pne.enddate
     and current_timestamp between pne.createts and pne.endts
     and pne.effectivedate < pne.enddate
    join person_names pnd
      on pnd.personid = de.dependentid
     and pnd.nametype = 'Dep'
     and current_date between pnd.effectivedate and pnd.enddate
     and current_timestamp between pnd.createts and pnd.endts   
     and pnd.effectivedate < pnd.enddate 
    join person_vitals pvd
      on pvd.personid = de.dependentid
     and current_date between pvd.effectivedate and pvd.enddate
     and current_timestamp between pvd.createts and pvd.endts 
     and pvd.effectivedate < pvd.enddate
    join person_dependent_relationship pdr
      on pdr.personid = de.personid
     and pdr.dependentid = de.dependentid
     and current_date between pdr.effectivedate and pdr.enddate
     and current_timestamp between pdr.createts and pdr.endts
     and pdr.effectivedate < pdr.enddate
    join person_employment pe
      on pe.personid = de.personid
     and current_date between pe.effectivedate and pe.enddate
     and current_timestamp between pe.createts and pe.endts
     and pe.effectivedate < pe.enddate
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
     and pbe.selectedoption = 'Y'
     and current_timestamp between pbe.createts and pbe.endts 
     and pbe.effectivedate < pbe.enddate    
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'   
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_timestamp between pdr.createts and pdr.endts
       and pdr.effectivedate < pdr.enddate
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.benefitsubclass in ('10','11','14','15','16','17','60','61')
   )
) 


left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 


WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A' 
order by 1


  

