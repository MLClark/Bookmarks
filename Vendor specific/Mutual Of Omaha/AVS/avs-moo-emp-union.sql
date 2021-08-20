select distinct

---!!!!!!!!! this is a union active EMPLOYEES 
-- BENEFITS ARE ACTIVE
-- THE ELIGIBILITY EVENT WILL BE BASED OFF BENEFIT STATUS

 pi.personid 
,0 as sort_seq 
-- DEMOGRAPHICS SEGMENT 1 - 325

,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9Y2' ::char(8) as group_id
,'M' ::char(1) as relationship_code

,pi.identity ::char(9) as employee_id 
,pn.lname ::char(35) as elname
,pn.fname ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh -- position 309

--,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as emp_eff_date -- this is the members date of hire from position 309
,to_char(pbe.effectivedate,'YYYYMMDD') ::char(8) as emp_eff_date -- bring forward all effective date starting at 317 to reset date 01/01/2018 do not alter dates after reset date


-- BILL GROUP DATA SEGMENT 393 - 405
,to_char(greatest
(pbe.effectivedate
,pbelife.effectivedate
,pbevollacd.effectivedate
,pbestd.effectivedate
,pbeltd.effectivedate
,pbebeevlife.effectivedate
,pbebSPvlife.effectivedate
,pbebDPvlife.effectivedate 
,pbe2ci.effectivedate
,pbe2cs.effectivedate
,pbe2si.effectivedate
,pbe2ss.effectivedate
), 'YYYYMMDD')::char(8) as sub_group_eff_date
,'0001' ::char(4) as sub_group

-- EMPLOYMENT DATA SEGMENT 405 - 474
,to_char(greatest(pbe.effectivedate,pl.effectivedate),'yyyymmdd')::char(8) as location_effective_date -- effectivedate of the subscribers location
,case when lc.locationid = '14' then '001'
      when lc.locationid = '13' then '002'
      when lc.locationid = '16' then '003'
      when lc.locationid = '15' then '004'
      when lc.locationid = '17' then '005'
      when lc.locationid = '18' then '006'
      when lc.locationid = '10' then '006' else null end ::char(8) as location_id

,case when lc.locationid = '14' then 'Lexus Monterey Peninsula'
      when lc.locationid = '13' then 'Lexus Parts'
      when lc.locationid = '16' then 'Mid Bay Ford Lincoln'
      when lc.locationid = '15' then 'Mont. Bay Chyslr Dodge'
      when lc.locationid = '17' then 'Storelli'
      when lc.locationid = '18' then 'Victory Toyota'
      when lc.locationid = '10' then 'Victory Toyota' else null end ::char(23) as location_description  

-- SALARY DATA SEGMENT 475 - 500

,to_char(greatest(pbe.effectivedate,pc.effectivedate),'YYYYMMDD')::char(8) as basic_sal_eff_date -- effective date of employee's salary compensation
,'A' ::char(1) as basic_sal_mode
,case when pc.compamount  > 0 and pc.frequencycode = 'H' then to_char((pc.compamount  * 2080) * 100, 'FM0000000000000000 ')
      when pc1.compamount > 0 and pc1.frequencycode = 'H' then to_char((pc1.compamount * 2080) * 100, 'FM0000000000000000 ')
      else to_char(coalesce(pc.compamount,pc1.compamount) * 100, 'FM0000000000000000 ') end as basic_salary_amount
-- CLASS DATA SEGMENT 608 620

,to_char(greatest
(pbe.effectivedate
,pbelife.effectivedate
,pbevollacd.effectivedate
,pbestd.effectivedate
,pbeltd.effectivedate
,pbebeevlife.effectivedate
,pbebSPvlife.effectivedate
,pbebDPvlife.effectivedate 
,pbe2ci.effectivedate
,pbe2cs.effectivedate
,pbe2si.effectivedate
,pbe2ss.effectivedate
), 'YYYYMMDD')::char(8) as class_eff_date 

,'A001'::char(4) as class_id

