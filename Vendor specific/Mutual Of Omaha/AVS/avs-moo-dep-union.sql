select distinct

---!!!!!!!!! this is a union active dependents 
-- BENEFITS ARE ACTIVE
-- THE ELIGIBILITY EVENT WILL BE BASED OFF BENEFIT STATUS

 pi.personid 
,2 as sort_seq 
-- DEMOGRAPHICS SEGMENT 1 - 325

,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9Y2' ::char(8) as group_id
--,'M' ::char(1) as relationship_code
-- pdr.dependentrelationship in ('D','S','C','DP','SP')
-- Relationship of Insured. Values: M = Subscriber/Member / H = Husband / W = Wife / S = Son / D = Daughter / I = Incapacitated D
,case when pdr.dependentrelationship = 'D'  then 'D'
      when pdr.dependentrelationship = 'S'  then 'S'
      when pdr.dependentrelationship = 'C'  and pvd.gendercode = 'F' then 'D'
      when pdr.dependentrelationship = 'C'  and pvd.gendercode = 'M' then 'S'
      when pdr.dependentrelationship = 'DP' and pvd.gendercode = 'F' then 'W'
      when pdr.dependentrelationship = 'DP' and pvd.gendercode = 'M' then 'H'
      when pdr.dependentrelationship = 'AC' and pvd.gendercode = 'F' then 'D'
      when pdr.dependentrelationship = 'AC' and pvd.gendercode = 'M' then 'S'         
      when pdr.dependentrelationship = 'SP' and pvd.gendercode = 'F' then 'W'
      when pdr.dependentrelationship = 'SP' and pvd.gendercode = 'M' then 'H'       
      end ::char(1) as relationship_code

,pi.identity ::char(9) as employee_id 
,pnd.lname ::char(35) as elname
,pnd.fname ::char(15) as efname
,pvd.gendercode ::char(1) as egender
,to_char(pvd.birthdate,'YYYYMMDD')::char(8) as dob
--,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh -- position 309
,null as doh

,to_char(greatest(de.effectivedate,pe.emplhiredate),'YYYYMMDD') ::char(8) as emp_eff_date -- bring forward all effective date starting at 317 to reset date 01/01/2018 do not alter dates after reset date


-- BILL GROUP DATA SEGMENT 393 - 405
---- This section should be blank for dep 3-21-2018
,null as sub_group_eff_date
,null as sub_group

-- EMPLOYMENT DATA SEGMENT 405 - 474
--,to_char(greatest(de.effectivedate,pl.effectivedate),'yyyymmdd')::char(8) as location_effective_date -- effectivedate of the subscribers location
,null as location_effective_date
,null as location_id
,null as location_description  
 

-- SALARY DATA SEGMENT 475 - 500
,null as basic_sal_eff_date -- effective date of employee's salary compensation
--,'A' ::char(1) as basic_sal_mode
,null as basic_sal_mode
,null as basic_salary_amount
-- CLASS DATA SEGMENT 608 620
---- This section should be blank for dep 3-21-2018
,null as class_eff_date 
,null as class_id
-- SMOKING STATUS SEGMENT 620 -629
---- This section should be blank for dep 3-21-2018
,null as smoker_status_effective_date
,null as smoker_indicator
-- ELIGIBILITY SEGMENTS
-- BASIC LIFE (23) 810 - 832
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,null as product_category_1
,null as pc_effective_date_1
,null as elig_event_1
,null as plan_id_1
,null as emp_only_1

-- BASIC AD&D (23) 865 - 887
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,null as product_category_a
,null as pc_effective_date_a
,null as elig_event_a
,null as plan_id_a
,null as emp_only_a

-- BASIC STD SEGMENT (32) 920 - 942
-- BASIC LTD SEGMENT (31) 975 - 997
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065

,null as product_category_3
,null as pc_effective_date_3
,null as elig_event_3
,null as plan_id_3
,null as emp_only_3
,null as pc_nom_effective_date_3
,null as pc_nom_amount_3

-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120

,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection in ('W','T')  then 'SE' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185

,case when pbebDPvlife.benefitsubclass in ('2X') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection in ('W','T') then 'SE' 
      when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) 1195 - 1239

