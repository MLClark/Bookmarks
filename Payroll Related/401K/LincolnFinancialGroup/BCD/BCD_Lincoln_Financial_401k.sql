select distinct
 piE.identity ::varchar(20) as employeeid 
,piE.personid
,to_char(pbe.effectivedate,'mm/dd/yyyy') ::char(10) as changedate
---- dep change date 
,CASE pbe.benefitelection WHEN 'T' THEN to_char(pbe.effectivedate,'MM/DD/YYYY') else '' END ::char(10) AS termdate
,pnE.fname ::varchar(50) as mbrFirstName
,pnE.lname ::varchar(50) as mbrLastName
,pnE.mname ::char(1)  as mbrMiddleInitial
,left(piS.identity,3)||'-'||substring(piS.identity,4,2)||'-'||right(piS.identity,4) ::char(11) as mbrSSN
,pvE.gendercode ::char(1) as mbrGender
,to_char(pvE.birthdate,'mm/dd/yyyy')::char(10) as mbrDOB
,to_char(pbe.effectivedate,'mm/dd/yyyy')::char(10) as appSignDate
,eed.positiontitle ::varchar(50)
,to_char(eed.scheduledhours,'999D99') ::char(6) as hrsPerWeek
,to_char(pc.compamount,'999999999D99') ::char(12) as salaryAmt
,pc.frequencycode ::char(1) as salaryCode
,to_char(pc.effectivedate,'mm/dd/yyyy')::char(10) as salEffDate
,paE.streetaddress ::varchar(40) as mbrAddr1
,paE.streetaddress2 ::varchar(40) as mbrAddr2
,paE.city ::varchar(40) as mbrCity
,paE.stateprovincecode ::char(2) as mbrState
,paE.postalcode ::char(7) as mbrZip
,' ' ::char(4) as mbrZipPlus4
,left(ppcH.phoneno,3)||'-'||substring(ppcH.phoneno,4,3)||'-'||right(ppcH.phoneno,4)::char(12) as homephone
,left(ppcW.phoneno,3)||'-'||substring(ppcW.phoneno,4,3)||'-'||right(ppcW.phoneno,4)::char(12) as workphone
,' ' ::char(10) as workphoneext
,pnc.url ::varchar(100) as emailAddr
,to_char(eed.emplhiredate,'mm/dd/yyyy')::char(10) as dateOfBeneElig
,to_char(eed.empllasthiredate,'mm/dd/yyyy')::char(10) as subDateOfBeneElig
,CASE WHEN eetd.currentemplstatus = 'T' AND eetd.emplevent = 'VT'  THEN 'TERMINATION'
      WHEN eetd.currentemplstatus = 'T' AND eetd.emplevent = 'LO'  THEN 'LAYOFF'
      WHEN eetd.currentemplstatus = 'T' AND eetd.emplevent = 'LOA' THEN 'LEAVE OF ABSENCE'
      ELSE ' ' end ::varchar(20) as rsnForLOBE
,case when b.beneficiaryclass = 'P' and pdr.dependentid = b.dependentid then pnD.fname else ' ' end ::varchar(50) as priBFirstName
,case when b.beneficiaryclass = 'P' and pdr.dependentid = b.dependentid then pnD.lname else ' ' end ::varchar(50) as priBLastName
,case when b.beneficiaryclass = 'P' and pdr.dependentid = b.dependentid then pnD.mname else ' ' end ::char(1)     as priBMI 
,case when b.beneficiaryclass = 'P' and pdr.dependentid = b.dependentid then dr.dependentreldesc else ' ' end ::varchar(40) as priBRel      
,case when b.beneficiaryclass = 'P' and pdr.dependentid = b.dependentid then paD.streetaddress else ' ' end ::varchar(40) as priBAddr1
,case when b.beneficiaryclass = 'P' and pdr.dependentid = b.dependentid then paD.streetaddress2 else ' ' end ::varchar(40) as priBAddr2
,case when b.beneficiaryclass = 'P' and pdr.dependentid = b.dependentid then paD.city else ' ' end ::varchar(40) as priBCity
,case when b.beneficiaryclass = 'P' and pdr.dependentid = b.dependentid then paD.stateprovincecode else ' ' end ::char(2) as priBState
,case when b.beneficiaryclass = 'P' and pdr.dependentid = b.dependentid then paD.postalcode else ' ' end ::char(7) as priBZip
,' ' ::char(4) as priZipPlus4

,left(piDS.identity,3)||'-'||substring(piDS.identity,4,2)||'-'||right(piDS.identity,4) ::char(11) as priBSSN      

FROM person_identity piE

