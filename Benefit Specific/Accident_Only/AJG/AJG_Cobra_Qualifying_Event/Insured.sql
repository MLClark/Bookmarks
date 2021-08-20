 Select distinct
 pi.personid
,pbe.effectivedate
,substr(PI.identity, 1, 9) AS employeeId
,substr(pn.lname, 1, 20) AS lname
,substr(pn.fname, 1, 15) AS fname
,substr(pa.streetaddress, 1, 30) as addr1
,substr(pa.streetaddress2, 1, 30) as addr2
,substr(pa.city, 1, 20) as city
,substr(pa.countrycode, 1, 2) as country
,substr(pa.stateprovincecode, 1, 2) as state
,substr(pa.postalcode, 1, 5) as zipcode
,coalesce(ppcw.phoneno,ppcm.phoneno,ppch.phoneno,ppcb.phoneno )::char(13) as phone
,coalesce(pnch.url,pncw.url,pncO.url)::char(50)  AS email
,to_char(pv.birthdate,'yyyymmdd')::char(8) AS dob
,pa.stateprovincecode::char(2) as stateOfEmployment
,case when pe.emplevent = 'InvTerm' then '10' 
      when pe.emplevent = 'VolTerm' then '01'
      else pe.emplevent end ::char(2) AS EventType
,to_char(pe.effectivedate,'yyyymmdd')::char(8) as dateOfEvent_old
,to_char(DATE_TRUNC('month', pe.effectivedate)  + INTERVAL '1 month'- INTERVAL '1 day','yyyymmdd')::char(8) as dateOfEvent
,to_char(DATE_TRUNC('month', pe.effectivedate) + INTERVAL '1 month' - INTERVAL '1 day','yyyymmdd')::char(8) as paidThruDate --added 11/30/2017
,lc.locationcode::char(10) as location
,elu.lastupdatets 

FROM person_identity pi

LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts
 and pe.emplstatus = 'T'

LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'AJG_Flores_Cobra_Qualifying_Event'

left join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('10','11','14','15','16','17','21','60','61')
 and pbe.benefitelection in ('T') 
 and pbe.selectedoption = 'Y'
 and pbe.effectivedate <= elu.lastupdatets 

JOIN comp_plan_benefit_plan cpbp 
  --on cpbp.compplanid = pbe.compplanid 
  on pbe.benefitsubclass = cpbp.benefitsubclass 
 AND current_date between cpbp.effectivedate AND cpbp.enddate 
 AND current_timestamp between cpbp.createts AND cpbp.endts

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

LEFT JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid --added 11/30/2017
 AND ppcw.phonecontacttype = 'Work'::bpchar 
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts

LEFT JOIN person_phone_contacts ppch 
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home'::bpchar 
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts

LEFT JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid --added 11/30/2017
 AND ppcb.phonecontacttype = 'BUSN'::bpchar 
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts

LEFT JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid --added 11/30/2017
 AND ppcm.phonecontacttype = 'Mobie'::bpchar 
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts

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

LEFT JOIN person_locations pl    --added 11/30/2017
  ON pl.personid = pi.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts

left join location_codes lc 
  on lc.locationid = pl.locationid --added 11/30/2017
 AND current_date BETWEEN lc.effectivedate AND lc.enddate
 AND current_timestamp BETWEEN lc.createts AND lc.endts

WHERE pi.identitytype = 'SSN' 
  AND current_date between pi.createts and pi.endts 
  and cpbp.cobraplan = 'Y'
 

ORDER BY 1