,null as product_category_c
,null as pc_effective_date_c
,null as elig_event_c
,null as plan_id_c
,null as emp_only_c
,null as pc_nom_effective_date_c
,null as pc_nom_amount_c

-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z) 1250 - 1294

,case when pbebSPvlife.benefitsubclass in ('2Z') then 'e' else ' ' end ::char(1) as product_category_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection in ('W','T')   then 'SE' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'BTA0CSPVAL' else ' ' end ::char(10) as plan_id_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_e

-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349

,case when pbebDPvlife.benefitsubclass in ('2X') then 'd' else ' ' end ::char(1) as product_category_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection in ('W','T')  then 'SE' 
      when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'BTA0CDPVAL' else ' ' end ::char(10) as plan_id_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_d

-- PCSTD (30) 1360 - 1382

,null as product_category_Q
,null as pc_effective_date_Q
,null as elig_event_Q
,null as plan_id_Q
,null as emp_only_Q

-- VOLUNTARY LTD (31) 1415 - 1437

,null as product_category_L
,null as pc_effective_date_L
,null as elig_event_L
,null as plan_id_L
,null as emp_only_L

-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2CI,2CS) 1470 - 1514

,null as product_category_A
,null as pc_effective_date_A
,null as elig_event_A
,null as plan_id_A
,null as emp_only_A
,null as elaprv_effective_date_A
,null as elaprv_amount_A

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
--- select * from dependent_enrollment;

,case when depvolaccd.benefitsubclass in ('13') then 'g' else ' ' end ::char(1) as product_category_g
,case when depvolaccd.benefitsubclass in ('13') then to_char(depvolaccd.effectivedate,'YYYYMMDD') else null end ::char(8) as pc_effective_date_g
,case when depvolaccd.benefitsubclass in ('13') and pbe.benefitelection in ('W','T')  then 'SE' 
      when depvolaccd.benefitsubclass in ('13') and pbe.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_g
,case when depvolaccd.benefitsubclass in ('13') then '6AS000VACC' else null end ::char(10) as plan_id_g
,case when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Family' then 'A'
      when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Employee + Spouse' then 'B'
      when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Employee Only' then 'C'
      when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Employee + Children' then 'D'
      else null end ::char(1) as emp_only_g

from person_identity pi

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in  ('2Z','2X','13','2SI','2SS')
 and pbe.benefitelection = 'E'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts   
   
----- dependent data

left join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

left join dependent_enrollment de
  on de.personid = pi.personid
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

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

left join (select distinct de.personid, de.dependentid, de.benefitsubclass, de.effectivedate, de.selectedoption, pdr.dependentrelationship, bcd.benefitcoveragedesc
              from dependent_enrollment de
              join person_dependent_relationship pdr
                on pdr.personid = de.personid
               and pdr.dependentrelationship in ('D','C','S','DP','SP')
               and current_date between pdr.effectivedate and pdr.enddate
               and current_timestamp between pdr.createts and pdr.endts
              join person_bene_election pbe 
                on pbe.personid = de.personid
               and current_date between pbe.effectivedate and pbe.enddate
               and current_timestamp between pbe.createts and pbe.endts
              join benefit_coverage_desc bcd
                on bcd.benefitcoverageid = pbe.benefitcoverageid
               and current_date between bcd.effectivedate and bcd.enddate
               and current_timestamp between bcd.createts and bcd.endts               
             where current_date between de.effectivedate and de.enddate
               and current_timestamp between de.createts and de.endts
               and de.benefitsubclass in ('13')
           )depvolaccd on depvolaccd.personid = pi.personid

left join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep'
 
left join person_vitals pvD
  on pvD.personid = pdr.dependentid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  

left join person_maritalstatus pmsd
  on pmsd.personid = pdr.dependentid
 and current_date between pmsd.effectivedate and pmsd.enddate
 and current_timestamp between pmsd.createts and pmsd.endts


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pdr.dependentrelationship in ('D','S','C','DP','SP','AC')  
  and pe.emplstatus <> 'T'
  
UNION


select distinct

