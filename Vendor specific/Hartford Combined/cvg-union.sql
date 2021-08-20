select distinct
--- employee
 pi.personid
,'e'
,'CVG'::char(3) AS recordtype
,'HAR'::char(5) AS client
,PI.identity ::char(10) AS certNumber
,' ' ::char(2) AS filler
,'01' ::char(2) as planSeq
,CASE when pbe.benefitplanid = '135' then 'ACCIDENT1'
      when pbe.benefitplanid = '138' then 'ACCIDENT2' ELSE 'CRITICAL ILLNESS'  END ::CHAR(20) AS planCode
,case when bcd.benefitcoveragedesc = 'Employee Only' then 'M'
      when bcd.benefitcoveragedesc = 'Employee + Spouse' then 'MS'
      when bcd.benefitcoveragedesc = 'Family' then 'F'
      when bcd.benefitcoveragedesc = 'Employee + Children' then 'MC9' 
      else 'M' end ::char(3) AS coveredpersons     
,case when pbeci.benefitplanid in ('120', '126','114') Then '10000'
      when pbeci.benefitplanid in ('129', '123', '132') Then '20000'
      Else ' ' End ::char(10) as benefitamount  -- benefitamounts are 0, parse the amount off benefitplandesc :-{ using benefitid 
,'   ' ::char(3) AS waitingperiod 
,upper(pa.stateprovincecode)::char(2) as issuestate
,' ' ::char(2) as coveragemonths
,'460192'::char(10) AS empID
,UPPER(PV.smoker) ::char(10) AS smoker
,' ' ::char(10) as var1
,to_char(pbe.effectivedate,'mm/dd/yyyy')::char(10) as effdate
,' ' ::char(1) as waiver
,' ' ::char(1) as status 

,' ' ::char(10) as statusdate
,' ' ::char(10) as paidtodate
,' ' ::char(10) as billtodate
,'RA' ::char(12) as campaign
,' ' ::char(10) as maintdate
,' ' ::char(10) as agentid
,' ' ::char(6) as agentpct
,' ' ::char(2) as replacementind      
   
from person_identity pi

JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 --AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ( '1W','13' )
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 and date_part('year',pbe.deductionstartdate) = date_part('year',current_date)


left JOIN person_bene_election pbet 
  on pbet.personid = pi.personid 
 --AND current_date between pbet.effectivedate and pbet.enddate
 AND current_timestamp between pbet.createts and pbet.endts
 AND pbet.benefitsubclass IN ( '1W','13' )
 AND pbet.selectedoption = 'Y'
 and pbet.benefitelection in ('T')
 and date_part('year',pbet.deductionstartdate) = date_part('year',current_date) 
 and pbet.personid <> ('9707')

--- accident
left JOIN person_bene_election pbeac
  on pbeac.personid = pi.personid 
 AND current_date between pbeac.effectivedate and pbeac.enddate
 AND current_timestamp between pbeac.createts and pbeac.endts
 AND pbeac.benefitsubclass IN ('13')
 AND pbeac.selectedoption = 'Y' 
 and pbeac.personid <> ('9707')
 
-- 10KCritNT           
left JOIN person_bene_election pbeci
  on pbeci.personid = pi.personid 
 AND current_date between pbeci.effectivedate and pbeci.enddate
 AND current_timestamp between pbeci.createts and pbeci.endts
 AND pbeci.benefitsubclass IN ('1W')
 AND pbeci.selectedoption = 'Y' 
 
left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid 
 AND current_date between bcd.effectivedate and bcd.enddate 
 AND current_timestamp between bcd.createts AND bcd.endts

left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts



where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.benefitelection <> 'W'
  and (pe.emplstatus = 'T' and date_part('year',pe.effectivedate)=date_part('year',current_date)
       or pe.emplstatus = 'A')  
  
  
union 

select distinct
 pi.personid
,'d'
,'CVG'::char(3) AS recordtype
,'HAR'::char(5) AS client
,PI.identity ::char(10) AS certNumber
,' ' ::char(2) AS filler
,'01' ::char(2) as planSeq
,CASE when pbe.benefitplanid = '135' then 'ACCIDENT1'
      when pbe.benefitplanid = '138' then 'ACCIDENT2' ELSE 'CRITICAL ILLNESS'  END ::CHAR(20) AS planCode
,case when bcd.benefitcoveragedesc = 'Employee Only' then 'M'
      when bcd.benefitcoveragedesc = 'Employee + Spouse' then 'MS'
      when bcd.benefitcoveragedesc = 'Family' then 'F'
      when bcd.benefitcoveragedesc = 'Employee + Children' then 'MC9' 
      else 'M' end ::char(3) AS coveredpersons     
,case when pbeci.benefitplanid in ('120', '126','114') Then '10000'
      when pbeci.benefitplanid in ('129', '123', '132') Then '20000'
      Else ' ' End ::char(10) as benefitamount  -- benefitamounts are 0, parse the amount off benefitplandesc :-{ using benefitid 
,'   ' ::char(3) AS waitingperiod 
,upper(pa.stateprovincecode)::char(2) as issuestate
,' ' ::char(2) as coveragemonths
,'460192'::char(10) AS empID
,UPPER(PV.smoker) ::char(10) AS smoker
,' ' ::char(10) as var1
,to_char(pbe.effectivedate,'mm/dd/yyyy')::char(10) as effdate
,' ' ::char(1) as waiver
,case when pm.maritalstatus = 'D' and pm.benefitactionrequested = 'Y' then 'T' 
      when dd.dependentstatus = 'X' then 'D'
      when termdep.DEP_STATUS = 'A' then 'A'
      else ' ' end  ::char(1) as status 

,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') 
      when termdep.dep_status = 'A' then to_char(termdep.enddate,'mm/dd/yyyy')
      else ' ' end ::char(10) as statusdate
,' ' ::char(10) as paidtodate
,' ' ::char(10) as billtodate
,'RA' ::char(12) as campaign
,' ' ::char(10) as maintdate
,' ' ::char(10) as agentid
,' ' ::char(6) as agentpct
,' ' ::char(2) as replacementind      
   
from person_identity pi

JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ( '1W','13' )
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 and date_part('year',pbe.deductionstartdate) = date_part('year',current_date)

left JOIN person_bene_election pbet 
  on pbet.personid = pi.personid 
 --AND current_date between pbet.effectivedate and pbet.enddate
 AND current_timestamp between pbet.createts and pbet.endts
 AND pbet.benefitsubclass IN ( '1W','13' )
 AND pbet.selectedoption = 'Y'
 and pbet.benefitelection in ('T')
 and date_part('year',pbet.deductionstartdate) = date_part('year',current_date) 

--- accident
left JOIN person_bene_election pbeac
  on pbeac.personid = pi.personid 
 AND current_date between pbeac.effectivedate and pbeac.enddate
 AND current_timestamp between pbeac.createts and pbeac.endts
 AND pbeac.benefitsubclass IN ('13')
 AND pbeac.selectedoption = 'Y' 
 
-- 10KCritNT           
left JOIN person_bene_election pbeci
  on pbeci.personid = pi.personid 
 AND current_date between pbeci.effectivedate and pbeci.enddate
 AND current_timestamp between pbeci.createts and pbeci.endts
 AND pbeci.benefitsubclass IN ('1W')
 AND pbeci.selectedoption = 'Y' 
 
left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid 
 AND current_date between bcd.effectivedate and bcd.enddate 
 AND current_timestamp between bcd.createts AND bcd.endts

left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts

----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and pdr.dependentrelationship in ('S','D','C','SP','DP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
 
join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep'   
 
join person_vitals pvd
  on pvd.personid = pdr.dependentid
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts  

LEFT JOIN dependent_desc dd 
  ON dd.dependentid = pdr.dependentid 
 AND current_date between dd.effectivedate and dd.enddate 
 AND current_timestamp between dd.createts and dd.endts 
 

join (
select distinct
 de.personid
,de.dependentid
,pn.name
,pn.nametype
,pdr.dependentrelationship
,pv.birthdate
from dependent_enrollment de
join person_dependent_relationship pdr
  on pdr.personid = de.personid
 and pdr.dependentid = de.dependentid
 and pdr.dependentrelationship in ('D','S','C')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
left join person_vitals pv
  on pv.personid = de.dependentid
 and current_timestamp between de.createts and de.endts 
 --and current_date between de.effectivedate and de.enddate
join person_names pn
  on pn.personid = de.dependentid
 and pn.nametype = 'Dep'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
where de.benefitsubclass = '13'
  and de.enddate < '2199-12-30'
  and pv.birthdate::date < current_date::date - interval '26 years'
) ageddep on ageddep.personid = pbe.personid and ageddep.dependentid = pdr.dependentid

left JOIN (
select distinct
 de.personid
,de.dependentid
,de.effectivedate 
,pv.birthdate
,CASE WHEN PV.BIRTHDATE <= CURRENT_DATE - INTERVAL '26 YEARS' THEN 'A' ELSE ' ' END AS DEP_STATUS
,max(de.enddate) enddate
from dependent_enrollment de
left join person_vitals pv
  on pv.personid = de.dependentid
 and current_timestamp between de.createts and de.endts 
where de.benefitsubclass = '13'
  and de.enddate < '2199-12-30'
 
  group by 1,2,3,4,5
) TERMDEP ON TERMDEP.PERSONID = PBE.PERSONID and TERMDEP.DEPENDENTID = ageddep.DEPENDENTID

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus = 'T' and date_part('year',pe.effectivedate)=date_part('year',current_date)
       or pe.emplstatus = 'A') 
  and pbe.benefitelection <> 'W' 
  and pi.personid <> ('9707')
  
union 


select distinct
 pi.personid
,'f'
,'CVG'::char(3) AS recordtype
,'HAR'::char(5) AS client
,PI.identity ::char(10) AS certNumber
,' ' ::char(2) AS filler
,'01' ::char(2) as planSeq
,CASE when pbe.benefitplanid = '135' then 'ACCIDENT1'
      when pbe.benefitplanid = '138' then 'ACCIDENT2' ELSE 'CRITICAL ILLNESS'  END ::CHAR(20) AS planCode
,case when bcd.benefitcoveragedesc = 'Employee Only' then 'M'
      when bcd.benefitcoveragedesc = 'Employee + Spouse' then 'MS'
      when bcd.benefitcoveragedesc = 'Family' then 'F'
      when bcd.benefitcoveragedesc = 'Employee + Children' then 'MC9' 
      else 'M' end ::char(3) AS coveredpersons     
,case when pbeci.benefitplanid in ('120', '126','114') Then '10000'
      when pbeci.benefitplanid in ('129', '123', '132') Then '20000'
      Else ' ' End ::char(10) as benefitamount  -- benefitamounts are 0, parse the amount off benefitplandesc :-{ using benefitid 
,'   ' ::char(3) AS waitingperiod 
,upper(pa.stateprovincecode)::char(2) as issuestate
,' ' ::char(2) as coveragemonths
,'460192'::char(10) AS empID
,UPPER(PV.smoker) ::char(10) AS smoker
,' ' ::char(10) as var1
,to_char(pbe.effectivedate,'mm/dd/yyyy')::char(10) as effdate
,' ' ::char(1) as waiver
,case when pm.maritalstatus = 'D' and pm.benefitactionrequested = 'Y' then 'T' 
      when dd.dependentstatus = 'X' then 'D'
      when termdepac.DEP_STATUS = 'A' then 'A'
      else ' ' end  ::char(1) as status 

,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') 
      when termdepac.dep_status = 'A' then to_char(termdepac.enddate,'mm/dd/yyyy')
      else ' ' end ::char(10) as statusdate
,' ' ::char(10) as paidtodate
,' ' ::char(10) as billtodate
,'RA' ::char(12) as campaign
,' ' ::char(10) as maintdate
,' ' ::char(10) as agentid
,' ' ::char(6) as agentpct
,' ' ::char(2) as replacementind      
   
from person_identity pi

JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ( '1W','13' )
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 and date_part('year',pbe.deductionstartdate) = date_part('year',current_date)

left JOIN person_bene_election pbet 
  on pbet.personid = pi.personid 
 --AND current_date between pbet.effectivedate and pbet.enddate
 AND current_timestamp between pbet.createts and pbet.endts
 AND pbet.benefitsubclass IN ( '1W','13' )
 AND pbet.selectedoption = 'Y'
 and pbet.benefitelection in ('T')
 and date_part('year',pbet.deductionstartdate) = date_part('year',current_date) 

--- accident
left JOIN person_bene_election pbeac
  on pbeac.personid = pi.personid 
 AND current_date between pbeac.effectivedate and pbeac.enddate
 AND current_timestamp between pbeac.createts and pbeac.endts
 AND pbeac.benefitsubclass IN ('13')
 AND pbeac.selectedoption = 'Y' 
 
-- 10KCritNT           
left JOIN person_bene_election pbeci
  on pbeci.personid = pi.personid 
 AND current_date between pbeci.effectivedate and pbeci.enddate
 AND current_timestamp between pbeci.createts and pbeci.endts
 AND pbeci.benefitsubclass IN ('1W')
 AND pbeci.selectedoption = 'Y' 
 
left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid 
 AND current_date between bcd.effectivedate and bcd.enddate 
 AND current_timestamp between bcd.createts AND bcd.endts

left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts

----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and pdr.dependentrelationship in ('S','D','C','SP','DP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
 
join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep'   
 
join person_vitals pvd
  on pvd.personid = pdr.dependentid
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts  

LEFT JOIN dependent_desc dd 
  ON dd.dependentid = pdr.dependentid 
 AND current_date between dd.effectivedate and dd.enddate 
 AND current_timestamp between dd.createts and dd.endts 
 

join (
select distinct
 de.personid
,de.dependentid
,pn.name
,pn.nametype
,pdr.dependentrelationship
,pv.birthdate
from dependent_enrollment de
join person_dependent_relationship pdr
  on pdr.personid = de.personid
 and pdr.dependentid = de.dependentid
 and pdr.dependentrelationship in ('D','S','C')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
left join person_vitals pv
  on pv.personid = de.dependentid
 and current_timestamp between de.createts and de.endts 
 --and current_date between de.effectivedate and de.enddate
join person_names pn
  on pn.personid = de.dependentid
 and pn.nametype = 'Dep'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
where de.benefitsubclass = '13'
  and de.enddate < '2199-12-30'
  and pv.birthdate::date < current_date::date - interval '26 years'
) ageddepac on ageddepac.personid = pbeac.personid and ageddepac.dependentid = pdr.dependentid

JOIN (
select distinct
 de.personid
,de.dependentid
,de.effectivedate 
,pv.birthdate
,CASE WHEN PV.BIRTHDATE <= CURRENT_DATE - INTERVAL '26 YEARS' THEN 'A' ELSE ' ' END AS DEP_STATUS
,max(de.enddate) enddate
from dependent_enrollment de
left join person_vitals pv
  on pv.personid = de.dependentid
 and current_timestamp between de.createts and de.endts 
where de.benefitsubclass = '13'
  and de.enddate < '2199-12-30'
 
  group by 1,2,3,4,5
) TERMDEPac ON TERMDEPac.PERSONID = PBEAC.PERSONID and TERMDEPac.DEPENDENTID = ageddepac.DEPENDENTID


left join (
select distinct
 de.personid
,de.dependentid
,pn.name
,pn.nametype
,pdr.dependentrelationship
,pv.birthdate
from dependent_enrollment de
join person_dependent_relationship pdr
  on pdr.personid = de.personid
 and pdr.dependentid = de.dependentid
 and pdr.dependentrelationship in ('D','S','C')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
left join person_vitals pv
  on pv.personid = de.dependentid
 and current_timestamp between de.createts and de.endts 
 --and current_date between de.effectivedate and de.enddate
join person_names pn
  on pn.personid = de.dependentid
 and pn.nametype = 'Dep'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
where de.benefitsubclass = '1W'
  and de.enddate < '2199-12-30'
  and pv.birthdate::date < current_date::date - interval '26 years'
) ageddepci on ageddepci.personid = pbeci.personid and ageddepci.dependentid = pdr.dependentid

left JOIN (
select distinct
 de.personid
,de.dependentid
,de.effectivedate 
,pv.birthdate
,CASE WHEN PV.BIRTHDATE <= CURRENT_DATE - INTERVAL '26 YEARS' THEN 'A' ELSE ' ' END AS DEP_STATUS
,max(de.enddate) enddate
from dependent_enrollment de
left join person_vitals pv
  on pv.personid = de.dependentid
 and current_timestamp between de.createts and de.endts 
where de.benefitsubclass = '1W'
  and de.enddate < '2199-12-30'
 
  group by 1,2,3,4,5
) TERMDEPci ON TERMDEPci.PERSONID = PBECi.PERSONID and TERMDEPci.DEPENDENTID = ageddepci.DEPENDENTID

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus = 'T' and date_part('year',pe.effectivedate)=date_part('year',current_date)
       or pe.emplstatus = 'A') 
  and pbe.benefitelection <> 'W' 

  and pi.personid in ('9707')  
  
order by 1,4