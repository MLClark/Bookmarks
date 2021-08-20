select distinct
pe.personid,
pbe.deductionenddate,
pbe.planyearenddate,
  '136161'                                           as policy
, CASE pbe.benefitplanid 
    WHEN '22'  THEN '0003'
    ELSE '0001'
  END                                                as division

, coalesce(piz.identity,pi.identity)                 as ssn

, to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10)   as hiredate
, to_char(pc.compamount,'99999999D99')               as salary
, pc.frequencycode                                   as salarymode
, pe.emplfulltimepercent
, CASE 
    WHEN pc.frequencycode = 'A' then ' ' 
    WHEN pc.frequencycode = 'H' and pe.emplfulltimepercent > '1.00000' THEN  to_char(emplfulltimepercent*40/100,'99D99')
    WHEN pc.frequencycode = 'W' and pe.emplfulltimepercent > '1.00000' THEN  to_char(emplfulltimepercent*40/100,'99D99')   
    ELSE to_char(emplfulltimepercent*40,'99D99')       
  END                                       as hoursworked
  
, pe.emplstatus  
, CASE WHEN pe.emplstatus IN ('T','R','D','L') THEN to_char(pe.effectivedate,'MM/dd/YYYY')::char(10)
  ELSE NULL END                                      as termdate
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
, classes.eeocode
, case when pbe.benefitplanid = '22' then '0100'
       when pbe.benefitplanid <> '22' and classes.eeocode = '11' then '100A'  --- owners
       when pbe.benefitplanid <> '22' and classes.eeocode = '50' then '2002'
       else '3003' end ::char(4) as class 
    
, to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) as sigdate
, to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) as effdate

, CASE
--    WHEN pe.Emplevent = 'Hire' AND pe.empleventdetcode IN ('H','NHR') THEN 'O'
    WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'O'
    ELSE ' '
  END                                                  as addtype

, ed.feedId                                          as feedid
, now()                                              as updatets

from person_identity pi

JOIN person_payroll pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate AND pp.enddate
 and current_timestamp between pp.createts AND pp.endts

JOIN pers_pos pos
  ON pos.personid = pi.personid
 AND current_timestamp between pos.createts AND pos.endts
 AND ( (current_date between pos.effectivedate AND pos.enddate)
     OR
     ( pos.enddate = (SELECT MAX(posm.enddate)
                        FROM pers_pos posm
                       WHERE posm.personid = pos.personid)
     ))

LEFT JOIN position_comp_plan pcp
  ON pcp.positionid = pos.positionid
 AND current_date between pcp.effectivedate AND pcp.enddate 
 AND current_timestamp between pcp.createts AND pcp.endts  

LEFT JOIN pos_org_rel por
  ON por.positionid = pos.positionid
 AND por.posorgreltype = 'Member'
 AND current_date between por.effectivedate AND por.enddate 
 AND current_timestamp between por.createts AND por.endts

LEFT JOIN rpt_orgstructure ros
  ON ros.org1id = por.organizationid
 AND ros.org1type = 'Dept'

LEFT JOIN pers_pos poslast
  ON poslast.personid = pi.personid
 AND (pos.effectivedate - 1) between poslast.effectivedate AND poslast.enddate 
 AND (pos.createts - INTERVAL '1 day')  between poslast.createts      
 AND poslast.endts

LEFT JOIN pos_org_rel porlast
  ON porlast.positionid = poslast.positionid
 AND porlast.posorgreltype = 'Member'
 AND current_date between porlast.effectivedate AND porlast.enddate 
 AND current_timestamp between porlast.createts      AND porlast.endts

LEFT JOIN rpt_orgstructure roslast
  ON roslast.org1id = porlast.organizationid
 AND roslast.org1type = 'Dept'
  
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
     and current_timestamp between pc.createts and pc.endts
     and pc.effectivedate < pc.enddate
     and ( (current_date between pc.effectivedate AND pc.enddate)
         OR
           ( pc.enddate = (SELECT MAX(pcm.enddate)
                              FROM person_compensation pcm
                             WHERE pcm.personid = pc.personid
                               AND pcm.earningscode <> 'BenBase')
         ))

left join person_identity piz on piz.personid = pe.personid
     and piz.identitytype = 'SSN'
     and piz.endts = (select max(pizm.endts) 
                        from person_identity pizm
                       where pizm.personid = piz.personid
                         and pizm.identitytype = 'SSN'
                         and pizm.endts < pi.endts)

left join person_bene_election pbe on pi.personid = pbe.personid
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts
     and pbe.benefitsubclass in ('20','23','31','30')
     
left join
( 
select distinct
pi.personid
,pp.positionid
,pj.jobid
,jd.jobdesc
,jd.eeocode
,jd.flsacode
from person_identity pi
left join pers_pos pp on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 and pp.persposrel = 'Occupies'
left join position_job pj ON pj.positionid = pp.positionid 
 AND current_date between pj.effectivedate AND pj.enddate 
 AND current_timestamp between pj.createts AND pj.endts 
left join job_desc jd ON jd.jobid = pj.jobid 
 AND current_date between jd.effectivedate AND jd.enddate 
 AND current_timestamp between jd.createts AND jd.endts 
where jd.eeocode in ('11','50')
) classes on classes.personid = pi.personid     

join edi.edi_last_update ed on ed.feedID = 'ABDUnum_BasicLifeADD-STD-LTD_Export'

where pi.identitytype = 'SSN'
  and (current_timestamp between pi.createts and pi.endts

and
--(
exists (select 1 
          from person_identity pi1
         where pi1.personid     = pi.personid
             and pi1.identitytype = 'SSN' 
           and pi1.createts      between ed.lastupdatets and current_timestamp
        )
or
exists (select 1 
          from person_names pn1
         where pn1.personid = pi.personid
           and pn1.nametype = 'Legal' 
           and current_date      between pn1.effectivedate and pn1.enddate
           and current_timestamp between pn1.createts      and pn1.endts
           and greatest(pn1.effectivedate,pn1.createts) > ed.lastupdatets  
        )
or
exists (select 1 
          from person_vitals pv1
         where pv1.personid = pi.personid
           and current_date      between pv1.effectivedate and pv1.enddate
           and current_timestamp between pv1.createts      and pv1.endts
           and greatest(pv1.effectivedate,pv1.createts) > ed.lastupdatets  
        )   
or
exists (select 1 
          from person_employment pe1
         where pe1.personid = pi.personid
           and current_date      between pe1.effectivedate and pe1.enddate
           and current_timestamp between pe1.createts      and pe1.endts
           and greatest(pe1.effectivedate,pe1.createts) > ed.lastupdatets  
        )
or
exists (select 1 
          from person_compensation pc1
         where pc1.personid = pi.personid
           and current_date      between pc1.effectivedate and pc1.enddate
           and current_timestamp between pc1.createts      and pc1.endts
           and greatest(pc1.effectivedate,pc1.createts) > ed.lastupdatets  
        )             
or
exists (select 1 
          from person_bene_election pbe1
         where pbe1.personid = pi.personid
           and pbe.benefitsubclass in ('20','23','31','30')
           and current_date      between pbe1.effectivedate and pbe1.enddate
           and current_timestamp between pbe1.createts      and pbe1.endts
           and greatest(pbe1.effectivedate,pbe1.createts) > ed.lastupdatets     
        )           
)
--)
