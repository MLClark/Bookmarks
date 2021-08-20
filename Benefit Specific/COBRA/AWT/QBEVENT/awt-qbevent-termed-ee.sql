SELECT distinct  
 pi.personid
,pe.emplstatus 
,'TERMED EE' ::varchar(30) as qsource  
,'[QBEVENT]' :: VARchar(35) as recordtype
,case when pe.emplevent = 'InvTerm' and pe.empleventdetcode = 'Death' then 'DEATH'
      when pe.emplstatus = 'T' and pe.emplevent = 'VolTerm' then 'TERMINATION'
      when pe.emplstatus = 'T' and pe.emplevent = 'InvTerm' then 'INVOLUNTARYTERMINATION'
      when pe.emplstatus = 'A' and pe.emplevent = 'FullPart' then 'REDUCTIONINHOURS-STATUSCHANGE'
      when pe.emplstatus = 'A' and pe.emplevent = 'LvReturn' then 'REDUCTIONINHOURS-ENDOFLEAVE'
      when pe.emplstatus = 'R' then 'RETIREMENT'
      else pe.emplevent end ::varchar(35) as event_type
,to_char(pe.effectivedate,'MM/DD/YYYY') ::char(10) as eventdate
,TO_CHAR(coalesce(pbee.effectivedate,pbe.effectivedate),'MM/DD/YYYY') ::char(10) as enrollmentdate
,replace(pi.identity,'-',''):: char(9) as emp_ssn

,pn.fname||' '||pn.lname ::varchar(100) as emp_name
,' ' ::char(1) as SecondEventOriginalFDOC

,'2A' ::char(10) as sort_seq


FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AWT_Discovery_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 
JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','60','61')
 and pe.effectivedate - interval '1 day' between pbe.effectivedate and pbe.enddate
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
 
left JOIN 
(select distinct personid, enddate, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('10','11','60','61')
   and enddate < '2199-12-30'
   and benefitelection = 'E'
   and selectedoption = 'Y'
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and effectivedate < enddate
   group by 1,2)
 pbee on pbee.personid = pbe.personid 

LEFT JOIN person_names pn 
  ON pn.personid = pe.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  and pe.emplstatus in ('R','T')
  and pe.personid = '7117'