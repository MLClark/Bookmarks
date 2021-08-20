--%%%%% CVG RECORD
Select DISTINCT
 'CVG'::char(3) AS recordtype
 ,pi.personid
,'HAR'::char(5) AS client
,PI.identity ::char(10) AS certNumber
,' ' ::char(2) AS filler
,'01' ::char(2) as planSeq
,pbe.benefitplanid 
,CASE pbe.benefitplanid 
   WHEN '135' THEN 'ACCIDENT1'
   WHEN '138' THEN 'ACCIDENT2'   
   ELSE 'CRITICAL ILLNESS' 
   END ::CHAR(20) AS planCode

,case bcd.benefitcoveragedesc 
      when 'Employee Only' then 'M'
      when 'Employee + Spouse' then 'MS'
      when 'Family' then 'F'
      when 'Employee + Children' then 'MC9' 
      else 'M' end ::char(3) AS coveredpersons 
,case
		When pbe.benefitplanid in ('120', '126') Then '10000'
		When pbe.benefitplanid in ('129', '123', '132') Then '20000'
		Else ' '
		End ::char(10) as benefitamount  -- benefitamounts are 0, parse the amount off benefitplandesc :-{ using benefitid 
,'   ' ::char(3) AS waitingperiod
,upper(pa.stateprovincecode)::char(2) as issuestate
,' ' ::char(2) as coveragemonths
,'460192'::char(10) AS empID
,UPPER(PV.smoker) ::char(10) AS smoker
,' ' ::char(10) as var1
,to_char(pbe.effectivedate,'mm/dd/yyyy') ::char(10) as effdate
,' ' ::char(1) as waiver
,case pe.emplstatus when 'A' then ' ' 
                    when 'P' then ' ' 
                    else pe.emplstatus end ::char(1) as status

,' ' ::char(10) as statusdate
,' ' ::char(10) as paidtodate
,' ' ::char(10) as billtodate
,'RA' ::char(12) as campaign
,' ' ::char(10) as maintdate
,' ' ::char(10) as agentid
,' ' ::char(6) as agentpct
,' ' ::char(2) as replacementind


from person_identity pi

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 AND current_timestamp between pbe.createts and pbe.endts
 and date_part('year',pbe.effectivedate) = date_part('year',current_date + interval '1 year')
 AND pbe.benefitsubclass IN ( '1W','13','30','31' )
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid 
 AND current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
left JOIN person_vitals pv 
  on pv.personid = pi.personid 
 AND current_date between pv.effectivedate and pv.enddate 
 AND current_timestamp between pv.createts and pv.endts	 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  
and pi.personid = '10618';
