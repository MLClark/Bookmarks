SELECT distinct  
 pi.personid
,'[QBEVENT]' :: VARchar(35) as recordtype
,case when pe.emplstatus = 'T' and pe.emplevent = 'VolTerm' then 'TERMINATION'
      when pe.emplstatus = 'T' and pe.emplevent = 'InvTerm' then 'INVOLUNTARYTERMINATION'
      when pe.emplstatus = 'A' and pe.emplevent = 'FullPart' then 'REDUCTIONINHOURS-STATUSCHANGE'
      when pe.emplstatus = 'A' and pe.emplevent = 'LvReturn' then 'REDUCTIONINHOURS-ENDOFLEAVE'
      when pe.emplstatus = 'R' then 'RETIREMENT'
      else pe.emplevent end ::varchar(35) as event_type
,to_char(pe.effectivedate,'MM/DD/YYYY') ::char(10) as eventdate
,TO_CHAR(pbe.effectivedate,'MM/DD/YYYY') ::char(10) as enrollmentdate
,replace(pi.identity,'-',''):: char(9) as emp_ssn

,pn.fname||' '||pn.lname ::varchar(100) as emp_name
,' ' ::char(1) as secondeventoriginalfdoc
,'2A' ::char(10) as sort_seq


FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AVS_BasicPacific_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid,max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
       from person_bene_election where benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate and current_timestamp between createts and endts             
      group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid) pbe on pbe.personid = pe.personid and pbe.rank = 1

LEFT JOIN person_names pn 
  ON pn.personid = pe.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.effectivedate >= elu.lastupdatets::DATE 
  and pe.emplstatus = 'T'

order by  pi.personid