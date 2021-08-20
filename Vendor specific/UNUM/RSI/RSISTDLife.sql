select distinct
 pi.personid
--,ros.org4code,ros.org3code,ros.org2code,ros.org1code,roslast.org4code,roslast.org3code,roslast.org2code,roslast.org1code
, '602941'                                           as policy
, CASE COALESCE(ros.org4code,ros.org3code,ros.org2code,ros.org1code,roslast.org4code,roslast.org3code,roslast.org2code,roslast.org1code) 
    WHEN 'MC'  THEN '0001'
    WHEN 'CO2' THEN '0002'
    WHEN 'CO3' THEN '0003'
    WHEN 'CO4' THEN '0004'
  END                                                as division
, coalesce(piz.identity,pi.identity)                 as ssn
, CASE 
    WHEN COALESCE(roslast.org4code,roslast.org3code,roslast.org2code,roslast.org1code) = 'MC'
     AND COALESCE(ros.org4code,ros.org3code,ros.org2code,ros.org1code) <> 'MC' THEN '0001'
    WHEN COALESCE(roslast.org4code,roslast.org3code,roslast.org2code,roslast.org1code) = 'CO2'
     AND COALESCE(ros.org4code,ros.org3code,ros.org2code,ros.org1code) <> 'MC' THEN '0002'
    WHEN COALESCE(roslast.org4code,roslast.org3code,roslast.org2code,roslast.org1code) = 'CO3'
     AND COALESCE(ros.org4code,ros.org3code,ros.org2code,ros.org1code) <> 'MC' THEN '0003'
    WHEN COALESCE(roslast.org4code,roslast.org3code,roslast.org2code,roslast.org1code) = 'CO4'
     AND COALESCE(ros.org4code,ros.org3code,ros.org2code,ros.org1code) <> 'MC' THEN '0004'
    ELSE ' '
  END                                                as priordiv
, to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10)   as hiredate
, to_char(pc.compamount,'99999999D99')               as salary
, pc.frequencycode                                   as salarymode
, CASE WHEN pc.frequencycode = 'H' THEN
    to_char(emplfulltimepercent*40/100,'99D99')
  ELSE ' ' END                                       as hoursworked 




, case when pbe.t_blife_effectivedate is not null and pe.emplstatus IN ('T','R','D','L') THEN to_char(pbe.t_blife_effectivedate , 'MM/dd/YYYY')
       when pbe.t_std_effectivedate is not null and pe.emplstatus IN ('T','R','D','L') THEN to_char(pbe.t_std_effectivedate , 'MM/dd/YYYY')
       when pbe.w_blife_effectivedate is not null and pe.emplstatus IN ('T','R','D','L') THEN to_char(pbe.w_blife_effectivedate , 'MM/dd/YYYY')
       when pbe.w_std_effectivedate is not null and pe.emplstatus IN ('T','R','D','L') THEN to_char(pbe.w_std_effectivedate , 'MM/dd/YYYY')
  ELSE NULL END                                      as termdate

, case when pbe.t_blife_effectivedate is not null and pe.emplstatus = 'T' THEN 'TE'
       when pbe.t_blife_effectivedate is not null and pe.emplstatus = 'R' THEN 'RT'
       when pbe.t_blife_effectivedate is not null and pe.emplstatus = 'D' THEN 'DT'
       when pbe.t_blife_effectivedate is not null and pe.emplstatus = 'L' THEN 'LO'
       
       when pbe.t_std_effectivedate is not null and pe.emplstatus = 'T' THEN 'TE'
       when pbe.t_std_effectivedate is not null and pe.emplstatus = 'R' THEN 'RT'
       when pbe.t_std_effectivedate is not null and pe.emplstatus = 'D' THEN 'DT'
       when pbe.t_std_effectivedate is not null and pe.emplstatus = 'L' THEN 'LO'

       when pbe.w_blife_effectivedate is not null and pe.emplstatus = 'T' THEN 'TE'
       when pbe.w_blife_effectivedate is not null and pe.emplstatus = 'R' THEN 'RT'
       when pbe.w_blife_effectivedate is not null and pe.emplstatus = 'D' THEN 'DT'
       when pbe.w_blife_effectivedate is not null and pe.emplstatus = 'L' THEN 'LO'
       
       when pbe.w_std_effectivedate is not null and pe.emplstatus = 'T' THEN 'TE'
       when pbe.w_std_effectivedate is not null and pe.emplstatus = 'R' THEN 'RT'
       when pbe.w_std_effectivedate is not null and pe.emplstatus = 'D' THEN 'DT'
       when pbe.w_std_effectivedate is not null and pe.emplstatus = 'L' THEN 'LO'
       ELSE '  ' END                                      as termreason


