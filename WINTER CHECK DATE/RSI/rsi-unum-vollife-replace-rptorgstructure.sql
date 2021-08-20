select distinct
  pi.personid,
--  pe.Emplevent,
  '602942'                                           as policy
,ed.lastupdatets edu
,pbelm.effectivedate as elm
,pbels.effectivedate as els
,pbelc.effectivedate as elc
,pbeam.effectivedate as eam
,pbeas.effectivedate as eas
,pbeac.effectivedate as eac
, CASE COALESCE(ros.org4code,ros.org3code,ros.org2code,ros.org1code) 
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
  
, CASE WHEN pe.emplstatus IN ('T','R','D','L') THEN to_char(greatest(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate), 'MM/dd/YYYY')::char(10)
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
, UPPER(pn.title)                                    as suffix
, pv.gendercode                                      as gender
, to_char(pv.birthdate, 'MM/dd/YYYY')::char(10)      as dob

, UPPER(spn.fname)                                   as sfname
, spv.gendercode                                     as sgender
, to_char(spv.birthdate, 'MM/dd/YYYY')::char(10)     as sdob

, pv.smoker                                          as tobacco
, to_char(pv.smokerquitdate + INTERVAL '1 YEAR', 'MM/dd/YYYY')::char(10) as tobaccochgdt

, '1000'                                             as class

, to_char(least(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate), 'MM/dd/YYYY')::char(10)  as sigdate
, to_char(greatest(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate), 'MM/dd/YYYY')::char(10)  as effdate

----602942:  O under Add Type should only be used for newly eligible employees – going from part time to full time or from an ineligible eligibility description to an eligible eligibility description.  Please confirm all employees reflecting with O are newly eligible.  If they are not please make correction and send new test files.
--,pe.Emplevent 
, CASE
    ---WHEN pe.Emplevent = 'Hire' AND pe.empleventdetcode IN ('H','NHR') THEN 'O'
    WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'O'
    ELSE ' '
  END as addtype    

, CASE WHEN pbelm.effectivedate IS NULL THEN NULL
  ELSE 'LM' END                                        as benidlm
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL 
  ELSE '5.0N02' END                                    as plcdlm
, to_char(pbelm.effectivedate, 'MM/dd/YYYY')::char(10) as qualdatelm
, CASE WHEN pbelm.benefitelection in ('T','W') THEN to_char(pbelm.effectivedate, 'MM/dd/YYYY')::char(10) 
  ELSE NULL END                                        as termdatelm
, pbelm.coverageamount                                 as covamtlm

, CASE WHEN pbeam.effectivedate IS NULL THEN NULL
  ELSE 'AM' END                                        as benidam
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL 
  ELSE '5.0S17' END                                    as plcdam
, to_char(pbeam.effectivedate, 'MM/dd/YYYY')::char(10) as qualdateam
, CASE WHEN pbeam.benefitelection in ('T','W') THEN to_char(pbeam.effectivedate, 'MM/dd/YYYY')::char(10) 
  ELSE NULL END                                        as termdateam
, pbeam.coverageamount                                 as covamtam

, CASE WHEN pbels.effectivedate IS NULL THEN NULL
  ELSE 'LS' END                                        as benidls
, CASE WHEN pbels.effectivedate IS NULL THEN NULL 
  ELSE '5.AN47' END                                    as plcdls
, to_char(pbels.effectivedate, 'MM/dd/YYYY')::char(10) as qualdatels
, CASE WHEN pbels.benefitelection in ('T','W') THEN to_char(pbels.effectivedate, 'MM/dd/YYYY')::char(10) 
  ELSE NULL END                                        as termdatels
, pbels.coverageamount                                 as covamtls

, CASE WHEN pbeas.effectivedate IS NULL THEN NULL
  ELSE 'AS' END                                        as benidas
, CASE WHEN pbeas.effectivedate IS NULL THEN NULL 
  ELSE '5.0L02' END                                    as plcdas
, to_char(pbeas.effectivedate, 'MM/dd/YYYY')::char(10) as qualdateas
, CASE WHEN pbeas.benefitelection in ('T','W') THEN to_char(pbeas.effectivedate, 'MM/dd/YYYY')::char(10) 
  ELSE NULL END                                        as termdateas
, pbeas.coverageamount                                 as covamtas

, CASE WHEN pbelc.effectivedate IS NULL THEN NULL
  ELSE 'LC' END                                        as benidlc
, CASE WHEN pbelc.effectivedate IS NULL THEN NULL 
  ELSE '5.0M04' END                                    as plcdlc
