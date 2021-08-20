select distinct
 pi.personid 
,1 as sort_seq 
,'174 ACTIVE BENEFITS' ::CHAR(20)

--,pbebeevlife.benefitsubclass
----------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325 --
----------------------------------
,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9Y2' ::char(8) as group_id
,'M' ::char(1) as relationship_code
,pi.identity ::char(9) as employee_id 
,ltrim(pn.lname) ::char(35) as elname
,ltrim(pn.fname) ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh --- position 309
,to_char(greatest(pe.empllasthiredate, '2018-01-01'),'yyyymmdd') ::char(8) as emp_eff_date --- position 317    
---------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405 --
---------------------------------------
,to_char(greatest(pbe_max.effectivedate, '2018-01-01'),'yyyymmdd') ::char(8) as sub_group_eff_date --- position 393
,'0001' ::char(4) as sub_group
---------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474 --
---------------------------------------
,to_char(pl.effectivedate,'yyyymmdd')::char(8) as location_effective_date -- position 405 effectivedate of the subscribers location
,case when lc.locationid = '10' then '000' ---- 3/20/19 000 (new code) Victory Dealership Group 
      when lc.locationid = '14' then '001'
      when lc.locationid = '13' then '001' ---- 3/20/19 Lexus Parts (move from 002 to 001)
      when lc.locationid = '16' then '003'
      when lc.locationid = '15' then '004'
      when lc.locationid = '17' then '005'
      when lc.locationid in ('18','19') then '006' else null end ::char(8) as location_id
