select distinct
  pi.personid
,ed.lastupdatets

,case when greatest(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate,pe.effectivedate,pc.effectivedate,pn.effectivedate,pncw.effectivedate) in (pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate) then 'BENEFIT CHANGE' 
      when greatest(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate,pe.effectivedate,pc.effectivedate,pn.effectivedate,pncw.effectivedate) in (pe.effectivedate) then 'EMPLOYMENT CHANGE' 
	   when greatest(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate,pe.effectivedate,pc.effectivedate,pn.effectivedate,pncw.effectivedate) in (pc.effectivedate) then 'COMPENSATION CHANGE' 
	   when greatest(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate,pe.effectivedate,pc.effectivedate,pn.effectivedate,pncw.effectivedate) in (pn.effectivedate) then 'NAME CHANGE' 
	   when greatest(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate,pe.effectivedate,pc.effectivedate,pn.effectivedate,pncw.effectivedate) in (pncw.effectivedate) then 'EMAIL CHANGE' 
      else null end ::varchar(25) as changetype  --- used by control report
,lkuppolicy.policy as policy
,lkupdivision.division as division
,' ' ::char(1) as prior_div
,pi.identity as memberid --- current ssn
,to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10) as hiredate
,cast(pc.compamount as dec(18,2)) as salary
,pc.frequencycode as salarymode
,CASE WHEN pc.frequencycode = 'H' THEN cast(emplfulltimepercent*40/100 as dec(18,2)) ELSE null END  as hoursworked
,case when pe.emplstatus in ('T','R','D') then to_char(pe.effectivedate,'mm/dd/yyyy') 
      when pe.emplstatus not in ('T','R','D') and pbelm.benefitelection in ('W','T') and pbelmw.benefitelection = 'E' then to_char(pbelmw.enddate,'mm/dd/yyyy')
      when pe.emplstatus not in ('T','R','D') and pbels.benefitelection in ('W','T') and pbelsw.benefitelection = 'E' then to_char(pbelsw.enddate,'mm/dd/yyyy')
      when pe.emplstatus not in ('T','R','D') and pbelc.benefitelection in ('W','T') and pbelcw.benefitelection = 'E' then to_char(pbelcw.enddate,'mm/dd/yyyy')
      when pe.emplstatus not in ('T','R','D') and pbeam.benefitelection in ('W','T') and pbeamw.benefitelection = 'E' then to_char(pbeamw.enddate,'mm/dd/yyyy')
      when pe.emplstatus not in ('T','R','D') and pbeas.benefitelection in ('W','T') and pbeasw.benefitelection = 'E' then to_char(pbeasw.enddate,'mm/dd/yyyy')
      when pe.emplstatus not in ('T','R','D') and pbeac.benefitelection in ('W','T') and pbeacw.benefitelection = 'E' then to_char(pbeacw.enddate,'mm/dd/yyyy') 
      else null end as termdate
,CASE WHEN pe.emplstatus = 'T' THEN 'TE'
      WHEN pe.emplstatus = 'R' THEN 'RT'
      WHEN pe.emplstatus = 'D' THEN 'DT'
      WHEN pe.emplstatus = 'L' THEN 'LO'  
      when pe.emplstatus not in ('T','R','D') and pbelm.benefitelection in ('W','T') and pbelmw.benefitelection = 'E' then 'DC'
      when pe.emplstatus not in ('T','R','D') and pbels.benefitelection in ('W','T') and pbelsw.benefitelection = 'E' then 'DC'
      when pe.emplstatus not in ('T','R','D') and pbelc.benefitelection in ('W','T') and pbelcw.benefitelection = 'E' then 'DC'
      when pe.emplstatus not in ('T','R','D') and pbeam.benefitelection in ('W','T') and pbeamw.benefitelection = 'E' then 'DC'
      when pe.emplstatus not in ('T','R','D') and pbeas.benefitelection in ('W','T') and pbeasw.benefitelection = 'E' then 'DC'
      when pe.emplstatus not in ('T','R','D') and pbeac.benefitelection in ('W','T') and pbeacw.benefitelection = 'E' then 'DC'
      ELSE '  ' END as termreason