JOIN person_identity piS
  ON piS.personid = piE.personid
 AND current_timestamp BETWEEN piS.createts and piS.endts
 AND piS.identitytype = 'SSN'

JOIN person_bene_election pbe  
  ON pbe.personid = pie.personid
 --AND pbe.benefitsubclass in ('60', '61' )
 --AND pbe.benefitelection IN ('T','E','W')
 AND pbe.enddate = '2199-12-31' 
 AND current_date BETWEEN pbe.effectivedate AND pbe.enddate 
 AND current_timestamp BETWEEN pbe.createts AND pbe.endts
 
JOIN person_names pnE 
  ON pnE.personid = piE.personid
 AND current_date BETWEEN pnE.effectivedate AND pnE.enddate
 AND current_timestamp BETWEEN pnE.createts AND pnE.endts      
 AND pnE.enddate > now()

JOIN person_vitals pvE 
  ON pvE.personid = piE.personid 
 AND current_date BETWEEN pvE.effectivedate AND pvE.enddate
 AND current_timestamp BETWEEN pvE.createts AND pvE.endts    
 AND pvE.enddate > now() 
 
LEFT JOIN person_address paE 
  ON paE.personid = piE.personid
 AND paE.addresstype = 'Res'::bpchar 
 AND current_date BETWEEN paE.effectivedate AND paE.enddate
 AND current_timestamp BETWEEN paE.createts AND paE.endts      
 AND paE.enddate > now() 

LEFT JOIN person_phone_contacts ppcH ON ppcH.personid = piE.personid
 AND current_date between ppcH.effectivedate and ppcH.enddate
 AND current_timestamp between ppcH.createts and ppcH.endts 
 AND ppcH.phonecontacttype = 'Home'
LEFT JOIN person_phone_contacts ppcW ON ppcW.personid = piE.personid
 AND current_date between ppcW.effectivedate and ppcW.enddate
 AND current_timestamp between ppcW.createts and ppcW.endts 
 AND ppcW.phonecontacttype = 'Work'   
LEFT JOIN person_phone_contacts ppcB ON ppcB.personid = piE.personid
 AND current_date between ppcB.effectivedate and ppcB.enddate
 AND current_timestamp between ppcB.createts and ppcB.endts 
 AND ppcB.phonecontacttype = 'BUSN'      
LEFT JOIN person_phone_contacts ppcM ON ppcM.personid = piE.personid
 AND current_date between ppcM.effectivedate and ppcM.enddate
 AND current_timestamp between ppcM.createts and ppcM.endts 
 AND ppcM.phonecontacttype = 'Mobile'  

LEFT JOIN person_net_contacts pnc ON pnc.personid = piE.personid 
 AND pnc.netcontacttype = 'WRK'::bpchar 
 AND current_date between pnc.effectivedate and pnc.enddate
 AND current_timestamp between pnc.createts and pnc.enddate 

JOIN person_compensation pc 
  ON pc.personid = piE.personid
 AND current_date BETWEEN pc.effectivedate and pc.enddate
 AND current_timestamp BETWEEN pc.createts and pc.endts
 
JOIN edi.etl_employment_data eed
  ON eed.personid = piE.personid
LEFT JOIN edi.etl_employment_term_data eetd
  ON eetd.personid = piE.personid
 
LEFT JOIN person_identity piDS 
  ON piDS.personid = piE.personid
 AND current_timestamp between piDS.createts and piDS.endts
 AND piDS.identitytype = 'SSN'
  
LEFT JOIN person_dependent_relationship pdr 
  ON pdr.personid = piDS.personid 
 AND current_date between pdr.effectivedate and pdr.enddate
 AND current_timestamp between pdr.createts and pdr.endts
 
LEFT JOIN dependent_relationship dr
  ON dr.dependentrelationship = pdr.dependentrelationship

LEFT JOIN person_names pnD 
  ON pnD.personid = pdr.dependentid
 AND pnD.nametype = 'Dep'  
 AND current_date BETWEEN pnD.effectivedate AND pnD.enddate
 AND current_timestamp BETWEEN pnD.createts AND pnD.endts   
    
LEFT JOIN person_address paD 
  ON paD.personid = piDS.personid 
 AND paD.addresstype = 'Res'::bpchar 
 AND current_date BETWEEN paD.effectivedate AND paD.enddate
 AND current_timestamp BETWEEN paD.createts AND paD.endts      
 AND paD.enddate > now() 
 
JOIN beneficiary b
  ON b.personid = piS.personid
 AND b.beneficiaryclass = 'P'
 AND current_date between b.effectivedate and b.enddate
 AND current_timestamp between b.createts and b.endts   
 
where piE.identitytype = 'EmpNo'
AND piE.personid in ('93238', '86850') 


order by 1

