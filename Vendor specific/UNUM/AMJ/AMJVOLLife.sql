select distinct
  pi.personid
, 'NEW QUERY'::char(10) as qsource
, '423184'                                                      as policy
, '0001'                                                        as division
, replace(coalesce(piz.identity,pi.identity),'-','')::char(9)   as ssn
, to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10)              as hiredate
, to_char(pc.compamount,'99999999D99')                          as salary
, pc.frequencycode                                              as salarymode
, CASE WHEN pc.frequencycode = 'H' THEN
    to_char(emplfulltimepercent*40/100,'99D99')
  ELSE ' ' END                                                  as hoursworked
, case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') end as termdate
, pe.emplstatus  
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

, '1000'                                             as class
-- need to use the date when the event created for sig date
, to_char(least(pbelm.createts,pbels.createts,pbelc.createts,pbeam.createts,pbeas.createts,pbeac.createts), 'MM/dd/YYYY')::char(10) as sigdate
, to_char(least(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate), 'MM/dd/YYYY')::char(10) as effdate
, CASE
    WHEN pe.Emplevent = 'Hire' AND pe.empleventdetcode IN ('H','NHR') THEN ' '
    WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'O'
    ELSE ' '
  END                                                                   AS addtype
-- ===============================================================================================================
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL
       ELSE 'LM' END                                                    AS benidlm
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL 
       ELSE '5.0N22' END                                                AS plcdlm
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL 
       ELSE to_char(pbelm.effectivedate, 'MM/dd/YYYY') END ::char(10)   AS qualdatelm
, CASE WHEN pbelm.personbeneelectionevent = 'Term' 
       THEN to_char(pbelm.effectivedate , 'MM/DD/YYYY')
       ELSE NULL END                                                    AS termdatelm
, pbelm.coverageamount                                                  AS covamtlm
-- Benefit Selection should be blank for Employee Life
-- , CASE WHEN pbelm.effectivedate IS NULL THEN NULL else 'Y' end AS benefitselectionlm
, ' '                                                                   AS benefitselectionlm
-- ===============================================================================================================
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL
       WHEN pbels.effectivedate IS NULL THEN NULL
       ELSE 'LS' END                                                    AS benidls
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL
       WHEN pbels.effectivedate IS NULL THEN NULL 
       ELSE '5.AN47' END                                                AS plcdls
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL
       WHEN pbels.effectivedate IS NULL THEN NULL  
       ELSE to_char(pbels.effectivedate,'MM/dd/YYYY') END ::char(10)    AS qualdatels
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL  
       WHEN pbels.personbeneelectionevent = 'Term' 
       THEN to_char(pbels.effectivedate , 'MM/DD/YYYY')
       ELSE NULL END                                                    AS termdatels
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL 
       WHEN pbels.effectivedate IS NULL THEN NULL
       ELSE pbels.coverageamount END                                    AS covamtls
-- Benefit Selection should be blank for Spouse Life
-- , CASE WHEN pbels.effectivedate IS NULL THEN NULL else 'Y' end AS benefitselectionls
, ' '                                                                   AS benefitselectionls
-- ===============================================================================================================
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL
       WHEN pbelc.effectivedate IS NULL THEN NULL
       ELSE 'LC' END                                                    AS benidlc
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL
       WHEN pbelc.effectivedate IS NULL THEN NULL 
       ELSE '5.0M04' END                                                AS plcdlc
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL 
       WHEN pbelc.effectivedate IS NULL THEN NULL
       ELSE to_char(pbelc.effectivedate, 'MM/dd/YYYY') END ::char(10)   AS qualdatelc
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL
       WHEN pbelc.personbeneelectionevent = 'Term' 
       THEN to_char(pbelc.effectivedate , 'MM/DD/YYYY')
       ELSE NULL END                                                    AS termdatelc
-- Benefit Selection Amount should NOT be blank for Child Life
, CASE WHEN pbelm.effectivedate IS NULL THEN NULL
       WHEN pbelc.effectivedate IS NULL THEN NULL
       ELSE pbelc.coverageamount END                                    AS covamtlc
-- , ' '                                                  as covamtlc
-- Benefit Selection should be blank for Child LIFE
-- , CASE WHEN pbelc.effectivedate IS NULL THEN NULL else 'Y' end AS benefitselectionlc
,' '                                                                    AS benefitselectionlc
-- ===============================================================================================================
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL
       ELSE 'AM' END                                                    AS benidam
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL 
       ELSE '5.0S17' END                                                AS plcdam
, to_char(pbeam.effectivedate, 'MM/dd/YYYY')::char(10)                  AS qualdateam
, CASE WHEN pbeam.personbeneelectionevent = 'Term' 
       THEN to_char(pbeam.effectivedate , 'MM/DD/YYYY')
       ELSE NULL END                                                    AS termdateam