,CASE WHEN piz.identity IS NULL THEN ' ' ELSE pi.identity END as newmemberid
,pn.fname  as fname
,UPPER(LEFT(pn.mname,1))                            as mname
,pn.lname as lname
,pn.title                                           as suffix
,pv.gendercode                                      as gender
,to_char(pv.birthdate, 'MM/dd/YYYY')::char(10)      as dob
,coalesce(pncw.url,pnch.url) as email

,UPPER(spn.fname)                                   as sfname
,spv.gendercode                                     as sgender
,to_char(spv.birthdate, 'MM/dd/YYYY')::char(10)     as sdob


,case when pi.personid = lkupclass.personid then lkupclass.class else '2000' end ::char(4) as class

-- need to use the date when the event created for sig date
,to_char(least(pbelm.createts,pbels.createts,pbelc.createts,pbeam.createts,pbeas.createts,pbeac.createts), 'MM/dd/YYYY')::char(10) as sigdate
,to_char(greatest(pbelm.effectivedate,pbels.effectivedate,pbelc.effectivedate,pbeam.effectivedate,pbeas.effectivedate,pbeac.effectivedate), 'MM/dd/YYYY')::char(10) as effdate
,CASE WHEN pe.Emplevent = 'Hire' AND pe.empleventdetcode IN ('H','NHR') THEN ' '
      WHEN pe.Emplevent = 'PartFull' AND pe.empleventdetcode = 'PF' THEN 'O' 
      ELSE ' ' END  AS addtype
-- ===============================================================================================================
,CASE WHEN (pbelm.benefitelection in ('T','W') AND pbelmw.benefitelection = 'E') THEN 'LM'  -- report prior active coverage now waived
      WHEN pbelm.benefitelection in ('E') THEN 'LM'
      ELSE NULL END                                                    AS benidlm
,CASE WHEN (pbelm.benefitelection in ('T','W') AND pbelmw.benefitelection = 'E') THEN '5.0N22'
      WHEN pbelm.benefitelection in ('E') THEN  '5.0N22' 
      ELSE NULL END                                                    AS plcdlm
,CASE WHEN (pbelm.benefitelection in ('T','W') AND pbelmw.benefitelection = 'E') THEN to_char(pbelmw.effectivedate,'MM/dd/YYYY')
      WHEN pbelm.benefitelection in ('E') THEN to_char(pbelm.effectivedate,'MM/dd/YYYY') 
      ELSE NULL END ::char(10)                                         AS qualdatelm   
,CASE WHEN (pbelm.benefitelection in ('T','W') and pbelmw.benefitelection = 'E') THEN to_char(pbelmw.enddate , 'MM/DD/YYYY')
      WHEN ((pbelm.benefitelection in ('T') and pbelmw.benefitelection = 'E') AND pe.emplstatus IN ('T','R','D')) THEN to_char(pbelm.effectivedate,'MM/DD/YYYY')
      ELSE NULL END                                                    AS termdatelm
,CASE WHEN (pbelm.benefitelection in ('T','W') AND pbelmw.benefitelection = 'E') THEN pbelmw.coverageamount 
      WHEN pbelm.benefitelection in ('E') THEN pbelm.coverageamount
      ELSE NULL END                                                    AS covamtlm
,CASE WHEN (pbelm.benefitelection in ('T','W') AND pbelmw.benefitelection = 'E') THEN NULL
      WHEN pbelm.benefitelection in ('E') THEN 'Y'
      ELSE NULL END                                                    AS benefitselectionlm
-- ===============================================================================================================
,CASE WHEN (pbels.benefitelection in ('T','W') AND pbelsw.benefitelection = 'E') THEN 'LS'  -- report prior active coverage now waived
      WHEN pbels.benefitelection in ('E') THEN 'LS'
      ELSE NULL END                                                    AS benidls