---!!!!!!!!! this is a union termed dependents 
-- BENEFITS MAY / MAYNOT BE ACTIVE
-- THE ELIGIBILITY EVENT WILL BE BASED OFF EMPLOYEE STATUS NOT BENEFIT STATUS
 pi.personid 
,3 as sort_seq 
-- DEMOGRAPHICS SEGMENT 1 - 325

,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9Y2' ::char(8) as group_id
--,'M' ::char(1) as relationship_code
-- pdr.dependentrelationship in ('D','S','C','DP','SP')
-- Relationship of Insured. Values: M = Subscriber/Member / H = Husband / W = Wife / S = Son / D = Daughter / I = Incapacitated D
,case when pdr.dependentrelationship = 'D' then 'D'
      when pdr.dependentrelationship = 'S' then 'S'
      when pdr.dependentrelationship = 'C'  and pvd.gendercode = 'F' then 'D'
      when pdr.dependentrelationship = 'C'  and pvd.gendercode = 'M' then 'S'
      when pdr.dependentrelationship = 'DP' and pvd.gendercode = 'F' then 'W'
      when pdr.dependentrelationship = 'DP' and pvd.gendercode = 'M' then 'H'
      when pdr.dependentrelationship = 'SP' and pvd.gendercode = 'F' then 'W'
      when pdr.dependentrelationship = 'SP' and pvd.gendercode = 'M' then 'H'      
      when pdr.dependentrelationship = 'SP' and pvd.gendercode  = 'F' and pvd.gendercode is null then 'H'
      when pdr.dependentrelationship = 'SP' and pvd.gendercode  = 'M' and pvd.gendercode is null then 'W'         
      end ::char(1) as relationship_code

,pi.identity ::char(9) as employee_id 
,pnd.lname ::char(35) as elname
,pnd.fname ::char(15) as efname
,pvd.gendercode ::char(1) as egender
,to_char(pvd.birthdate,'YYYYMMDD')::char(8) as dob
--,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh -- position 309
,null as doh
,to_char(greatest(de.effectivedate,pe.emplhiredate),'YYYYMMDD') ::char(8) as emp_eff_date -- bring forward all effective date starting at 317 to reset date 01/01/2018 do not alter dates after reset date

-- BILL GROUP DATA SEGMENT 393 - 405
---- This section should be blank for dep 3-21-2018
,null as sub_group_eff_date
,null as sub_group

-- EMPLOYMENT DATA SEGMENT 405 - 474
--,to_char(greatest(de.effectivedate,pl.effectivedate),'yyyymmdd')::char(8) as location_effective_date -- effectivedate of the subscribers location
,null as location_effective_date
,null as location_id
,null as location_description  

-- SALARY DATA SEGMENT 475 - 500

,null as basic_sal_eff_date -- effective date of employee's salary compensation
,null as basic_sal_mode
,null as basic_salary_amount
-- CLASS DATA SEGMENT 608 620
---- This section should be blank for dep 3-21-2018
,null as class_eff_date 
,null as class_id

-- SMOKING STATUS SEGMENT 620 -629
---- This section should be blank for dep 3-21-2018
,null as smoker_status_effective_date
,null as smoker_indicator

-- ELIGIBILITY SEGMENTS
-- BASIC LIFE (23) 810 - 832
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,null as product_category_1
,null as pc_effective_date_1
,null as elig_event_1
,null as plan_id_1
,null as emp_only_1

-- BASIC AD&D (23) 865 - 887
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,null as product_category_a
,null as pc_effective_date_a
,null as elig_event_a
,null as plan_id_a
,null as emp_only_a

-- BASIC STD SEGMENT (32) 920 - 942
-- BASIC LTD SEGMENT (31) 975 - 997
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065

,null as product_category_3
,null as pc_effective_date_3
,null as elig_event_3
,null as plan_id_3
,null as emp_only_3
,null as pc_nom_effective_date_3
,null as pc_nom_amount_3

-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120

,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection in ('W','T')  then 'SE' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185

,case when pbebDPvlife.benefitsubclass in ('2X') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection in ('W','T') then 'SE' 
      when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) 1195 - 1239

,null as product_category_c
,null as pc_effective_date_c
,null as elig_event_c
,null as plan_id_c
,null as emp_only_c
,null as pc_nom_effective_date_c
,null as pc_nom_amount_c

