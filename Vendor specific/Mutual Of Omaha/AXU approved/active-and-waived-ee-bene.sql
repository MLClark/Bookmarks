select distinct
-----Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans
 coalesce(elected.personid,waived.personid) as personid
,coalesce(elected.lastupdatets,waived.lastupdatets) as lastupdatets
,'ACTIVE EE BENEFIT' ::VARCHAR(30) AS SOURCESEQ
,coalesce(elected.sort_seq,waived.sort_seq) as sort_seq
----------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325 --
----------------------------------
,coalesce(elected.trans_date,waived.trans_date) ::char(8) as trans_date
,coalesce(elected.group_id,waived.group_id) ::char(8) as group_id
,coalesce(elected.relationship_code,waived.relationship_code) ::char(1) as relationship_code
,coalesce(elected.employee_id,waived.employee_id) ::char(9) as employee_id
,coalesce(elected.elname,waived.elname) ::char(35) as elname
,coalesce(elected.efname,waived.efname) ::char(15) as efname
,coalesce(elected.egender,waived.egender) ::char(1) as egender
,coalesce(elected.dob,waived.dob) ::char(8) as dob
--- address is only applicable if ee has Dental
,coalesce(elected.addr1,waived.addr1) ::char(30) as addr1
,coalesce(elected.addr2,waived.addr2) ::char(30) as addr2
,coalesce(elected.city,waived.city) ::char(19) as city
,coalesce(elected.state,waived.state) ::char(2) as state
,coalesce(elected.zip,waived.zip) ::char(11) as zip
,coalesce(elected.doh,waived.doh) ::char(8) as doh --- position 309
--- All effective dates after doh should be either 5/1/18 (Benefit Plan Year) or Last Hired Date, whichever is greater
,coalesce(elected.emp_eff_date,waived.emp_eff_date) ::char(8) as emp_eff_date --- position 317
---------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405 --
---------------------------------------
,coalesce(elected.sub_group_eff_date,waived.sub_group_eff_date) ::char(8) as sub_group_eff_date --- position 393
,coalesce(elected.sub_group,waived.sub_group) ::char(4) as sub_group
---------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474 --
---------------------------------------
-----------------------------------
-- SALARY DATA SEGMENT 475 - 527 --
-----------------------------------
,coalesce(elected.basic_sal_eff_date,waived.basic_sal_eff_date) ::char(8) as basic_sal_eff_date --- position 475
,coalesce(elected.basic_sal_mode,waived.basic_sal_mode) ::char(1) as basic_sal_mode
,coalesce(elected.basic_salary_amount,waived.basic_salary_amount) ::char(16) as basic_salary_amount -- assume decimal zero fill    
,coalesce(elected.first_add_comp_type,waived.first_add_comp_type) ::char(2) as first_add_comp_type
,coalesce(elected.first_add_comp_amt,waived.first_add_comp_amt) ::char(16) as first_add_comp_amt
----------------------------------
-- CLASS DATA SEGMENT 608 - 620 --
----------------------------------
,coalesce(elected.class_eff_date,waived.class_eff_date) ::char(8) as class_eff_date --- position 608
,coalesce(elected.class_id,waived.class_id) ::char(4) as class_id
--------------------------------------
-- SMOKING STATUS SEGMENT 620 - 629 --
--------------------------------------
,coalesce(elected.smoker_status_effective_date,waived.smoker_status_effective_date) ::char(8) as smoker_status_effective_date --- position 620
---Values: B - Both Subscriber & Spouse Smoke ; N - Neither Smoke; S - Subscriber Only Smokes; P - Spouse Only Smokes.
,coalesce(elected.smoker_indicator,waived.smoker_indicator) ::char(1) as smoker_indicator
--------------------------
-- ELIGIBILITY SEGMENTS --
--------------------------
-------------------------------
-- BASIC LIFE (20) 810 - 832 --
-------------------------------
-------------------------------
-- BASIC AD&D (22) 865 - 887 -- 
------------------------------- 
--------------------------------------
-- BASIC STD SEGMENT (32) 920 - 942 --
--------------------------------------
--------------------------------------
-- BASIC LTD SEGMENT (31) 975 - 997 --
--------------------------------------
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
,coalesce(elected.product_category_3,waived.product_category_3) ::char(1) as product_category_3
,coalesce(elected.pc_effective_date_3,waived.pc_effective_date_3) ::char(8) as pc_effective_date_3
,coalesce(elected.elig_event_3,waived.elig_event_3) ::char(2) as elig_event_3
,coalesce(elected.plan_id_3,waived.plan_id_3) ::char(10) as plan_id_3
,coalesce(elected.emp_only_3,waived.emp_only_3) ::char(1) as emp_only_3
,coalesce(elected.pc_nom_effective_date_3,waived.pc_nom_effective_date_3) ::char(8) as pc_nom_effective_date_3
,coalesce(elected.pc_nom_amount_3,waived.pc_nom_amount_3) ::char(10) as pc_nom_amount_3
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
,coalesce(elected.product_category_4,waived.product_category_4) ::char(1) as product_category_4
,coalesce(elected.pc_effective_date_4,waived.pc_effective_date_4) ::char(8) as pc_effective_date_4
,coalesce(elected.elig_event_4,waived.elig_event_4) ::char(2) as elig_event_4
,coalesce(elected.plan_id_4,waived.plan_id_4) ::char(10) as plan_id_4
,coalesce(elected.emp_only_4,waived.emp_only_4) ::char(1) as emp_only_4
,coalesce(elected.pc_nom_effective_date_4,waived.pc_nom_effective_date_4) ::char(8) as pc_nom_effective_date_4
,coalesce(elected.pc_nom_amount_4,waived.pc_nom_amount_4) ::char(10) as pc_nom_amount_4
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
-------------------------------------------------------------
,coalesce(elected.product_category_5,waived.product_category_5) ::char(1) as product_category_5
,coalesce(elected.pc_effective_date_5,waived.pc_effective_date_5) ::char(8) as pc_effective_date_5
,coalesce(elected.elig_event_5,waived.elig_event_5) ::char(2) as elig_event_5
,coalesce(elected.plan_id_5,waived.plan_id_5) ::char(10) as plan_id_5
,coalesce(elected.emp_only_5,waived.emp_only_5) ::char(1) as emp_only_5
,coalesce(elected.pc_nom_effective_date_5,waived.pc_nom_effective_date_5) ::char(8) as pc_nom_effective_date_5
,coalesce(elected.pc_nom_amount_5,waived.pc_nom_amount_5) ::char(10) as pc_nom_amount_5
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (21) 1195 - 1239  --
------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,coalesce(elected.product_category_c,waived.product_category_c) ::char(1) as product_category_c
,coalesce(elected.pc_effective_date_c,waived.pc_effective_date_c) ::char(8) as pc_effective_date_c
,coalesce(elected.elig_event_c,waived.elig_event_c) ::char(2) as elig_event_c
,coalesce(elected.plan_id_c,waived.plan_id_c) ::char(10) as plan_id_c
,coalesce(elected.emp_only_c,waived.emp_only_c) ::char(1) as emp_only_c
,coalesce(elected.pc_nom_effective_date_c,waived.pc_nom_effective_date_c) ::char(8) as pc_nom_effective_date_c
,coalesce(elected.pc_nom_amount_c,waived.pc_nom_amount_c) ::char(10) as pc_nom_amount_c
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z) 1250 - 1294  --
------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,coalesce(elected.product_category_e,waived.product_category_e) ::char(1) as product_category_e
,coalesce(elected.pc_effective_date_e,waived.pc_effective_date_e) ::char(8) as pc_effective_date_e
,coalesce(elected.elig_event_e,waived.elig_event_e) ::char(2) as elig_event_e
,coalesce(elected.plan_id_e,waived.plan_id_e) ::char(10) as plan_id_e
,coalesce(elected.emp_only_e,waived.emp_only_e) ::char(1) as emp_only_e
,coalesce(elected.pc_nom_effective_date_e,waived.pc_nom_effective_date_e) ::char(8) as pc_nom_effective_date_e
,coalesce(elected.pc_nom_amount_e,waived.pc_nom_amount_e) ::char(10) as pc_nom_amount_e
---------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349  --
---------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,coalesce(elected.product_category_d,waived.product_category_d) ::char(1) as product_category_d
,coalesce(elected.pc_effective_date_d,waived.pc_effective_date_d) ::char(8) as pc_effective_date_d
,coalesce(elected.elig_event_d,waived.elig_event_d) ::char(2) as elig_event_d
,coalesce(elected.plan_id_d,waived.plan_id_d) ::char(10) as plan_id_d
,coalesce(elected.emp_only_d,waived.emp_only_d) ::char(1) as emp_only_d
,coalesce(elected.pc_nom_effective_date_d,waived.pc_nom_effective_date_d) ::char(8) as pc_nom_effective_date_d
,coalesce(elected.pc_nom_amount_d,waived.pc_nom_amount_d) ::char(10) as pc_nom_amount_d
------------------------------------
-- VOLUNTARY STD (30) 1360 - 1382 --
------------------------------------
,coalesce(elected.product_category_Q,waived.product_category_Q) ::char(1) as product_category_Q
,coalesce(elected.pc_effective_date_Q,waived.pc_effective_date_Q) ::char(8) as pc_effective_date_Q
,coalesce(elected.elig_event_Q,waived.elig_event_Q) ::char(2) as elig_event_Q
,coalesce(elected.plan_id_Q,waived.plan_id_Q) ::char(10) as plan_id_Q
,coalesce(elected.emp_only_Q,waived.emp_only_Q) ::char(1) as emp_only_Q
------------------------------------
-- VOLUNTARY LTD (31) 1415 - 1437 --
------------------------------------
,coalesce(elected.product_category_L,waived.product_category_L) ::char(1) as product_category_L
,coalesce(elected.pc_effective_date_L,waived.pc_effective_date_L) ::char(8) as pc_effective_date_L
,coalesce(elected.elig_event_L,waived.elig_event_L) ::char(2) as elig_event_L
,coalesce(elected.plan_id_L,waived.plan_id_L) ::char(10) as plan_id_L
,coalesce(elected.emp_only_L,waived.emp_only_L) ::char(1) as emp_only_L
-----------------------------------------------------------
-- VOLUNTARY EMPLOYEE CRITICAL ILLNESS (2C) 1470 - 1514  --
-----------------------------------------------------------
,coalesce(elected.product_category_A,waived.product_category_A) ::char(1) as product_category_A
,coalesce(elected.pc_effective_date_A,waived.pc_effective_date_A) ::char(8) as pc_effective_date_A
,coalesce(elected.elig_event_A,waived.elig_event_A) ::char(2) as elig_event_A
,coalesce(elected.plan_id_A,waived.plan_id_A) ::char(10) as plan_id_A
,coalesce(elected.emp_only_A,waived.emp_only_A) ::char(1) as emp_only_A
,coalesce(elected.elaprv_effective_date_A,waived.elaprv_effective_date_A) ::char(8) as elaprv_effective_date_A
,coalesce(elected.elaprv_amount_A,waived.elaprv_amount_A) ::char(10) as elaprv_amount_A
--------------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2S) 1525 - 1569 --
--------------------------------------------------------
,coalesce(elected.product_category_J,waived.product_category_J) ::char(1) as product_category_J
,coalesce(elected.pc_effective_date_J,waived.pc_effective_date_J) ::char(8) as pc_effective_date_J
,coalesce(elected.elig_event_J,waived.elig_event_J) ::char(2) as elig_event_J
,coalesce(elected.plan_id_J,waived.plan_id_J) ::char(10) as plan_id_J
,coalesce(elected.emp_only_J,waived.emp_only_J) ::char(1) as emp_only_J
,coalesce(elected.elaprv_effective_date_J,waived.elaprv_effective_date_J) ::char(8) as elaprv_effective_date_J
,coalesce(elected.elaprv_amount_J,waived.elaprv_amount_J) ::char(10) as elaprv_amount_J
-----------------------------------------
-- VOLUNTARY ACCIDENT (13) 1865 - 1877 --
-----------------------------------------
,coalesce(elected.product_category_g,waived.product_category_g) ::char(1) as product_category_g
,coalesce(elected.pc_effective_date_g,waived.pc_effective_date_g) ::char(8) as pc_effective_date_g
,coalesce(elected.elig_event_g,waived.elig_event_g) ::char(2) as elig_event_g
,coalesce(elected.plan_id_g,waived.plan_id_g) ::char(10) as plan_id_g
,coalesce(elected.family_cvg_ind_g,waived.family_cvg_ind_g) ::char(1) as family_cvg_ind_g 
  
      from 




