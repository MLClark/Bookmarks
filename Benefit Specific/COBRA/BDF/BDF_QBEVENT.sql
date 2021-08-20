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
,TO_CHAR(coalesce(pbee.effectivedate,pbe.effectivedate),'MM/DD/YYYY') ::char(10) as enrollmentdate
,replace(pi.identity,'-',''):: char(9) as emp_ssn

,pn.fname||' '||pn.lname ::varchar(100) as emp_name
,' ' ::char(1) as SecondEventOriginalFDOC
,' ' ::char(1) as IsSecondEventAEIEligible
,'' ::char(1) as SecondEventAEISubsidyStartDate
,'2A' ::char(10) as sort_seq



FROM person_identity pi

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BDF_IGOE_QB_EXPORT'

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 

left join (
select personid,max(effectivedate) as effectivedate
  from person_bene_election 
 where current_timestamp between createts and endts
   and benefitsubclass in ('10','11','14')
   and benefitelection in ('E' )
   and selectedoption = 'Y'      
   group by 1  ) maxeff on maxeff.personid = pe.personid
   

JOIN person_bene_election pbe 
  on pbe.personid = maxeff.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11','14')
 --AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14') and benefitelection = 'E' and selectedoption = 'Y') 
 and pbe.effectivedate = maxeff.effectivedate                         


left JOIN person_bene_election pbee
  on pbee.personid = pi.personid 
 and pbee.selectedoption = 'Y' 
 and pbee.benefitsubclass in ('10','11','14')
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

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'T'
  and (pe.effectivedate >= elu.lastupdatets::DATE 
 --  or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) 
   )   


order by  pi.personid