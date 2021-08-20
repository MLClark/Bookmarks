----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection in ('W','T')  then 'SE' 
      when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
-------------------------------------------------------------
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('2X') then '5' else ' ' end ::char(1) as product_category_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection in ('W','T') then 'SE' 
      when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('2X') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z ) 1250 - 1294 --
------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'e' else ' ' end ::char(1) as product_category_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection in ('W','T')   then 'SE' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'BTA0CSPVAL' else ' ' end ::char(10) as plan_id_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_e
---------------------------------------------------------
-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349 --
--------------------------------------------------------- 
,case when pbebDPvlife.benefitsubclass in ('2X') then 'd' else ' ' end ::char(1) as product_category_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection in ('W','T')  then 'SE' 
      when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'BTA0CDPVAL' else ' ' end ::char(10) as plan_id_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_d
-------------------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2SI,2SS) 1525 - 1569 --
-------------------------------------------------------------
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then 'J' else ' ' end ::char(1) as product_category_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then to_char(coalesce(greatest(pbe2si.effectivedate,pbe2ss.effectivedate,'2018-01-01')),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') and coalesce(pbe2si.benefitelection,pbe2ss.benefitelection) = 'T'  then 'TM' 
      when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') and coalesce(pbe2si.benefitelection,pbe2ss.benefitelection) = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then '3CI00SPVAB' else ' ' end ::char(10) as plan_id_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then 'C' else ' ' end ::char(1) as emp_only_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then to_char(coalesce(greatest(pbe2si.effectivedate,pbe2ss.effectivedate,'2018-01-01')),'YYYYMMDD') else ' ' end ::char(8) as elaprv_effective_date_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then to_char(coalesce(pbe2si.coverageamount,pbe2ss.coverageamount), 'FM0000000000') else null end as elaprv_amount_J
-----------------------------------------
-- VOLUNTARY ACCIDENT (13) 1855 - 1877 --
-----------------------------------------
,case when depvolaccd.benefitsubclass in ('13') then 'g' else ' ' end ::char(1) as product_category_g
,case when depvolaccd.benefitsubclass in ('13') then to_char(greatest(depvolaccd.effectivedate,'2018-01-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_g
,case when depvolaccd.benefitsubclass in ('13') and pbe.benefitelection in ('W','T')  then 'SE' 
      when depvolaccd.benefitsubclass in ('13') and pbe.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_g
,case when depvolaccd.benefitsubclass in ('13') then '6AS000VACC' else null end ::char(10) as plan_id_g
,case when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Family' then 'A'
      when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Employee + Spouse' then 'B'
      when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Employee Only' then 'C'
      when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Employee + Children' then 'D'
      else null end ::char(1) as emp_only_g
