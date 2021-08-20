select   
  pi.personid
, pi.identity as trankey
, pi2.identity::char(9) as SSNO


, upper(pn.fname)::varchar(30) as firstname
, upper(pn.lname)::varchar(30) as lastname
, upper(pn.mname)::varchar(30) as middlename

, coalesce (SUM(distinct ppd_401k.etv_amount), 0) + coalesce (SUM(distinct ppd_catch.etv_amount), 0) as ee401kamt 
, coalesce (SUM(distinct ppd_Roth.etv_amount), 0) as eerothamt
, coalesce (SUM(distinct ppd_ERmatch.etv_amount), 0) as ermatchamt
, coalesce (SUM(distinct ppd_ERpension.etv_amount), 0) as erpensionamt
, coalesce (SUM(distinct ppd_ERsafeharbor.etv_amount), 0) as ersafeharboramt

FROM person_identity pi

LEFT JOIN person_identity pi2 ON pi.personid = pi2.personid 
 AND pi2.identitytype = 'SSN'::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts

LEFT JOIN pspay_payment_detail ppd_401k ON ppd_401k.individual_key = pi.identity
 AND ppd_401k.etv_id = 'VB1'
 AND ppd_401k.check_date = ?::DATE

LEFT JOIN pspay_payment_detail ppd_catch ON ppd_catch.individual_key = pi.identity
 AND ppd_catch.etv_id = 'VB2'
 AND ppd_catch.check_date = ?::DATE

LEFT JOIN pspay_payment_detail ppd_Roth ON ppd_Roth.individual_key = pi.identity
 AND ppd_Roth.etv_id = 'VB3'
 AND ppd_Roth.check_date = ?::DATE

LEFT JOIN pspay_payment_detail ppd_ERmatch ON ppd_ERmatch.individual_key = pi.identity
 AND ppd_ERmatch.etv_id = 'VB5'
 AND ppd_ERmatch.check_date = ?::DATE

LEFT JOIN pspay_payment_detail ppd_ERpension ON ppd_ERpension.individual_key = pi.identity
 AND ppd_ERpension.etv_id = 'VBT'
 AND ppd_ERpension.check_date = ?::DATE

LEFT JOIN pspay_payment_detail ppd_ERsafeharbor ON ppd_ERsafeharbor.individual_key = pi.identity
 AND ppd_ERsafeharbor.etv_id = 'VBU'
 AND ppd_ERsafeharbor.check_date = ?::DATE


LEFT Join person_names pn ON pn.personid = pi.personid
 AND pn.nametype = 'Legal'
 AND CURRENT_DATE between pn.effectivedate and pn.enddate
 AND CURRENT_TIMESTAMP between pn.createts and pn.endts

where pi.identitytype = 'PSPID'
  AND CURRENT_TIMESTAMP between pi.createts AND pi.endts
  AND (ppd_401k.etv_id = 'VB1' or 
	   ppd_catch.etv_id = 'VB2' or 	
	   ppd_Roth.etv_id = 'VB3' or
       ppd_ERmatch.etv_id = 'VB5' or
       ppd_ERpension.etv_id = 'VBT' or	
       ppd_ERsafeharbor.etv_id = 'VBU')

group by pi.personid, pi.identity, pi2.identity, pn.fname, pn.mname, pn.lname

order by 1 