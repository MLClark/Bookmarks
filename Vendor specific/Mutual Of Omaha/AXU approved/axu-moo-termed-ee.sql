
select distinct
-----Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans
 pi.personid
,elu.lastupdatets 
,'Termed EE' ::varchar(30) as sourceseq

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
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh -- position 309
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
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
,case when pbebeevlife.benefitsubclass in ('21') then '3' else ' ' end ::char(1) as product_category_3
----- for terminations the effectivedate should be the coverage enddate
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.enddate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'T'  then 'TM' 
      when pbebeevlife.benefitsubclass in ('21') and pe.emplstatus = 'T'  then 'TM' else ' ' end ::char(2) as elig_event_3
,case when pbebeevlife.benefitsubclass in ('21') then 'ETL0CEEVAL' else ' ' end ::char(10) as plan_id_3
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_3
----- for terminations the nom effectivedate should be the coverage start date
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-09-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_3
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
----- for terminations the effectivedate should be the coverage enddate
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.enddate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'T'  then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pe.emplstatus = 'T'  then 'TM' else ' ' end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
----- for terminations the nom effectivedate should be the coverage start date
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-09-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
-------------------------------------------------------------
,case when pbebDPvlife.benefitsubclass in ('2X') then '5' else ' ' end ::char(1) as product_category_5
----- for terminations the effectivedate should be the coverage enddate
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.enddate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('2X') and pe.emplstatus = 'T'  then 'TM' else ' ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_5
----- for terminations the nom effectivedate should be the coverage start date
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-09-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) 1195 - 1239 --
------------------------------------------------------
-----Vol Life & AD&D are bundled, so for every Vol Life, you should also have the corresponding Vol AD&D plans problem is the ee isn't actually enrolled in ad&d
,case when pbebeevlife.benefitsubclass in ('21') then 'c' else ' ' end ::char(1) as product_category_c
----- for terminations the effectivedate should be the coverage enddate
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.enddate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'T'  then 'TM' 
      when pbebeevlife.benefitsubclass in ('21') and pe.emplstatus = 'T'  then 'TM' else ' ' end ::char(2) as elig_event_c
