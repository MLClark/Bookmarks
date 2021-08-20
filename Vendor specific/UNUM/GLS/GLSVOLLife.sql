select
  '135873'                                           as policy
, '0001'                                             as division
, coalesce(piz.identity,pi.identity)                 as ssn
, to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10)   as hiredate
, to_char(pc.compamount,'99999999D99')               as salary
, pc.frequencycode                                   as salarymode
, CASE WHEN pc.frequencycode = 'H' THEN
    to_char(emplfulltimepercent*40/100,'99D99')
  ELSE ' ' END                                       as hoursworked
  
, CASE WHEN pe.emplstatus IN ('T','R','D','L') THEN greatest(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate)
  ELSE NULL END                                      as termdate
, CASE WHEN pe.emplstatus = 'T' THEN 'TE'
       WHEN pe.emplstatus = 'R' THEN 'RT'
       WHEN pe.emplstatus = 'D' THEN 'DT'
       WHEN pe.emplstatus = 'L' THEN 'LO'
  ELSE '  ' END                                      as termreason
  
, CASE WHEN piz.identity IS NULL THEN ' '
  ELSE pi.identity END                               as newmemberid

, UPPER(pn.fname)                                    as fname
, UPPER(LEFT(pn.mname,1))                            as mname
, UPPER(pn.lname)                                    as lname
, pn.title                                           as suffix
, pv.gendercode                                      as gender
, to_char(pv.birthdate, 'MM/dd/YYYY')::char(10)      as dob

, UPPER(spn.fname)                                   as sfname
, spv.gendercode                                     as sgender
, to_char(spv.birthdate, 'MM/dd/YYYY')::char(10)     as sdob

, '2002'                                             as class

, to_char(least(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate), 'MM/dd/YYYY')::char(10) as sigdate
, to_char(least(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate), 'MM/dd/YYYY')::char(10) as effdate

, CASE
    WHEN pe.Emplevent = 'Hire' AND pe.empleventdetcode IN ('H','NHR') THEN 'O'
    WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'O'
    ELSE ' '
  END                                                  as addtype

, CASE WHEN pbelm.effectivedate IS NULL THEN NULL
  ELSE 'LM' END                                        as benidlm
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL 
       WHEN pe.emplhiredate >= '07/01/2009' THEN '5.0N22'
  ELSE '5.0N30' END                                    as plcdlm
, to_char(pbelm.effectivedate, 'MM/dd/YYYY')::char(10) as qualdatelm
, CASE WHEN pbelm.personbeneelectionevent = 'Term' THEN pbelm.effectivedate 
  ELSE NULL END                                        as termdatelm
, pbelm.coverageamount                                 as covamtlm

, CASE WHEN pbels.effectivedate IS NULL THEN NULL
  ELSE 'LS' END                                        as benidls
, CASE WHEN pbels.effectivedate IS NULL THEN NULL 
       WHEN pe.emplhiredate >= '07/01/2009' THEN '5.0N47'
  ELSE '5.AN39' END                                    as plcdls
, to_char(pbels.effectivedate, 'MM/dd/YYYY')::char(10) as qualdatels
, CASE WHEN pbels.personbeneelectionevent = 'Term' THEN pbels.effectivedate 
  ELSE NULL END                                        as termdatels
, pbels.coverageamount                                 as covamtls

, CASE WHEN pbelc.effectivedate IS NULL THEN NULL
  ELSE 'LC' END                                        as benidlc
, CASE WHEN pbelc.effectivedate IS NULL THEN NULL 
       WHEN pe.emplhiredate >= '07/01/2009' THEN '5.0N47'
  ELSE '5.0F00' END                                    as plcdlc
, to_char(pbelc.effectivedate, 'MM/dd/YYYY')::char(10) as qualdatelc
, CASE WHEN pbelc.personbeneelectionevent = 'Term' THEN pbelc.effectivedate 
  ELSE NULL END                                        as termdatelc
, pbelc.coverageamount                                 as covamtlc

, CASE WHEN pbeam.effectivedate IS NULL THEN NULL
  ELSE 'AM' END                                        as benidam
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL 
  ELSE '5.0S17' END                                    as plcdam
, to_char(pbeam.effectivedate, 'MM/dd/YYYY')::char(10) as qualdateam
, CASE WHEN pbeam.personbeneelectionevent = 'Term' THEN pbeam.effectivedate 
  ELSE NULL END                                        as termdateam
, pbeam.coverageamount                                 as covamtam

, CASE WHEN pbeas.effectivedate IS NULL THEN NULL
  ELSE 'AS' END                                        as benidas
, CASE WHEN pbeas.effectivedate IS NULL THEN NULL 
  ELSE '5.0L02' END                                    as plcdas
, to_char(pbeas.effectivedate, 'MM/dd/YYYY')::char(10) as qualdateas
, CASE WHEN pbeas.personbeneelectionevent = 'Term' THEN pbeas.effectivedate 
  ELSE NULL END                                        as termdateas
, pbeas.coverageamount                                 as covamtas

, CASE WHEN pbeac.effectivedate IS NULL THEN NULL
  ELSE 'AC' END                                        as benidac
, CASE WHEN pbeac.effectivedate IS NULL THEN NULL 
  ELSE '5.0L23' END                                    as plcdac