(
select distinct
-----Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans
 pi.personid
,elu.lastupdatets 
,'ACTIVE EE BENEFIT' ::VARCHAR(30) AS SOURCESEQ
,'0' ::char(1) as sort_seq 
----------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325 --
----------------------------------
,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9CJ' ::char(8) as group_id
,'M' ::char(1) as relationship_code 
,pi.identity ::char(9) as employee_id 
,pn.lname ::char(35) as elname
,pn.fname ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
--- address is only applicable if ee has Dental
,' ' ::char(30) as addr1
,' ' ::char(30) as addr2
,' ' ::char(19) as city
,' ' ::char(2) state
,' ' ::char(11) as zip
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh --- position 309
--- All effective dates after doh should be either 5/1/18 (Benefit Plan Year) or Last Hired Date, whichever is greater
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-05-01'),'yyyymmdd') ::char(8) as emp_eff_date --- position 317
---------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405 --
---------------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-05-01'),'yyyymmdd') ::char(8) as sub_group_eff_date --- position 393
,'0001' ::char(4) as sub_group
---------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474 --
---------------------------------------
-----------------------------------
-- SALARY DATA SEGMENT 475 - 527 --
-----------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-05-01'),'yyyymmdd') ::char(8) as basic_sal_eff_date --- position 475
,'A' ::char(1) as basic_sal_mode
,case when pc.frequencycode = 'H' then to_char((round(pc.compamount,2) * pp.scheduledhours) * 26 * 100, 'FM0000000000000000 ')
      else to_char(pc.compamount * 100, 'FM0000000000000000 ') end ::char(16) as basic_salary_amount -- assume decimal zero fill    
,' ' ::char(2) as first_add_comp_type
,' ' ::char(16) as first_add_comp_amt
----------------------------------
-- CLASS DATA SEGMENT 608 - 620 --
----------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-05-01'),'yyyymmdd') ::char(8) as class_eff_date --- position 608
,'A001' ::char(4) as class_id 
--------------------------------------
-- SMOKING STATUS SEGMENT 620 - 629 --
--------------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-05-01'),'yyyymmdd') ::char(8) as smoker_status_effective_date --- position 620
---Values: B - Both Subscriber & Spouse Smoke ; N - Neither Smoke; S - Subscriber Only Smokes; P - Spouse Only Smokes.
,pv.smoker ::char(1) as smoker_indicator
--------------------------
-- ELIGIBILITY SEGMENTS --
--------------------------
-------------------------------
-- BASIC LIFE (20) 810 - 832 --
-------------------------------
-------------------------------
-- BASIC AD&D (22) 865 - 887 -- 
------------------------------- 
--------------------------------------
-- BASIC STD SEGMENT (32) 920 - 942 --
--------------------------------------
--------------------------------------
-- BASIC LTD SEGMENT (31) 975 - 997 --
--------------------------------------
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
,case when pbebeevlife.benefitsubclass in ('21') then '3' else null end ::char(1) as product_category_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate, '2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_3
,case when pbebeevlife.benefitsubclass in ('21') then 'ETL0CEEVAL' else null end ::char(10) as plan_id_3
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else null end ::char(1) as emp_only_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_3
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else null end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else null end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else null end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
-------------------------------------------------------------
,case when pbebDPvlife.benefitsubclass in ('2X') then '5' else null end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'ETL0CDPVAL' else null end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else null end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (21) 1195 - 1239  --
------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,case when pbebeevlife.benefitsubclass in ('21') then 'c' else null end ::char(1) as product_category_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'EN'  else null end ::char(2) as elig_event_c
,case when pbebeevlife.benefitsubclass in ('21') then 'BTA0CEEVAL' else null end ::char(10) as plan_id_c
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else null end ::char(1) as emp_only_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_c
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z) 1250 - 1294  --
------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'e' else null end ::char(1) as product_category_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'BTA0CSPVAL' else null end ::char(10) as plan_id_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_e
---------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349  --
---------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'd' else null end ::char(1) as product_category_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'BTA0CDPVAL' else null end ::char(10) as plan_id_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else null end ::char(1) as emp_only_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_d
------------------------------------
-- VOLUNTARY STD (30) 1360 - 1382 --
------------------------------------
,case when pbestd.benefitsubclass in ('30') then 'Q' else null end ::char(1) as product_category_Q
,case when pbestd.benefitsubclass in ('30') then to_char(greatest(pbestd.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_Q
,case when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_Q
,case when pbestd.benefitsubclass in ('30') then 'YTS0CABSAL' else null end ::char(10) as plan_id_Q
,case when pbestd.benefitsubclass in ('30') then 'C' else null end ::char(1) as emp_only_Q
------------------------------------
-- VOLUNTARY LTD (31) 1415 - 1437 --
------------------------------------
,case when pbeltd.benefitsubclass in ('31') then 'L' else null end ::char(1) as product_category_L
,case when pbeltd.benefitsubclass in ('31') then to_char(greatest(pbeltd.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_L
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_L
,case when pbeltd.benefitsubclass in ('31') then 'ZTT0CABSAL' else null end ::char(10) as plan_id_L
,case when pbeltd.benefitsubclass in ('31') then 'C' else null end ::char(1) as emp_only_L
-----------------------------------------------------------
-- VOLUNTARY EMPLOYEE CRITICAL ILLNESS (2C) 1470 - 1514  --
-----------------------------------------------------------
,case when pbebeeci.benefitsubclass in ('2C') then 'A' else null end ::char(1) as product_category_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(greatest(pbebeeci.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_A
,case when pbebeeci.benefitsubclass in ('2C') and pbebeeci.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_A
,case when pbebeeci.benefitsubclass in ('2C') then '3CI00EDVAB' else null end ::char(10) as plan_id_A
,case when pbebeeci.benefitsubclass in ('2C') then 'C' else null end ::char(1) as emp_only_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(greatest(pbebeeci.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as elaprv_effective_date_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(pbebeeci.coverageamount, 'FM0000000000') else null end as elaprv_amount_A
--------------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2S) 1525 - 1569 --
--------------------------------------------------------
,case when pbespci.benefitsubclass in ('2S') then 'J' else null end ::char(1) as product_category_J
,case when pbespci.benefitsubclass in ('2S') then to_char(greatest(pbespci.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_J
,case when pbespci.benefitsubclass in ('2S') and pbespci.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_J
,case when pbespci.benefitsubclass in ('2S') then '3CI00SPVAB' else null end ::char(10) as plan_id_J
,case when pbespci.benefitsubclass in ('2S') then 'C' else null end ::char(1) as emp_only_J
,case when pbespci.benefitsubclass in ('2S') then to_char(greatest(pbespci.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as elaprv_effective_date_J
,case when pbespci.benefitsubclass in ('2S') then to_char(pbespci.coverageamount, 'FM0000000000') else null end as elaprv_amount_J
-----------------------------------------
-- VOLUNTARY ACCIDENT (13) 1865 - 1877 --
-----------------------------------------
,case when pbevollacd.benefitsubclass in ('13') then 'g' else null end ::char(1) as product_category_g
,case when pbevollacd.benefitsubclass in ('13') then to_char(greatest(pbevollacd.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_g
,case when pbevollacd.benefitsubclass in ('13') and pbevollacd.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_g
,case when pbevollacd.benefitsubclass in ('13') then '6AS000VACC' else null end ::char(10) as plan_id_g
,case when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Family' then 'A' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee + Spouse' then 'B' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee Only' then 'C' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee + Children' then 'D'
      else null end ::char(1) as family_cvg_ind_g 

from person_identity pi
--- only need look back date on terms 
left join edi.edi_last_update elu on elu.feedid = 'AXU_Mutual_Of_Omaha_Carrier_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_bene_election pbe
  on pbe.personid = pi.personid
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in ('21','2Z','2X','30','31','2C','2S','13')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts

left join 
     (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('21','2Z','2X','30','31','2C','2S','13')
         and benefitelection in ('E')
         and selectedoption = 'Y'
       group by 1) pbe_max
  on pbe_max.personid = pbe.personid    
-----------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) --&-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) --
----------------------------------------------------------------------------------------- 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('21') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebeevlife on pbebeevlife.personid = pbe.personid and pbebeevlife.coverageamount <> 0 and pbebeevlife.rank = 1 
-----------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) --&-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z ) --
----------------------------------------------------------------------------------------- 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2Z') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebSPvlife on pbebSPvlife.personid = pbe.personid and pbebSPvlife.coverageamount <> 0 and pbebSPvlife.rank = 1  
-----------------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) --&-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) --
-----------------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2X') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebDPvlife on pbebDPvlife.personid = pbe.personid and pbebDPvlife.coverageamount <> 0 and pbebDPvlife.rank = 1 
----------------
-- PCSTD (30) --
---------------- 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('30') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbestd on pbestd.personid = pbe.personid and pbestd.rank = 1 
------------------------  
-- VOLUNTARY LTD (31) --
------------------------    
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('31') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbeltd on pbeltd.personid = pbe.personid and pbeltd.rank = 1 
------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2C)      --
------------------------------------------------------------      
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2C') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebeeci on pbebeeci.personid = pbe.personid and pbebeeci.rank = 1 
------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/SPOUSE CRITICAL ILLNESS (2S)        --
------------------------------------------------------------                           
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2S') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbespci on pbespci.personid = pbe.personid and pbespci.rank = 1 
-----------------------------
-- VOLUNTARY ACCIDENT (13) --
-----------------------------          
left join (select personid, benefitsubclass, benefitelection, benefitcoverageid, personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('13') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and current_date between effectivedate and enddate
            group by personid, benefitsubclass, benefitelection, benefitcoverageid, personbeneelectionpid, coverageamount) pbevollacd on pbevollacd.personid = pbe.personid and pbevollacd.rank = 1 

left join benefit_coverage_desc bcd on bcd.benefitcoverageid = pbevollacd.benefitcoverageid
and current_date between bcd.effectivedate and bcd.enddate
and current_timestamp between bcd.createts and bcd.endts

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1  
 
left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1

   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus not in ('R','T')
  and pbe.benefitelection = 'E'
 -- and pi.personid in ('1071', '1045','2386','2396','2413','2435','2447','2536','2568','2653','785','788','803','810','826','846','847','875','882','902','984','994')
) elected

full outer join 

(
select distinct
-----Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans
 pi.personid
,elu.lastupdatets 
,'ACTIVE EE WAIVED BENEFIT' ::VARCHAR(30) AS SOURCESEQ
,'0' ::char(1) as sort_seq  
----------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325 --
----------------------------------
,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9CJ' ::char(8) as group_id
,'M' ::char(1) as relationship_code 
,pi.identity ::char(9) as employee_id 
,pn.lname ::char(35) as elname
,pn.fname ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
--- address is only applicable if ee has Dental
,' ' ::char(30) as addr1
,' ' ::char(30) as addr2
,' ' ::char(19) as city
,' ' ::char(2) state
,' ' ::char(11) as zip
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh --- position 309
--- All effective dates after doh should be either 5/1/18 (Benefit Plan Year) or Last Hired Date, whichever is greater
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-05-01'),'yyyymmdd') ::char(8) as emp_eff_date --- position 317
---------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405 --
---------------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-05-01'),'yyyymmdd') ::char(8) as sub_group_eff_date --- position 393
,'0001' ::char(4) as sub_group
---------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474 --
---------------------------------------
-----------------------------------
-- SALARY DATA SEGMENT 475 - 527 --
-----------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-05-01'),'yyyymmdd') ::char(8) as basic_sal_eff_date --- position 475
,'A' ::char(1) as basic_sal_mode
,case when pc.frequencycode = 'H' then to_char((round(pc.compamount,2) * pp.scheduledhours) * 26 * 100, 'FM0000000000000000 ')
      else to_char(pc.compamount * 100, 'FM0000000000000000 ') end ::char(16) as basic_salary_amount -- assume decimal zero fill    
,' ' ::char(2) as first_add_comp_type
,' ' ::char(16) as first_add_comp_amt
----------------------------------
-- CLASS DATA SEGMENT 608 - 620 --
----------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-05-01'),'yyyymmdd') ::char(8) as class_eff_date --- position 608
,'A001' ::char(4) as class_id 
--------------------------------------
-- SMOKING STATUS SEGMENT 620 - 629 --
--------------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-05-01'),'yyyymmdd') ::char(8) as smoker_status_effective_date --- position 620
---Values: B - Both Subscriber & Spouse Smoke ; N - Neither Smoke; S - Subscriber Only Smokes; P - Spouse Only Smokes.
,pv.smoker ::char(1) as smoker_indicator
--------------------------
-- ELIGIBILITY SEGMENTS --
--------------------------
-------------------------------
-- BASIC LIFE (20) 810 - 832 --
-------------------------------
-------------------------------
-- BASIC AD&D (22) 865 - 887 -- 
------------------------------- 
--------------------------------------
-- BASIC STD SEGMENT (32) 920 - 942 --
--------------------------------------
--------------------------------------
-- BASIC LTD SEGMENT (31) 975 - 997 --
--------------------------------------
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
,case when pbebeevlife.benefitsubclass in ('21') then '3' else null end ::char(1) as product_category_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.enddate, '2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'TM' else null end ::char(2) as elig_event_3
,case when pbebeevlife.benefitsubclass in ('21') then 'ETL0CEEVAL' else null end ::char(10) as plan_id_3
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else null end ::char(1) as emp_only_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_3
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else null end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.enddate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'TM' else null end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else null end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else null end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
-------------------------------------------------------------
,case when pbebDPvlife.benefitsubclass in ('2X') then '5' else null end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.enddate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'TM' else null end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'ETL0CDPVAL' else null end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else null end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (21) 1195 - 1239  --
------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,case when pbebeevlife.benefitsubclass in ('21') then 'c' else null end ::char(1) as product_category_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.enddate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'TM'  else null end ::char(2) as elig_event_c
,case when pbebeevlife.benefitsubclass in ('21') then 'BTA0CEEVAL' else null end ::char(10) as plan_id_c
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else null end ::char(1) as emp_only_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_c
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z) 1250 - 1294  --
------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'e' else null end ::char(1) as product_category_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.enddate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'TM' else null end ::char(2) as elig_event_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'BTA0CSPVAL' else null end ::char(10) as plan_id_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else null end ::char(1) as emp_only_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_e
---------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349  --
---------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'd' else null end ::char(1) as product_category_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.enddate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'TM' else null end ::char(2) as elig_event_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'BTA0CDPVAL' else null end ::char(10) as plan_id_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else null end ::char(1) as emp_only_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_d
------------------------------------
-- VOLUNTARY STD (30) 1360 - 1382 --
------------------------------------
,case when pbestd.benefitsubclass in ('30') then 'Q' else null end ::char(1) as product_category_Q
,case when pbestd.benefitsubclass in ('30') then to_char(greatest(pbestd.enddate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_Q
,case when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'E'  then 'TM' else null end ::char(2) as elig_event_Q
,case when pbestd.benefitsubclass in ('30') then 'YTS0CABSAL' else null end ::char(10) as plan_id_Q
,case when pbestd.benefitsubclass in ('30') then 'C' else null end ::char(1) as emp_only_Q
------------------------------------
-- VOLUNTARY LTD (31) 1415 - 1437 --
------------------------------------
,case when pbeltd.benefitsubclass in ('31') then 'L' else null end ::char(1) as product_category_L
,case when pbeltd.benefitsubclass in ('31') then to_char(greatest(pbeltd.enddate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_L
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'TM' else null end ::char(2) as elig_event_L
,case when pbeltd.benefitsubclass in ('31') then 'ZTT0CABSAL' else null end ::char(10) as plan_id_L
,case when pbeltd.benefitsubclass in ('31') then 'C' else null end ::char(1) as emp_only_L
-----------------------------------------------------------
-- VOLUNTARY EMPLOYEE CRITICAL ILLNESS (2C) 1470 - 1514  --
-----------------------------------------------------------
,case when pbebeeci.benefitsubclass in ('2C') then 'A' else null end ::char(1) as product_category_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(greatest(pbebeeci.enddate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_A
,case when pbebeeci.benefitsubclass in ('2C') and pbebeeci.benefitelection = 'E'  then 'TM' else null end ::char(2) as elig_event_A
,case when pbebeeci.benefitsubclass in ('2C') then '3CI00EDVAB' else null end ::char(10) as plan_id_A
,case when pbebeeci.benefitsubclass in ('2C') then 'C' else null end ::char(1) as emp_only_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(greatest(pbebeeci.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as elaprv_effective_date_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(pbebeeci.coverageamount, 'FM0000000000') else null end as elaprv_amount_A
--------------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2S) 1525 - 1569 --
--------------------------------------------------------
,case when pbespci.benefitsubclass in ('2S') then 'J' else null end ::char(1) as product_category_J
,case when pbespci.benefitsubclass in ('2S') then to_char(greatest(pbespci.enddate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_J
,case when pbespci.benefitsubclass in ('2S') and pbespci.benefitelection = 'E'  then 'TM' else null end ::char(2) as elig_event_J
,case when pbespci.benefitsubclass in ('2S') then '3CI00SPVAB' else null end ::char(10) as plan_id_J
,case when pbespci.benefitsubclass in ('2S') then 'C' else null end ::char(1) as emp_only_J
,case when pbespci.benefitsubclass in ('2S') then to_char(greatest(pbespci.effectivedate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as elaprv_effective_date_J
,case when pbespci.benefitsubclass in ('2S') then to_char(pbespci.coverageamount, 'FM0000000000') else null end as elaprv_amount_J
-----------------------------------------
-- VOLUNTARY ACCIDENT (13) 1865 - 1877 --
-----------------------------------------
,case when pbevollacd.benefitsubclass in ('13') then 'g' else null end ::char(1) as product_category_g
,case when pbevollacd.benefitsubclass in ('13') then to_char(greatest(pbevollacd.enddate,'2018-05-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_g
,case when pbevollacd.benefitsubclass in ('13') and pbevollacd.benefitelection = 'E'  then 'TM' else null end ::char(2) as elig_event_g
,case when pbevollacd.benefitsubclass in ('13') then '6AS000VACC' else null end ::char(10) as plan_id_g
,case when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Family' then 'A' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee + Spouse' then 'B' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee Only' then 'C' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee + Children' then 'D'
      else null end ::char(1) as family_cvg_ind_g 

from person_identity pi
--- only need look back date on terms 
left join edi.edi_last_update elu on elu.feedid = 'AXU_Mutual_Of_Omaha_Carrier_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_bene_election pbe
  on pbe.personid = pi.personid
  and pbe.benefitsubclass in ('21','2Z','2X','30','31','2C','2S','13')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts
   

left join 
     (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_timestamp between createts and endts
         and effectivedate < enddate
         and benefitsubclass in ('21','2Z','2X','30','31','2C','2S','13')
         and benefitelection in ('E','T')
         and selectedoption = 'Y'
         AND PERSONID IN (select distinct personid from person_bene_election where current_timestamp between createts and endts and current_date between effectivedate and enddate and benefitsubclass in ('21','2Z','2X','30','31','2C','2S','13') and benefitelection = 'W' and selectedoption = 'Y' )
       group by 1) pbe_max
  on pbe_max.personid = pbe.personid    
-----------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) --&-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) --
----------------------------------------------------------------------------------------- 
/*
The logic to find active ee's termed during OE checks for active enrollment in the past year (first select) for person's waived current year (AND personid in select)
Note you have to check for Terminations along with elected in past year - in case there is a waived / term action see '2447' accident benefit
*/
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('21') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
              AND PERSONID IN (select distinct personid from person_bene_election where current_timestamp between createts and endts and current_date between effectivedate and enddate and benefitsubclass in ('21') and benefitelection = 'W' and selectedoption = 'Y' )
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount)  pbebeevlife on pbebeevlife.personid = pbe.personid and  pbe.effectivedate - interval '1 year' <= pbebeevlife.effectivedate  and pbebeevlife.benefitelection = 'E' and pbebeevlife.rank = 1 
-----------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) --&-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z ) --
----------------------------------------------------------------------------------------- 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2Z') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
              AND PERSONID IN (select distinct personid from person_bene_election where current_timestamp between createts and endts and current_date between effectivedate and enddate and benefitsubclass in ('2Z') and benefitelection = 'W' and selectedoption = 'Y' )
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount)  pbebSPvlife on pbebSPvlife.personid = pbe.personid and pbe.effectivedate - interval '1 year' <= pbebSPvlife.effectivedate and pbebSPvlife.benefitelection = 'E' and pbebSPvlife.rank = 1  
-----------------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) --&-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) --
-----------------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2X') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
              AND PERSONID IN (select distinct personid from person_bene_election where current_timestamp between createts and endts and current_date between effectivedate and enddate and benefitsubclass in ('2X') and benefitelection = 'W' and selectedoption = 'Y' )
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount)  pbebDPvlife on pbebDPvlife.personid = pbe.personid and pbe.effectivedate - interval '1 year' <= pbebDPvlife.effectivedate and pbebDPvlife.benefitelection = 'E' and pbebDPvlife.rank = 1 
----------------
-- PCSTD (30) --
---------------- 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('30') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
              AND PERSONID IN (select distinct personid from person_bene_election where current_timestamp between createts and endts and current_date between effectivedate and enddate and benefitsubclass in ('30') and benefitelection = 'W' and selectedoption = 'Y' )
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount)   pbestd on pbestd.personid = pbe.personid and pbe.effectivedate - interval '1 year' <= pbestd.effectivedate and pbestd.benefitelection = 'E' and pbestd.rank = 1 
------------------------  
-- VOLUNTARY LTD (31) --
------------------------    
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('31') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
              AND PERSONID IN (select distinct personid from person_bene_election where current_timestamp between createts and endts and current_date between effectivedate and enddate and benefitsubclass in ('31') and benefitelection = 'W' and selectedoption = 'Y' )
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount)  pbeltd on pbeltd.personid = pbe.personid and pbe.effectivedate - interval '1 year' <= pbeltd.effectivedate and pbeltd.benefitelection = 'E' and pbeltd.rank = 1 
------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2C)      --
------------------------------------------------------------      
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2C') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate  
              AND PERSONID IN (select distinct personid from person_bene_election where current_timestamp between createts and endts and current_date between effectivedate and enddate and benefitsubclass in ('2C') and benefitelection = 'W' and selectedoption = 'Y' )
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount)  pbebeeci on pbebeeci.personid = pbe.personid and pbe.effectivedate - interval '1 year' <= pbebeeci.effectivedate and pbebeeci.benefitelection = 'E' and pbebeeci.rank = 1 
------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/SPOUSE CRITICAL ILLNESS (2S)        --
------------------------------------------------------------                           
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, effectivedate, enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2S') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
              AND PERSONID IN (select distinct personid from person_bene_election where current_timestamp between createts and endts and current_date between effectivedate and enddate and benefitsubclass in ('2S') and benefitelection = 'W' and selectedoption = 'Y' )
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount)  pbespci on pbespci.personid = pbe.personid and pbe.effectivedate - interval '1 year' <= pbespci.effectivedate and pbespci.benefitelection = 'E' and pbespci.rank = 1 
-----------------------------
-- VOLUNTARY ACCIDENT (13) --
-----------------------------          
left join (select personid, benefitsubclass, benefitelection, benefitcoverageid, personbeneelectionpid, coverageamount, effectivedate, enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('13') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
              AND PERSONID IN (select distinct personid from person_bene_election where current_timestamp between createts and endts and current_date between effectivedate and enddate and benefitsubclass in ('13') and benefitelection = 'W' and selectedoption = 'Y' )
            group by personid, benefitsubclass, benefitelection, benefitcoverageid, personbeneelectionpid, coverageamount)  pbevollacd on pbevollacd.personid = pbe.personid and pbe.effectivedate - interval '1 year' <= pbevollacd.effectivedate and pbevollacd.benefitelection = 'E' and pbevollacd.rank = 1 

left join benefit_coverage_desc bcd on bcd.benefitcoverageid = pbevollacd.benefitcoverageid
and current_date between bcd.effectivedate and bcd.enddate
and current_timestamp between bcd.createts and bcd.endts

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1  
 
left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1

   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus not in ('R','T')
  and (pbebeevlife.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbebSPvlife.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbebDPvlife.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbestd.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbeltd.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbebeeci.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbespci.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbevollacd.effectivedate >= pbe.effectivedate - interval '1 year')

--  and pi.personid in ('1071', '1045','2386','2396','2413','2435','2447','2536','2568','2653','785','788','803','810','826','846','847','875','882','902','984','994')
  ) waived on waived.personid = elected.personid
