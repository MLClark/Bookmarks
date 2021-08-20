select distinct
 pi.personid
,'TERMED EE' ::varchar(30) as qsource
,'IB' ::char(2) as recordtype
,'IHS' ::varchar(6) as tpaid
,'IHSSBS' ::varchar(9) as employerid
,pi.identity ::char(9) as employeeid
,pn.lname ::varchar(26) as lname
,pn.fname ::varchar(19) as fname
,pn.mname ::char(1) as mname
,ppch.phoneno ::varchar(19) as homephone
,ppcm.phoneno ::varchar(19) as mobilephone
,pa.streetaddress ::varchar(36) as addr1
,pa.streetaddress2 ::varchar(36) as addr2
,pa.city ::varchar(20) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(9) as zip
,pa.countrycode ::varchar(3) as country
,'1' ::char(1) as reimburse_method
,coalesce(pncw.url,pnch.url) ::varchar(100) as email
,'5' ::char(1) as employee_status 
,case when pv.gendercode = 'F' then '2'
      when pv.gendercode = 'M' then '1' else '0' end ::char(1) as gender
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob
,pi.identity ::char(9) as ssn
     

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'CDE_Innovative_Health_Services_FSADC_Enroll_Export'

join person_employment pe
  on pe.personid = pi.personid
 and pe.effectivedate < pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'T'
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
 
left join person_bene_election pbefsa
  on pbefsa.personid = pbe.personid
 and pbefsa.benefitsubclass = '60'
 and pbefsa.selectedoption = 'Y'
 and pbefsa.benefitelection <> 'W'
 and pbefsa.effectivedate < pbefsa.enddate
 and current_timestamp between pbefsa.createts and pbefsa.endts

left join person_bene_election pbedfsa
  on pbedfsa.personid = pbe.personid
 and pbedfsa.benefitsubclass = '61'
 and pbedfsa.selectedoption = 'Y'
 and pbedfsa.benefitelection <> 'W'
 and pbedfsa.effectivedate < pbedfsa.enddate
 and current_timestamp between pbedfsa.createts and pbedfsa.endts  
 
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
left join person_vitals pv
  on pv.personid = pe.personid
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
 and ppcb.phonecontacttype = 'BUSN'      
left join person_phone_contacts ppcm
  on ppcm.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'  
  

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts 
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts  
LEFT JOIN person_net_contacts pnco
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.endts   
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus <> 'A'
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  --and pe.personid = '199' 