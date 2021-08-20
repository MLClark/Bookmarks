 Select distinct

  substr(PI.identity, 1, 9) AS employeeId,
 'INSURED' ::VARCHAR(30) AS QSOURCE,  
 substr(pn.lname, 1, 20) AS lname,
 substr(pn.fname, 1, 15) AS fname,
 substr(pa.streetaddress, 1, 30) as addr1,
 substr(pa.streetaddress2, 1, 30) as addr2,
 substr(pa.city, 1, 20) as city,
 substr(pa.countrycode, 1, 2) as country,
 substr(pa.stateprovincecode, 1, 2) as state,
 substr(pa.postalcode, 1, 5) as zipcode,
 coalesce(ppcw.phoneno,ppcm.phoneno,ppch.phoneno,ppcb.phoneno )::char(13) as phone,
 coalesce(trim(pnc.url), trim(pnc1.url),trim(pncO.url))::char(50)  AS email,
 to_char(pv.birthdate,'yyyymmdd')::char(8) AS dob,
 pa.stateprovincecode::char(2) as stateOfEmployment,
 case etd.emplevent 
	when 'InvTerm' then '10' 
	when 'VolTerm' then '01'
	else etd.emplevent
	 end ::char(2) AS EventType,
 to_char(etd.termdate,'yyyymmdd')::char(8) as dateOfEvent_old,
 to_char(DATE_TRUNC('month', etd.termdate)  
      + INTERVAL '1 month'            
      - INTERVAL '1 day',              
    'yyyymmdd'                               
  )::char(8) as dateOfEvent,  -- added 10/23/2017
 --to_char(etd.termdate,'yyyymmdd')::char(8) as paidThruDate_old,
 to_char(DATE_TRUNC('month', etd.termdate)  
      + INTERVAL '1 month'            
      - INTERVAL '1 day',              
    'yyyymmdd'                               
  )::char(8) as paidThruDate, --added 11/30/2017
 lc.locationcode::char(10) as location
 --epi.locationcode as location_2

FROM person_identity pi

--JOIN edi.etl_personal_info EPI on EPI.personid = PI.personid

--LEFT JOIN edi.ediemployee ee on ee.personid = pi.personid

LEFT JOIN person_employment pe ON pe.personid = pi.personid 
 AND now() >= pe.effectivedate AND now() <= pe.enddate 
 AND now() >= pe.createts AND now() <= pe.endts

LEFT JOIN person_bene_election pbeT on pbeT.personid = pi.personid 
 	   AND pbeT.benefitelection = 'T' and pbeT.selectedoption = 'Y' 
 	   AND CURRENT_DATE BETWEEN pbeT.effectivedate AND pbeT.enddate 
 	   AND CURRENT_DATE BETWEEN pbeT.createts AND pbeT.endts

JOIN person_bene_election pbeE ON pbeE.personid = pi.personid 
 	   AND pbeE.effectivedate <= pbeE.enddate 
 	   AND pbeE.benefitplanid IS NOT NULL AND pbeE.benefitelection = 'E'::bpchar 
 	   AND CURRENT_DATE >= pbeE.effectivedate
 	   AND CURRENT_DATE BETWEEN pbeE.createts AND pbeE.endts 
 	   AND pbeE.benefitplanid = pbeT.benefitplanid

JOIN benefit_option_coverage boc on boc.benefitoptionid = pbeE.benefitoptionid 
      AND CURRENT_DATE >= boc.effectivedate 
      AND CURRENT_DATE BETWEEN boc.createts AND boc.endts 
      AND now() <= boc.enddate 

JOIN (select compplanid, benefitsubclass,effectivedate,cobraplan 
       from comp_plan_benefit_plan where cobraplan = 'Y' and benefitsubclass in 
         (select benefitsubclass from comp_plan_benefit_plan where cobraplan = 'Y' group by 1) 
          and enddate >= now() and compplanid = 1) bsubclass on bsubclass.benefitsubclass = pbeE.benefitsubclass          

LEFT JOIN dxcompanyname dx on dx.companyid = bsubclass.compplanid             

LEFT JOIN person_names pn ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND now() >= pn.effectivedate AND now() <= pn.enddate 
 AND now() >= pn.createts AND now() <= pn.endts