, to_char(pbelc.effectivedate, 'MM/dd/YYYY')::char(10) as qualdatelc
, CASE WHEN pbelc.benefitelection in ('T','W') THEN to_char(pbelc.effectivedate, 'MM/dd/YYYY')::char(10) 
  ELSE NULL END                                        as termdatelc
, pbelc.coverageamount                                 as covamtlc

, CASE WHEN pbeac.effectivedate IS NULL THEN NULL
  ELSE 'AC' END                                        as benidac
, CASE WHEN pbeac.effectivedate IS NULL THEN NULL 
  ELSE '5.0L23' END                                    as plcdac
, to_char(pbeac.effectivedate, 'MM/dd/YYYY')::char(10) as qualdateac
, CASE WHEN pbeac.benefitelection in ('T','W') THEN to_char(pbeac.effectivedate, 'MM/dd/YYYY')::char(10) 
  ELSE NULL END                                        as termdateac
, pbeac.coverageamount                                 as covamtac   

, ed.feedID                                            as feedid
, current_timestamp                                    as updatets

from person_identity pi

join edi.edi_last_update ed on ed.feedID = 'RSI_Unum_VolLifeADD_Export'



LEFT JOIN pers_pos pos
  ON pos.personid = pi.personid
 AND now() between pos.createts      AND pos.endts
AND (now() between pos.effectivedate AND pos.enddate 
      OR
      pos.enddate = (SELECT MAX(pos1.enddate)
                       FROM pers_pos pos1
                      WHERE pos1.personid = pos.personid))

LEFT JOIN pos_org_rel por
  ON por.positionid = pos.positionid
AND por.posorgreltype = 'Member'
AND now() between por.effectivedate AND por.enddate 
 AND now() between por.createts      AND por.endts

LEFT JOIN edi.orgstructure ros
  ON ros.org1id = por.organizationid
AND ros.org1type = 'Dept'

LEFT JOIN pers_pos poslast
  ON poslast.personid = pi.personid
AND (pos.effectivedate - 1) between poslast.effectivedate AND poslast.enddate 
 AND (pos.createts - INTERVAL '1 day')  between poslast.createts      AND poslast.endts

LEFT JOIN pos_org_rel porlast
  ON porlast.positionid = poslast.positionid
AND porlast.posorgreltype = 'Member'
AND now() between porlast.effectivedate AND porlast.enddate 
 AND now() between porlast.createts      AND porlast.endts

LEFT JOIN edi.orgstructure roslast
  ON roslast.org1id = porlast.organizationid
AND roslast.org1type = 'Dept'

join person_names pn on pi.personid = pn.personid
     and current_date      between pn.effectivedate and pn.enddate
     and current_timestamp between pn.createts and pn.endts
     and pn.nametype = 'Legal'
     
join person_vitals pv on pi.personid = pv.personid
     and current_date      between pv.effectivedate and pv.enddate
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

left join person_compensation pc on pc.personid = pe.personid
     and pc.earningscode <> 'BenBase'
     and current_date between pc.effectivedate and pc.enddate
     and current_timestamp between pc.createts and pc.endts

left join person_identity piz on piz.personid = pe.personid
     and piz.identitytype = 'SSN'
     and piz.endts = (select max(pizm.endts) 
                        from person_identity pizm
                       where pizm.personid = piz.personid
                         and pizm.identitytype = 'SSN'
                         and pizm.endts < pi.endts
                         )
     and pi.createts >= ed.lastupdatets  

left join person_bene_election pbelm on pi.personid = pbelm.personid
     and current_date      between pbelm.effectivedate and pbelm.enddate
     and current_timestamp between pbelm.createts      and pbelm.endts
     and pbelm.benefitsubclass in ('21')

left join person_bene_election pbels on pi.personid = pbels.personid
     and current_date      between pbels.effectivedate and pbels.enddate
     and current_timestamp between pbels.createts      and pbels.endts   
     and pbels.benefitsubclass in ('2Z')    

left join person_bene_election pbelc on pi.personid = pbelc.personid
     and current_date      between pbelc.effectivedate and pbelc.enddate
     and current_timestamp between pbelc.createts      and pbelc.endts     
     and pbelc.benefitsubclass in ('25')     

left join person_bene_election pbeam on pi.personid = pbeam.personid
     and current_date      between pbeam.effectivedate and pbeam.enddate
     and current_timestamp between pbeam.createts      and pbeam.endts
     and pbeam.benefitsubclass in ('22')

left join person_bene_election pbeas on pi.personid = pbeas.personid
     and current_date      between pbeas.effectivedate and pbeas.enddate
     and current_timestamp between pbeas.createts      and pbeas.endts
     and pbeas.benefitsubclass in ('27')  
     