-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z) 1250 - 1294

,case when pbebSPvlife.benefitsubclass in ('2Z') then 'e' else ' ' end ::char(1) as product_category_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection in ('W','T')   then 'SE' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'BTA0CSPVAL' else ' ' end ::char(10) as plan_id_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_e
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_e

-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349

,case when pbebDPvlife.benefitsubclass in ('2X') then 'd' else ' ' end ::char(1) as product_category_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection in ('W','T')  then 'SE' 
      when pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'BTA0CDPVAL' else ' ' end ::char(10) as plan_id_d
,case when pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_d
,case when pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_d

-- PCSTD (30) 1360 - 1382

,null as product_category_Q
,null as pc_effective_date_Q
,null as elig_event_Q
,null as plan_id_Q
,null as emp_only_Q

-- VOLUNTARY LTD (31) 1415 - 1437

,null as product_category_L
,null as pc_effective_date_L
,null as elig_event_L
,null as plan_id_L
,null as emp_only_L

-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2CI,2CS) 1470 - 1514

,null as product_category_A
,null as pc_effective_date_A
,null as elig_event_A
,null as plan_id_A
,null as emp_only_A
,null as elaprv_effective_date_A
,null as elaprv_amount_A

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
--- select * from dependent_enrollment;

,case when depvolaccd.benefitsubclass in ('13') then 'g' else ' ' end ::char(1) as product_category_g
,case when depvolaccd.benefitsubclass in ('13') then to_char(depvolaccd.effectivedate,'YYYYMMDD') else null end ::char(8) as pc_effective_date_g
,case when depvolaccd.benefitsubclass in ('13') and pbe.benefitelection in ('W','T')  then 'SE' 
      when depvolaccd.benefitsubclass in ('13') and pbe.benefitelection = 'E'  then 'EN' else null end ::char(2) as elig_event_g
,case when depvolaccd.benefitsubclass in ('13') then '6AS000VACC' else null end ::char(10) as plan_id_g
,case when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Family' then 'A'
      when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Employee + Spouse' then 'B'
      when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Employee Only' then 'C'
      when depvolaccd.benefitsubclass in ('13') and depvolaccd.benefitcoveragedesc = 'Employee + Children' then 'D'
      else null end ::char(1) as emp_only_g


from person_identity pi

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in  ('2Z','2X','13','2SI','2SS')
 and pbe.benefitelection = 'E'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts   
   
----- dependent data

left join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

left join dependent_enrollment de
  on de.personid = pi.personid
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts

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

left join (select distinct de.personid, de.dependentid, de.benefitsubclass, de.effectivedate, de.selectedoption, pdr.dependentrelationship, bcd.benefitcoveragedesc
              from dependent_enrollment de
              join person_dependent_relationship pdr
                on pdr.personid = de.personid
               and pdr.dependentrelationship in ('D','C','S','DP','SP')
               and current_date between pdr.effectivedate and pdr.enddate
               and current_timestamp between pdr.createts and pdr.endts
              join person_bene_election pbe 
                on pbe.personid = de.personid
               and current_date between pbe.effectivedate and pbe.enddate
               and current_timestamp between pbe.createts and pbe.endts
              join benefit_coverage_desc bcd
                on bcd.benefitcoverageid = pbe.benefitcoverageid
               and current_date between bcd.effectivedate and bcd.enddate
               and current_timestamp between bcd.createts and bcd.endts               
             where current_date between de.effectivedate and de.enddate
               and current_timestamp between de.createts and de.endts
               and de.benefitsubclass in ('13')
           )depvolaccd on depvolaccd.personid = pi.personid

left join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep'
 
left join person_vitals pvD
  on pvD.personid = pdr.dependentid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  

left join person_maritalstatus pmsd
  on pmsd.personid = pdr.dependentid
 and current_date between pmsd.effectivedate and pmsd.enddate
 and current_timestamp between pmsd.createts and pmsd.endts

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pdr.dependentrelationship in ('D','S','C','DP','SP','AC')
  and pe.emplstatus = 'T'
 -- and pi.personid = '5300'

  