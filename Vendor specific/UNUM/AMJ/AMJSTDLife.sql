select 
  pi.personid
, '423183' ::char(6)                                            as policy
-- STD division = 0001 LTD division = 0002
, '0001'                                                     as division

/*, CASE WHEN pbedd.effectivedate IS NULL THEN NULL
       ELSE '0002' END  ::char(4)                               AS dd_division
, CASE WHEN pbewo.effectivedate IS NULL THEN NULL
       ELSE '0001' END  ::char(4)                               AS wo_division*/
, replace(coalesce(piz.identity,pi.identity),'-','')::char(9)   as ssn
, to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10)              as hiredate
, to_char(pc.compamount,'99999999D99')                          as salary
, case when pe.emplstatus  = 'T' then null 
      when pc.frequencycode = 'H' then 'H' 
      else  coalesce(pc.frequencycode,'A') end ::char(1)        as salarymode
, CASE WHEN pc.frequencycode = 'H' THEN
    to_char(emplfulltimepercent*40/100,'99D99')
  ELSE ' ' END                                                  as hoursworked
, CASE WHEN pe.emplstatus  = 'T' THEN 
    greatest(pbe.effectivedate,pe.effectivedate)::char(10) 
    ELSE NULL END                                               as termdate
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
, CASE WHEN pbe.effectivedate IS NULL THEN NULL
       ELSE '0100' END                                AS class

, to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) as sigdate
, to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) as effdate
,pe.Emplevent
, CASE
    WHEN pe.Emplevent = 'Hire' AND pe.empleventdetcode IN ('H','NHR') THEN ' '
    WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'O'
    ELSE ' '
  END                                                as addtype

------------------
-- LTD Benefit 
------------------
, ''            as beniddd
, ''            as plcddd
, ''			as qualdatedd
, ''            as termdatedd
, ''			as covamtdd
, ''			AS benefitselectiondd

------------------
-- STD Benefit 
------------------
, CASE WHEN pbe.effectivedate IS NULL THEN NULL
  when pbe.benefitsubclass = '30' then 'WO' 
  else null END ::char(2)                                       as benidwo
, CASE WHEN pbe.effectivedate IS NULL THEN NULL 
  when pbe.benefitsubclass = '30' then '.60VVA' 
  else null END ::char(6)                                   as plcdwo
, case when pbe.benefitsubclass = '30' then to_char(pbe.effectivedate, 'MM/dd/YYYY') 
  else null end ::char(10)				as qualdatewo
, CASE WHEN pbe.benefitsubclass = '30' and pbe.personbeneelectionevent = 'Term' THEN to_char(pbe.effectivedate , 'mm/dd/yyyy')
  ELSE NULL END ::char(10)                                       as termdatewo
, ' ' as covamtwo
, CASE WHEN pbe.effectivedate IS NULL THEN NULL else 'Y' end AS benefitselectionwo



, ed.feedID                                          as feedid
, now()                                              as updatets

from person_identity pi

left join edi.edi_last_update ed on ed.feedID = 'Unum_StdLifeADD_Export'
left join edi.edi_last_update ef on ef.feedID = 'Unum_Export_Effective_Date'

left join person_employment pe 
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

left join person_names pn 
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

left join person_vitals pv 
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

 
left join (SELECT personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        FROM person_compensation 
        WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and compamount <> 0
        GROUP BY personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1   


left join person_bene_election pbe 
  on pi.personid = pbe.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('30')
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('30') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate - interval '1 Day' <= enddate)



where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.effectivedate is not null
  and pbe.benefitelection <> 'W'
  and (pbe.effectivedate >= ed.lastupdatets::DATE or (pbe.createts > ed.lastupdatets and pbe.effectivedate < coalesce(ed.lastupdatets, ef.lastupdatets)) )
and
(
exists (select 1 
          from person_identity pi1
         where pi1.personid     = pi.personid
             and pi1.identitytype = 'SSN' 
           and pi1.createts      between ed.lastupdatets and now()	--ed.lastupdatets
        )
or
exists (select 1 
          from person_names pn1
         where pn1.personid = pi.personid
           and pn1.nametype = 'Legal' 
           and (pn1.effectivedate between ed.lastupdatets and now()	--ed.lastupdatets
            or  pn1.createts      between ed.lastupdatets and now())	--ed.lastupdatets
        )
or
exists (select 1 
          from person_vitals pv1
         where pv1.personid = pi.personid
           and (pv1.effectivedate between ed.lastupdatets and now()	--ed.lastupdatets
            or  pv1.createts      between ed.lastupdatets and now())	--ed.lastupdatets
        )   
or
exists (select 1 
          from person_employment pe1
         where pe1.personid = pi.personid
           and (pe1.effectivedate between ed.lastupdatets and now()	--ed.lastupdatets
            or  pe1.createts      between ed.lastupdatets and now())	--ed.lastupdatets
        )
or
exists (select 1 
          from person_compensation pc1
         where pc1.personid = pi.personid
           and (pc1.effectivedate between ed.lastupdatets and now()	--ed.lastupdatets
            or  pc1.createts      between ed.lastupdatets and now())	--ed.lastupdatets
        )   
or
exists (select 1 
          from person_bene_election pbe1dd
         where pbe1dd.personid = pi.personid
           and pbe.benefitsubclass in ('30')
           and (pbe1dd.effectivedate between ed.lastupdatets and now()	--ed.lastupdatets
            or  pbe1dd.createts      between ed.lastupdatets and now())	--ed.lastupdatets
        )        
                   
)                 

union

select
  pi.personid
, '423183' ::char(6)                                            as policy
-- STD division = 0001 LTD division = 0002
, '0002'                                                     as division