left join person_bene_election pbeac on pi.personid = pbeac.personid
     and current_date      between pbeac.effectivedate and pbeac.enddate
     and current_timestamp between pbeac.createts      and pbeac.endts    
     and pbeac.benefitsubclass in ('24')     

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pi.personid = '486'

and
(
(
exists (select 1 
          from person_bene_election pbed
         where pi.personid = pbed.personid
           and current_date      between pbed.effectivedate and pbed.enddate
           and current_timestamp between pbed.createts      and pbed.endts  
           and pbed.effectivedate >= ed.lastupdatets      
           and pbed.benefitsubclass in ('21','25','2Z','22','24','27'))
and
(         
exists (select 1 
          from person_identity pi1
         where pi1.personid     = pi.personid
             and pi1.identitytype = 'SSN' 
           and current_timestamp between pi1.createts      and pi1.endts
           and pi1.createts > ed.lastupdatets)
or
exists (select 1 
          from person_names pn1
         where pn1.personid = pi.personid
           and pn1.nametype = 'Legal' 
           and current_date      between pn1.effectivedate and pn1.enddate
           and current_timestamp between pn1.createts      and pn1.endts
           and greatest(pn1.effectivedate,pn1.createts) > ed.lastupdatets)
or
exists (select 1 
          from person_vitals pv1
         where pv1.personid = pi.personid
           and current_date      between pv1.effectivedate and pv1.enddate
           and current_timestamp between pv1.createts      and pv1.endts
           and greatest(pv1.effectivedate,pv1.createts) > ed.lastupdatets)      
or
exists (select 1 
          from person_employment pe1
         where pe1.personid = pi.personid
           and current_date      between pe1.effectivedate and pe1.enddate
           and current_timestamp between pe1.createts      and pe1.endts
           and greatest(pe1.effectivedate,pe1.createts) > ed.lastupdatets)
or
exists (select 1 
          from person_compensation pc1
         where pc1.personid = pi.personid
           and current_date      between pc1.effectivedate and pc1.enddate
           and current_timestamp between pc1.createts      and pc1.endts
           and greatest(pc1.effectivedate,pc1.createts) > ed.lastupdatets)               
)
)            
or 
(        
exists (select 1 
          from person_bene_election pbelm1
         where pi.personid = pbelm1.personid
           and current_date      between pbelm1.effectivedate and pbelm1.enddate
           and current_timestamp between pbelm1.createts      and pbelm1.endts
           and greatest(pbelm1.effectivedate,pbelm1.createts) > ed.lastupdatets           
           and pbelm1.benefitplanid in ('16'))         
or
exists (select 1 
          from person_bene_election pbels1
         where pi.personid = pbels1.personid
           and current_date      between pbels1.effectivedate and pbels1.enddate
           and current_timestamp between pbels1.createts      and pbels1.endts
           and greatest(pbels1.effectivedate,pbels1.createts) > ed.lastupdatets           
           and pbels1.benefitplanid in ('15'))    
or
exists (select 1 
          from person_bene_election pbelc1
         where pi.personid = pbelc1.personid
           and current_date      between pbelc1.effectivedate and pbelc1.enddate
           and current_timestamp between pbelc1.createts      and pbelc1.endts
           and greatest(pbelc1.effectivedate,pbelc1.createts) > ed.lastupdatets           
           and pbelc1.benefitplanid in ('14'))    
or
exists (select 1 
          from person_bene_election pbeam1
         where pi.personid = pbeam1.personid
           and current_date      between pbeam1.effectivedate and pbeam1.enddate
           and current_timestamp between pbeam1.createts      and pbeam1.endts
           and greatest(pbeam1.effectivedate,pbeam1.createts) > ed.lastupdatets           
           and pbeam1.benefitplanid in ('25'))    
or
exists (select 1 
          from person_bene_election pbeas1
         where pi.personid = pbeas1.personid
           and current_date      between pbeas1.effectivedate and pbeas1.enddate
           and current_timestamp between pbeas1.createts      and pbeas1.endts
           and greatest(pbeas1.effectivedate,pbeas1.createts) > ed.lastupdatets
           and pbeas1.benefitplanid in ('27'))    
or
exists (select 1 
          from person_bene_election pbeac1
         where pi.personid = pbeac1.personid
           and current_date      between pbeac1.effectivedate and pbeac1.enddate
           and current_timestamp between pbeac1.createts      and pbeac1.endts
           and greatest(pbeac1.effectivedate,pbeac1.createts) > ed.lastupdatets
           and pbeac1.benefitplanid in ('26'))           
)          
)
;

