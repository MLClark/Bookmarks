select distinct
  pi.identity as trankey
-- record key start
,'097408' as planid
, pi2.identity::char(9) as SSN
, 'B' ::char(1) as recordtype
, ' ' ::char(24) as fill0
-- record key end
, to_char(ppd_401k.check_date,'YYYYMMDD') ::char(08) as payrollEndDate
, to_char(ppd_401k.check_date,'YYYYMMDD') ::char(08) as PRSOvrdPayrollEndDate
, ' ' ::char(10) as contribFund1
, ppd_401k.etv_id ::char(04) as contribSource1
, to_char((ppd_401k.etv_amount * 100),'9999999999S') as contribamt1
, ' ' ::char(10) as contribFund2
, ppd_401kcu.etv_id ::char(04) as contribSource2
, to_char((ppd_401kcu.etv_amount * 100),'999999999S') as contribamt2


FROM person_identity pi

LEFT JOIN person_identity pi2 ON pi2.personid = pi.personid 
 AND pi2.identitytype = 'SSN'::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts
 
LEFT JOIN person_address pa ON pa.personid = pi.personid 
 AND CURRENT_DATE BETWEEN pa.effectivedate AND pa.enddate
 AND CURRENT_TIMESTAMP BETWEEN pa.createts AND pa.endts
 
LEFT JOIN person_employment pe ON pe.personid = pi.personid
 AND CURRENT_DATE BETWEEN pe.effectivedate AND pe.enddate
 AND CURRENT_TIMESTAMP BETWEEN pe.createts AND pe.endts
 
LEFT JOIN edi.etl_personal_info EPI on EPI.personid = PI.personid
     
LEFT JOIN person_vitals pv on pi.personid = pv.personid
 AND CURRENT_DATE BETWEEN pv.effectivedate AND pv.enddate
 AND CURRENT_TIMESTAMP BETWEEN pv.createts AND pv.endts
 
LEFT JOIN person_locations pl ON pl.personid = pi.personid 
 AND pl.personlocationtype = 'P'::bpchar 
 AND current_date between pl.effectivedate AND pl.enddate
 AND current_timestamp between pl.createts AND pl.endts
 

JOIN edi.etl_employment_data eed ON eed.personid = epi.personid 
LEFT JOIN edi.etl_employment_term_data etd on etd.personid = pi.personid
 
JOIN location_codes lc on lc.locationid = pl.locationid 

LEFT JOIN person_compensation pc ON pc.personid = epi.personid
 AND pc.earningscode <> 'BenBase'
 AND current_timestamp between pc.createts and pc.endts
 AND pc.effectivedate < pc.enddate
 AND ( (current_date between pc.effectivedate AND pc.enddate)
         OR
       ( pc.enddate = (SELECT MAX(pcm.enddate)
                         FROM person_compensation pcm
                        WHERE pcm.personid = pc.personid
                          AND pcm.earningscode <> 'BenBase')
     ))
     
LEFT JOIN pspay_payment_detail ppd_401k ON ppd_401k.individual_key = pi.identity
 AND ppd_401k.etv_id = 'VB1'
 --AND ppd_401k.check_date = ?::DATE

LEFT JOIN pspay_payment_detail ppd_401kcu ON ppd_401kcu.individual_key = pi.identity
 AND ppd_401kcu.etv_id = 'VB2' -- catch up
 --AND ppd_401k.check_date = ?::DATE
 

LEFT Join person_names pn ON pn.personid = pi.personid
 AND pn.nametype = 'Legal'
 AND CURRENT_DATE between pn.effectivedate and pn.enddate
 AND CURRENT_TIMESTAMP between pn.createts and pn.endts

where pi.identitytype = 'PSPID'
  AND CURRENT_TIMESTAMP between pi.createts AND pi.endts
  AND (ppd_401k.etv_id = 'VB1' or 
       ppd_401kcu.etv_id = 'VB2')

order by SSN