,case when pbebeevlife.benefitsubclass in ('21') then 'BTA0CEEVAL' else ' ' end ::char(10) as plan_id_c
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_c
----- for terminations the nom effectivedate should be the coverage start date
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-09-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_c
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z) 1250 - 1294  --
------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'e' else ' ' end ::char(1) as product_category_e
----- for terminations the effectivedate should be the coverage enddate
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.enddate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'T'  then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pe.emplstatus = 'T'  then 'TM' else ' ' end ::char(2) as elig_event_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'BTA0CSPVAL' else ' ' end ::char(10) as plan_id_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_e
----- for terminations the nom effectivedate should be the coverage start date
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-09-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_e
---------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349  --
---------------------------------------------------------
,case when pbebDPvlife.benefitsubclass in ('2X') then 'd' else ' ' end ::char(1) as product_category_d
----- for terminations the effectivedate should be the coverage enddate
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.enddate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('2X') and pe.emplstatus = 'T'  then 'TM' else ' ' end ::char(2) as elig_event_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'BTA0CDPVAL' else ' ' end ::char(10) as plan_id_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_d
----- for terminations the nom effectivedate should be the coverage start date
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(greatest(pbebDPvlife.effectivedate,'2018-09-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_d
------------------------------------
-- VOLUNTARY STD (30) 1360 - 1382 --
------------------------------------
,case when pbestd.benefitsubclass in ('30') then 'Q' else ' ' end ::char(1) as product_category_Q
----- for terminations the effectivedate should be the coverage enddate
,case when pbestd.benefitsubclass in ('30') then to_char(greatest(pbestd.enddate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_Q
,case when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'T'  then 'TM' 
      when pbestd.benefitsubclass in ('30') and pe.emplstatus = 'T'  then 'TM' else '  ' end ::char(2) as elig_event_Q
,case when pbestd.benefitsubclass in ('30') then 'YTS0CABSAL' else ' ' end ::char(10) as plan_id_Q
,case when pbestd.benefitsubclass in ('30') then 'C' else ' ' end ::char(1) as emp_only_Q
------------------------------------
-- VOLUNTARY LTD (31) 1415 - 1437 --
------------------------------------
,case when pbeltd.benefitsubclass in ('31') then 'L' else ' ' end ::char(1) as product_category_L
----- for terminations the effectivedate should be the coverage enddate
,case when pbeltd.benefitsubclass in ('31') then to_char(greatest(pbeltd.enddate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_L
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pe.emplstatus = 'T'  then 'TM' else ' ' end ::char(2) as elig_event_L
,case when pbeltd.benefitsubclass in ('31') then 'ZTT0CABSAL' else ' ' end ::char(10) as plan_id_L
,case when pbeltd.benefitsubclass in ('31') then 'C' else ' ' end ::char(1) as emp_only_L
-------------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2C) 1470 - 1514 --
-------------------------------------------------------------------
,case when pbebeeci.benefitsubclass in ('2C') then 'A' else ' ' end ::char(1) as product_category_A
----- for terminations the effectivedate should be the coverage enddate
,case when pbebeeci.benefitsubclass in ('2C') then to_char(greatest(pbebeeci.enddate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_A
,case when pbebeeci.benefitsubclass in ('2C') and pbebeeci.benefitelection = 'T'  then 'TM' 
      when pbebeeci.benefitsubclass in ('2C') and pe.emplstatus = 'T'  then 'TM' else ' ' end ::char(2) as elig_event_A
,case when pbebeeci.benefitsubclass in ('2C') then '3CI00EDVAB' else ' ' end ::char(10) as plan_id_A
,case when pbebeeci.benefitsubclass in ('2C') then 'C' else ' ' end ::char(1) as emp_only_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(greatest(pbebeeci.effectivedate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as elaprv_effective_date_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(pbebeeci.coverageamount, 'FM0000000000') else null end as elaprv_amount_A
--------------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2S) 1525 - 1569 --
--------------------------------------------------------
,case when pbebspci.benefitsubclass in ('2S') then 'J' else ' ' end ::char(1) as product_category_J
----- for terminations the effectivedate should be the coverage enddate
,case when pbebspci.benefitsubclass in ('2S') then to_char(greatest(pbebspci.enddate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_J
,case when pbebspci.benefitsubclass in ('2S') and pbebspci.benefitelection = 'T'  then 'TM' 
      when pbebspci.benefitsubclass in ('2S') and pe.emplstatus = 'T'  then 'TM' else ' ' end ::char(2) as elig_event_J
,case when pbebspci.benefitsubclass in ('2S') then '3CI00SPVAB' else ' ' end ::char(10) as plan_id_J
,case when pbebspci.benefitsubclass in ('2S') then 'C' else ' ' end ::char(1) as emp_only_J
,case when pbebspci.benefitsubclass in ('2S') then to_char(greatest(pbebspci.effectivedate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as elaprv_effective_date_J
,case when pbebspci.benefitsubclass in ('2S') then to_char(pbebspci.coverageamount, 'FM0000000000') else null end as elaprv_amount_J
-----------------------------------------
-- VOLUNTARY ACCIDENT (13) 1865 - 1877 --
-----------------------------------------
,case when pbevollacd.benefitsubclass in ('13') then 'g' else ' ' end ::char(1) as product_category_g
----- for terminations the effectivedate should be the coverage enddate
,case when pbevollacd.benefitsubclass in ('13') then to_char(greatest(pbevollacd.enddate,'2018-09-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_g
,case when pbevollacd.benefitsubclass in ('13') and pbevollacd.benefitelection = 'T'  then 'TM' 
      when pbevollacd.benefitsubclass in ('13') and pe.emplstatus = 'T'  then 'TM' else null end ::char(2) as elig_event_g
,case when pbevollacd.benefitsubclass in ('13') then '6AS000VACC' else null end ::char(10) as plan_id_g
,case when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Family' then 'A' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee + Spouse' then 'B' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee Only' then 'C' 
      when pbevollacd.benefitsubclass in ('13') and bcd.benefitcoveragedesc = 'Employee + Children' then 'D'
      --when pbevollacd.benefitsubclass in ('13') then 'C'
      else ' ' end ::char(1) as family_cvg_ind_g 


from person_identity pi
--- only need look back date on terms 
left join edi.edi_last_update elu on elu.feedid = 'AXU_Mutual_Of_Omaha_Carrier_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join (select personid, benefitsubclass,benefitcoverageid, benefitelection,  personbeneelectionpid, eventdate, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in ('21','2Z','2X','30','31','2C','2S','13')
              and benefitelection in ('E') and selectedoption = 'Y'
              and effectivedate < enddate and current_timestamp between createts and endts
              and date_part('year',eventdate::date) >= date_part('year',current_date - interval '1 year')
              and date_part('year',effectivedate) >= date_part('year',current_date)
            group by personid, benefitsubclass,benefitcoverageid, benefitelection,  personbeneelectionpid, eventdate) pbe on pbe.personid = pe.personid and pbe.rank = 1   

left join (select personid, max(effectivedate) as effectivedate
             from person_bene_election 
            where effectivedate < enddate
              and current_timestamp between createts and endts
              and benefitsubclass in ('21','2Z','2X','30','31','2C','2S','13')
              and benefitelection in ('T')
              and selectedoption = 'Y'
            group by 1) pbe_max
      on pbe_max.personid = pbe.personid   
  
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
   

left join (
select distinct
  e.personid
 ,coalesce(t.benefitsubclass,e.benefitsubclass) as benefitsubclass
 ,coalesce(t.benefitelection,e.benefitelection) as benefitelection
 ,coalesce(t.createts, e.createts) as createts
 ,coalesce(t.personbeneelectionpid, e.personbeneelectionpid) as personbeneelectionpid
 ,coalesce(e.enddate, t.enddate) as enddate
 ,coalesce(e.coverageamount, t.coverageamount) as coverageamount
 ,coalesce(t.effectivedate, e.effectivedate) as effectivedate 
 ,e.rank as rank
 from 
 
 (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) ASC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('21') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) >= date_part('year',current_date - interval '1 year')  --- 9/1/2020 check prior year for start of event personid 2750 elected bene's in 2019 termed his employment in 2020.
              and date_part('year',effectivedate) >= date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) e
            
 join 
 
( select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) desc) AS RANK
             from person_bene_election
            where benefitsubclass in  ('21') and benefitelection in ('T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) = date_part('year',current_date) 
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) t    
            on t.personid = e.personid  
)  pbebeevlife on pbebeevlife.personid = pbe.personid and pbebeevlife.rank = 1   
                        
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
left join (
select distinct
  e.personid
 ,coalesce(t.benefitsubclass,e.benefitsubclass) as benefitsubclass
 ,coalesce(t.benefitelection,e.benefitelection) as benefitelection
 ,coalesce(t.createts, e.createts) as createts
 ,coalesce(t.personbeneelectionpid, e.personbeneelectionpid) as personbeneelectionpid
 ,coalesce(e.enddate, t.enddate) as enddate
 ,coalesce(e.coverageamount, t.coverageamount) as coverageamount
 ,coalesce(t.effectivedate, e.effectivedate) as effectivedate 
 ,e.rank as rank
 from 
 
 (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) ASC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('2Z') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) >= date_part('year',current_date - interval '1 year')
              and date_part('year',effectivedate) >= date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) e
            
 join 
 
( select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) desc) AS RANK
             from person_bene_election
            where benefitsubclass in  ('2Z') and benefitelection in ('T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) = date_part('year',current_date) 
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) t    
            on t.personid = e.personid  
)  pbebSPvlife on pbebSPvlife.personid = pbe.personid and pbebSPvlife.rank = 1
            
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
------------------------------------------------------------- 
left join (
select distinct
  e.personid
 ,coalesce(t.benefitsubclass,e.benefitsubclass) as benefitsubclass
 ,coalesce(t.benefitelection,e.benefitelection) as benefitelection
 ,coalesce(t.createts, e.createts) as createts
 ,coalesce(t.personbeneelectionpid, e.personbeneelectionpid) as personbeneelectionpid
 ,coalesce(e.enddate, t.enddate) as enddate
 ,coalesce(e.coverageamount, t.coverageamount) as coverageamount
 ,coalesce(t.effectivedate, e.effectivedate) as effectivedate 
 ,e.rank as rank
 from 
 
 (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) ASC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('2X') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) >= date_part('year',current_date - interval '1 year')
              and date_part('year',effectivedate) >= date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) e
            
 join 
 
( select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) desc) AS RANK
             from person_bene_election
            where benefitsubclass in  ('2X') and benefitelection in ('T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) = date_part('year',current_date) 
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) t    
            on t.personid = e.personid  
) pbebDPvlife on pbebDPvlife.personid = pbe.personid and pbebDPvlife.rank = 1
            
----------------
-- PCSTD (30) --
---------------- 
left join (
select distinct
  e.personid
 ,coalesce(t.benefitsubclass,e.benefitsubclass) as benefitsubclass
 ,coalesce(t.benefitelection,e.benefitelection) as benefitelection
 ,coalesce(t.createts, e.createts) as createts
 ,coalesce(t.personbeneelectionpid, e.personbeneelectionpid) as personbeneelectionpid
 ,coalesce(e.enddate, t.enddate) as enddate
 ,coalesce(e.coverageamount, t.coverageamount) as coverageamount
 ,coalesce(t.effectivedate, e.effectivedate) as effectivedate 
 ,e.rank as rank
 from 
 
 (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) ASC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('30') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) >= date_part('year',current_date - interval '1 year')
              and date_part('year',effectivedate) >= date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) e
            
 join 
 
( select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) desc) AS RANK
             from person_bene_election
            where benefitsubclass in  ('30') and benefitelection in ('T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) = date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) t    
            on t.personid = e.personid  
)  pbestd on pbestd.personid = pbe.personid and pbestd.rank = 1             
------------------------  
-- VOLUNTARY LTD (31) --
------------------------  
left join (
select distinct
  e.personid
 ,coalesce(t.benefitsubclass,e.benefitsubclass) as benefitsubclass
 ,coalesce(t.benefitelection,e.benefitelection) as benefitelection
 ,coalesce(t.createts, e.createts) as createts
 ,coalesce(t.personbeneelectionpid, e.personbeneelectionpid) as personbeneelectionpid
 ,coalesce(e.enddate, t.enddate) as enddate
 ,coalesce(e.coverageamount, t.coverageamount) as coverageamount
 ,coalesce(t.effectivedate, e.effectivedate) as effectivedate 
 ,e.rank as rank
 from 
 
 (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) ASC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('31') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) >= date_part('year',current_date - interval '1 year')
              and date_part('year',effectivedate) >= date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) e
            
 join 
 
( select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) desc) AS RANK
             from person_bene_election
            where benefitsubclass in  ('31') and benefitelection in ('T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) = date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) t    
            on t.personid = e.personid  
) pbeltd on pbeltd.personid = pbe.personid and pbeltd.rank = 1        
------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2C)      --
------------------------------------------------------------   
left join (
select distinct
  e.personid
 ,coalesce(t.benefitsubclass,e.benefitsubclass) as benefitsubclass
 ,coalesce(t.benefitelection,e.benefitelection) as benefitelection
 ,coalesce(t.createts, e.createts) as createts
 ,coalesce(t.personbeneelectionpid, e.personbeneelectionpid) as personbeneelectionpid
 ,coalesce(e.enddate, t.enddate) as enddate
 ,coalesce(e.coverageamount, t.coverageamount) as coverageamount
 ,coalesce(t.effectivedate, e.effectivedate) as effectivedate 
 ,e.rank as rank
 from 
 
 (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) ASC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('2C') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) >= date_part('year',current_date - interval '1 year')
              and date_part('year',effectivedate) >= date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) e
            
 join 
 
