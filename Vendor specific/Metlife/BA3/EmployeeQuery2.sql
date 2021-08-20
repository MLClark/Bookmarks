SELECT

  CASE WHEN pu.payunitxid = '15' then 'BCI'
       ELSE 'HealthNow' END as location

, CASE WHEN ppd.etv_id = 'VEO' THEN 'Basic Comp Cost'
       WHEN ppd.etv_id in ('VA3', 'VA4', 'V9A', 'VA9', 'VAB','VAK','VAI','VAJ','VAE') THEN 'Opt Life Emp Cost'  --- includes AD&D
       WHEN ppd.etv_id = 'VES' THEN 'STD'
       WHEN ppd.etv_id = 'VER' THEN 'LTD'
        END AS lifeplan

, CASE WHEN ppd.etv_id = 'VEO' THEN SUM(ppd.etv_amount)                                -- Basic Life
       WHEN ppd.etv_id in ('VA3', 'VA4', 'V9A', 'VA9', 'VAB','VAK','VAI','VAJ','VAE') THEN SUM(ppd.etv_amount) -- AD&D
       WHEN ppd.etv_id = 'VES' THEN SUM(ppd.etv_amount)                                -- STD
       WHEN ppd.etv_id = 'VER' THEN SUM(ppd.etv_amount)                                -- LTD       
        END AS inscost

, to_char(ppd.check_date, 'YYYYMMDD') as checkdate

FROM pspay_payment_detail ppd
 
LEFT JOIN person_identity pi on pi.identity = ppd.individual_key
 AND identitytype = 'PSPID'

LEFT JOIN person_payroll pp on pp.personid = pi.personid
 AND CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate
 AND CURRENT_DATE BETWEEN pp.createts AND pp.endts

LEFT JOIN pay_unit pu on pu.payunitid = pp.payunitid

WHERE ppd.check_date between ? and ?
  AND ppd.etv_id in ('VEO', 'VAB', 'VA9', 'VA4', 'VER', 'VES', 'V9A', 'VA3','VAK','VAI','VAJ','VAE') 
--  AND PPD.ETV_AMOUNT > 0 
  AND PPD.ETV_AMOUNT <> 0 

GROUP BY location, ppd.etv_id, ppd.check_date

ORDER BY location, lifeplan