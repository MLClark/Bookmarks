select distinct
 piE.identity ::varchar(20) as employeeid
,piE.personid
,piDS.personid
,pnE.fname ::varchar(50) as mbrFirstName
,pnE.lname ::varchar(50) as mbrLastName
,pnE.mname ::char(1)  as mbrMI
,left(piS.identity,3)||'-'||substring(piS.identity,4,2)||'-'||right(piS.identity,4) ::char(11) as mbrSSN
,paE.streetaddress ::varchar(40) as mbrAddr1
,paE.streetaddress2 ::varchar(40) as mbrAddr2
,paE.city ::varchar(40) as mbrCity
,paE.stateprovincecode ::char(2) as mbrState
,paE.postalcode ::char(7) as mbrZip
,' ' ::char(4) as mbrZipPlus4
,b.beneficiaryclass
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


FROM person_identity piE

JOIN person_identity piS
  ON piS.personid = piE.personid
 AND current_timestamp BETWEEN piS.createts and piS.endts
 AND piS.identitytype = 'SSN'
JOIN person_names pnE 
  ON pnE.personid = piE.personid
 AND current_date BETWEEN pnE.effectivedate AND pnE.enddate
 AND current_timestamp BETWEEN pnE.createts AND pnE.endts      
 AND pnE.enddate > now()
 
LEFT JOIN person_address paE 
  ON paE.personid = piE.personid
 AND paE.addresstype = 'Res'::bpchar 
 AND current_date BETWEEN paE.effectivedate AND paE.enddate
 AND current_timestamp BETWEEN paE.createts AND paE.endts      
 AND paE.enddate > now()  
 
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
AND piE.personid in ('2185')
order by 1
 