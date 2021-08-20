select 
 pi.personid     
,pnd.fname ::char(30) as depfirstname
,pnd.mname ::char(30) as depmiddlename
,pnd.lname ::char(50) as deplastname
,to_char(pvd.birthdate, 'yyyymmdd')::char(8) as depdob
,pvd.gendercode ::char(1) as depgender
,case pdr.dependentrelationship when 'SP' then 'S' else 'C' end ::char(1) as relationship
,to_char(pvd.birthdate, 'yyyymmdd')::char(8) as depAsofDate


,case pmsd.maritalstatus when 'M' then 'M' else 'S' end ::char(1) as maritalstatus
,case when dd.dependentstatus = 'D' then 'Y' else 'N' end ::char(1) as disabled


,to_char(pvd.birthdate, 'yyyymmdd')::char(8) as depAsofDate
,dd.student::char(1) as student

from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'ABD-BRMS Carrier Feed'
  
JOIN person_bene_election pbe  
  ON pbe.personid = pI.personid
 AND pbe.benefitsubclass = '10'
 AND pbe.benefitelection IN ('T','E','W')
 AND pbe.enddate = '2199-12-31' 
 AND CURRENT_DATE BETWEEN pbe.effectivedate AND pbe.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pbe.createts AND pbe.endts


LEFT JOIN person_dependent_relationship pdr 
  on pdr.personid = pi.personid
 AND CURRENT_DATE BETWEEN pdr.effectivedate AND pdr.enddate 
 AND CURRENT_TIMESTAMP BETWEEN pdr.createts AND pdr.endts
 
LEFT JOIN person_identity pid 
  ON pid.personid = pdr.dependentid 
 AND pid.identitytype = 'SSN'::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pid.createts AND pid.endts  

LEFT JOIN dependent_enrollment de 
  on de.dependentid = pdr.dependentid 
 AND de.benefitsubclass = pbe.benefitsubclass
 AND CURRENT_DATE BETWEEN de.effectivedate AND de.enddate 
 AND CURRENT_TIMESTAMP BETWEEN de.createts AND de.endts 

JOIN person_names pnd 
  ON pnd.personid = pid.personid
 AND CURRENT_DATE BETWEEN pnd.effectivedate AND pnd.enddate
 AND CURRENT_TIMESTAMP BETWEEN pnd.createts AND pnd.endts    
 
JOIN person_vitals pvd 
  ON pvd.personid = pid.personid
 AND CURRENT_DATE BETWEEN pvd.effectivedate AND pvd.enddate
 AND CURRENT_TIMESTAMP BETWEEN pvd.createts AND pvd.endts  
 
join dependent_desc dd
  on dd.dependentid = pdr.dependentid
 and current_date between dd.effectivedate and dd.enddate
 and current_timestamp between dd.createts and dd.endts 

join person_maritalstatus pmsd
  on pmsd.personid = pid.personid
 and current_date between pmsd.effectivedate and pmsd.enddate
 and current_timestamp between pmsd.createts and pmsd.endts
 


 
where pi.identitytype = 'SSN'
AND pbe.effectivedate >= elu.lastupdatets
--and pi.personid = '4030'


