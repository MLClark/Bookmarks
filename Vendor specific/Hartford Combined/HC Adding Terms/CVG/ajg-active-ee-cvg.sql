select distinct
--- active employee
 pi.personid
,' ' as dependentid
,'active ee' ::varchar(30) as qsource
,'3' ::char(2) as sortseq
,'CVG'::char(3) AS recordtype
,'HAR'::char(5) AS client
,PI.identity ::char(10) AS certNumber
,' ' ::char(2) AS filler
,'01' ::char(2) as planSeq
,CASE when pbe.benefitsubclass = '13' and pbe.benefitplanid = '135' then 'ACCIDENT1'
      when pbe.benefitsubclass = '13' and pbe.benefitplanid = '138' then 'ACCIDENT2' 
      else 'CRITICAL ILLNESS'  END ::CHAR(20) AS planCode
 
,case when bcd.benefitcoveragedesc = 'Employee Only' then 'M'
      when bcd.benefitcoveragedesc = 'Employee + Spouse' then 'MS'
      when bcd.benefitcoveragedesc = 'Family' then 'F'
      when bcd.benefitcoveragedesc = 'Employee + Children' then 'MC9' 
      else 'M' end ::char(3) AS coveredpersons     
,case when pbe.benefitsubclass = '1W' and pbe.benefitplanid in ('120', '126', '114') Then '10000'
      when pbe.benefitsubclass = '1W' and pbe.benefitplanid in ('129', '123', '132') Then '20000'
      Else ' ' End ::char(10) as benefitamount  -- benefitamounts are 0, parse the amount off benefitplandesc :-{ using benefitid 
,'   ' ::char(3) AS waitingperiod 
,upper(pa.stateprovincecode)::char(2) as issuestate
,' ' ::char(2) as coveragemonths
,'460192'::char(10) AS empID
,UPPER(PV.smoker) ::char(10) AS smoker
,' ' ::char(10) as var1
,to_char(coalesce(pbeac.effectivedate,pbeci.effectivedate),'mm/dd/yyyy')::char(10) as effdate
,' ' ::char(1) as waiver
,' ' ::char(1) as status --- this should always be blank on cvg record

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

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.benefitelection <> 'W'
  and pe.emplstatus = 'A'
  and pe.personid = '10108'
  