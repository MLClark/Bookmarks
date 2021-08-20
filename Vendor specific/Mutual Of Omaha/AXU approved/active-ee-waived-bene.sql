
(
select distinct
-----Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans
-----ACTIVE EE WAIVED BENEFIT is used to locate waived or termed benefits for ACTIVE employees with active enrollments.
-----This data is combimed with ACTIVE EE BENEFIT and coalesced into single record 
-----Expectation is to have either active or termed/waived benefits should never be both
 pi.personid
,elu.lastupdatets ::date + interval '30 days' as lastupdatets
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
--- All effective dates after doh should be either 09/01/2018  (Benefit Plan Year) or Last Hired Date, whichever is greater
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-09-01'),'yyyymmdd') ::char(8) as emp_eff_date --- position 317
---------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405 --
---------------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-09-01'),'yyyymmdd') ::char(8) as sub_group_eff_date --- position 393
,'0001' ::char(4) as sub_group
---------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474 --
---------------------------------------
-----------------------------------
-- SALARY DATA SEGMENT 475 - 527 --
-----------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-09-01'),'yyyymmdd') ::char(8) as basic_sal_eff_date --- position 475
,'A' ::char(1) as basic_sal_mode
,case when pc.frequencycode = 'H' then to_char((round(pc.compamount,2) * pp.scheduledhours) * 26 * 100, 'FM0000000000000000 ')
      else to_char(pc.compamount * 100, 'FM0000000000000000 ') end ::char(16) as basic_salary_amount -- assume decimal zero fill    
,' ' ::char(2) as first_add_comp_type
,' ' ::char(16) as first_add_comp_amt
----------------------------------
-- CLASS DATA SEGMENT 608 - 620 --
----------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-09-01'),'yyyymmdd') ::char(8) as class_eff_date --- position 608
,'A001' ::char(4) as class_id 
--------------------------------------
-- SMOKING STATUS SEGMENT 620 - 629 --
--------------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-09-01'),'yyyymmdd') ::char(8) as smoker_status_effective_date --- position 620
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
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.e_enddate, '2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_3 --when the coverage is terminated, this field should be the Coverage End Date
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'W'  then 'TM' else null end ::char(2) as elig_event_3
,case when pbebeevlife.benefitsubclass in ('21') then 'ETL0CEEVAL' else null end ::char(10) as plan_id_3
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else null end ::char(1) as emp_only_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.e_effectivedate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_3
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else null end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.e_enddate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_4 --when the coverage is terminated, this field should be the Coverage End Date
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'W'  then 'TM' else null end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else null end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else null end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.e_effectivedate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
-------------------------------------------------------------
,case when pbebDPvlife.benefitsubclass in ('2X') then '5' else null end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.e_enddate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_5 --when the coverage is terminated, this field should be the Coverage End Date
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'W'  then 'TM' else null end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'ETL0CDPVAL' else null end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else null end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.e_effectivedate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (21) 1195 - 1239  --
------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,case when pbebeevlife.benefitsubclass in ('21') then 'c' else null end ::char(1) as product_category_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.e_enddate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_c --when the coverage is terminated, this field should be the Coverage End Date
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'W'  then 'TM'  else null end ::char(2) as elig_event_c
,case when pbebeevlife.benefitsubclass in ('21') then 'BTA0CEEVAL' else null end ::char(10) as plan_id_c
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else null end ::char(1) as emp_only_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.e_effectivedate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_c
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z) 1250 - 1294  --
------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'e' else null end ::char(1) as product_category_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.e_enddate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_e --when the coverage is terminated, this field should be the Coverage End Date
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'W'  then 'TM' else null end ::char(2) as elig_event_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'BTA0CSPVAL' else null end ::char(10) as plan_id_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else null end ::char(1) as emp_only_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.e_effectivedate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_e
---------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349  --
---------------------------------------------------------
---Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'd' else null end ::char(1) as product_category_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.e_enddate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_d --when the coverage is terminated, this field should be the Coverage End Date
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'W'  then 'TM' else null end ::char(2) as elig_event_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'BTA0CDPVAL' else null end ::char(10) as plan_id_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else null end ::char(1) as emp_only_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.e_effectivedate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_nom_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_d
------------------------------------
-- VOLUNTARY STD (30) 1360 - 1382 --
------------------------------------
,case when pbestd.benefitsubclass in ('30') then 'Q' else null end ::char(1) as product_category_Q
,case when pbestd.benefitsubclass in ('30') then to_char(greatest(pbestd.e_enddate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_Q  --when the coverage is terminated, this field should be the Coverage End Date
,case when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'W'  then 'TM' else null end ::char(2) as elig_event_Q
,case when pbestd.benefitsubclass in ('30') then 'YTS0CABSAL' else null end ::char(10) as plan_id_Q
,case when pbestd.benefitsubclass in ('30') then 'C' else null end ::char(1) as emp_only_Q
------------------------------------
-- VOLUNTARY LTD (31) 1415 - 1437 --
------------------------------------
,case when pbeltd.benefitsubclass in ('31') then 'L' else null end ::char(1) as product_category_L
,case when pbeltd.benefitsubclass in ('31') then to_char(greatest(pbeltd.e_enddate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_L --when the coverage is terminated, this field should be the Coverage End Date
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'W'  then 'TM' else null end ::char(2) as elig_event_L
,case when pbeltd.benefitsubclass in ('31') then 'ZTT0CABSAL' else null end ::char(10) as plan_id_L
,case when pbeltd.benefitsubclass in ('31') then 'C' else null end ::char(1) as emp_only_L
-----------------------------------------------------------
-- VOLUNTARY EMPLOYEE CRITICAL ILLNESS (2C) 1470 - 1514  --
-----------------------------------------------------------
,case when pbebeeci.benefitsubclass in ('2C') then 'A' else null end ::char(1) as product_category_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(greatest(pbebeeci.e_enddate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_A --when the coverage is terminated, this field should be the Coverage End Date
,case when pbebeeci.benefitsubclass in ('2C') and pbebeeci.benefitelection in ('T','W')  then 'TM' else null end ::char(2) as elig_event_A
,case when pbebeeci.benefitsubclass in ('2C') then '3CI00EDVAB' else null end ::char(10) as plan_id_A
,case when pbebeeci.benefitsubclass in ('2C') then 'C' else null end ::char(1) as emp_only_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(greatest(pbebeeci.e_effectivedate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as elaprv_effective_date_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(pbebeeci.coverageamount, 'FM0000000000') else null end as elaprv_amount_A
--------------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2S) 1525 - 1569 --
--------------------------------------------------------
,case when pbespci.benefitsubclass in ('2S') then 'J' else null end ::char(1) as product_category_J
,case when pbespci.benefitsubclass in ('2S') then to_char(greatest(pbespci.e_enddate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_J --when the coverage is terminated, this field should be the Coverage End Date
,case when pbespci.benefitsubclass in ('2S') and pbespci.benefitelection = 'W'  then 'TM' else null end ::char(2) as elig_event_J
,case when pbespci.benefitsubclass in ('2S') then '3CI00SPVAB' else null end ::char(10) as plan_id_J
,case when pbespci.benefitsubclass in ('2S') then 'C' else null end ::char(1) as emp_only_J
,case when pbespci.benefitsubclass in ('2S') then to_char(greatest(pbespci.e_effectivedate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as elaprv_effective_date_J
,case when pbespci.benefitsubclass in ('2S') then to_char(pbespci.coverageamount, 'FM0000000000') else null end as elaprv_amount_J
-----------------------------------------
-- VOLUNTARY ACCIDENT (13) 1865 - 1877 --
-----------------------------------------
,case when pbevollacd.benefitsubclass in ('13') then 'g' else null end ::char(1) as product_category_g
,case when pbevollacd.benefitsubclass in ('13') then to_char(greatest(pbevollacd.e_enddate,'2018-09-01'),'YYYYMMDD') else null end ::char(8) as pc_effective_date_g --when the coverage is terminated, this field should be the Coverage End Date
,case when pbevollacd.benefitsubclass in ('13') and pbevollacd.benefitelection = 'W'  then 'TM' else null end ::char(2) as elig_event_g
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
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('21','2Z','2X','30','31','2C','2S','13')
         and benefitelection in ('E')
         and selectedoption = 'Y'
       group by 1) pbe_max
  on pbe_max.personid = pbe.personid    
---------------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) --3 & c-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) --
--------------------------------------------------------------------------------------------- 
/*
Find active ee's termed or waived during the past year based on evenddate
First select - find termed / waived enrollments for current election 
Second select - find active enrollments within current benefit event year to get coverageamount
*/
left join 
(select 
 w.personid
,w.benefitsubclass
,w.benefitelection
,w.personbeneelectionpid
,e.coverageamount
,w.effectivedate
,w.enddate
,coalesce(w.benefitcoverageid,e.benefitcoverageid) as benefitcoverageid
,e.effectivedate as e_effectivedate
,e.enddate as e_enddate
,w.rank
from 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe 
  where current_timestamp between createts and endts and benefitsubclass in ('21') and benefitelection in ('T','W') and selectedoption = 'Y' and current_date between effectivedate and enddate 
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T'))  
    and personid in (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
                      where benefitsubclass in ('21') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year'))
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) w
join 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
  where benefitsubclass in ('21') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate <= planyearstart 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) e on w.personid = e.personid and e.rank = 1) pbebeevlife on pbebeevlife.personid = pbe.personid and pbebeevlife.rank = 1 
    and pbebeevlife.effectivedate::date + interval '30 days' >= elu.lastupdatets::date
---------------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) --4 & e-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z ) --
--------------------------------------------------------------------------------------------- 
left join 
(select 
 w.personid
,w.benefitsubclass
,w.benefitelection
,w.personbeneelectionpid
,e.coverageamount
,w.effectivedate
,w.enddate
,coalesce(w.benefitcoverageid,e.benefitcoverageid) as benefitcoverageid
,e.effectivedate as e_effectivedate
,e.enddate as e_enddate
,w.rank
from 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe 
  where current_timestamp between createts and endts and benefitsubclass in ('2Z') and benefitelection in ('T','W') and selectedoption = 'Y' and current_date between effectivedate and enddate   
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T'))
    and personid in (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
                      where benefitsubclass in ('2Z') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year'))            
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) w
join 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
  where benefitsubclass in ('2Z') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate <= planyearstart 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) e on w.personid = e.personid and e.rank = 1) pbebSPvlife on pbebSPvlife.personid = pbe.personid and pbebSPvlife.rank = 1  
    and pbebSPvlife.effectivedate::date + interval '30 days' >= elu.lastupdatets::date
---------------------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) --5 & d-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) --
---------------------------------------------------------------------------------------------------
left join 
(select 
 w.personid
,w.benefitsubclass
,w.benefitelection
,w.personbeneelectionpid
,e.coverageamount
,w.effectivedate
,w.enddate
,coalesce(w.benefitcoverageid,e.benefitcoverageid) as benefitcoverageid
,e.effectivedate as e_effectivedate
,e.enddate as e_enddate
,w.rank
from 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe 
  where current_timestamp between createts and endts and benefitsubclass in ('2X') and benefitelection in ('T','W') and selectedoption = 'Y' and current_date between effectivedate and enddate   
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T'))
    and personid in (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
                      where benefitsubclass in ('2X') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year'))
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) w
join 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
  where benefitsubclass in ('2X') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate <= planyearstart 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) e on w.personid = e.personid and e.rank = 1) pbebDPvlife on pbebDPvlife.personid = pbe.personid and pbebDPvlife.rank = 1 
    and pbebDPvlife.effectivedate::date + interval '30 days' >= elu.lastupdatets::date
------------------
-- PCSTD (30) Q --
------------------ 
left join 
(select 
 w.personid
,w.benefitsubclass
,w.benefitelection
,w.personbeneelectionpid
,e.coverageamount
,w.effectivedate
,w.enddate
,coalesce(w.benefitcoverageid,e.benefitcoverageid) as benefitcoverageid
,e.effectivedate as e_effectivedate
,e.enddate as e_enddate
,w.rank
from 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe 
  where current_timestamp between createts and endts and benefitsubclass in ('30') and benefitelection in ('T','W') and selectedoption = 'Y' and current_date between effectivedate and enddate
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T'))     
    and personid in (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
                      where benefitsubclass in ('30') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year'))
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) w
join 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
  where benefitsubclass in ('30') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate <= planyearstart 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) e on w.personid = e.personid and e.rank = 1) pbestd on pbestd.personid = pbe.personid and pbestd.rank = 1 
    and pbestd.effectivedate::date + interval '30 days' >= elu.lastupdatets::date
