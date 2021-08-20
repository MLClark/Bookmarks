SELECT distinct
 pi.personid
,pn.lname,pn.fname
,pi.identity ::char(9)  AS SSN

,CASE pbe.benefitsubclass 
      WHEN '10' THEN 'UMR Medical PPO*'
      WHEN '1Y' THEN 'DBS HRA (can only elect with Medical Plan)*'
      WHEN '14' THEN 'UHC Vision'
      WHEN '11' THEN 'Delta Dental DPPO'  END ::CHAR(50)  AS poplanname

,' ' ::CHAR(50) AS POPLANBUNDLENAME
--,bcd.benefitcoveragedesc
--,pdr.dependentrelationship
,case when bcd.benefitcoveragedesc = 'EE & 1 Dep or More' and pdr.dependentrelationship = 'SP' then 'EE+SPOUSE'
      when bcd.benefitcoveragedesc = 'EE & 1 Dep or More' and pdr.dependentrelationship in ('DP','S','D','C') then 'EE+CHILD'
      when bcd.benefitcoveragedesc = 'Employee + Children' then 'EE+CHILDREN'
      when bcd.benefitcoveragedesc = 'Employee + Spouse' then 'EE+SPOUSE'
      when bcd.benefitcoveragedesc = 'Family' then 'EE+FAMILY'     
      else 'EE' end ::char(15) as coverageLevel
    
,TO_CHAR(PBE.EFFECTIVEDATE,'mm/dd/YYYY') ::CHAR(10) AS POSTARTDATE
,to_char(pe.paythroughdate,'mm/dd/YYYY') ::char(10) AS QEventDate

,case pbe.benefitsubclass when '1Y' then 'Y' when '10' then 'Y' else 'N' end ::char(1)  as convertEventDate
,date_part('day',pe.paythroughdate) as daypart
,date_part('month',pe.paythroughdate) as monthpart
,date_part('year',pe.paythroughdate) as yearpart

FROM PERSON_IDENTITY PI
JOIN edi.edi_last_update elu on elu.feedID = 'RSI_DBS_COBRA_QB_Feed'  

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_names pn 
  ON pn.personid = pe.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts
 
left join (select distinct personid, benefitsubclass
        from person_bene_election 
       where current_timestamp between createts and endts 
         and benefitsubclass in ('10','11','14','1Y') and benefitelection = 'E' and selectedoption = 'Y'
         and date_part('year',planyearenddate) = date_part('year',current_date)) as eligee on eligee.personid = pe.personid
 
JOIN person_bene_election pbe 
  on pbe.personid = eligee.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass = eligee.benefitsubclass -- in ('10','11','14','1Y')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 
  
left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid 
 AND current_date between bcd.effectivedate and bcd.enddate 
 AND current_timestamp between bcd.createts AND bcd.endts
 
left join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and pdr.dependentrelationship in ('S','D','C','SP','DP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts 

where pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'T'
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 

              
UNION 

SELECT distinct
 pi.personid
,pn.lname,pn.fname
,pi.identity ::char(9)  AS SSN

,'DBS HRA (can only elect with Medical Plan)*' ::CHAR(50)  AS poplanname
,' ' ::CHAR(50) AS POPLANBUNDLENAME
--,bcd.benefitcoveragedesc
--,pdr.dependentrelationship
, 'EE' ::char(15) as coverageLevel
    
,TO_CHAR(pbehra.EFFECTIVEDATE,'mm/dd/YYYY') ::CHAR(10) AS POSTARTDATE
,to_char(pe.paythroughdate,'mm/dd/YYYY') ::char(10) AS QEventDate

,'Y' ::char(1)  as convertEventDate
,date_part('day',pe.paythroughdate) as daypart
,date_part('month',pe.paythroughdate) as monthpart
,date_part('year',pe.paythroughdate) as yearpart

FROM PERSON_IDENTITY PI
JOIN edi.edi_last_update elu on elu.feedID = 'RSI_DBS_COBRA_QB_Feed'  

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_names pn 
  ON pn.personid = pe.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts


JOIN person_bene_election pbe 
  on pbe.personid = pe.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts

   -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10') and benefitelection = 'E' and selectedoption = 'Y'
                         and date_part('year',planyearenddate) = date_part('year',current_date))
 
JOIN person_bene_election pbehra 
  on pbehra.personid = pbe.personid 
 and pbehra.benefitsubclass in ('1Y')
 AND current_date between pbehra.effectivedate AND pbehra.enddate 
 AND current_timestamp between pbehra.createts AND pbehra.endts
 
 -- select * from person_employment where personid = '1601'
  
left JOIN benefit_coverage_desc bcd 
  ON bcd.benefitcoverageid = pbe.benefitcoverageid 
 AND current_date between bcd.effectivedate and bcd.enddate 
 AND current_timestamp between bcd.createts AND bcd.endts
 
where pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'T'
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 

              
order by 1      