--- 12/26/2018 map location of 'Victory Toyota 2' (TOYSVC2 to Victory Toyota.
,case when lc.locationid = '14' then 'Lexus Monterey Peninsula'
      when lc.locationid = '13' then 'Lexus Monterey Peninsula'
      when lc.locationid = '16' then 'Mid Bay Ford Lincoln'
      when lc.locationid = '15' then 'Mont. Bay Chyslr Dodge'
      when lc.locationid = '17' then 'Storelli'
      when lc.locationid in ('18','19') then 'Victory Toyota' 
      when lc.locationid in ('10') then 'Victory Dealership Group' 
      else null end ::char(23) as location_description  
-----------------------------------
-- SALARY DATA SEGMENT 475 - 527 --
-----------------------------------
,to_char(greatest(pc.effectivedate, '2018-01-01'),'yyyymmdd') ::char(8) as basic_sal_eff_date --- position 475
,'A' ::char(1) as basic_sal_mode
,case when pc.frequencycode = 'H' then to_char(pc.compamount  * pp.scheduledhours * 24 * 100, 'FM0000000000000000 ')
      else to_char(pc.compamount * 100, 'FM0000000000000000 ') end as basic_salary_amount -- assume decimal zero filled 
----------------------------------
-- CLASS DATA SEGMENT 608 - 620 --
----------------------------------
,to_char(greatest(pe.empllasthiredate, '2018-01-01'),'yyyymmdd') ::char(8) as class_eff_date --- position 608
,'A001'::char(4) as class_id
--------------------------------------
-- SMOKING STATUS SEGMENT 620 - 629 --
-------------------------------------- 
,to_char(greatest(pv.effectivedate,'2018-01-01'),'yyyymmdd') ::char(8) as smoker_status_effective_date --- position 620
---Values: B - Both Subscriber & Spouse Smoke ; N - Neither Smoke; S - Subscriber Only Smokes; P - Spouse Only Smokes.
,pv.smoker ::char(1) as smoker_indicator
--------------------------
-- ELIGIBILITY SEGMENTS --
--------------------------
---------------------------------------------
-- BASIC LIFE (23) 810 - 832 -- LTL0NCFLAT --
---------------------------------------------
--,pbeblife.benefitelection as pbeblife
---- Note pbeblife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,case when pbeblife.benefitsubclass in ('23') then '1' else ' ' end ::char(1) as product_category_1
,case when pbeblife.benefitsubclass in ('23') then to_char(greatest(pbeblife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_1
,case when pbeblife.benefitsubclass in ('23') and pbeblife.benefitelection = 'T'  then 'TM' 
      when pbeblife.benefitsubclass in ('23') and pbeblife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_1
,case when pbeblife.benefitsubclass in ('23') then 'LTL0NCFLAT' else ' ' end ::char(10) as plan_id_1
,case when pbeblife.benefitsubclass in ('23') then 'C' else ' ' end ::char(1) as emp_only_1
------------------------------------------------------------------------
-- BASIC AD&D (23) 865 - 887 -- ATA0NCFLAT -- map the same as basic life 
------------------------------------------------------------------------
--,pbeblife.benefitelection as pbeblife
---- Note pbeblife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,case when pbeblife.benefitsubclass in ('23') then 'a' else ' ' end ::char(1) as product_category_a
,case when pbeblife.benefitsubclass in ('23') then to_char(greatest(pbeblife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_a
,case when pbeblife.benefitsubclass in ('23') and pbeblife.benefitelection = 'T'  then 'TM' 
      when pbeblife.benefitsubclass in ('23') and pbeblife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_a
,case when pbeblife.benefitsubclass in ('23') then 'ATA0NCFLAT' else ' ' end ::char(10) as plan_id_a
,case when pbeblife.benefitsubclass in ('23') then 'C' else ' ' end ::char(1) as emp_only_a
--------------------------------------
-- BASIC STD SEGMENT (??) 920 - 942 --
--------------------------------------
--------------------------------------
-- BASIC LTD SEGMENT (??) 975 - 997 --
--------------------------------------
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
--,pbebeevlife.benefitelection as pbebeevlife
,case when pbebeevlife.benefitsubclass in ('21') then '3' else ' ' end ::char(1) as product_category_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'T'  then 'TM' 
      when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_3
,case when pbebeevlife.benefitsubclass in ('21') then 'ETL0CEEVAL' else ' ' end ::char(10) as plan_id_3
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-01-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_3
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
--,pbebSPvlife.benefitelection as pbebSPvlife
,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'T'  then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
-------------------------------------------------------------
--,pbebDPvlife.benefitelection as pbebDPvlife
,case when pbebDPvlife.benefitsubclass in ('2X') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) 1195 - 1239 --
------------------------------------------------------
--,pbebeevlife.benefitelection as pbebeevlife
,case when pbebeevlife.benefitsubclass in ('21') then 'c' else ' ' end ::char(1) as product_category_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'T'  then 'TM' 
      when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_c
,case when pbebeevlife.benefitsubclass in ('21') then 'BTA0CEEVAL' else ' ' end ::char(10) as plan_id_c
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-01-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_c
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z ) 1250 - 1294 --
------------------------------------------------------
--,pbebSPvlife.benefitelection as pbebSPvlife
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'e' else ' ' end ::char(1) as product_category_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'T'  then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'BTA0CSPVAL' else ' ' end ::char(10) as plan_id_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_e
---------------------------------------------------------
-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349 --
--------------------------------------------------------- 
--,pbebDPvlife.benefitelection as pbebDPvlife
,case when pbebDPvlife.benefitsubclass in ('2X') then 'd' else ' ' end ::char(1) as product_category_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'BTA0CDPVAL' else ' ' end ::char(10) as plan_id_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_d
----------------------------
-- PCSTD (30) 1360 - 1382 --
----------------------------
--,pbestd.benefitelection as pbestd
,case when pbestd.benefitsubclass in ('30') then 'Q' else ' ' end ::char(1) as product_category_Q
,case when pbestd.benefitsubclass in ('30') then to_char(greatest(pbestd.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_Q
,case when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'T'  then 'TM' 
      when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_Q
,case when pbestd.benefitsubclass in ('30') then 'YTS000CSAL' else ' ' end ::char(10) as plan_id_Q
,case when pbestd.benefitsubclass in ('30') then 'C' else ' ' end ::char(1) as emp_only_Q
------------------------------------
-- VOLUNTARY LTD (31) 1415 - 1437 --
------------------------------------
--,pbeltd.benefitelection as pbeltd
,case when pbeltd.benefitsubclass in ('31') then 'L' else ' ' end ::char(1) as product_category_L
,case when pbeltd.benefitsubclass in ('31') then to_char(greatest(pbeltd.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_L
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_L
,case when pbeltd.benefitsubclass in ('31') then 'ZTT0CABSAL' else ' ' end ::char(10) as plan_id_L
,case when pbeltd.benefitsubclass in ('31') then 'C' else ' ' end ::char(1) as emp_only_L
------------------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2CI,2CS) 1470 - 1514 --
------------------------------------------------------------------------
--,pbe2ci.benefitelection as pbe2ci
--,pbe2cs.benefitelection as pbe2cs
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then 'A' else ' ' end ::char(1) as product_category_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then to_char(coalesce(greatest(pbe2ci.effectivedate,pbe2cs.effectivedate,'2018-01-01')),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') and coalesce(pbe2ci.benefitelection,pbe2cs.benefitelection) = 'T'  then 'TM' 
      when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') and coalesce(pbe2ci.benefitelection,pbe2cs.benefitelection) = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then '3CI00EDVAB' else ' ' end ::char(10) as plan_id_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then 'C' else ' ' end ::char(1) as emp_only_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then to_char(coalesce(greatest(pbe2ci.effectivedate,pbe2cs.effectivedate,'2018-01-01')),'YYYYMMDD') else ' ' end ::char(8) as elaprv_effective_date_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then to_char(coalesce(pbe2ci.coverageamount,pbe2cs.coverageamount), 'FM0000000000') else null end as elaprv_amount_A
-------------------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2SI,2SS) 1525 - 1569 --
-------------------------------------------------------------
--,pbe2si.benefitelection as pbe2si
--,pbe2ss.benefitelection as pbe2ss
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
--,pbevollacd.benefitelection as pbevollacd
,case when pbevollacd.benefitsubclass in ('13') then 'g' else ' ' end ::char(1) as product_category_g
,case when pbevollacd.benefitsubclass in ('13') then to_char(greatest(pbevollacd.effectivedate,'2018-01-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_g
,case when pbevollacd.benefitsubclass in ('13') and pbevollacd.benefitelection = 'T'  then 'TM' 
      when pbevollacd.benefitsubclass in ('13') and pbevollacd.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_g
,case when pbevollacd.benefitsubclass in ('13') then '6AS000VACC' else null end ::char(10) as plan_id_g
,case when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Family' then 'A' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee + Spouse' then 'B' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee Only' then 'C' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee + Children' then 'D'
      when pbevollacd.benefitsubclass in ('13') then 'C'
      else ' ' end ::char(1) as emp_only_g 

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AVS_Mutual_Of_Omaha_Carrier_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pe.personid
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E','T')
  and pbe.benefitsubclass in ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13')
  and pbe.selectedoption = 'Y' 
  
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts   
  
left join 
     (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and date_part('year',deductionstartdate::date)>=date_part('year',current_date::date)
         and benefitsubclass in ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13')
         and benefitelection in ('E') and selectedoption = 'Y'
       group by 1) pbe_max
  on pbe_max.personid = pbe.personid  
-------------------------------------------
-- BASIC LIFE (23) --&-- BASIC AD&D (23) --
-------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('23') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbeblife on pbeblife.personid = pbe.personid and pbeblife.rank = 1 
              and pbeblife.personid in (select distinct personid from person_bene_election where benefitsubclass in ('23') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate )              
-----------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) --&-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) --
-----------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('21') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebeevlife on pbebeevlife.personid = pbe.personid and pbebeevlife.coverageamount <> 0 and pbebeevlife.rank = 1 
              and pbebeevlife.personid in (select distinct personid from person_bene_election where benefitsubclass in ('21') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate )              
-----------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) --&-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z ) --
-----------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2Z') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebSPvlife on pbebSPvlife.personid = pbe.personid and pbebSPvlife.coverageamount <> 0 and pbebSPvlife.rank = 1  
              and pbebSPvlife.personid in (select distinct personid from person_bene_election where benefitsubclass in ('2Z') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate )                        
-----------------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) --&-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) --
-----------------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2X') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebDPvlife on pbebDPvlife.personid = pbe.personid and pbebDPvlife.coverageamount <> 0 and pbebDPvlife.rank = 1 
              and pbebDPvlife.personid in (select distinct personid from person_bene_election where benefitsubclass in ('2X') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate )              
----------------
-- PCSTD (30) --
---------------- 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('30') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbestd on pbestd.personid = pbe.personid and pbestd.rank = 1 
              and pbestd.personid in (select distinct personid from person_bene_election where benefitsubclass in ('30') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate )               
------------------------  
-- VOLUNTARY LTD (31) --
------------------------    
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('31') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbeltd on pbeltd.personid = pbe.personid and pbeltd.rank = 1 
              and pbeltd.personid in (select distinct personid from person_bene_election where benefitsubclass in ('31') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate )              
------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2CI,2CS) --
------------------------------------------------------------      
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2CI') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbe2ci on pbe2ci.personid = pbe.personid and pbe2ci.rank = 1 
              and pbe2ci.personid in (select distinct personid from person_bene_election where benefitsubclass in ('2CI') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate )  
                          
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2CS') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbe2cs on pbe2cs.personid = pbe.personid and pbe2cs.rank = 1 
              and pbe2cs.personid in (select distinct personid from person_bene_election where benefitsubclass in ('2CS') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate )              
-------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2SI,2SS) --
-------------------------------------------------  
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2SI') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbe2si on pbe2si.personid = pbe.personid and pbe2si.rank = 1 
              and pbe2si.personid in (select distinct personid from person_bene_election where benefitsubclass in ('2SI') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate )
              
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2SS') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbe2ss on pbe2ss.personid = pbe.personid and pbe2ss.rank = 1     
              and pbe2ss.personid in (select distinct personid from person_bene_election where benefitsubclass in ('2SI') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate )             
