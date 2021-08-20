select
  pi.personid
, '135873'                                           as policy
, '0001'                                             as division
, coalesce(piz.identity,pi.identity)                 as ssn
, to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10)   as hiredate
, to_char(pc.compamount,'99999999D99')               as salary
, pc.frequencycode                                   as salarymode
, CASE WHEN pc.frequencycode = 'H' THEN
    to_char(emplfulltimepercent*40/100,'99D99')
  ELSE ' ' END                                       as hoursworked
, CASE WHEN pbe.personbeneelectionevent = 'Term' THEN to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) 
  ELSE NULL END as termdate
, CASE WHEN pe.emplstatus = 'T' THEN 'TE'
       WHEN pe.emplstatus = 'R' THEN 'RT'
       WHEN pe.emplstatus = 'D' THEN 'DT'
       WHEN pe.emplstatus = 'L' THEN 'LO'
  ELSE '  ' END                                      as termreason
, CASE WHEN piz.identity IS NULL THEN ' '
  ELSE pi.identity END                               as newmemberid
, pn.fname                                           as fname
, LEFT(pn.mname,1)                                   as mname
, pn.lname                                           as lname
, pn.title                                           as suffix
, pv.gendercode                                      as gender
, to_char(pv.birthdate, 'MM/dd/YYYY')::char(10)      as dob
, '2002'                                             as class
, to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) as sigdate
, to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) as effdate

, CASE
    WHEN pe.Emplevent = 'Hire' AND pe.empleventdetcode IN ('H','NHR') THEN 'O'
    WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'O'
    ELSE ' '
  END                                                  as addtype

, ed.feedID                                          as feedid
, now()                                              as updatets

from person_identity pi

join person_payroll pp
  on pp.personid = pi.personid
 and current_date      between pp.effectivedate AND pp.enddate
 and current_timestamp between pp.createts AND pp.endts

join pay_unit pu 
  on pu.payunitid = pp.payunitid

join person_names pn on pi.personid = pn.personid
     and current_date between pn.effectivedate and pn.enddate
     and current_timestamp between pn.createts and pn.endts
     and pn.nametype = 'Legal'

join person_vitals pv on pi.personid = pv.personid
     and current_date between pv.effectivedate and pv.enddate
     and current_timestamp between pv.createts and pv.endts

join person_employment pe on pi.personid = pe.personid
     and current_date between pe.effectivedate and pe.enddate
     and current_timestamp between pe.createts and pe.endts

join person_compensation pc on pc.personid = pe.personid
     and pc.earningscode <> 'BenBase'
     and current_date between pc.effectivedate and pc.enddate
     and current_timestamp between pc.createts and pc.endts

left join person_identity piz on piz.personid = pe.personid
     and piz.identitytype = 'SSN'
     and piz.endts = (select max(pizm.endts) 
                        from person_identity pizm
                       where pizm.personid = piz.personid
                         and pizm.identitytype = 'SSN'
                         and pizm.endts < pi.endts)

join person_bene_election pbe on pi.personid = pbe.personid
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts
     and pbe.benefitplanid in ('23')

join edi.edi_last_update ed on ed.feedID = 'Unum_StdLifeADD_Export'

where pi.identitytype = 'SSN'
  and (current_timestamp between pi.createts and pi.endts

and
(
exists (select 1 
          from person_identity pi1
         where pi1.personid     = pi.personid
             and pi1.identitytype = 'SSN' 
           and pi1.createts      between ed.lastupdatets and now()
        )
or
exists (select 1 
          from person_names pn1
         where pn1.personid = pi.personid
           and pn1.nametype = 'Legal' 
           and (pn1.effectivedate between ed.lastupdatets and now()
            or  pn1.createts      between ed.lastupdatets and now())
        )
or
exists (select 1 
          from person_vitals pv1
         where pv1.personid = pi.personid
           and (pv1.effectivedate between ed.lastupdatets and now()
            or  pv1.createts      between ed.lastupdatets and now())
        )   
or
exists (select 1 
          from person_employment pe1
         where pe1.personid = pi.personid
           and (pe1.effectivedate between ed.lastupdatets and now()
            or  pe1.createts      between ed.lastupdatets and now())
        )
or
exists (select 1 
          from person_compensation pc1
         where pc1.personid = pi.personid
           and (pc1.effectivedate between ed.lastupdatets and now()
            or  pc1.createts      between ed.lastupdatets and now())
        )             
or
exists (select 1 
          from person_bene_election pbe1
         where pbe1.personid = pi.personid
           and pbe.benefitplanid in ('23')
           and (pbe1.effectivedate between ed.lastupdatets and now()
            or  pbe1.createts      between ed.lastupdatets and now())
        )           
)           
)