LEFT JOIN person_address pa ON pa.personid = pi.personid 
 AND pa.addresstype = 'Res'::bpchar 
 AND now() >= pa.effectivedate AND now() <= pa.enddate 
 AND now() >= pa.createts AND now() <= pa.endts


LEFT JOIN person_vitals pv ON pv.personid = pi.personid 
 AND now() >= pv.effectivedate AND now() <= pv.enddate 
 AND now() >= pv.createts AND now() <= pv.endts

JOIN edi.etl_employment_term_data etd ON etd.personid = pi.personid

LEFT JOIN person_phone_contacts ppcw ON ppcw.personid = pi.personid --added 11/30/2017
AND ppcw.phonecontacttype = 'Work'::bpchar 
AND 'now'::text::date >= ppcw.effectivedate 
AND 'now'::text::date <= ppcw.enddate 
AND now() >= ppcw.createts 
AND now() <= ppcw.endts

LEFT JOIN person_phone_contacts ppch ON ppch.personid = pi.personid 
AND ppch.phonecontacttype = 'Home'::bpchar 
AND 'now'::text::date >= ppch.effectivedate 
AND 'now'::text::date <= ppch.enddate 
AND now() >= ppch.createts 
AND now() <= ppch.endts

LEFT JOIN person_phone_contacts ppcb ON ppcb.personid = pi.personid --added 11/30/2017
AND ppcb.phonecontacttype = 'BUSN'::bpchar 
AND 'now'::text::date >= ppcb.effectivedate 
AND 'now'::text::date <= ppcb.enddate 
AND now() >= ppcb.createts 
AND now() <= ppcb.endts	

LEFT JOIN person_phone_contacts ppcm ON ppcm.personid = pi.personid --added 11/30/2017
AND ppcm.phonecontacttype = 'Mobie'::bpchar 
AND 'now'::text::date >= ppcm.effectivedate 
AND 'now'::text::date <= ppcm.enddate 
AND now() >= ppcm.createts 
AND now() <= ppcm.endts	


LEFT JOIN person_net_contacts pnc ON pnc.personid = pi.personid 
AND pnc.netcontacttype = 'HomeEmail'::bpchar 
AND now() >= pnc.effectivedate AND now() <= pnc.enddate 
AND now() >= pnc.createts AND now() <= pnc.endts

LEFT JOIN person_net_contacts pnc1 ON pnc1.personid = pi.personid --added 11/30/2017
AND pnc1.netcontacttype = 'WRK'::bpchar 
AND now() >= pnc1.effectivedate AND now() <= pnc1.enddate 
AND now() >= pnc1.createts AND now() <= pnc1.endts

LEFT JOIN person_net_contacts pncO ON pncO.personid = pi.personid --added 11/30/2017
AND pncO.netcontacttype = 'OtherEmail'::bpchar
and current_date between pncO.effectivedate and pncO.enddate
and current_timestamp between pncO.createts and pncO.endts

LEFT JOIN person_locations pl    --added 11/30/2017
ON pl.personid = pi.personid
AND current_date BETWEEN pl.effectivedate AND pl.enddate
AND current_timestamp BETWEEN pl.createts AND pl.endts

left join location_codes lc on lc.locationid = pl.locationid --added 11/30/2017
AND current_date BETWEEN lc.effectivedate AND lc.enddate
AND current_timestamp BETWEEN lc.createts AND lc.endts
  
LEFT JOIN person_payroll ppay ON ppay.personid = pi.personid 
 AND now() between ppay.effectivedate AND ppay.enddate 
 AND now() between ppay.createts AND ppay.endts 

LEFT JOIN pay_unit pu ON pu.payunitid = ppay.payunitid
LEFT JOIN pspay_employee_profile pep ON pep.individual_key = pi.identity

JOIN edi.edi_last_update lu on lu.feedID = 'AJG_Flores_Cobra_Qualifying_Event'

WHERE pi.identitytype = 'SSN' 
 AND (pe.createts between lu.lastupdatets AND now()
      OR pe.effectivedate > lu.lastupdatets)

ORDER BY 1