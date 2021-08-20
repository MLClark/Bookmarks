SELECT distinct  
 pi.personid
,pe.emplstatus
,'[QBEVENT]' :: VARchar(35) as recordtype
,case when pm.maritalstatus = 'D' then 'DIVORCELEGALSEPARATION'
      else pe.emplevent end ::varchar(35) as event_type
,case when pm.maritalstatus = 'D' then to_char(pm.effectivedate,'MM/DD/YYYY')
      ELSE to_char(pe.effectivedate,'MM/DD/YYYY') END ::char(10) as eventdate
,TO_CHAR(coalesce(pbee.effectivedate,pbe.effectivedate),'MM/DD/YYYY') ::char(10) as enrollmentdate
,replace(pi.identity,'-',''):: char(9) as emp_ssn

,pn.fname||' '||pn.lname ::varchar(100) as empname
,' ' ::char(1) as secondeventoriginalfdoc
,'2' ::char(10) as sort_seq

FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AMJ_COBRA_EBC_QB'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

join person_bene_election pbe 
  on pbe.personid = pe.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','15','16','17','60','61')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E','T')
 -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','15','16','17','60','61') and benefitelection = 'E' and selectedoption = 'Y')
 
left JOIN person_bene_election pbee
  on pbee.personid = pi.personid 
 and pbee.selectedoption = 'Y' 
 and pbee.benefitsubclass in ('10','11','14','15')
 --AND current_date between pbee.effectivedate AND pbee.enddate 
 AND current_timestamp between pbee.createts AND pbee.endts
 and pbee.benefitelection = 'E' and pbee.selectedoption = 'Y'
 and date_part('year',pbee.planyearenddate)=date_part('year',current_date)
 and pbee.benefitactioncode = 'A' 

LEFT JOIN person_names pn 
  ON pn.personid = pe.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts

left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A' and pm.maritalstatus = 'D' and pm.effectivedate >= elu.lastupdatets::DATE 

order by  pi.personid