-- SMOKING STATUS SEGMENT 620 -629
,to_char(greatest(pbe.effectivedate,pv.effectivedate),'yyyymmdd') ::char(8) as smoker_status_effective_date
---Values: B - Both Subscriber & Spouse Smoke ; N - Neither Smoke; S - Subscriber Only Smokes; P - Spouse Only Smokes.
,pv.smoker ::char(1) as smoker_indicator

-- ELIGIBILITY SEGMENTS
-- BASIC LIFE (23) 810 - 832
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,case when pbelife.benefitsubclass in ('23') then '1' else ' ' end ::char(1) as product_category_1
,case when pbelife.benefitsubclass in ('23') then to_char(pbelife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_1
,case when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'T'  then 'TM' 
      when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_1
,case when pbelife.benefitsubclass in ('23') then 'LTL0NCFLAT' else ' ' end ::char(10) as plan_id_1
,case when pbelife.benefitsubclass in ('23') then 'C' else ' ' end ::char(1) as emp_only_1

-- BASIC AD&D (23) 865 - 887
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,case when pbelife.benefitsubclass in ('23') then 'a' else ' ' end ::char(1) as product_category_a
,case when pbelife.benefitsubclass in ('23') then to_char(pbelife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_a
,case when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'T'  then 'TM' 
      when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_a
,case when pbelife.benefitsubclass in ('23') then 'ATA0NCFLAT' else ' ' end ::char(10) as plan_id_a
,case when pbelife.benefitsubclass in ('23') then 'C' else ' ' end ::char(1) as emp_only_a

-- BASIC STD SEGMENT (32) 920 - 942
-- BASIC LTD SEGMENT (31) 975 - 997
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065

,case when pbebeevlife.benefitsubclass in ('21') then '3' else ' ' end ::char(1) as product_category_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'T'  then 'TM' 
      when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_3
,case when pbebeevlife.benefitsubclass in ('21') then 'ETL0CEEVAL' else ' ' end ::char(10) as plan_id_3
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_3

-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120

,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'T'  then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185

,case when pbebDPvlife.benefitsubclass in ('2X') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) 1195 - 1239

,case when pbebeevlife.benefitsubclass in ('21') then 'c' else ' ' end ::char(1) as product_category_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'T'  then 'TM' 
      when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_c
,case when pbebeevlife.benefitsubclass in ('21') then 'BTA0CEEVAL' else ' ' end ::char(10) as plan_id_c
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_c

-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z) 1250 - 1294

,case when pbebSPvlife.benefitsubclass in ('2Z') then 'e' else ' ' end ::char(1) as product_category_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'T'  then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'BTA0CSPVAL' else ' ' end ::char(10) as plan_id_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_e

-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349

,case when pbebDPvlife.benefitsubclass in ('2X') then 'd' else ' ' end ::char(1) as product_category_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'BTA0CDPVAL' else ' ' end ::char(10) as plan_id_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_d

-- PCSTD (30) 1360 - 1382

,case when pbestd.benefitsubclass in ('30') then 'Q' else ' ' end ::char(1) as product_category_Q
,case when pbestd.benefitsubclass in ('30') then to_char(pbestd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_Q
,case when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'T'  then 'TM' 
      when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_Q
,case when pbestd.benefitsubclass in ('30') then 'YTS000CSAL' else ' ' end ::char(10) as plan_id_Q
,case when pbestd.benefitsubclass in ('30') then 'C' else ' ' end ::char(1) as emp_only_Q

-- VOLUNTARY LTD (31) 1415 - 1437

,case when pbeltd.benefitsubclass in ('31') then 'L' else ' ' end ::char(1) as product_category_L
,case when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_L
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_L
,case when pbeltd.benefitsubclass in ('31') then 'ZTT0CABSAL' else ' ' end ::char(10) as plan_id_L
,case when pbeltd.benefitsubclass in ('31') then 'C' else ' ' end ::char(1) as emp_only_L

-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2CI,2CS) 1470 - 1514