/*

, CASE WHEN pbe.benefitelection in ('T','W') and pe.emplstatus = 'T' THEN 'TE'
       WHEN pbe.benefitelection in ('T','W') and pe.emplstatus = 'R' THEN 'RT'
       WHEN pbe.benefitelection in ('T','W') and pe.emplstatus = 'D' THEN 'DT'
       WHEN pbe.benefitelection in ('T','W') and pe.emplstatus = 'L' THEN 'LO'
  ELSE '  ' END                                      as termreason
*/  


, CASE WHEN piz.identity IS NULL THEN ' '
  ELSE pi.identity END                               as newmemberid


, pn.fname                                           as fname
, LEFT(pn.mname,1)                                   as mname
, pn.lname                                           as lname
, pn.title                                           as suffix
, pv.gendercode                                      as gender
, to_char(pv.birthdate, 'MM/dd/YYYY')::char(10)      as dob



, CASE pcp.compplanid
    WHEN '5' THEN '2002'
    WHEN '6' THEN '1001'        
    WHEN '7' THEN '2002'    
    ELSE '2003'
  END                                              as class
  
/*  
,pbe.e_blife_effectivedate
,pbe.e_std_effectivedate
,pbe.w_blife_effectivedate
,pbe.w_std_effectivedate
,pbe.t_blife_effectivedate
,pbe.t_std_effectivedate
,pe.emplstatus
*/
, to_char(   least(pbe.e_blife_effectivedate,pbe.t_blife_effectivedate,pbe.w_blife_effectivedate,pbe.e_std_effectivedate,pbe.t_std_effectivedate,pbe.w_std_effectivedate), 'MM/dd/YYYY')::char(10)  as sigdate
, to_char(greatest(pbe.e_blife_effectivedate,pbe.t_blife_effectivedate,pbe.w_blife_effectivedate,pbe.e_std_effectivedate,pbe.t_std_effectivedate,pbe.w_std_effectivedate), 'MM/dd/YYYY')::char(10)  as effdate

  
----602942:  O under Add Type should only be used for newly eligible employees – going from part time to full time or from an ineligible eligibility description to an eligible eligibility description.  Please confirm all employees reflecting with O are newly eligible.  If they are not please make correction and send new test files.
---, pe.Emplevent
, CASE
    --WHEN pe.Emplevent = 'Hire' AND pe.empleventdetcode IN ('H','NHR') THEN 'O'
    WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'O'
    ELSE ' '
  END                                               as addtype
      
, ed.feedId                                          as feedid
, now()                                              as updatets
  
from person_identity pi
join edi.edi_last_update ed on ed.feedID = 'RSI_Unum_StdLifeADD_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 --and pe.emplevent = 'Hire'
     
left join person_identity piz
  on piz.personid = pe.personid
 and piz.identitytype = 'SSN'
 and piz.endts = (select max(pizm.endts) 
                    from person_identity pizm
                   where pizm.personid = piz.personid
                     and pizm.identitytype = 'SSN'
                     and pizm.endts < pi.endts)