, to_char(pbeac.effectivedate, 'MM/dd/YYYY')::char(10) as qualdateac
, CASE WHEN pbeac.personbeneelectionevent = 'Term' THEN pbeac.effectivedate 
  ELSE NULL END                                        as termdateac
, pbeac.coverageamount                                 as covamtac

, ed.feedId                                            as feedid
, now()                                                as updatets

from person_identity pi

join person_payroll pp
  on pp.personid = pi.personid
 and current_date      between pp.effectivedate AND pp.enddate
 and current_timestamp between pp.createts AND pp.endts

join person_names pn on pi.personid = pn.personid
     and current_date between pn.effectivedate and pn.enddate
     and current_timestamp between pn.createts and pn.endts
     and pn.nametype = 'Legal'
     
join person_vitals pv on pi.personid = pv.personid
     and current_date between pv.effectivedate and pv.enddate
     and current_timestamp between pv.createts and pv.endts

left join person_dependent_relationship pdr on pi.personid = pdr.personid
     and current_date      between pdr.effectivedate and pdr.enddate
     and current_timestamp between pdr.createts      and pdr.endts
     and pdr.dependentrelationship = 'SP'

left join person_names spn on spn.personid = pdr.dependentid
     and current_date      between spn.effectivedate and spn.enddate
     and current_timestamp between spn.createts      and spn.endts
     and spn.nametype = 'Dep'

left join person_vitals spv on pdr.personid = spv.personid
     and current_date      between spv.effectivedate and spv.enddate
     and current_timestamp between spv.createts      and spv.endts

left join person_maritalstatus pms on pi.personid = pms.personid
     and current_date between pms.effectivedate and pms.enddate
     and current_timestamp between pms.createts and pms.endts

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

left join person_bene_election pbelm on pi.personid = pbelm.personid
     and current_date      between pbelm.effectivedate and pbelm.enddate
     and current_timestamp between pbelm.createts      and pbelm.endts
     and pbelm.benefitplanid in ('33')

left join person_bene_election pbels on pi.personid = pbels.personid
     and current_date      between pbels.effectivedate and pbels.enddate
     and current_timestamp between pbels.createts      and pbels.endts
     and pbels.benefitplanid in ('30')     

left join person_bene_election pbelc on pi.personid = pbelc.personid
     and current_date      between pbelc.effectivedate and pbelc.enddate
     and current_timestamp between pbelc.createts      and pbelc.endts
     and pbelc.benefitplanid in ('35')     

left join person_bene_election pbeam on pi.personid = pbeam.personid
     and current_date      between pbeam.effectivedate and pbeam.enddate
     and current_timestamp between pbeam.createts      and pbeam.endts
     and pbeam.benefitplanid in ('31')

left join person_bene_election pbeas on pi.personid = pbeas.personid
     and current_date      between pbeas.effectivedate and pbeas.enddate
     and current_timestamp between pbeas.createts      and pbeas.endts
     and pbeas.benefitplanid in ('34')     

left join person_bene_election pbeac on pi.personid = pbeac.personid
     and current_date      between pbeac.effectivedate and pbeac.enddate
     and current_timestamp between pbeac.createts      and pbeac.endts
     and pbeac.benefitplanid in ('36')     

join edi.edi_last_update ed on ed.feedID = 'Unum_VolLifeADD_Export'

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
)
or
(
exists (select 1 
          from person_bene_election pbelm1
         where pi.personid = pbelm1.personid
           and current_date      between pbelm1.effectivedate and pbelm1.enddate
           and current_timestamp between pbelm1.createts      and pbelm1.endts
           and pbelm1.benefitplanid in ('33')
        )         
or
exists (select 1 
          from person_bene_election pbels1
         where pi.personid = pbels1.personid
           and current_date      between pbels1.effectivedate and pbels1.enddate
           and current_timestamp between pbels1.createts      and pbels1.endts
           and pbels1.benefitplanid in ('30')     
        )    
or
exists (select 1 
          from person_bene_election pbelc1
         where pi.personid = pbelc1.personid
           and current_date      between pbelc1.effectivedate and pbelc1.enddate
           and current_timestamp between pbelc1.createts      and pbelc1.endts
           and pbelc1.benefitplanid in ('35')     
        )    
or
exists (select 1 
          from person_bene_election pbeam1
         where pi.personid = pbeam1.personid
           and current_date      between pbeam1.effectivedate and pbeam1.enddate
           and current_timestamp between pbeam1.createts      and pbeam1.endts
           and pbeam1.benefitplanid in ('31')
        )    
or
exists (select 1 
          from person_bene_election pbeas1
         where pi.personid = pbeas1.personid
           and current_date      between pbeas1.effectivedate and pbeas1.enddate
           and current_timestamp between pbeas1.createts      and pbeas1.endts
           and pbeas1.benefitplanid in ('34')     
        )    
or
exists (select 1 
          from person_bene_election pbeac1
         where pi.personid = pbeac1.personid
           and current_date      between pbeac1.effectivedate and pbeac1.enddate
           and current_timestamp between pbeac1.createts      and pbeac1.endts
           and pbeac1.benefitplanid in ('36')     
        )    
        
)
)
;