,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then 'A' else ' ' end ::char(1) as product_category_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then to_char(coalesce(pbe2ci.effectivedate,pbe2cs.effectivedate),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') and coalesce(pbe2ci.benefitelection,pbe2cs.benefitelection) = 'T'  then 'TM' 
      when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') and coalesce(pbe2ci.benefitelection,pbe2cs.benefitelection) = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then '3CI00EDVAB' else ' ' end ::char(10) as plan_id_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then 'C' else ' ' end ::char(1) as emp_only_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then to_char(coalesce(pbe2ci.effectivedate,pbe2cs.effectivedate),'YYYYMMDD') else ' ' end ::char(8) as elaprv_effective_date_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then to_char(coalesce(pbe2ci.coverageamount,pbe2cs.coverageamount), 'FM0000000000') else null end as elaprv_amount_A

-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2SI,2SS) 1525 - 1569

,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then 'J' else ' ' end ::char(1) as product_category_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then to_char(coalesce(pbe2si.effectivedate,pbe2ss.effectivedate),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') and coalesce(pbe2si.benefitelection,pbe2ss.benefitelection) = 'T'  then 'TM' 
      when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') and coalesce(pbe2si.benefitelection,pbe2ss.benefitelection) = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then '3CI00SPVAB' else ' ' end ::char(10) as plan_id_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then 'C' else ' ' end ::char(1) as emp_only_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then to_char(coalesce(pbe2si.effectivedate,pbe2ss.effectivedate),'YYYYMMDD') else ' ' end ::char(8) as elaprv_effective_date_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then to_char(coalesce(pbe2si.coverageamount,pbe2ss.coverageamount), 'FM0000000000') else null end as elaprv_amount_J

-- VOLUNTARY ACCIDENT (13) 1855 - 1877

,case when pbevollacd.benefitsubclass in ('13') then 'g' else ' ' end ::char(1) as product_category_g
,case when pbevollacd.benefitsubclass in ('13') then to_char(pbevollacd.effectivedate,'YYYYMMDD') else null end ::char(8) as pc_effective_date_g
,case when pbevollacd.benefitsubclass in ('13') and pbevollacd.benefitelection = 'T'  then 'TM' 
      when pbevollacd.benefitsubclass in ('13') and pbevollacd.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_g
,case when pbevollacd.benefitsubclass in ('13') then '6AS000VACC' else null end ::char(10) as plan_id_g
,case when pbevollacd.benefitsubclass in ('13') then 'C' else null end ::char(1) as emp_only_g

from person_identity pi

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_bene_election pbe
  on pbe.personid = pi.personid

left join person_bene_election pbelife
  on pbelife.personid = pi.personid
 and pbelife.benefitsubclass in ('23')
 and pbelife.benefitelection in ('E')
 and pbelife.selectedoption = 'Y' 
 and current_date between pbelife.effectivedate and pbelife.enddate
 and current_timestamp between pbelife.createts and pbelife.endts  
 
left join person_bene_election pbevollacd
  on pbevollacd.personid = pi.personid
 and pbevollacd.benefitsubclass in ('13')
 and pbevollacd.benefitelection in ('E')
 and pbevollacd.selectedoption = 'Y' 
 and current_date between pbevollacd.effectivedate and pbevollacd.enddate
 and current_timestamp between pbevollacd.createts and pbevollacd.endts   

left join person_bene_election pbestd
  on pbestd.personid = pi.personid
 and pbestd.benefitsubclass in ('30')
 and pbestd.benefitelection in ('E')
 and pbestd.selectedoption = 'Y' 
 and current_date between pbestd.effectivedate and pbestd.enddate
 and current_timestamp between pbestd.createts and pbestd.endts  
 
left join person_bene_election pbeltd
  on pbeltd.personid = pi.personid
 and pbeltd.benefitsubclass in ('31')
 and pbeltd.benefitelection in ('E')
 and pbeltd.selectedoption = 'Y' 
 and current_date between pbeltd.effectivedate and pbeltd.enddate
 and current_timestamp between pbeltd.createts and pbeltd.endts  

left join person_bene_election pbebeevlife
  on pbebeevlife.personid = pi.personid
 and pbebeevlife.benefitsubclass in ('21')
 and pbebeevlife.benefitelection in ('E')
 and pbebeevlife.selectedoption = 'Y' 
 and current_date between pbebeevlife.effectivedate and pbebeevlife.enddate
 and current_timestamp between pbebeevlife.createts and pbebeevlife.endts 
 
left join person_bene_election pbebSPvlife
  on pbebSPvlife.personid = pi.personid
 and pbebSPvlife.benefitsubclass in ('2Z')
 and pbebSPvlife.benefitelection in ('E')
 and pbebSPvlife.selectedoption = 'Y' 
 and current_date between pbebSPvlife.effectivedate and pbebSPvlife.enddate
 and current_timestamp between pbebSPvlife.createts and pbebSPvlife.endts  
 
left join person_bene_election pbebDPvlife
  on pbebDPvlife.personid = pi.personid
 and pbebDPvlife.benefitsubclass in ('2X')
 and pbebDPvlife.benefitelection in ('E')
 and pbebDPvlife.selectedoption = 'Y' 
 and current_date between pbebDPvlife.effectivedate and pbebDPvlife.enddate
 and current_timestamp between pbebDPvlife.createts and pbebDPvlife.endts   
 
left join person_bene_election pbe2ci
  on pbe2ci.personid = pi.personid
 and pbe2ci.benefitsubclass in ('2CI')
 and pbe2ci.benefitelection in ('E')
 and pbe2ci.selectedoption = 'Y' 
 and current_date between pbe2ci.effectivedate and pbe2ci.enddate
 and current_timestamp between pbe2ci.createts and pbe2ci.endts 
  
left join person_bene_election pbe2cs
  on pbe2cs.personid = pi.personid
 and pbe2cs.benefitsubclass in ('2CS')
 and pbe2cs.benefitelection in ('E')
 and pbe2cs.selectedoption = 'Y' 
 and current_date between pbe2cs.effectivedate and pbe2cs.enddate
 and current_timestamp between pbe2cs.createts and pbe2cs.endts 
  
left join person_bene_election pbe2si
  on pbe2si.personid = pi.personid
 and pbe2si.benefitsubclass in ('2SI')
 and pbe2si.benefitelection in ('E')
 and pbe2si.selectedoption = 'Y' 
 and current_date between pbe2si.effectivedate and pbe2si.enddate
 and current_timestamp between pbe2si.createts and pbe2si.endts 

left join person_bene_election pbe2ss
  on pbe2ss.personid = pi.personid
 and pbe2ss.benefitsubclass in ('2SS')
 and pbe2ss.benefitelection in ('E')
 and pbe2ss.selectedoption = 'Y' 
 and current_date between pbe2ss.effectivedate and pbe2ss.enddate
 and current_timestamp between pbe2ss.createts and pbe2ss.endts  

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts


left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.compamount > 0

--- provides missing compamounts
left join 
(select pc.personid, pc.compamount, pc.effectivedate, pc.enddate, pc.earningscode, pc.compevent, pc.frequencycode
 from person_compensation pc
 join 
(select pc.personid, pc.compamount, pc.effectivedate, pc.enddate, pc.earningscode, pc.compevent, pc.frequencycode
   from person_compensation pc
  where current_date between pc.effectivedate and pc.enddate
    and current_timestamp between pc.createts and pc.endts
    and pc.enddate = '2199-12-31'
    and pc.compamount = 0
    and pc.personid not in 
   (select personid 
      from person_compensation
     where current_date between effectivedate and enddate
       and current_timestamp between createts and endts
       and compamount > 0
       group by 1)) pcemp
   on pcemp.personid = pc.personid       
   where pc.compamount > 0)
pc1 on pc1.personid = pi.personid 

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
   
----- dependent data
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in  ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts   

  and pe.emplstatus <> 'T'
  --and pi.personid = '5194'
  
  UNION
  

select distinct

---!!!!!!!!! this is a union TERMED EMPLOYEES 
-- BENEFITS MAY / MAYNOT BE ACTIVE
-- THE ELIGIBILITY EVENT WILL BE BASED OFF EMPLOYEE STATUS NOT BENEFIT STATUS

 pi.personid 
,1 as sort_seq 
-- DEMOGRAPHICS SEGMENT 1 - 325

,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9Y2' ::char(8) as group_id
,'M' ::char(1) as relationship_code

,pi.identity ::char(9) as employee_id 
,pn.lname ::char(35) as elname
,pn.fname ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(peh.effectivedate,'YYYYMMDD') ::CHAR(8) as doh -- position 309

--,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as emp_eff_date -- this is the members date of hire from position 309
,to_char(pbe.effectivedate,'YYYYMMDD') ::char(8) as emp_eff_date -- bring forward all effective date starting at 317 to reset date 01/01/2018 do not alter dates after reset date


-- BILL GROUP DATA SEGMENT 393 - 405

,to_char(greatest
(pbe.effectivedate
,pbelife.effectivedate
,pbevollacd.effectivedate
,pbestd.effectivedate
,pbeltd.effectivedate
,pbebeevlife.effectivedate
,pbebSPvlife.effectivedate
,pbebDPvlife.effectivedate 
,pbe2ci.effectivedate
,pbe2cs.effectivedate
,pbe2si.effectivedate
,pbe2ss.effectivedate
), 'YYYYMMDD')::char(8) as sub_group_eff_date
,'0001' ::char(4) as sub_group

-- EMPLOYMENT DATA SEGMENT 405 - 474
,to_char(greatest(pbe.effectivedate,pl.effectivedate),'yyyymmdd')::char(8) as location_effective_date -- effectivedate of the subscribers location

,case when lc.locationid = '14' then '001'
      when lc.locationid = '13' then '002'
      when lc.locationid = '16' then '003'
      when lc.locationid = '15' then '004'
      when lc.locationid = '17' then '005'
      when lc.locationid = '18' then '006'
      when lc.locationid = '10' then '006' else null end ::char(8) as location_id

,case when lc.locationid = '14' then 'Lexus Monterey Peninsula'
      when lc.locationid = '13' then 'Lexus Parts'
      when lc.locationid = '16' then 'Mid Bay Ford Lincoln'
      when lc.locationid = '15' then 'Mont. Bay Chyslr Dodge'
      when lc.locationid = '17' then 'Storelli'
      when lc.locationid = '18' then 'Victory Toyota'
      when lc.locationid = '10' then 'Victory Toyota' else null end ::char(23) as location_description  

-- SALARY DATA SEGMENT 475 - 500

,to_char(greatest(pbe.effectivedate,pc.effectivedate),'YYYYMMDD')::char(8) as basic_sal_eff_date
,'A' ::char(1) as basic_sal_mode
,case when pc.frequencycode = 'H' then to_char((pc.compamount * 2080) * 100, 'FM0000000000000000 ')
      else to_char(pc.compamount * 100, 'FM0000000000000000 ') end as basic_salary_amount -- assume decimal zero filled 
-- CLASS DATA SEGMENT 608 620


,to_char(greatest
(pbe.effectivedate
,pbelife.effectivedate
,pbevollacd.effectivedate
,pbestd.effectivedate
,pbeltd.effectivedate
,pbebeevlife.effectivedate
,pbebSPvlife.effectivedate
,pbebDPvlife.effectivedate 
,pbe2ci.effectivedate
,pbe2cs.effectivedate
,pbe2si.effectivedate
,pbe2ss.effectivedate
), 'YYYYMMDD')::char(8) as class_eff_date 
,'A001'::char(4) as class_id

-- SMOKING STATUS SEGMENT 620 -629
,to_char(greatest(pbe.effectivedate,pv.effectivedate),'yyyymmdd') ::char(8) as smoker_status_effective_date
---Values: B - Both Subscriber & Spouse Smoke ; N - Neither Smoke; S - Subscriber Only Smokes; P - Spouse Only Smokes.
,pv.smoker ::char(1) as smoker_indicator

-- ELIGIBILITY SEGMENTS
-- BASIC LIFE (23) 810 - 832
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,case when pbelife.benefitsubclass in ('23') then '1' else ' ' end ::char(1) as product_category_1
,case when pbelife.benefitsubclass in ('23') then to_char(pbelife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_1
,case when pbelife.benefitsubclass in ('23') and PE.EMPLSTATUS = 'T'  then 'TM' 
      when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_1
,case when pbelife.benefitsubclass in ('23') then 'LTL0NCFLAT' else ' ' end ::char(10) as plan_id_1
,case when pbelife.benefitsubclass in ('23') then 'C' else ' ' end ::char(1) as emp_only_1

-- BASIC AD&D (23) 865 - 887
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,case when pbelife.benefitsubclass in ('23') then 'a' else ' ' end ::char(1) as product_category_a
,case when pbelife.benefitsubclass in ('23') then to_char(pbelife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_a
,case when pbelife.benefitsubclass in ('23') and PE.EMPLSTATUS = 'T'  then 'TM' 
      when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_a
,case when pbelife.benefitsubclass in ('23') then 'ATA0NCFLAT' else ' ' end ::char(10) as plan_id_a
,case when pbelife.benefitsubclass in ('23') then 'C' else ' ' end ::char(1) as emp_only_a

-- BASIC STD SEGMENT (32) 920 - 942
-- BASIC LTD SEGMENT (31) 975 - 997
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065

,case when pbebeevlife.benefitsubclass in ('21') then '3' else ' ' end ::char(1) as product_category_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') and PE.EMPLSTATUS  = 'T'  then 'TM' 
      when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_3
,case when pbebeevlife.benefitsubclass in ('21') then 'ETL0CEEVAL' else ' ' end ::char(10) as plan_id_3
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_3

-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120

,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and PE.EMPLSTATUS = 'T'  then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185

,case when pbebDPvlife.benefitsubclass in ('2X') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') and PE.EMPLSTATUS = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) 1195 - 1239

,case when pbebeevlife.benefitsubclass in ('21') then 'c' else ' ' end ::char(1) as product_category_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') and PE.EMPLSTATUS  = 'T'  then 'TM' 
      when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_c
,case when pbebeevlife.benefitsubclass in ('21') then 'BTA0CEEVAL' else ' ' end ::char(10) as plan_id_c
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_c
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_c

-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z) 1250 - 1294

,case when pbebSPvlife.benefitsubclass in ('2Z') then 'e' else ' ' end ::char(1) as product_category_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') and PE.EMPLSTATUS  = 'T'  then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'BTA0CSPVAL' else ' ' end ::char(10) as plan_id_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_e

-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349

,case when pbebDPvlife.benefitsubclass in ('2X') then 'd' else ' ' end ::char(1) as product_category_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') and PE.EMPLSTATUS = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'BTA0CDPVAL' else ' ' end ::char(10) as plan_id_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_d

-- PCSTD (30) 1360 - 1382

,case when pbestd.benefitsubclass in ('30') then 'Q' else ' ' end ::char(1) as product_category_Q
,case when pbestd.benefitsubclass in ('30') then to_char(pbestd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_Q
,case when pbestd.benefitsubclass in ('30') and PE.EMPLSTATUS = 'T'  then 'TM' 
      when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_Q
,case when pbestd.benefitsubclass in ('30') then 'YTS000CSAL' else ' ' end ::char(10) as plan_id_Q
,case when pbestd.benefitsubclass in ('30') then 'C' else ' ' end ::char(1) as emp_only_Q

-- VOLUNTARY LTD (31) 1415 - 1437

,case when pbeltd.benefitsubclass in ('31') then 'L' else ' ' end ::char(1) as product_category_L
,case when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_L
,case when pbeltd.benefitsubclass in ('31') and PE.EMPLSTATUS  = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_L
,case when pbeltd.benefitsubclass in ('31') then 'ZTT0CABSAL' else ' ' end ::char(10) as plan_id_L
,case when pbeltd.benefitsubclass in ('31') then 'C' else ' ' end ::char(1) as emp_only_L

-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2CI,2CS) 1470 - 1514

,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then 'A' else ' ' end ::char(1) as product_category_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then to_char(coalesce(pbe2ci.effectivedate,pbe2cs.effectivedate),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') and PE.EMPLSTATUS = 'T'  then 'TM' 
      when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') and coalesce(pbe2ci.benefitelection,pbe2cs.benefitelection) = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then '3CI00EDVAB' else ' ' end ::char(10) as plan_id_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then 'C' else ' ' end ::char(1) as emp_only_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then to_char(coalesce(pbe2ci.effectivedate,pbe2cs.effectivedate),'YYYYMMDD') else ' ' end ::char(8) as elaprv_effective_date_A
,case when coalesce(pbe2ci.benefitsubclass,pbe2cs.benefitsubclass) in ('2CI','2CS') then to_char(coalesce(pbe2ci.coverageamount,pbe2cs.coverageamount), 'FM0000000000') else null end as elaprv_amount_A

-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2SI,2SS) 1525 - 1569

,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then 'J' else ' ' end ::char(1) as product_category_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then to_char(coalesce(pbe2si.effectivedate,pbe2ss.effectivedate),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') and PE.EMPLSTATUS = 'T'  then 'TM' 
      when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') and coalesce(pbe2si.benefitelection,pbe2ss.benefitelection) = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then '3CI00SPVAB' else ' ' end ::char(10) as plan_id_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then 'C' else ' ' end ::char(1) as emp_only_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then to_char(coalesce(pbe2si.effectivedate,pbe2ss.effectivedate),'YYYYMMDD') else ' ' end ::char(8) as elaprv_effective_date_J
,case when coalesce(pbe2si.benefitsubclass,pbe2ss.benefitsubclass) in ('2SI','2SS') then to_char(coalesce(pbe2si.coverageamount,pbe2ss.coverageamount), 'FM0000000000') else null end as elaprv_amount_J

-- VOLUNTARY ACCIDENT (13) 1855 - 1877

,case when pbevollacd.benefitsubclass in ('13') then 'g' else ' ' end ::char(1) as product_category_g
,case when pbevollacd.benefitsubclass in ('13') then to_char(pbevollacd.effectivedate,'YYYYMMDD') else null end ::char(8) as pc_effective_date_g
,case when pbevollacd.benefitsubclass in ('13') and pbevollacd.benefitelection = 'T'  then 'TM' 
      when pbevollacd.benefitsubclass in ('13') and pbevollacd.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_g
,case when pbevollacd.benefitsubclass in ('13') then '6AS000VACC' else null end ::char(10) as plan_id_g
,case when pbevollacd.benefitsubclass in ('13') then 'C' else null end ::char(1) as emp_only_g


from person_identity pi

left join person_bene_election pbe
  on pbe.personid = pi.personid

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_employment peH
  on peH.personid = pi.personid
 and current_timestamp between peH.createts and peH.endts  
 and peH.emplstatus = 'A'
 
left join person_bene_election pbelife
  on pbelife.personid = pi.personid
 and pbelife.benefitsubclass in ('23')
 and pbelife.benefitelection in ('E','T')
 and pbelife.selectedoption = 'Y' 
 and current_date between pbelife.effectivedate and pbelife.enddate
 and current_timestamp between pbelife.createts and pbelife.endts  
 
left join person_bene_election pbevollacd
  on pbevollacd.personid = pi.personid
 and pbevollacd.benefitsubclass in ('13')
 and pbevollacd.benefitelection in ('E','T')
 and pbevollacd.selectedoption = 'Y' 
 and current_date between pbevollacd.effectivedate and pbevollacd.enddate
 and current_timestamp between pbevollacd.createts and pbevollacd.endts   

left join person_bene_election pbestd
  on pbestd.personid = pi.personid
 and pbestd.benefitsubclass in ('30')
 and pbestd.benefitelection in ('E','T')
 and pbestd.selectedoption = 'Y' 
 and current_date between pbestd.effectivedate and pbestd.enddate
 and current_timestamp between pbestd.createts and pbestd.endts  
 
left join person_bene_election pbeltd
  on pbeltd.personid = pi.personid
 and pbeltd.benefitsubclass in ('31')
 and pbeltd.benefitelection in ('E','T')
 and pbeltd.selectedoption = 'Y' 
 and current_date between pbeltd.effectivedate and pbeltd.enddate
 and current_timestamp between pbeltd.createts and pbeltd.endts  

left join person_bene_election pbebeevlife
  on pbebeevlife.personid = pi.personid
 and pbebeevlife.benefitsubclass in ('21')
 and pbebeevlife.benefitelection in ('E','T')
 and pbebeevlife.selectedoption = 'Y' 
 and current_date between pbebeevlife.effectivedate and pbebeevlife.enddate
 and current_timestamp between pbebeevlife.createts and pbebeevlife.endts 
 
left join person_bene_election pbebSPvlife
  on pbebSPvlife.personid = pi.personid
 and pbebSPvlife.benefitsubclass in ('2Z')
 and pbebSPvlife.benefitelection in ('E','T')
 and pbebSPvlife.selectedoption = 'Y' 
 and current_date between pbebSPvlife.effectivedate and pbebSPvlife.enddate
 and current_timestamp between pbebSPvlife.createts and pbebSPvlife.endts  
 
left join person_bene_election pbebDPvlife
  on pbebDPvlife.personid = pi.personid
 and pbebDPvlife.benefitsubclass in ('2X')
 and pbebDPvlife.benefitelection in ('E','T')
 and pbebDPvlife.selectedoption = 'Y' 
 and current_date between pbebDPvlife.effectivedate and pbebDPvlife.enddate
 and current_timestamp between pbebDPvlife.createts and pbebDPvlife.endts   
 
left join person_bene_election pbe2ci
  on pbe2ci.personid = pi.personid
 and pbe2ci.benefitsubclass in ('2CI')
 and pbe2ci.benefitelection in ('E','T')
 and pbe2ci.selectedoption = 'Y' 
 and current_date between pbe2ci.effectivedate and pbe2ci.enddate
 and current_timestamp between pbe2ci.createts and pbe2ci.endts 
  
left join person_bene_election pbe2cs
  on pbe2cs.personid = pi.personid
 and pbe2cs.benefitsubclass in ('2CS')
 and pbe2cs.benefitelection in ('E','T')
 and pbe2cs.selectedoption = 'Y' 
 and current_date between pbe2cs.effectivedate and pbe2cs.enddate
 and current_timestamp between pbe2cs.createts and pbe2cs.endts 
  
left join person_bene_election pbe2si
  on pbe2si.personid = pi.personid
 and pbe2si.benefitsubclass in ('2SI')
 and pbe2si.benefitelection in ('E','T')
 and pbe2si.selectedoption = 'Y' 
 and current_date between pbe2si.effectivedate and pbe2si.enddate
 and current_timestamp between pbe2si.createts and pbe2si.endts 

left join person_bene_election pbe2ss
  on pbe2ss.personid = pi.personid
 and pbe2ss.benefitsubclass in ('2SS')
 and pbe2ss.benefitelection in ('E','T')
 and pbe2ss.selectedoption = 'Y' 
 and current_date between pbe2ss.effectivedate and pbe2ss.enddate
 and current_timestamp between pbe2ss.createts and pbe2ss.endts  

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join person_compensation pc
  on pc.personid = pi.personid
 and current_timestamp between pc.createts and pc.endts
 and pc.compamount > 0
  
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
   
----- dependent data

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E','T')
  and pbe.benefitsubclass in  ('30','31','21','2Z','2X','2CI','2CS','2SI','2SS','23','13')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts   

  and pe.emplstatus = 'T'
  