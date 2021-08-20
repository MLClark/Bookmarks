SELECT distinct
 pi.personid
,'DEPENDENT' ::VARCHAR(30) AS QSOURCE 
,pe.effectivedate  
,pi.identity::char(9)
,pid.identity::char(9) AS DepSSN
,pnd.fname ::varchar(30) AS FirstName
,pnd.lname ::varchar(30) AS LastName
,case when pdr.dependentrelationship in ('DP','SP') then 'S'    
      when pdr.dependentrelationship in ('S','D','C') THEN 'C' else 'O' end ::char(1) AS Relationship
,case when pdr.dependentrelationship in ('DP','SP') then '1'   else '2' end ::char(1) AS DepRel
,to_char(pvd.birthdate,'yyyymmdd')::char(8) as dob
,pvd.gendercode ::char(1) as gender

FROM person_identity pi

JOIN edi.edi_last_update elu on elu.feedID = 'AJG_Flores_Cobra_Qualifying_Event'

LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection in ('T','E')
 and pbe.benefitsubclass in ('10','11','14','20','60')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','20','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

JOIN person_dependent_relationship pdr 
  on pdr.personid = pbe.personid 
 AND CURRENT_DATE BETWEEN pdr.effectivedate AND pdr.enddate
 AND current_timestamp BETWEEN pdr.createts AND pdr.endts
 AND pdr.dependentrelationship in ('SP','DP','S','D','C')

left JOIN dependent_enrollment de 
  on de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y' 
 and de.benefitsubclass in ('10','11','14','20','60')
 and de.effectivedate < de.enddate
 and current_timestamp between de.createts and de.endts

JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid
 AND CURRENT_DATE BETWEEN pnd.effectivedate AND pnd.enddate
 AND current_timestamp BETWEEN pnd.createts AND pnd.endts
 AND nametype in ('Legal','Dep')   --HS_#19004_05252018

LEFT JOIN person_identity pid 
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'
 AND current_timestamp BETWEEN pid.createts AND pid.endts

LEFT JOIN person_vitals pvd 
  ON pvd.personid = pdr.dependentid
 AND CURRENT_DATE BETWEEN pvd.effectivedate AND pvd.enddate
 AND current_timestamp BETWEEN pvd.createts AND pvd.endts

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('R','T')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  
ORDER BY 2,1