( select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) desc) AS RANK
             from person_bene_election
            where benefitsubclass in  ('2C') and benefitelection in ('T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) = date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) t    
            on t.personid = e.personid  
) pbebeeci on pbebeeci.personid = pbe.personid and pbebeeci.rank = 1             
------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/SPOUSE CRITICAL ILLNESS (2S)        --
------------------------------------------------------------ 
left join (
select distinct
  e.personid
 ,coalesce(t.benefitsubclass,e.benefitsubclass) as benefitsubclass
 ,coalesce(t.benefitelection,e.benefitelection) as benefitelection
 ,coalesce(t.createts, e.createts) as createts
 ,coalesce(t.personbeneelectionpid, e.personbeneelectionpid) as personbeneelectionpid
 ,coalesce(e.enddate, t.enddate) as enddate
 ,coalesce(e.coverageamount, t.coverageamount) as coverageamount
 ,coalesce(t.effectivedate, e.effectivedate) as effectivedate 
 ,e.rank as rank
 from 
 
 (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) ASC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('2S') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) >= date_part('year',current_date - interval '1 year')
              and date_part('year',effectivedate) >= date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) e
            
 join 
 
( select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(createts) desc) AS RANK
             from person_bene_election
            where benefitsubclass in  ('2S') and benefitelection in ('T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0 
              and date_part('year',eventdate::date) = date_part('year',current_date) 
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate) t    
            on t.personid = e.personid  
) pbebspci on pbebspci.personid = pbe.personid and pbebspci.rank = 1 
            
