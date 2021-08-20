select distinct
  pi.identity as trankey
-- record key begin  
,'097408' as planid
, pi2.identity::char(9) as SSN
, 'A' ::char(1) as recordtype 
, ' ' ::char(24) as fill0 
-- record key end

, upper(pn.lname||', '||pn.fname||COALESCE(pn.mname,''))::char(30)  	AS  empName
, '  ' ::char(2) AS status

, pa.streetaddress  ::char(30) AS addr1
, pa.streetaddress2 ::char(30) AS addr2
, pa.city ::char(18) AS city
, pa.stateprovincecode ::char(03) as state
, pa.postalcode ::char(09) as zip
, ' '::char(1) as foreignAddrFlag

, pe.peremplpid ::char(13) as eenbr

, ' ':: char(04) as loc_code4
, ' '::char(10) as loc_code10

, to_char(pv.birthdate,'YYYYMMDD')::char(08) as dob
, to_char(pe.emplhiredate,'YYYYMMDD')::char(08) as doH
, '        '::char(08) as plan_eligibility_date
, '        '::char(08) as plan_entry_date
, '        '::char(08) as alt_vesting_date
, case pe.emplstatus when 'T' then to_char(etd.termdate,'YYYYMMDD') ::char(08) end as termdate
, case etd.emplevent when 'Retire' then '4' when 'VolTerm' then '0' else ' ' end ::char(01) as termrsn
, ' ' ::char(01) as sendKitInd
, CASE WHEN eed.empllasthiredate > eed.emplhiredate THEN to_char(eed.empllasthiredate,'YYYYMMDD') ELSE null  END ::char(8) AS rehiredate
, ' ' ::char(04) as vestingovrpct
, ' ' ::char(01) as vestingovrpctind
, '7' ::char(01) AS payrollfreq
, ' ' ::char(34) AS fill1
, '7' ::char(10) as payroll_code_one
, ' ' ::char(10) as payroll_code_two
, coalesce(pc.hce_ind,'N') ::char(01) as hce
, to_char(pe.effectivedate,'YYYYMMDD') ::char(08) as effectivedate
, ' ' ::char(24) as fill2
, ' ' ::char(08) as fill3
, ' ' ::char(01) as changeType --- this needs to be set to '0' if sending change only records
, '        '::char(08) as termKitMailDate
, ' ' ::char(01) as termKit
, ' ' ::char(01) as keyempind
, ' ' ::char(03) as dataelement1
, ' ' ::char(30) as dataelement1Info
, ' ' ::char(03) as dataelement2
, ' ' ::char(30) as dataelement2Info
, ' ' ::char(24) as fill4
, ' ' ::char(03) as dataelement3
, ' ' ::char(30) as dataelement3Info
, ' ' ::char(03) as dataelement4
, ' ' ::char(30) as dataelement4Info
, ' ' ::char(05) as priorvestedyears
, ' ' ::char(06) as currentYearsHoursOfService
, ' ' ::char(01) as breakInVesingInd
, ' ' ::char(01) as calcOpt
,case EPI.maritalstatus when 'M' then '2' when 'S' then '1' else '0' end ::char(01) as maritalstatus
,case pv.gendercode when 'M' then '1' when 'F' then '2' else '0' end ::char(1) AS gender
, '        '::char(08) as breakinServicedate
, '        '::char(08) as breakinServiceEnddate
, ' ' ::char(02) as breakinServicersncd
, ' ' ::char(09) as spousalSSN
, ' ' ::char(01) as LOAtype
, '        '::char(08) as LOAbegindate
, '        '::char(08) as LOAenddate
, ' ' ::char(08) as ETLFormatid
, ' ' ::char(01) as ETLDataGroupAtype
, ' ' ::char(03) as DataElementNumber5
, ' ' ::char(30) as DataElementNumber5Info
, ' ' ::char(03) as DataElementNumber6
, ' ' ::char(30) as DataElementNumber6Info
, ' ' ::char(03) as DataElementNumber7
, ' ' ::char(30) as DataElementNumber7Info
, ' ' ::char(03) as DataElementNumber8
, ' ' ::char(30) as DataElementNumber8Info
, ' ' ::char(03) as DataElementNumber9
, ' ' ::char(30) as DataElementNumber9Info
, ' ' ::char(03) as DataElementNumber10
, ' ' ::char(30) as DataElementNumber10Info
, ' ' ::char(03) as DataElementNumber11
, ' ' ::char(30) as DataElementNumber11Info
, ' ' ::char(03) as DataElementNumber12
, ' ' ::char(30) as DataElementNumber12Info
, ' ' ::char(42) as fill5

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

order by SSN