, pbeam.coverageamount                                                  AS covamtam
-- Benefit Selection should be blank for Employee AD&D
--, CASE WHEN pbeam.effectivedate IS NULL THEN NULL else 'Y' end AS benefitselectionam
, ' '                                                                   AS benefitselectionam
-- ===============================================================================================================
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL
       WHEN pbeas.effectivedate IS NULL THEN NULL
       ELSE 'AS' END                                                    AS benidas
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL
       WHEN pbeas.effectivedate IS NULL THEN NULL 
       ELSE '5.0L02' END                                                AS plcdas
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL
       WHEN pbeas.effectivedate IS NULL THEN NULL  
       ELSE to_char(pbeas.effectivedate, 'MM/dd/YYYY') END ::char(10)   AS qualdateas
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL 
       WHEN pbeas.personbeneelectionevent = 'Term' 
       THEN to_char(pbeas.effectivedate , 'MM/DD/YYYY')
       ELSE NULL END                                                    AS termdateas
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL 
       WHEN pbeas.effectivedate IS NULL THEN NULL 
       ELSE pbeas.coverageamount END                                    AS covamtas
, ' '                                                                   AS benefitselectionas
-- ===============================================================================================================
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL
       WHEN pbeac.effectivedate IS NULL THEN NULL
       ELSE 'AC' END                                                    AS benidac
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL
       WHEN pbeac.effectivedate IS NULL THEN NULL 
       ELSE '5.0L23' END                                                AS plcdac
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL 
       WHEN pbeac.effectivedate IS NULL THEN NULL 
       ELSE to_char(pbeac.effectivedate, 'MM/dd/YYYY')  END ::char(10)  AS qualdateac
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL
       WHEN pbeac.personbeneelectionevent = 'Term' 
       THEN to_char(pbeac.effectivedate , 'MM/DD/YYYY')
       ELSE NULL END                                                    AS termdateac
-- Benefit Selection Amount should NOT be blank for Child Life and Child AD&D  
, CASE WHEN pbeam.effectivedate IS NULL THEN NULL 
       WHEN pbeac.effectivedate IS NULL THEN NULL
       ELSE pbeac.coverageamount END                                    AS covamtac
-- Benefit Selection should be blank for Child AD&D
-- , CASE WHEN pbeac.effectivedate IS NULL THEN NULL else 'Y' end AS benefitselectionac
, ' '                                                                   AS benefitselectionac
-- ===============================================================================================================

from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
 -- employees corrected ssn
left join person_identity piz 
  on piz.personid = pe.personid
 and piz.identitytype = 'SSN'
 and piz.endts = (select max(pizm.endts) 
                        from person_identity pizm
                       where pizm.personid = piz.personid
                         and pizm.identitytype = 'SSN'
                         and pizm.endts < pi.endts)

left join person_payroll pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate AND pp.enddate
 and current_timestamp between pp.createts AND pp.endts

join person_names pn 
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'
     
join person_vitals pv 
  on pi.personid = pv.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join person_dependent_relationship pdr 
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 and pdr.dependentrelationship = 'SP'

left join person_names spn 
  on spn.personid = pdr.dependentid
 and current_date between spn.effectivedate and spn.enddate
 and current_timestamp between spn.createts and spn.endts
 and spn.nametype = 'Dep'

left join person_vitals spv 
  on spv.personid = pdr.dependentid
 and current_date between spv.effectivedate and spv.enddate
 and current_timestamp between spv.createts and spv.endts

left join person_maritalstatus pms 
  on pms.personid = pi.personid
 and current_date between pms.effectivedate and pms.enddate
 and current_timestamp between pms.createts and pms.endts

left join (SELECT personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_compensation 
            WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and compamount <> 0
            GROUP BY personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1   

left join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitsubclass in ('21','22','24','25','27','2Z')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection <> 'W'
 AND current_date between pbe.effectivedate AND pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('21','22','24','25','27','2Z') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate - interval '1 Day' <= enddate)  

------------------------------     
----- lm = Employee Life -----
------------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('21') and benefitelection in ( 'E') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent ) as pbelm on pbelm.personid = pbe.personid and pbelm.rank = 1  
----------------------------
----- ls = Spouse Life -----
----------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('2Z') and benefitelection in ( 'E') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent ) as pbels on pbels.personid = pbe.personid and pbels.rank = 1    
---------------------------
----- lc = Child Life -----
---------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('25') and benefitelection in ( 'E') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent ) as pbelc on pbelc.personid = pbe.personid and pbelc.rank = 1      
------------------------------
----- am = Employee AD&D -----
------------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('22') and benefitelection in ( 'E') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent ) as pbeam on pbeam.personid = pbe.personid and pbeam.rank = 1    
----------------------------
----- as = Spouse AD&D -----
----------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('27') and benefitelection in ( 'E') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent ) as pbeas on pbeas.personid = pbe.personid and pbeas.rank = 1   
---------------------------
----- ac = Child AD&D -----
---------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('24') and benefitelection in ( 'E') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent ) as pbeac on pbeac.personid = pbe.personid and pbeac.rank = 1   
     
join edi.edi_last_update ed on ed.feedID = 'Unum_VolLifeADD_Export'
join edi.edi_last_update elubase on elubase.feedID = 'Unum_Export_Effective_Date'

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.benefitelection <> 'W'  
  and current_date between pbe.effectivedate and pbe.enddate 
  and (pbe.effectivedate >= ed.lastupdatets::DATE or (pbe.createts > ed.lastupdatets and pbe.effectivedate < coalesce(ed.lastupdatets, elubase.lastupdatets)) ) 

  
        order by personid
; 
