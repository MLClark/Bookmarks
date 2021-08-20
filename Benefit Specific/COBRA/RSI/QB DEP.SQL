select distinct
 pi.personid
,pe.effectivedate 
,pn.lname
,pn.fname 
,pdr.dependentid
,rank() over (ORDER BY PI.identity,pid.personid,pi.personid ) AS rownumber
,pi.identity ::char(9) AS SSN
,pid.identity::char(9) AS DepSSN
,case when pdr.dependentrelationship in ('S','D','QC','C')   THEN 'CHILD'
      when pdr.dependentrelationship in ('SP')               THEN 'SPOUSE'
      when pdr.dependentrelationship in ('DP')               THEN 'DOMESTICPARTNER' END ::char(35)  AS Relationship 
,' ' ::char(35) AS Salutation
,rtrim(ltrim(pnd.fname))::char(50)  AS FirstName
,coalesce(rtrim(ltrim(upper(substring(pnd.mname from 1 for 1)))),'') ::char(1) AS MiddleInitial
,rtrim(ltrim(pnd.lname)) ::char(50)  AS LastName
,' ' ::char(100) AS Email
,' ' ::char(10)  AS Phone1
,' ' ::char(10)  AS Phone2
,' ' ::char(50)  AS Address1
,' ' ::char(50)  AS Address2
,' ' ::char(50)  AS Address3
,' ' ::char(50)  AS City
,' ' ::char(50)  AS StateOrProvince
,' ' ::char(35)  AS PostalCode
,' ' ::char(50)  AS Country
,' ' ::char(10)  AS EnrollmentDate
,' ' ::char(1)   AS Sex
,' ' ::char(10)  AS DependentDOB
,' ' ::char(35)  AS IsQMCSO
,CASE WHEN eligee.benefitsubclass = '10' THEN 'UMR Medical PPO*'
      WHEN eligee.benefitsubclass = '1Y' THEN 'DBS HRA (can only elect with Medical Plan)*'
      WHEN eligee.benefitsubclass = '14' THEN 'UHC Vision'
      WHEN eligee.benefitsubclass = '11' THEN 'Delta Dental DPPO'  END ::CHAR(50)  AS poplanname
,' ' ::char(50)  AS POPlanBundleName
,' ' ::char(10)  AS POStartDate
,to_char(pe.effectivedate,'MM/DD/YYYY') ::char(10) AS QEventDate     
 --- convert date required for medical - conversion uses date part fields in kettle script
,case when pbem.benefitsubclass = '10' then 'Y' else 'N' end ::char(1)  as convertEventDate
,date_part('day', pe.effectivedate) as daypart
,date_part('month',pe.effectivedate) as monthpart
,date_part('year',pe.effectivedate) as yearpart


FROM person_identity pi
JOIN edi.edi_last_update elu on elu.feedID = 'RSI_DBS_COBRA_QB_Feed' 

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
  
join (select distinct personid, benefitsubclass
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

JOIN comp_plan_benefit_plan cpbp 
  on cpbp.benefitsubclass = eligee.benefitsubclass
 AND current_date between cpbp.effectivedate AND cpbp.enddate 
 AND current_timestamp between cpbp.createts AND cpbp.endts 

JOIN person_names pn 
  ON pn.personid = pe.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts 
 
----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = eligee.personid
 and pdr.dependentrelationship in ('S','D','C','SP','DP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

left JOIN (select personid, max(effectivedate) as effectivedate
from person_bene_election 
where current_timestamp between createts and endts
  and benefitelection = 'E'
  and selectedoption = 'Y'
  and benefitsubclass in ('10','11','14','1Y')
  group by 1) pbee on pbee.personid = pbe.personid 

JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitsubclass = pbe.benefitsubclass
 and de.enddate >= pbee.effectivedate
 and current_date >= de.effectivedate 
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


--- medical 10
left JOIN person_bene_election pbem
  on pbem.personid = eligee.personid 
 and pbem.selectedoption = 'Y' 
 and pbem.benefitsubclass in ('10')
 AND current_date between pbem.effectivedate AND pbem.enddate 
 AND current_timestamp between pbem.createts AND pbem.endts



 
where pi.identitytype = 'SSN' 
  AND current_timestamp between pi.createts AND pi.endts  
  and cpbp.cobraplan = 'Y' 
  and pe.emplstatus = 'T'
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  ;
