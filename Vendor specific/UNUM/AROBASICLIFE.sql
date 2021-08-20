select distinct
 pi.personid
,'631298' ::char(6) as policy
,'0001' ::char(4) as division
, coalesce(piz.identity,pi.identity) as ssn
, to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10)   as hiredate
, to_char(pc.compamount,'99999999D99')               as salary
, pc.frequencycode                                   as salarymode
, CASE WHEN pe.emplstatus in ('R','T') then ' '
       WHEN pc.frequencycode = 'A' then ' ' 
       WHEN pc.frequencycode = 'H' and pe.emplfulltimepercent > '1.00000' THEN  to_char(emplfulltimepercent*40/100,'99D99')
       WHEN pc.frequencycode = 'W' and pe.emplfulltimepercent > '1.00000' THEN  to_char(emplfulltimepercent*40/100,'99D99')   
       ELSE to_char(emplfulltimepercent*40,'99D99') END  as hoursworked
, CASE WHEN pe.emplstatus IN ('T','R','D','L') THEN to_char(pe.effectivedate,'MM/dd/YYYY')::char(10)  ELSE NULL END as termdate
, CASE WHEN pe.emplstatus = 'T' THEN 'TE'
       WHEN pe.emplstatus = 'R' THEN 'RT'
       WHEN pe.emplstatus = 'D' THEN 'DT'
       WHEN pe.emplstatus = 'L' THEN 'LO'
  ELSE '  ' END                                      as termreason
  
, CASE WHEN piz.identity IS NULL THEN ' '  ELSE pi.identity END as newmemberid
  
, pn.fname                                           as fname
, LEFT(pn.mname,1)                                   as mname
, pn.lname                                           as lname
, pn.title                                           as suffix

, pv.gendercode                                      as gender
, to_char(pv.birthdate, 'MM/dd/YYYY')::char(10)      as dob
,classes.eeocode 
,pe.emplclass
,pe.emplstatus
,case when classes.eeocode is not null then '1001'
      when classes.eeocode is null and pe.emplclass = 'F' and pe.emplstatus in ('A','T','P') then '2002'
      when classes.eeocode is null and pe.emplclass = 'P' and pe.emplstatus in ('A','T','P') then '3003'
      when classes.eeocode is null and pe.emplclass = 'F' and pe.emplstatus = 'R' then '4000'
      when classes.eeocode is null and pe.emplclass = 'P' and pe.emplstatus = 'R' then '5000'
      end as class

    
, to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) as sigdate
, to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) as effdate

, CASE WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'O' ELSE ' ' END as addtype

from person_identity pi

join edi.edi_last_update ed on ed.feedID = 'ARO_Unum_BasicLife-ADD-LTD'

JOIN person_payroll pp
  on pp.personid = pi.personid
 and current_date      between pp.effectivedate AND pp.enddate
 and current_timestamp between pp.createts AND pp.endts

LEFT JOIN pers_pos pos
  ON pos.personid = pi.personid
 AND current_date between pos.effectivedate AND pos.enddate 
 AND current_timestamp between pos.createts AND pos.endts

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
 AND poslast.effectivedate = (SELECT MAX(effectivedate)
                                FROM pers_pos 
                               WHERE personid = poslast.personid)
 AND current_date not between poslast.effectivedate and poslast.enddate

LEFT JOIN pos_org_rel porlast
  ON porlast.positionid = poslast.positionid
 AND porlast.posorgreltype = 'Member'
 AND current_date between porlast.effectivedate AND porlast.enddate 
 AND current_timestamp between porlast.createts      AND porlast.endts

LEFT JOIN rpt_orgstructure roslast
  ON roslast.org1id = porlast.organizationid
 AND roslast.org1type = 'Dept'
  
join person_names pn 
  on pi.personid = pn.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

join person_vitals pv 
  on pi.personid = pv.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

join person_employment pe 
  on pi.personid = pe.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_compensation pc 
  on pc.personid = pe.personid
 and pc.earningscode <> 'BenBase'
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts

left join person_identity piz 
  on piz.personid = pe.personid
 and piz.identitytype = 'SSN'
 and piz.endts = (select max(pizm.endts) 
                    from person_identity pizm
                   where pizm.personid = piz.personid
                     and pizm.identitytype = 'SSN'
                     and pizm.endts < pi.endts)
     and pi.createts >= ed.lastupdatets  
     
left join
( 
  select distinct
      pi.personid
     ,pp.positionid
     ,pj.jobid
     ,jd.jobdesc
     ,jd.eeocode
     ,jd.flsacode
     ,jd.jobcode
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
   where (jd.eeocode in ('11') 
      or  jd.jobcode like '%PH%'
      or  jd.jobcode in ('DENT','PDDT'))
) classes on classes.personid = pi.personid   



join person_bene_election pbe 
  on pi.personid = pbe.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('20','31')

where pi.identitytype = 'SSN'
  and (current_timestamp between pi.createts and pi.endts

and
(
exists (select 1 
          from person_identity pi1
         where pi1.personid     = pi.personid
           and pi1.identitytype = 'SSN' 
           and pi1.createts between ed.lastupdatets and current_timestamp
        )
or
exists (select 1 
          from person_names pn1
         where pn1.personid = pi.personid
           and pn1.nametype = 'Legal' 
           and current_date between pn1.effectivedate and pn1.enddate
           and current_timestamp between pn1.createts and pn1.endts
           and greatest(pn1.effectivedate,pn1.createts) > ed.lastupdatets  
        )
or
exists (select 1 
          from person_vitals pv1
         where pv1.personid = pi.personid
           and current_date between pv1.effectivedate and pv1.enddate
           and current_timestamp between pv1.createts and pv1.endts
           and greatest(pv1.effectivedate,pv1.createts) > ed.lastupdatets  
        )   
or
exists (select 1 
          from person_employment pe1
         where pe1.personid = pi.personid
           and current_date between pe1.effectivedate and pe1.enddate
           and current_timestamp between pe1.createts and pe1.endts
           and greatest(pe1.effectivedate,pe1.createts) > ed.lastupdatets  
        )
or
exists (select 1 
          from person_compensation pc1
         where pc1.personid = pi.personid
           and current_date between pc1.effectivedate and pc1.enddate
           and current_timestamp between pc1.createts and pc1.endts
           and greatest(pc1.effectivedate,pc1.createts) > ed.lastupdatets  
        )             
or
exists (select 1 
          from person_bene_election pbe1
         where pbe1.personid = pi.personid
           and pbe.benefitsubclass in ('20','30')
           and current_date between pbe1.effectivedate and pbe1.enddate
           and current_timestamp between pbe1.createts and pbe1.endts
           and greatest(pbe1.effectivedate,pbe1.createts) > ed.lastupdatets     
        )           
)
)
