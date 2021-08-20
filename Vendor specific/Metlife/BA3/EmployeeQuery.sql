SELECT

DISTINCT pi.personid

, CASE WHEN lc.locationcode = 'ALB' then 'Albany'
       WHEN lc.locationcode = 'END' then 'Endicott'
       WHEN pu.payunitxid = '15' then 'BCI'
       WHEN substring(pi.identity, 1,5) = 'BA300' then 'Buffalo Union'
       ELSE 'Buffalo Non Union' END as location

, CASE WHEN ppd.etv_id = 'VEO' THEN 'Basic Life'
       WHEN ppd.etv_id = 'VAB' THEN 'Opt Sp AD&D'
       WHEN ppd.etv_id = 'VA3' THEN 'Opt Sp Life'
       WHEN ppd.etv_id = 'VA4' THEN 'Child'
       WHEN ppd.etv_id = 'VA9' THEN 'Opt Emp AD&D'
       WHEN ppd.etv_id = 'V9A' THEN 'Opt Emp Life'
       WHEN ppd.etv_id = 'VES' THEN 'STD'
       WHEN ppd.etv_id = 'VER' THEN 'LTD'
       when ppd.etv_id = 'VAK' then 'Opt Sp AD&D 25K'     -- OptADDSP25  AD&D Opt Spouse 25K                
       when ppd.etv_id = 'VAI' then 'Opt Sp Life 25K'     -- Optional Life Sp 25k Voluntary Life - Spouse 25k
       when ppd.etv_id = 'VAJ' then 'Opt Emp AD&D 25K'    -- OptADD25k  Employee Vol ADD 25K        
       when ppd.etv_id = 'VAE' then 'Opt Emp Life 25K'    -- Optional Life 25k    Employee Vol Life 25K       
        END AS lifeplan

, CASE WHEN ppd.etv_id = 'VEO' THEN sum(ppd.etv_amount) -- Basic Life
       WHEN ppd.etv_id = 'VAB' THEN sum(ppd.etv_amount) -- Opt Spouse AD&D
       WHEN ppd.etv_id = 'VA3' THEN sum(ppd.etv_amount) -- Opt Spouse Life
       WHEN ppd.etv_id = 'VA4' THEN sum(ppd.etv_amount) -- Child Life
       WHEN ppd.etv_id = 'VA9' THEN sum(ppd.etv_amount) -- Opt Employee AD&D       
       WHEN ppd.etv_id = 'V9A' THEN sum(ppd.etv_amount) -- Opt Employee Life       
       WHEN ppd.etv_id = 'VES' THEN sum(ppd.etv_amount) -- STD
       WHEN ppd.etv_id = 'VER' THEN sum(ppd.etv_amount) -- LTD
       when ppd.etv_id = 'VAK' then sum(ppd.etv_amount) -- OptADDSP25  AD&D Opt Spouse 25K               
       when ppd.etv_id = 'VAI' then sum(ppd.etv_amount) -- Optional Life Sp 25k Voluntary Life - Spouse 25k
       when ppd.etv_id = 'VAJ' then sum(ppd.etv_amount) -- OptADD25k  Employee Vol ADD 25K                 
       when ppd.etv_id = 'VAE' then sum(ppd.etv_amount) -- Optional Life 25k    Employee Vol Life 25K           
        END AS inscost

, (select DATE_PART('year', NOW()) - DATE_PART('year', pv.birthdate)
       - CASE '0101' < TO_CHAR(pv.birthdate, 'MMDD')
     WHEN TRUE THEN 1
     ELSE 0
     END) AS emplage

, to_char(ppd.check_date, 'Month')|| date_part('year',ppd.check_date::date) as coverageDate
--, to_char(ppd.check_date, 'YYYYMMDD') as checkdate

FROM pspay_payment_detail ppd
 
LEFT JOIN person_identity pi ON pi.identity = ppd.individual_key
 AND identitytype = 'PSPID'

LEFT JOIN person_vitals pv on pv.personid = pi.personid
 AND CURRENT_DATE BETWEEN pv.effectivedate AND pv.enddate
 AND CURRENT_DATE BETWEEN pv.createts AND pv.endts

LEFT JOIN person_locations pl ON pl.personid = pi.personid
 AND personlocationtype = 'P'
 AND CURRENT_DATE BETWEEN pl.effectivedate AND pl.enddate
 AND CURRENT_DATE BETWEEN pl.createts AND pl.endts

LEFT JOIN location_codes lc ON lc.locationid = pl.locationid
 AND CURRENT_DATE BETWEEN lc.effectivedate AND lc.enddate
 AND CURRENT_DATE BETWEEN lc.createts AND lc.endts

LEFT JOIN person_payroll pp ON pp.personid = pi.personid
 AND CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate
 AND CURRENT_DATE BETWEEN pp.createts AND pp.endts

LEFT JOIN pay_unit pu ON pu.payunitid = pp.payunitid

WHERE ppd.check_date BETWEEN ? AND ?
  AND ppd.etv_id in ('VEO', 'VAB', 'VA3', 'VA4', 'VA9', 'V9A','VES', 'VER','VAK','VAI','VAJ','VAE')
--  AND PPD.ETV_AMOUNT > 0 
  AND PPD.ETV_AMOUNT <> 0 

GROUP BY pi.personid, lc.locationcode, pu.payunitxid, pi.identity, ppd.etv_id, pv.birthdate, coveragedate--, ppd.check_date

ORDER BY location, pi.personid