,CASE WHEN (pbels.benefitelection in ('T','W') AND pbelsw.benefitelection = 'E') THEN '5.AN47'
      WHEN pbels.benefitelection in ('E') THEN  '5.AN47' 
      ELSE NULL END                                                    AS plcdls
,CASE WHEN (pbels.benefitelection in ('T','W') AND pbelsw.benefitelection = 'E') THEN to_char(pbelsw.effectivedate,'MM/dd/YYYY')
      WHEN pbels.benefitelection in ('E') THEN to_char(pbels.effectivedate,'MM/dd/YYYY') 
      ELSE NULL END ::char(10)                                         AS qualdatels
,CASE WHEN (pbels.benefitelection in ('T','W') and pbelsw.benefitelection = 'E') THEN to_char(pbelsw.enddate , 'MM/DD/YYYY')
      WHEN ((pbels.benefitelection in ('T') and pbelsw.benefitelection = 'E') AND pe.emplstatus IN ('T','R','D')) THEN to_char(pbels.effectivedate,'MM/DD/YYYY')
      ELSE NULL END                                                    AS termdatels
,CASE WHEN (pbels.benefitelection in ('T','W') AND pbelsw.benefitelection = 'E') THEN pbelsw.coverageamount 
      WHEN pbels.benefitelection in ('E') THEN pbels.coverageamount
      ELSE NULL END                                                    AS covamtls
,CASE WHEN (pbels.benefitelection in ('T','W') AND pbelsw.benefitelection = 'E') THEN NULL
      WHEN pbels.benefitelection in ('E') THEN 'Y'
      ELSE NULL END                                                    AS benefitselectionls
-- ===============================================================================================================
,CASE WHEN (pbelc.benefitelection in ('T','W') AND pbelcw.benefitelection = 'E') THEN 'LC' 
      WHEN pbelc.benefitelection = 'E' THEN 'LC' 
      ELSE NULL END                                                    AS benidlc
,CASE WHEN (pbelc.benefitelection in ('T','W') AND pbelcw.benefitelection = 'E') THEN '5.0M04'
      WHEN pbelc.benefitelection = 'E' THEN '5.0M04'  
      ELSE NULL END                                                    AS plcdlc
,CASE WHEN (pbelc.benefitelection in ('T','W') AND pbelcw.benefitelection = 'E') THEN to_char(pbelcw.effectivedate,'MM/dd/YYYY')
      WHEN pbelc.benefitelection = 'E' THEN to_char(pbelc.effectivedate, 'MM/dd/YYYY')
      ELSE NULL END ::char(10)                                         AS qualdatelc
,CASE WHEN (pbelc.benefitelection in ('T','W') AND pbelcw.benefitelection = 'E') THEN to_char(pbelcw.enddate , 'MM/DD/YYYY')
      WHEN ((pbelc.benefitelection in ('T') and pbelcw.benefitelection = 'E') AND pe.emplstatus IN ('T','R','D')) THEN to_char(pbelc.effectivedate,'MM/DD/YYYY')
      ELSE NULL END                                                    AS termdatelc
,CASE WHEN (pbelc.benefitelection in ('T','W') AND pbelcw.benefitelection = 'E') THEN pbelcw.coverageamount
      WHEN pbelc.benefitelection = 'E' THEN pbelc.coverageamount
      ELSE NULL END                                                    AS covamtlc
,CASE WHEN (pbelc.benefitelection in ('T','W') AND pbelcw.benefitelection = 'E') THEN NULL
      WHEN pbelc.benefitelection in ('E') THEN 'Y'
      ELSE NULL END                                                    AS benefitselectionlc
-- ===============================================================================================================
,CASE WHEN (pbeam.benefitelection in ('T','W') AND pbeamw.benefitelection = 'E') THEN 'AM' 
      WHEN pbeam.benefitelection = 'E' THEN 'AM' 
      ELSE NULL END                                                    AS benidam