-------------------------------------------------
join 
(
select 
 pbe_elections.personid
,pbe_elections.elected_blife_effectivedate as e_blife_effectivedate
,pbe_elections.elected_std_effectivedate as e_std_effectivedate
,pbe_terms.elected_blife_effectivedate as t_blife_effectivedate
,pbe_terms.elected_std_effectivedate as t_std_effectivedate
,pbe_waived.elected_blife_effectivedate as w_blife_effectivedate
,pbe_waived.elected_std_effectivedate as w_std_effectivedate

from  
(
select distinct
 max_pbe_dates.personid
,max_pbe_dates.blife_effectivedate as elected_blife_effectivedate
,max_pbe_dates.std_effectivedate as elected_std_effectivedate
,pbe.benefitelection
from

(
 select distinct

 pi.personid 
,max(pbe_blife.effectivedate) as blife_effectivedate
,max(pbe_std.effectivedate)   as std_effectivedate
from person_identity pi

join person_bene_election pbe_blife
  on pbe_blife.personid = pi.personid
 and current_date between pbe_blife.effectivedate and pbe_blife.enddate
 and current_timestamp between pbe_blife.createts and pbe_blife.endts
 and pbe_blife.benefitsubclass in ('20')
                             
join person_bene_election pbe_std
  on pbe_std.personid = pi.personid
 and current_date between pbe_std.effectivedate and pbe_std.enddate
 and current_timestamp between pbe_std.createts and pbe_std.endts
 and pbe_std.benefitsubclass in ('30')    
 
 where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pi.personid = '1961'   
  
  group by 1
) max_pbe_dates  

join person_bene_election pbe 
  on pbe.personid = max_pbe_dates.personid
 and pbe.benefitsubclass in ('20','30')
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and (pbe.effectivedate = max_pbe_dates.blife_effectivedate
  or  pbe.effectivedate = max_pbe_dates.std_effectivedate)
 and benefitelection = 'E'
 
) pbe_elections

left join
(
select distinct
 max_pbe_dates.personid
,max_pbe_dates.blife_effectivedate as elected_blife_effectivedate
,max_pbe_dates.std_effectivedate as elected_std_effectivedate
,pbe.benefitelection
from

(
 select distinct

 pi.personid 
,max(pbe_blife.effectivedate) as blife_effectivedate
,max(pbe_std.effectivedate)   as std_effectivedate
from person_identity pi

join person_bene_election pbe_blife
  on pbe_blife.personid = pi.personid
 and current_date between pbe_blife.effectivedate and pbe_blife.enddate
 and current_timestamp between pbe_blife.createts and pbe_blife.endts
 and pbe_blife.benefitsubclass in ('20')
                             
join person_bene_election pbe_std
  on pbe_std.personid = pi.personid
 and current_date between pbe_std.effectivedate and pbe_std.enddate
 and current_timestamp between pbe_std.createts and pbe_std.endts
 and pbe_std.benefitsubclass in ('30')    
 
 where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pi.personid = '1961'   
  
  group by 1
) max_pbe_dates  

join person_bene_election pbe 
  on pbe.personid = max_pbe_dates.personid
 and pbe.benefitsubclass in ('20','30')
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and (pbe.effectivedate = max_pbe_dates.blife_effectivedate
  or  pbe.effectivedate = max_pbe_dates.std_effectivedate)
 and benefitelection = 'T'
) pbe_terms on pbe_terms.personid = pbe_elections.personid

left join
(
select distinct
 max_pbe_dates.personid
,max_pbe_dates.blife_effectivedate as elected_blife_effectivedate
,max_pbe_dates.std_effectivedate as elected_std_effectivedate
,pbe.benefitelection
from

(
 select distinct

 pi.personid 
,max(pbe_blife.effectivedate) as blife_effectivedate
,max(pbe_std.effectivedate)   as std_effectivedate
from person_identity pi

join person_bene_election pbe_blife
  on pbe_blife.personid = pi.personid
 and current_date between pbe_blife.effectivedate and pbe_blife.enddate
 and current_timestamp between pbe_blife.createts and pbe_blife.endts
 and pbe_blife.benefitsubclass in ('20')
                             
join person_bene_election pbe_std
  on pbe_std.personid = pi.personid
 and current_date between pbe_std.effectivedate and pbe_std.enddate
 and current_timestamp between pbe_std.createts and pbe_std.endts
 and pbe_std.benefitsubclass in ('30')    
 
 where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pi.personid = '1961'   
  
  group by 1
) max_pbe_dates  

join person_bene_election pbe 
  on pbe.personid = max_pbe_dates.personid
 and pbe.benefitsubclass in ('20','30')
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and (pbe.effectivedate = max_pbe_dates.blife_effectivedate
  or  pbe.effectivedate = max_pbe_dates.std_effectivedate)
 and benefitelection = 'W'
) pbe_waived on pbe_waived.personid = pbe_elections.personid
) pbe on pbe.personid = pi.personid


-------------------------------------------------                     
                     
join person_names pn 
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

join person_vitals pv 
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
                          
LEFT JOIN pers_pos pos
  ON pos.personid = pi.personid
 AND current_date between pos.effectivedate AND pos.enddate 
 AND current_timestamp between pos.createts AND pos.endts     
 
left join person_compensation pc 
  on pc.personid = pe.personid
 and pc.earningscode <> 'BenBase'
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts            

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
 AND current_timestamp between porlast.createts AND porlast.endts 
 
    
 
LEFT JOIN rpt_orgstructure roslast
  ON roslast.org1id = porlast.organizationid
 AND roslast.org1type = 'Dept' 



where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pi.personid = '508' 
  


and
(
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
           and pbe1.benefitsubclass in ('20','30')
           and current_date      between pbe1.effectivedate and pbe1.enddate
           and current_timestamp between pbe1.createts      and pbe1.endts
           and greatest(pbe1.effectivedate,pbe1.createts) > ed.lastupdatets     
        )                      
          
)

order by lname

  