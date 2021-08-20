select distinct
--- dependent
 pi.personid
,pdr.dependentid as dependentid 
,'2' ::char(1) as qsource
,'3' ::char(2) as sortseq 
,'CVG'::char(3) AS recordtype
,'HAR'::char(5) AS client
,PId.identity ::char(10) AS certNumber
,' ' ::char(2) AS filler
,'01' ::char(2) as planSeq
,CASE when pbeac.benefitplanid = '135' then 'ACCIDENT1'
      when pbeac.benefitplanid = '138' then 'ACCIDENT2' 
      when pbeci.benefitsubclass = '1W' then 'CRITICAL ILLNESS'  END ::CHAR(20) AS planCode
,case when bcd.benefitcoveragedesc = 'Employee Only' then 'M'
      when bcd.benefitcoveragedesc = 'Employee + Spouse' then 'MS'
      when bcd.benefitcoveragedesc = 'Family' then 'F'
      when bcd.benefitcoveragedesc = 'Employee + Children' then 'MC9' 
      else 'M' end ::char(3) AS coveredpersons     
,case when pbeci.benefitplanid in ('120', '126', '114') Then '10000'
      when pbeci.benefitplanid in ('129', '123', '132') Then '20000'
      Else ' ' End ::char(10) as benefitamount  -- benefitamounts are 0, parse the amount off benefitplandesc :-{ using benefitid 
,'   ' ::char(3) AS waitingperiod 
,upper(pa.stateprovincecode)::char(2) as issuestate
,' ' ::char(2) as coveragemonths
,'460192'::char(10) AS empID
,UPPER(PV.smoker) ::char(10) AS smoker
,' ' ::char(10) as var1
,to_char(coalesce(pbeac.effectivedate,pbeci.effectivedate),'mm/dd/yyyy')::char(10) as effdate
,' ' ::char(1) as waiver
,case when pe.emplstatus = 'T' then 'T'
      when pm.maritalstatus = 'D' and pm.benefitactionrequested = 'Y' then 'T' 
      when dd.dependentstatus = 'X' then 'D'
       end ::char(1) as status 

,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') 
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
  on pbe.personid = pe.personid 
 --AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ( '1W','13' )
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 and date_part('year',pbe.deductionstartdate) = date_part('year',current_date)
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ( '1W','13') and benefitelection = 'E' and selectedoption = 'Y')   

left JOIN person_bene_election pbet 
  on pbet.personid = pe.personid 
 AND current_date between pbet.effectivedate and pbet.enddate
 AND current_timestamp between pbet.createts and pbet.endts
 AND pbet.benefitsubclass IN ( '1W','13' )
 AND pbet.selectedoption = 'Y'
 and pbet.benefitelection in ('T')

--- accident
left JOIN person_bene_election pbeac
  on pbeac.personid = pbe.personid 
 and current_date between pbeac.effectivedate and pbeac.enddate
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
  
left JOIN benefit_coverage_desc bcdac
  ON bcdac.benefitcoverageid = pbeac.benefitcoverageid 
 AND current_date between bcdac.effectivedate and bcdac.enddate 
 AND current_timestamp between bcdac.createts AND bcdac.endts
 
left JOIN benefit_coverage_desc bcdci
  ON bcdci.benefitcoverageid = pbeci.benefitcoverageid 
 AND current_date between bcdci.effectivedate and bcdci.enddate 
 AND current_timestamp between bcdci.createts AND bcdci.endts 

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
 and de.benefitsubclass = pbeac.benefitsubclass
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
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'T'
  and pe.personid = '10166'
  