,CASE WHEN (pbeam.benefitelection in ('T','W') AND pbeamw.benefitelection = 'E') THEN '5.0S17'
      WHEN pbeam.benefitelection = 'E' THEN '5.0S17'  
      ELSE NULL END                                                    AS plcdam
,CASE WHEN (pbeam.benefitelection in ('T','W') AND pbeamw.benefitelection = 'E') THEN to_char(pbeamw.effectivedate,'MM/dd/YYYY')
      WHEN pbeam.benefitelection = 'E' THEN to_char(pbeam.effectivedate, 'MM/dd/YYYY')
      ELSE NULL END ::char(10)                                         AS qualdateam
,CASE WHEN (pbeam.benefitelection in ('T','W') AND pbeamw.benefitelection = 'E') THEN to_char(pbeamw.enddate , 'MM/DD/YYYY')
      WHEN ((pbeam.benefitelection in ('T') and pbeamw.benefitelection = 'E') AND pe.emplstatus IN ('T','R','D')) THEN to_char(pbeam.effectivedate,'MM/DD/YYYY')
      ELSE NULL END                                                    AS termdateam
,CASE WHEN (pbeam.benefitelection in ('T','W') AND pbeamw.benefitelection = 'E') THEN pbeamw.coverageamount
      WHEN pbeam.benefitelection = 'E' THEN pbeam.coverageamount
      ELSE NULL END                                                    AS covamtam
,CASE WHEN (pbeam.benefitelection in ('T','W') AND pbeamw.benefitelection = 'E') THEN NULL
      WHEN pbeam.benefitelection in ('E') THEN 'Y'
      ELSE NULL END                                                    AS benefitselectionam    
-- ===============================================================================================================
,CASE WHEN (pbeas.benefitelection in ('T','W') AND pbeasw.benefitelection = 'E') THEN 'AS' 
      WHEN pbeas.benefitelection = 'E' THEN 'AS' 
      ELSE NULL END                                                    AS benidas
,CASE WHEN (pbeas.benefitelection in ('T','W') AND pbeasw.benefitelection = 'E') THEN '5.0L02'
      WHEN pbeas.benefitelection = 'E' THEN '5.0L02'  
      ELSE NULL END                                                    AS plcdas
,CASE WHEN (pbeas.benefitelection in ('T','W') AND pbeasw.benefitelection = 'E') THEN to_char(pbeasw.effectivedate,'MM/dd/YYYY')
      WHEN pbeas.benefitelection = 'E' THEN to_char(pbeas.effectivedate, 'MM/dd/YYYY')
      ELSE NULL END ::char(10)                                         AS qualdateas
,CASE WHEN (pbeas.benefitelection in ('T','W') AND pbeasw.benefitelection = 'E') THEN to_char(pbeasw.enddate , 'MM/DD/YYYY')
      WHEN ((pbeas.benefitelection in ('T') and pbeasw.benefitelection = 'E') AND pe.emplstatus IN ('T','R','D')) THEN to_char(pbeas.effectivedate,'MM/DD/YYYY')
      ELSE NULL END                                                    AS termdateas
,CASE WHEN (pbeas.benefitelection in ('T','W') AND pbeasw.benefitelection = 'E') THEN pbeasw.coverageamount
      WHEN pbeas.benefitelection = 'E' THEN pbeas.coverageamount
      ELSE NULL END                                                    AS covamtas
,CASE WHEN (pbeas.benefitelection in ('T','W') AND pbeasw.benefitelection = 'E') THEN NULL
      WHEN pbeas.benefitelection in ('E') THEN 'Y'
      ELSE NULL END                                                    AS benefitselectionas  
-- ===============================================================================================================
,CASE WHEN (pbeac.benefitelection in ('T','W') AND pbeacw.benefitelection = 'E') THEN 'AC' 
      WHEN pbeac.benefitelection = 'E' THEN 'AC' 
      ELSE NULL END                                                    AS benidac