/*, CASE WHEN pbedd.effectivedate IS NULL THEN NULL
       ELSE '0002' END  ::char(4)                               AS dd_division
, CASE WHEN pbewo.effectivedate IS NULL THEN NULL
       ELSE '0001' END  ::char(4)                               AS wo_division*/
, replace(coalesce(piz.identity,pi.identity),'-','')::char(9)   as ssn
, to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10)              as hiredate
, to_char(pc.compamount,'99999999D99')                          as salary
, case when pe.emplstatus  = 'T' then null 
      when pc.frequencycode = 'H' then 'H' 
      else  coalesce(pc.frequencycode,'A') end ::char(1)        as salarymode
, CASE WHEN pc.frequencycode = 'H' THEN
    to_char(emplfulltimepercent*40/100,'99D99')
  ELSE ' ' END                                                  as hoursworked
, CASE WHEN pe.emplstatus  = 'T' THEN 
    greatest(pbe.effectivedate,pe.effectivedate)::char(10) 
    ELSE NULL END                                               as termdate
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
-- , '0101'                                             as class  ** come back to thins
, CASE WHEN pbe.effectivedate IS NULL THEN NULL
       ELSE '0001' END                                AS class
/* , CASE WHEN pbewo.effectivedate IS NULL THEN NULL
       ELSE '0100' END                                AS woclass*/

, to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) as sigdate
, to_char(pbe.effectivedate, 'MM/dd/YYYY')::char(10) as effdate
,pe.Emplevent
, CASE
    WHEN pe.Emplevent = 'Hire' AND pe.empleventdetcode IN ('H','NHR') THEN ' '
    WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'O'
    ELSE ' '
  END                                                as addtype

------------------
-- LTD Benefit 
------------------
, CASE WHEN pbe.effectivedate IS NULL THEN NULL
  when pbe.benefitsubclass = '31' then 'DD' 
  else null END ::char(2)                                       as beniddd
, CASE WHEN pbe.effectivedate IS NULL THEN NULL 
  when pbe.benefitsubclass = '31' then '.60S1A' 
  else null END ::char(6)                                   as plcddd
, case when pbe.benefitsubclass = '31' then to_char(pbe.effectivedate, 'MM/dd/YYYY') 
  else null end ::char(10)				as qualdatedd
, CASE WHEN pbe.benefitsubclass = '31' and pbe.personbeneelectionevent = 'Term' THEN to_char(pbe.effectivedate , 'mm/dd/yyyy')
  ELSE NULL END ::char(10)                                       as termdatedd
, ' ' as covamtdd
, CASE WHEN pbe.effectivedate IS NULL THEN NULL when pbe.benefitsubclass = '31' then 'Y' 
  else null end ::char(1)						AS benefitselectiondd

------------------
-- STD Benefit 
------------------
, ''                as benidwo
, ''                as plcdwo
, ''				as qualdatewo
, ''                as termdatewo
, '' 				as covamtwo
, ''				AS benefitselectionwo



, ed.feedID                                          as feedid
, now()                                              as updatets

from person_identity pi

left join edi.edi_last_update ed on ed.feedID = 'Unum_StdLifeADD_Export'
left join edi.edi_last_update ef on ef.feedID = 'Unum_Export_Effective_Date'

left join person_employment pe 
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

left join person_names pn 
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

left join person_vitals pv 
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

 
left join (SELECT personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        FROM person_compensation 
        WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and compamount <> 0
        GROUP BY personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1   


left join person_bene_election pbe 
  on pi.personid = pbe.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('31')
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('31') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate - interval '1 Day' <= enddate)


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.effectivedate is not null
  and pbe.benefitelection <> 'W'
  and (pbe.effectivedate >= ed.lastupdatets::DATE or (pbe.createts > ed.lastupdatets and pbe.effectivedate < coalesce(ed.lastupdatets, ef.lastupdatets)) )
and
(
exists (select 1 
          from person_identity pi1
         where pi1.personid     = pi.personid
             and pi1.identitytype = 'SSN' 
           and pi1.createts      between ed.lastupdatets and now()	--ed.lastupdatets
        )
or
exists (select 1 
          from person_names pn1
         where pn1.personid = pi.personid
           and pn1.nametype = 'Legal' 
           and (pn1.effectivedate between ed.lastupdatets and now()	--ed.lastupdatets
            or  pn1.createts      between ed.lastupdatets and now())	--ed.lastupdatets
        )
or
exists (select 1 
          from person_vitals pv1
         where pv1.personid = pi.personid
           and (pv1.effectivedate between ed.lastupdatets and now()	--ed.lastupdatets
            or  pv1.createts      between ed.lastupdatets and now())	--ed.lastupdatets
        )   
or
exists (select 1 
          from person_employment pe1
         where pe1.personid = pi.personid
           and (pe1.effectivedate between ed.lastupdatets and now()	--ed.lastupdatets
            or  pe1.createts      between ed.lastupdatets and now())	--ed.lastupdatets
        )
or
exists (select 1 
          from person_compensation pc1
         where pc1.personid = pi.personid
           and (pc1.effectivedate between ed.lastupdatets and now()	--ed.lastupdatets
            or  pc1.createts      between ed.lastupdatets and now())	--ed.lastupdatets
        )   
or
exists (select 1 
          from person_bene_election pbe1dd
         where pbe1dd.personid = pi.personid
           and pbe.benefitsubclass in ('31')
           and (pbe1dd.effectivedate between ed.lastupdatets and now()	--ed.lastupdatets
            or  pbe1dd.createts      between ed.lastupdatets and now())	--ed.lastupdatets
        )        
                   
)           
order by personid
;
