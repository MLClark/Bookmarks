 Select distinct
 pi.personid
,pe.emplevent
,pe.effectivedate
,'INSURED' ::VARCHAR(30) AS QSOURCE
,PI.identity ::char(9) AS employeeId
,pn.lname ::varchar(20) AS lname
,pn.fname ::varchar(30) AS fname
,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2
,pa.city ::varchar(20) as city
,pa.countrycode ::char(2) as country
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zipcode
,coalesce(ppcw.phoneno,ppcm.phoneno,ppch.phoneno,ppcb.phoneno )::char(13) as phone
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(100)  AS email
,to_char(pv.birthdate,'yyyymmdd')::char(8) AS dob
,pa.stateprovincecode ::char(2) as stateOfEmployment
,case when pe.emplevent = 'InvTerm' then '10' 
      when pe.emplevent = 'VolTerm' then '01'
      when pe.emplevent = 'Retire'  then '01'
      else pe.emplevent end ::char(2) AS EventType
,case when pe.emplstatus in ('T','R') then to_char(pe.effectivedate,'yyyymmdd') else null end ::char(8) as dateOfEvent_old
,case when pe.emplstatus in ('T','R') then to_char(DATE_TRUNC('month',pe.effectivedate) + INTERVAL '1 month' - INTERVAL '1 day','yyyymmdd')end ::char(8) as dateOfEvent  -- added 10/23/2017
,case when pe.emplstatus in ('T','R') then to_char(DATE_TRUNC('month',pe.effectivedate) + INTERVAL '1 month' - INTERVAL '1 day','yyyymmdd')end ::char(8) as paidThruDate  --added 11/30/2017
,lc.locationcode::char(10) as location



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

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts

LEFT JOIN person_address pa 
  ON pa.personid = pi.personid 
 AND pa.addresstype = 'Res'::bpchar 
 AND current_date between pa.effectivedate AND pa.enddate 
 AND current_timestamp between pa.createts AND pa.endts

LEFT JOIN person_vitals pv 
  ON pv.personid = pi.personid 
 AND current_date between pv.effectivedate AND pv.enddate 
 AND current_timestamp between pv.createts AND pv.endts

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
 and current_timestamp between pncw.createts and pncw.enddate 
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate      
left join person_net_contacts pnco 
  on pnco.personid = pi.personid 
 and pnco.netcontacttype = 'OtherEmail'::bpchar 
 and current_date between pnco.effectivedate and pnco.enddate
 and current_timestamp between pnco.createts and pnco.enddate   

LEFT JOIN person_locations pl    --added 11/30/2017
  ON pl.personid = pi.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts

left join location_codes lc 
  on lc.locationid = pl.locationid --added 11/30/2017
 AND current_date BETWEEN lc.effectivedate AND lc.enddate
 AND current_timestamp BETWEEN lc.createts AND lc.endts

WHERE pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('R','T')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 

ORDER BY 1

;