,CASE WHEN (pbeac.benefitelection in ('T','W') AND pbeacw.benefitelection = 'E') THEN '5.0L23'
      WHEN pbeac.benefitelection = 'E' THEN '5.0L23'  
      ELSE NULL END                                                    AS plcdac
,CASE WHEN (pbeac.benefitelection in ('T','W') AND pbeacw.benefitelection = 'E') THEN to_char(pbeacw.effectivedate,'MM/dd/YYYY')
      WHEN pbeac.benefitelection = 'E' THEN to_char(pbeac.effectivedate, 'MM/dd/YYYY')
      ELSE NULL END ::char(10)                                         AS qualdateac
,CASE WHEN (pbeac.benefitelection in ('T','W') AND pbeacw.benefitelection = 'E') THEN to_char(pbeacw.enddate , 'MM/DD/YYYY')
      WHEN ((pbeac.benefitelection in ('T') and pbeacw.benefitelection = 'E') AND pe.emplstatus IN ('T','R','D')) THEN to_char(pbeac.effectivedate,'MM/DD/YYYY')
      WHEN (pbeac.benefitelection in ('T') OR pe.emplstatus IN ('T','R','D')) THEN to_char(pbeac.effectivedate , 'MM/DD/YYYY')
      ELSE NULL END                                                    AS termdateac
,CASE WHEN (pbeac.benefitelection in ('T','W') AND pbeacw.benefitelection = 'E') THEN pbeacw.coverageamount
      WHEN pbeac.benefitelection = 'E' THEN pbeac.coverageamount
      ELSE NULL END                                                    AS covamtac
,CASE WHEN (pbeac.benefitelection in ('T','W') AND pbeacw.benefitelection = 'E') THEN NULL
      WHEN pbeac.benefitelection in ('E') THEN 'Y'
      ELSE NULL END                                                    AS benefitselectionac
-- ===============================================================================================================

from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
 -- employees with corrected ssns
left join person_identity piz 
  on piz.personid = pe.personid
 and piz.identitytype = 'SSN'
 and piz.endts = (select max(pizm.endts) 
                        from person_identity pizm
                       where pizm.personid = piz.personid
                         and pizm.identitytype = 'SSN'
                         and pizm.endts < pi.endts)

left join person_identity pie
  on pie.personid = pe.personid
 and pie.identitytype = 'EMPNO'
 and current_timestamp between pie.createts and pie.endts
 
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

left join (SELECT personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_compensation WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts and compamount <> 0
            GROUP BY personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1   

left join ( select personid, url, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_net_contacts where netcontacttype = 'HomeEmail' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, url) pnch on pnch.personid = pe.personid and pnch.rank = 1 

left join ( select personid, url, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_net_contacts where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, url) pncw on pncw.personid = pe.personid and pncw.rank = 1              
 
----- Lookups - Benefit Descriptions  
left join ( select lkup.value1 as benefitsubclass, lkup.key1 as benefit_desc from edi.lookup lkup
              join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts
               and lkups.lookupname = 'Unum_VolLifeADD_Export' ) lkups on 1 = 1
----- Lookups - Class
LEFT JOIN  (select lp.lookupid, key1 as personid, value1 as class from edi.lookup lp
              join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'EDE_UNUM_Owner_Class_VOL_LIFE' 
	          where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
	     ) lkupclass on lkupclass.lookupid is not null  --- for EDE - owner's assigned a different class.
----- Lookups - Policy 
LEFT JOIN  (select lp.lookupid, value1 as policy from edi.lookup lp
              join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'EDE_UNUM_Policy_VOL_LIFE' 
	          where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
	     ) lkuppolicy on lkuppolicy.lookupid is not null  --- 
----- Lookups - Division 
LEFT JOIN  (select lp.lookupid, value1 as division from edi.lookup lp
              join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'EDE_UNUM_Division_VOL_LIFE' 
	          where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
	     ) lkupdivision on lkupdivision.lookupid is not null  --- 	     	     
	     
left join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitsubclass in (select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid
                                and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts
                                and lkups.lookupname = 'Unum_VolLifeADD_Export' ) --- List of applicable benefitsubclasses 
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection <> 'W'
 AND current_date between pbe.effectivedate AND pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                 and benefitsubclass in (select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid
                 and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts
                 and lkups.lookupname = 'Unum_VolLifeADD_Export' ) and benefitelection = 'E' and selectedoption = 'Y' and effectivedate - interval '1 Day' <= enddate)  

