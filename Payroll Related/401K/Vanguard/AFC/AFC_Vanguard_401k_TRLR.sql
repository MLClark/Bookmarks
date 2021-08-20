select 

'99999999999'::char(11) as trlrNines
,'TRLR'::char(4) as trlrIndicator
,'097408'::char(6) as trlrPlanNumber
,to_char(current_date,'YYYYMMDD')::char(8) as createDate
,to_char(current_timestamp,'HHMMSS')::char(6) as createTime
, to_char((count(*)*3),'000000000')::char(10) as totals
,' '::char(31) as filler
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
 AND ppd_401kcu.etv_id = 'VB2'
 --AND ppd_401k.check_date = ?::DATE
 
LEFT JOIN pspay_payment_detail ppd_Roth ON ppd_Roth.individual_key = pi.identity
 AND ppd_Roth.etv_id = 'VB3'
-- AND ppd_Roth.check_date = ?::DATE

LEFT JOIN pspay_payment_detail ppd_ERmatch ON ppd_ERmatch.individual_key = pi.identity
 AND ppd_ERmatch.etv_id = 'VB5'
-- AND ppd_ERmatch.check_date = ?::DATE

LEFT JOIN pspay_payment_detail ppd_ERpension ON ppd_ERpension.individual_key = pi.identity
 AND ppd_ERpension.etv_id = 'VBT'
-- AND ppd_ERpension.check_date = ?::DATE

LEFT JOIN pspay_payment_detail ppd_ERsafeharbor ON ppd_ERsafeharbor.individual_key = pi.identity
 AND ppd_ERsafeharbor.etv_id = 'VBU'
-- AND ppd_ERsafeharbor.check_date = ?::DATE

LEFT Join person_names pn ON pn.personid = pi.personid
 AND pn.nametype = 'Legal'
 AND CURRENT_DATE between pn.effectivedate and pn.enddate
 AND CURRENT_TIMESTAMP between pn.createts and pn.endts

where pi.identitytype = 'PSPID'
  AND CURRENT_TIMESTAMP between pi.createts AND pi.endts
  AND (ppd_401k.etv_id = 'VB1' or 
       ppd_401kcu.etv_id = 'VB2' or 
       ppd_Roth.etv_id = 'VB3' or
       ppd_ERmatch.etv_id = 'VB5' or
       ppd_ERpension.etv_id = 'VBT' or
       ppd_ERsafeharbor.etv_id = 'VBU')
