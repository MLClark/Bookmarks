SELECT distinct  
 pi.personid
 ,pe.emplstatus
,'ACTIVE EE TERMED DEP' ::varchar(30) as qsource
,'[QBEVENT]' :: VARchar(35) as recordtype
,case when pm.maritalstatus = 'D' then 'DIVORCELEGALSEPARATION'
      when pm.maritalstatusevent = 'DIV' then 'DIVORCELEGALSEPARATION'
      when pm.maritalstatus = 'S' and pm.maritalstatusevent = 'Correct' then 'DIVORCELEGALSEPARATION'
      else 'INELIGIBLEDEPENDENT' end ::varchar(35) as event_type
      
,case when pm.maritalstatus = 'D' then to_char(pm.effectivedate,'MM/DD/YYYY')
      ELSE to_char(de.enddate,'MM/DD/YYYY') END ::char(10) as eventdate
      
,pbee.effectivedate,pbe.effectivedate

,TO_CHAR(coalesce(pbee.effectivedate,pbe.effectivedate),'MM/DD/YYYY') ::char(10) as enrollmentdate

,replace(pi.identity,'-',''):: char(9) as emp_ssn

,pn.fname||' '||pn.lname ::varchar(100) as emp_name
,' ' ::char(1) as SecondEventOriginalFDOC

,'1A'||de.dependentid ::char(10) as sort_seq


FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'


JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  
 
JOIN (select distinct personid, benefitsubclass, max(effectivedate) as effectivedate
  from person_bene_election 
 where benefitsubclass in ('10','11')
   and enddate < '2199-12-30'
   and benefitelection = 'E'
   and effectivedate < current_date
   and date_part('year',enddate)=date_part('year',current_date)
   group by 1,2) pbee on pbee.personid = pbe.personid


LEFT JOIN person_names pn 
  ON pn.personid = pe.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts


join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and pdr.dependentrelationship in ('S','D','C','SP','DP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
--- yes I'm hardcoding this on purpose this is the earliest day I need to go back to get termed dependents for Regina 
 --and de.enddate >= '2018-01-01' 
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
     and pbe.benefitsubclass in ('10','11')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('10','11')
    and pdr.dependentrelationship in ('S','D','C','SP','DP')
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
       and de.benefitsubclass in ('10','11')
       and pdr.dependentrelationship in ('S','D','C','SP','DP')
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