------------------------------     
----- lm = Employee Life -----
------------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass 
             in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts
                     and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'EEVLIFE') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate ) as pbelm on pbelm.personid = pbe.personid and pbelm.rank = 1  
----------------------------
----- ls = Spouse Life -----
----------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass 
             in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts
                     and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'SPVLIFE') and selectedoption = 'Y'  
            GROUP BY personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate ) as pbels on pbels.personid = pbe.personid and pbels.rank = 1    

---------------------------
----- lc = Child Life -----
---------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass 
             in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts
                     and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'CHVLIFE') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate ) as pbelc on pbelc.personid = pbe.personid and pbelc.rank = 1      
------------------------------
----- am = Employee AD&D -----
------------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass 
             in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts
                     and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'EEADD  ') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate ) as pbeam on pbeam.personid = pbe.personid and pbeam.rank = 1    
----------------------------
----- as = Spouse AD&D -----
----------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass 
             in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts
                     and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'SPADD  ') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate  ) as pbeas on pbeas.personid = pbe.personid and pbeas.rank = 1   
---------------------------
----- ac = Child AD&D -----
---------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass 
             in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts
                     and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'DEPADD ') and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent,benefitelection,effectivedate,enddate ) as pbeac on pbeac.personid = pbe.personid and pbeac.rank = 1 
            
-----------------------------------------------------------------------------------------------------------
----- Coverage for active employees with active termed / waived elections with prior active elections -----
-----------------------------------------------------------------------------------------------------------
----------------------------------     
----- pbelmw = Employee Life -----
----------------------------------
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,coverageamount, max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		       from person_bene_election pbe
		       left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				              from person_bene_election pbe
				             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'EEVLIFE')
				               and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'EEVLIFE')
               and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
             group by 1,2,3,4,5,6,7,8 order by 1,11) pbelmw on pbelmw.personid = pbe.personid and pbelmw.rank = 1 
--------------------------------
----- pbelsw = Spouse Life -----
--------------------------------            
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,coverageamount, max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		       from person_bene_election pbe
		       left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				              from person_bene_election pbe
				             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'SPVLIFE')            
				               and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'SPVLIFE')            
               and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
             group by 1,2,3,4,5,6,7,8 order by 1,11) pbelsw on pbelsw.personid = pbe.personid and pbelsw.rank = 1 
-------------------------------
----- pbelcw = Child Life -----
-------------------------------
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,coverageamount, max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		       from person_bene_election pbe
		       left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				              from person_bene_election pbe
				             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'CHVLIFE')
				              and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'CHVLIFE')
               and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
             group by 1,2,3,4,5,6,7,8 order by 1,11) pbelcw on pbelcw.personid = pbe.personid and pbelcw.rank = 1 
----------------------------------
----- pbeamw = Employee AD&D -----
----------------------------------
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,coverageamount, max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		       from person_bene_election pbe
		       left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				              from person_bene_election pbe
				             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'EEADD  ') 
				               and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'EEADD  ') 
               and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
             group by 1,2,3,4,5,6,7,8 order by 1,11) pbeamw on pbeamw.personid = pbe.personid and pbeamw.rank = 1 
--------------------------------
----- pbeasw = Spouse AD&D -----
--------------------------------
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,coverageamount, max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		       from person_bene_election pbe
		       left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				              from person_bene_election pbe
				             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts  and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'SPADD  ')
				               and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts  and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'SPADD  ')
               and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
             group by 1,2,3,4,5,6,7,8 order by 1,11) pbeasw on pbeasw.personid = pbe.personid and pbeasw.rank = 1 