--------------------------  
-- VOLUNTARY LTD (31) L --
--------------------------    
left join 
(select 
 w.personid
,w.benefitsubclass
,w.benefitelection
,w.personbeneelectionpid
,e.coverageamount
,w.effectivedate
,w.enddate
,coalesce(w.benefitcoverageid,e.benefitcoverageid) as benefitcoverageid
,e.effectivedate as e_effectivedate
,e.enddate as e_enddate
,w.rank
from 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe 
  where current_timestamp between createts and endts and benefitsubclass in ('31') and benefitelection in ('T','W') and selectedoption = 'Y' and current_date between effectivedate and enddate   
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T'))
    and personid in (select pbe.personid from person_bene_election pbe
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
                      where benefitsubclass in ('31') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year'))
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) w
join 
  (select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear = date_part('year',current_date - interval '1 year')))
  where benefitsubclass in ('31') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate <= planyearstart  
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) e on w.personid = e.personid and e.rank = 1) pbeltd on pbeltd.personid = pbe.personid and pbeltd.rank = 1 
    and pbeltd.effectivedate::date + interval '30 days' >= elu.lastupdatets::date
------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2C)  A   --
------------------------------------------------------------      
left join 
(select 
 w.personid
,w.benefitsubclass
,w.benefitelection
,w.personbeneelectionpid
,e.coverageamount
,w.effectivedate
,w.enddate
,coalesce(w.benefitcoverageid,e.benefitcoverageid) as benefitcoverageid
,e.effectivedate as e_effectivedate
,e.enddate as e_enddate
,w.rank
from 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe 
  where current_timestamp between createts and endts and benefitsubclass in ('2C') and benefitelection in ('T','W') and selectedoption = 'Y' and current_date between effectivedate and enddate   
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T'))
    and personid in (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
                      where benefitsubclass in ('2C') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year'))
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) w
join 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
  where benefitsubclass in ('2C') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate <= planyearstart 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) e on w.personid = e.personid  and e.rank = 1) pbebeeci on pbebeeci.personid = pbe.personid and pbebeeci.rank = 1 
    and pbebeeci.effectivedate::date + interval '30 days' >= elu.lastupdatets::date