-----------------------------
-- VOLUNTARY ACCIDENT (13) --
-----------------------------            
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('13') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbevollacd on pbevollacd.personid = pbe.personid and pbevollacd.rank = 1 
              and pbevollacd.personid in (select distinct personid from person_bene_election where benefitsubclass in ('13') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate )             
                    
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
--- this join is used to determine coverage level for the dependents
left join (select distinct de.personid, de.dependentid, de.benefitsubclass, de.effectivedate, de.selectedoption, pdr.dependentrelationship, bcd.benefitcoveragedesc
              from dependent_enrollment de
              join person_dependent_relationship pdr
                on pdr.personid = de.personid
               and pdr.dependentrelationship in ('D','C','S','DP','SP','NA','ND','NS','NC') --- NA,ND,NS,NC DP DOMESTIC PARTNER
               and current_date between pdr.effectivedate and pdr.enddate
               and current_timestamp between pdr.createts and pdr.endts
              join person_bene_election pbe 
                on pbe.personid = de.personid
               and pbe.benefitsubclass = de.benefitsubclass                
               and current_date between pbe.effectivedate and pbe.enddate
               and current_timestamp between pbe.createts and pbe.endts
              join benefit_coverage_desc bcd
                on bcd.benefitcoverageid = pbe.benefitcoverageid
               and current_date between bcd.effectivedate and bcd.enddate
               and current_timestamp between bcd.createts and bcd.endts               
             where current_date between de.effectivedate and de.enddate
               and current_timestamp between de.createts and de.endts
               and de.benefitsubclass in ('13')
           )bcd on bcd.personid = pbe.personid 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join (select personid, compamount, frequencycode, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts) desc) as rank
             from person_compensation where current_timestamp between createts and endts and current_date between effectivedate and enddate and compamount <> 0 and enddate >= '2199-12-30'
            group by personid, compamount, frequencycode) pc on pc.personid = pi.personid and pc.rank = 1 

left join (select personid, scheduledhours, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts) desc) as rank
             from pers_pos where current_timestamp between createts and endts 
            group by personid, scheduledhours) pp on pp.personid = pi.personid and pp.rank = 1   
 
left join person_locations pl 
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts

left join locationcodeslist lc
  on lc.locationid = pl.locationid
 and lc.companyid = '1'
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts   
 
LEFT JOIN person_payroll ppay
  ON ppay.personid = pi.personid
 AND current_date BETWEEN ppay.effectivedate AND ppay.enddate
 AND current_timestamp BETWEEN ppay.createts AND ppay.endts      

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppay.payunitid

LEFT JOIN frequency_codes fc
  ON fc.frequencycode = pu.frequencycode
   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus not in ('R','T')
  and date_part('year',pbe.planyearenddate::date)>=date_part('year',current_date::date)
 -- and pe.personid = '5220';