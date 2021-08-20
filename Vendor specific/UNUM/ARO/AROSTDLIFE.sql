select distinct
  pi.personid
, '691090'                                               as policy
--- STD division = 0001 LTD division = 0002

, '0001'                                                 as division

, coalesce(piz.identity,pi.identity)                     as ssn
, to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10)       as hiredate
, to_char(pc.compamount,'99999999D99')                   as salary
, case when pe.emplstatus    = 'T' then null
       when pc.frequencycode = 'H' then 'H' 
       else  coalesce(pc.frequencycode,'A') end          as salarymode
, CASE WHEN pc.frequencycode = 'H' 
       THEN to_char(emplfulltimepercent*40/100,'99D99') 
       ELSE ' ' END                                      as hoursworked
, CASE WHEN pbe.benefitelection in ('T') 
       THEN to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) 
       ELSE NULL END                                     as termdate
,pbe.benefitelection       
, CASE WHEN pe.emplstatus       = 'T' THEN 'TE'
       when pbe.benefitelection = 'T' THEN 'TE'
       WHEN pe.emplstatus       = 'R' THEN 'RT'
       WHEN pe.emplstatus       = 'D' THEN 'DT'
       WHEN pe.emplstatus       = 'L' THEN 'LO'
  ELSE '  ' END                                          as termreason
, CASE WHEN piz.identity IS NULL THEN ' '  
       ELSE pi.identity END                              as newmemberid
, pn.fname                                               as fname
, LEFT(pn.mname,1)                                       as mname
, pn.lname                                               as lname
, pn.title                                               as suffix
, pv.gendercode                                          as gender
, to_char(pv.birthdate, 'MM/dd/YYYY')::char(10)          as dob
, '0100'                                                 as class

, to_char(pbewo.effectivedate,'MM/dd/YYYY')::char(10)    as sigdate
, to_char(greatest(pbe.effectivedate,pe.effectivedate), 'MM/dd/YYYY')::char(10) as effdate
, pe.Emplevent
, CASE
    WHEN pe.Emplevent = 'Hire' AND pe.empleventdetcode IN ('H','NHR') THEN ' '
    WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'O'
    ELSE ' '  END                                        as addtype

, CASE WHEN pbewo.effectivedate IS NULL THEN NULL
  ELSE 'WO' END                                          as benidwo
, CASE WHEN pbewo.effectivedate IS NULL THEN NULL 
       when pbewo.benefitplanid = '9' 
       then '.60VVA' else '.60VVB' END                   as plcdwo
, to_char(pbewo.effectivedate, 'MM/dd/YYYY')::char(10)   as qualdatewo
, CASE WHEN pbewo.benefitelection in ('T') 
       THEN to_char(pbewo.effectivedate , 'mm/dd/yyyy')
       ELSE NULL END                                     as termdatewo
--, pbewo.coverageamount as covamtwo  --leave blank
, ' ' as covamtwo
, CASE WHEN pbewo.effectivedate IS NULL THEN NULL 
       else 'Y' end                                      AS benefitselectionwo


from person_identity pi

join edi.edi_last_update ed on ed.feedID = 'ARO_Unum_STD_Export'


left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
--- employees corrected ssn
left join person_identity piz 
  on piz.personid = pe.personid
 and piz.identitytype = 'SSN'
 and piz.endts = (select max(pizm.endts) 
                        from person_identity pizm
                       where pizm.personid = piz.personid
                         and pizm.identitytype = 'SSN'
                         and pizm.endts < pi.endts)
 and pi.createts >= ed.lastupdatets                         

left join person_names pn 
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

left join person_vitals pv 
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_compensation pc 
  on pc.personid = pe.personid
 and pc.earningscode <> 'BenBase'
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 

join person_bene_election pbe 
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('30')
 and pbe.benefitelection in ('T','E')

-- wo = Select STD
left join person_bene_election pbewo 
  on pbewo.personid = pi.personid
 and current_date between pbewo.effectivedate and pbewo.enddate
 and current_timestamp between pbewo.createts and pbewo.endts
 and pbewo.benefitsubclass in ('30') 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts

AND 
( 
   (
exists (select 1 
          from person_bene_election pbed
         where pi.personid = pbed.personid
           and current_date      between pbed.effectivedate and pbed.enddate
           and current_timestamp between pbed.createts      and pbed.endts  
           and pbed.effectivedate >= ed.lastupdatets      
           and pbed.benefitsubclass in ('30'))
AND 
   (    
exists (select 1 
          from person_identity pi1
         where pi1.personid = pi.personid
           and pi1.identitytype = 'SSN' 
           and current_timestamp between pi1.createts and pi1.endts
           and pi1.createts > ed.lastupdatets)
or
exists (select 1 
          from person_names pn1
         where pn1.personid = pi.personid
           and pn1.nametype = 'Legal' 
           and current_date between pn1.effectivedate and pn1.enddate
           and current_timestamp between pn1.createts and pn1.endts
           and greatest(pn1.effectivedate,pn1.createts) > ed.lastupdatets)
or
exists (select 1 
          from person_vitals pv1
         where pv1.personid = pi.personid
           and current_date between pv1.effectivedate and pv1.enddate
           and current_timestamp between pv1.createts and pv1.endts
           and greatest(pv1.effectivedate,pv1.createts) > ed.lastupdatets)   
or
exists (select 1 
          from person_employment pe1
         where pe1.personid = pi.personid
           and current_date between pe1.effectivedate and pe1.enddate
           and current_timestamp between pe1.createts and pe1.endts
           and greatest(pe1.effectivedate,pe1.createts) > ed.lastupdatets)
or
exists (select 1 
          from person_compensation pc1
         where pc1.personid = pi.personid
           and current_date between pc1.effectivedate and pc1.enddate
           and current_timestamp between pc1.createts and pc1.endts
           and greatest(pc1.effectivedate,pc1.createts) > ed.lastupdatets)              
      ) 
   )
OR (exists (select 1 
          from person_bene_election pbe1wo
         where pbe1wo.personid = pi.personid
           and pbe1wo.benefitsubclass in ('30')
           and current_date between pbe1wo.effectivedate and pbe1wo.enddate
           and current_timestamp between pbe1wo.createts and pbe1wo.endts
           and greatest(pbe1wo.effectivedate,pbe1wo.createts) > ed.lastupdatets)                
   ) 
)     
;