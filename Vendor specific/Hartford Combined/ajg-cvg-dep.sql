select distinct
 pi.personid
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

/* this status is set if coverage change that only applies to the dependent - divorce or death is only change I can track
•	Status codes
•	blank - active,
•	A – attained age termination,
•	C – cancelled,
•	D - deceased,
•	L – lapsed,
•	T – terminated
*/
,case when pm.maritalstatus = 'D' and pm.benefitactionrequested = 'Y' then 'T' 
      when dd.dependentstatus = 'X' then 'D'
      when 
      else ' ' end  ::char(1) as status 

,case when pm.maritalstatus = 'D' and pm.benefitactionrequested = 'Y' then to_char(pm.effectivedate,'mm/dd/yyyy') 
      when dd.dependentstatus = 'X' then to_char(dd.effectivedate,'mm/dd/yyyy') 
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

left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ( '1W','13' )
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T','E')
 and date_part('year',pbe.deductionstartdate) = date_part('year',current_date)

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
 and current_date between de.effectivedate and de.enddate
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

join (select distinct
 de.personid
,de.dependentid
,de.effectivedate 
,pv.birthdate
,max(de.enddate) enddate
from dependent_enrollment de
left join person_vitals pv
  on pv.personid = de.dependentid
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts 
where de.benefitsubclass = '13'
  and de.enddate < '2199-12-30'
  and de.dependentid = '11235'
  group by 1,2,3,4) termdep on termdep.personid = pbe.personid  
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus = 'T' and date_part('year',pe.effectivedate)=date_part('year',current_date)
       or pe.emplstatus = 'A')  
 and pi.personid = '9707'
order by 1