-------------------------------
----- pbeacw = Child AD&D -----
-------------------------------
left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,pbe.benefitplanid,pbe.benefitsubclass,pbe.compplanid,pbe.personbeneelectionpid,coverageamount, max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
		       from person_bene_election pbe
		       left join (select pbe.personid,pbe.benefitelection,pbe.benefitcoverageid,max(pbe.createts) as createts,max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate, rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
				              from person_bene_election pbe
				             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'DEPADD ')
				               and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate group by 1,2,3 order by 1,7) pbeno on pbeno.personid = pbe.personid and pbeno.rank = 1
             where pbe.benefitsubclass in ( select lkup.value1 as benefitsubclass from edi.lookup lkup join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate and current_timestamp between lkups.createts and lkups.endts and lkups.lookupname = 'Unum_VolLifeADD_Export' and key1 = 'DEPADD ')
               and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbeno.effectivedate <> pbe.effectivedate
             group by 1,2,3,4,5,6,7,8 order by 1,11) pbeacw on pbeacw.personid = pbe.personid and pbeacw.rank = 1                            
     
join edi.edi_last_update ed on ed.feedID = 'Unum_VolLifeADD_Export'


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.effectivedate >= ed.lastupdatets 
  and 
(
(         
exists (select 1 
          from person_identity pi1
         where pi1.personid     = pi.personid
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
or 
(        
exists (select 1 
          from person_bene_election pbelm1
         where pi.personid = pbelm1.personid
           and current_date between pbelm1.effectivedate and pbelm1.enddate
           and current_timestamp between pbelm1.createts and pbelm1.endts
           and greatest(pbelm1.effectivedate,pbelm1.createts) > ed.lastupdatets           
           and pbelm1.benefitsubclass in ('21'))         
or
exists (select 1 
          from person_bene_election pbeam1
         where pi.personid = pbeam1.personid
           and current_date between pbeam1.effectivedate and pbeam1.enddate
           and current_timestamp between pbeam1.createts and pbeam1.endts
           and greatest(pbeam1.effectivedate,pbeam1.createts) > ed.lastupdatets           
           and pbeam1.benefitsubclass in ('22'))         
or
exists (select 1 
          from person_bene_election pbels1
         where pi.personid = pbels1.personid
           and current_date between pbels1.effectivedate and pbels1.enddate
           and current_timestamp between pbels1.createts and pbels1.endts
           and greatest(pbels1.effectivedate,pbels1.createts) > ed.lastupdatets           
           and pbels1.benefitsubclass in ('2Z'))    
or
exists (select 1 
          from person_bene_election pbeas1
         where pi.personid = pbeas1.personid
           and current_date between pbeas1.effectivedate and pbeas1.enddate
           and current_timestamp between pbeas1.createts and pbeas1.endts
           and greatest(pbeas1.effectivedate,pbeas1.createts) > ed.lastupdatets           
           and pbeas1.benefitsubclass in ('27'))    
or
exists (select 1 
          from person_bene_election pbelc1
         where pi.personid = pbelc1.personid
           and current_date between pbelc1.effectivedate and pbelc1.enddate
           and current_timestamp between pbelc1.createts and pbelc1.endts
           and greatest(pbelc1.effectivedate,pbelc1.createts) > ed.lastupdatets           
           and pbelc1.benefitsubclass in ('25'))  
or
exists (select 1 
          from person_bene_election pbeac1
         where pi.personid = pbeac1.personid
           and current_date between pbeac1.effectivedate and pbeac1.enddate
           and current_timestamp between pbeac1.createts and pbeac1.endts
           and greatest(pbeac1.effectivedate,pbeac1.createts) > ed.lastupdatets           
           and pbeac1.benefitsubclass in ('24'))             
        
)         
)

;
