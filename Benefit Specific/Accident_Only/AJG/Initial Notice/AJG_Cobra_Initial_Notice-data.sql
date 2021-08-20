SELECT 
  DISTINCT
  pi.personid
, pie.identity as employeeid
, pn.lname::varchar(20) as lastname
, pn.fname::varchar(15) as firstname
, replace(pa.streetaddress,',',' ') ::varchar(50) as streetaddress1
, replace(pa.streetaddress2,',',' ') ::varchar(50) as streetaddress2
, pa.city ::varchar(30) as city
, pa.stateprovincecode ::char(2) statecode
, pa.postalcode ::char(5) as zipcode
, ppch.phoneno::char(12) as homephone
, pncw.url ::varchar(50) as emailaddress
, to_char(pv.birthdate,'yyyymmdd')::char(8) as birthdate
, spn.lname::varchar(20) as spouselname
, spn.fname::varchar(15) as spousefname


-- ETL EMPLOYMENT DATA VIEW
FROM person_identity pi

left join edi.edi_last_update elu  on elu.feedID = 'AJG_Cobra_Initial_Notice'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

LEFT JOIN person_employment pe ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts

--Get Benefit Elections
JOIN person_bene_election pbe on pbe.personid = pi.personid
 AND pbe.benefitelection = 'E' 
 AND pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11','14','60')
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 -- to be qualified for NEW cobra enrollment the EE must NOT have participated in employer's health care plan 
 and pbe.personid NOT in (select distinct personid from person_bene_election where current_timestamp between createts and endts and effectivedate <= elu.lastupdatets 
                         and benefitsubclass in ('10','11','14','60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts     
 
left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts              
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
left join person_phone_contacts ppcw 
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 
 and ppcw.phonecontacttype = 'Work'   
left join person_phone_contacts ppcb 
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'Mobile'      
left join person_phone_contacts ppcm 
  on ppcm.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts        
 --select * from person_phone_contacts
LEFT JOIN person_net_contacts pnch
  ON pnch.personid = pi.personid 
 AND pnch.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnch.effectivedate AND pnch.enddate 
 AND current_timestamp between pnch.createts AND pnch.endts
LEFT JOIN person_net_contacts pncw
  ON pncw.personid = pi.personid --added 11/30/2017
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate AND pncw.enddate 
 AND current_timestamp between pncw.createts AND pncw.endts
LEFT JOIN person_net_contacts pncO 
  ON pncO.personid = pi.personid --added 11/30/2017
 AND pncO.netcontacttype = 'OtherEmail'::bpchar
 and current_date between pncO.effectivedate and pncO.enddate
 and current_timestamp between pncO.createts and pncO.endts  

--Get Spouse Relationship
LEFT JOIN person_dependent_relationship pdr ON pdr.personid = pbe.personid
 AND pdr.dependentrelationship = 'SP'
 AND current_date between pdr.effectivedate and pdr.enddate
 AND current_timestamp between pdr.createts and pdr.endts
 
left join dependent_enrollment de
  on de.personid = pbe.personid
 and de.benefitsubclass in ('10','11','14','60')
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts 

--Get Spouse Name
LEFT JOIN person_names spn ON spn.personid = pdr.dependentid
 AND spn.nametype = 'Dep'
 AND current_date between spn.effectivedate and spn.enddate
 AND current_timestamp between spn.createts and spn.endts

WHERE pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) 
   or (pbe.effectivedate >= elu.lastupdatets::DATE)
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01'))) 
  and pe.emplstatus in ('A')
 -- and pe.personid = '12898'


