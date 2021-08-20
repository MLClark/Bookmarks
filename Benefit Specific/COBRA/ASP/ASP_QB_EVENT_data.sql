select distinct
 PI.PERSONID
,'[QBEVENT]' ::CHAR(9) as cobraid
,case pe.emplevent 
    when 'InvTerm' then 'INVOLUNTARYTERMINATION' 
    when 'VolTerm' then 'TERMINATION'
    when 'Divorce' then 'DIVORCELEGALSEPARATION'
    when 'Retire' then 'RETIREMENT' 
    when 'REDUCTIONINFORCE'  then 'REDUCTIONINFORCE'
    when 'BANKRUPTCY' then 'BANKRUPTCY'
    when 'STATECONTINUATION' then 'STATECONTINUATION'
    when 'LOSSOFELIGIBILITY' then 'LOSSOFELIGIBILITY' 
    when 'REDUCTIONINHOURS-ENDOFLEAVE' then 'REDUCTIONINHOURS-ENDOFLEAVE'
    when 'WORKSTOPPAGE' then 'WORKSTOPPAGE'
    when 'USERRA-TERMINATION' then 'USERRA-TERMINATION'
    when 'USERRA-REDUCTIONINHOURS' then 'USERRA-REDUCTIONINHOURS'
    when 'TERMINATIONWITHSEVERANCE' then 'TERMINATIONWITHSEVERANCE'
    else 'UNKNOWN' end ::varchar(35) AS eventType
,to_char(pe.effectivedate,'MM/DD/YYYY') ::char(10) as eventdate
,TO_CHAR(coalesce(pbe.effectivedate,pbee.effectivedate),'MM/DD/YYYY') ::char(10) as enrollmentdate
,pi.identity ::char(9) as SSN
,pne.fname||' '||pne.lname ::varchar(100) as empname
,' ' ::char(1) as second_event_original_fdoc
,2 as sort_seq

FROM person_identity pi
LEFT join edi.edi_last_update elu on elu.feedid = 'ASP_SHDR_COBRA_QB_Export'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11','14','6Z')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','6Z') and benefitelection = 'E' and selectedoption = 'Y')

left JOIN person_bene_election pbee
  on pbee.personid = pi.personid 
 and pbee.selectedoption = 'Y' 
 and pbee.benefitsubclass in ('10','11','14','6Z')
 --AND current_date between pbee.effectivedate AND pbee.enddate 
 AND current_timestamp between pbee.createts AND pbee.endts
 and pbee.benefitelection = 'E' and pbee.selectedoption = 'Y'
 and date_part('year',pbee.planyearenddate)=date_part('year',current_date)
 and pbee.benefitactioncode = 'A'


LEFT JOIN person_names pne 
  ON pne.personid = pi.personid 
 AND pne.nametype = 'Legal'::bpchar 
 AND current_date between pne.effectivedate AND pne.enddate 
 AND current_timestamp between pne.createts AND pne.endts

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.effectivedate >= elu.lastupdatets::DATE 
  and pe.emplstatus = 'T'

order by  pi.personid