------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/SPOUSE CRITICAL ILLNESS (2S)   J    --
------------------------------------------------------------                           
left join 
(select  
 w.personid
,w.benefitsubclass
,w.benefitelection
,w.personbeneelectionpid
,e.coverageamount
,w.effectivedate
,w.enddate
,coalesce(w.benefitcoverageid,e.benefitcoverageid) as benefitcoverageid
,e.effectivedate as e_effectivedate
,e.enddate as e_enddate
,w.rank
from 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe 
  where current_timestamp between createts and endts and benefitsubclass in ('2S') and benefitelection in ('T','W') and selectedoption = 'Y' and current_date between effectivedate and enddate  
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T')) 
    and personid in (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
                      where benefitsubclass in ('2S') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year'))
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) w
join 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
  where benefitsubclass in ('2S') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate <= planyearstart 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) e on w.personid = e.personid and e.rank = 1) pbespci on pbespci.personid = pbe.personid and pbespci.rank = 1 
    and pbespci.effectivedate::date + interval '30 days' >= elu.lastupdatets::date
--------------------------------
-- VOLUNTARY ACCIDENT (13)  g --
--------------------------------          
left join 
(select 
 w.personid
,w.benefitsubclass
,w.benefitelection
,w.personbeneelectionpid
,e.coverageamount
,w.effectivedate
,w.enddate
,coalesce(w.benefitcoverageid,e.benefitcoverageid) as benefitcoverageid
,e.effectivedate as e_effectivedate
,e.enddate as e_enddate
,w.rank
from 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe 
  where current_timestamp between createts and endts and benefitsubclass in ('13') and benefitelection in ('T','W') and selectedoption = 'Y' and current_date between effectivedate and enddate   
    and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus not in ('R','T'))
    and personid in (select pbe.personid from person_bene_election pbe 
                       join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
                      where benefitsubclass in ('13') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E') and eventdate >= date_trunc('year',current_date - interval '1 year')) 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) w
join 
(select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) DESC) AS RANK
   from person_bene_election pbe join comp_plan_plan_year cppy on cppy.compplanplanyeartype = 'Bene' and (cppy.planyear = date_part('year',current_date) or (cppy.planyear <= date_part('year',current_date - interval '1 year')))
  where benefitsubclass in ('13') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection in ('E','T') and (effectivedate between date_trunc('year',current_date - interval '1 year') and date_trunc('year',current_date)) and eventdate <= planyearstart 
  group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid ) e on w.personid = e.personid and e.rank = 1) pbevollacd on pbevollacd.personid = pbe.personid and pbevollacd.rank = 1 
    and pbevollacd.effectivedate::date + interval '30 days' >= elu.lastupdatets::date

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
 -- and pe.personid = '846'
  and (pbebeevlife.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbebSPvlife.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbebDPvlife.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbestd.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbeltd.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbebeeci.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbespci.effectivedate >= pbe.effectivedate - interval '1 year'
   or  pbevollacd.effectivedate >= pbe.effectivedate - interval '1 year')
   
  )