-----------------------------
-- VOLUNTARY ACCIDENT (13) --
-----------------------------  
left join (select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, createts, effectivedate, enddate, benefitcoverageid, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) ASC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('13') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate 
              and date_part('year',eventdate::date) >= date_part('year',current_date - interval '1 year')
              and date_part('year',effectivedate) >= date_part('year',current_date)
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, createts, effectivedate, enddate,benefitcoverageid) pbevollacd on pbevollacd.personid = pbe.personid and pbevollacd.rank = 1   

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
             from person_compensation where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1  
 
left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1         
   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('R','T')
  and pbe.benefitsubclass in ('21','2Z','2X','30','31','2C','2S','13') --and pe.personid = '2709'

  --- only need look back date on terms    

 and (greatest(pbebeevlife.effectivedate,pbe.effectivedate,pbebSPvlife.effectivedate,pbebDPvlife.effectivedate,pbestd.effectivedate,pbeltd.effectivedate,pbebeeci.effectivedate,pbebspci.effectivedate,pbevollacd.effectivedate) >= coalesce(?::timestamp::date,elu.lastupdatets::date,'2018-09-01')
  or (greatest(pbebeevlife.createts,pbe.createts,pbebSPvlife.createts,pbebDPvlife.createts,pbestd.createts,pbeltd.createts,pbebeeci.createts,pbebspci.createts,pbevollacd.createts) > coalesce(elu.lastupdatets,?::timestamp,'2018-09-01')
 and  greatest(pbebeevlife.effectivedate,pbe.effectivedate,pbebSPvlife.effectivedate,pbebDPvlife.effectivedate,pbestd.effectivedate,pbeltd.effectivedate,pbebeeci.effectivedate,pbebspci.effectivedate,pbevollacd.effectivedate) < coalesce(?::timestamp::date,elu.lastupdatets::date,'2018-08-05')) ) 
