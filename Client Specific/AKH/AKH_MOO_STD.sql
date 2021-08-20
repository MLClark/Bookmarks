select distinct
 pi.personid 
,0 as sort_seq 
-- DEMOGRAPHICS SEGMENT 1 - 325

,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000ADZ5' ::char(8) as group_id
,'M' ::char(1) as relationship_code

,pi.identity ::char(9) as employee_id 
,pn.lname ::char(35) as elname
,pn.fname ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh
,to_char(pbe_max.effectivedate, 'YYYYMMDD')::char(8) as emp_eff_date -- position 317 date

-- BILL GROUP DATA SEGMENT 393 - 405

,to_char(greatest(pbe.effectivedate,pbeltd.effectivedate,pbestd.effectivedate), 'YYYYMMDD')::char(8) as sub_group_eff_date
,'0001' ::char(4) as sub_group

-- SALARY DATA SEGMENT 475 - 500

,to_char(pbe_max.effectivedate, 'YYYYMMDD')::char(8) as basic_sal_eff_date
--,case when pc.frequencycode = 'H' then 'H' else 'A' end ::char(1) as basic_sal_mode
,'A' ::char(1) as basic_sal_mode

--,to_char(pc.compamount * 100, 'FM00000000000') as basic_salary_amount
,case when pc.frequencycode = 'H' then to_char((pc.compamount * 2080), 'FM00000000000')
      else to_char(pc.compamount * 100, 'FM00000000000') end as basic_salary_amount

-- CLASS DATA SEGMENT 608 620

,to_char(greatest(pbe.effectivedate,pbeltd.effectivedate,pbestd.effectivedate), 'YYYYMMDD')::char(8) as class_eff_date -- position 317 date
,case when pbe.benefitelection = 'E' then 'A003' else 'A004' end ::char(4) as class_id

-- ELIGIBILITY SEGMENTS
-- BASIC LIFE (20) 810 - 832

,case when pbeblife.benefitsubclass in ('20') then '1' else ' ' end ::char(1) as product_category_1
,case when pbeblife.benefitsubclass in ('20') then to_char(pbeblife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_1
,case when pbeblife.benefitsubclass in ('20') and pbeblife.benefitelection = 'T'  then 'TM' 
      when pbeblife.benefitsubclass in ('20') and pbeblife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_1
,case when pbeblife.benefitsubclass in ('20') then 'LTL0NCFLAT' else ' ' end ::char(10) as plan_id_1
,case when pbeblife.benefitsubclass in ('20') then 'C' else ' ' end ::char(1) as emp_only_1

-- BASIC AD&D (22) 865 - 887

,case when pbeadd.benefitsubclass in ('22') then 'a' else ' ' end ::char(1) as product_category_a
,case when pbeadd.benefitsubclass in ('22') then to_char(pbeadd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_a
,case when pbeadd.benefitsubclass in ('22') and pbeadd.benefitelection = 'T'  then 'TM' 
      when pbeadd.benefitsubclass in ('22') and pbeadd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_a
,case when pbeadd.benefitsubclass in ('22') then 'ATA0NCFLAT' else ' ' end ::char(10) as plan_id_a
,case when pbeadd.benefitsubclass in ('22') then 'C' else ' ' end ::char(1) as emp_only_a

-- BASIC STD SEGMENT (32) 920 - 942

,case when pbestd.benefitsubclass in ('32') then 'S' else ' ' end ::char(1) as product_category_S
,case when pbestd.benefitsubclass in ('32') then to_char(pbestd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_s
,case when pbestd.benefitsubclass in ('32') and pbestd.benefitelection = 'T'  then 'TM' 
      when pbestd.benefitsubclass in ('32') and pbestd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_s
,case when pbestd.benefitsubclass in ('32') then 'STS00NCSAL' else ' ' end ::char(10) as plan_id_s
,case when pbestd.benefitsubclass in ('32') then 'C' else ' ' end ::char(1) as emp_only_s

-- BASIC LTD SEGMENT (31) 975 - 997

,case when pbeltd.benefitsubclass in ('31') then 'T' else ' ' end ::char(1) as product_category_t
,case when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_t
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_t
,case when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' else ' ' end ::char(10) as plan_id_t
,case when pbeltd.benefitsubclass in ('31') then 'C' else ' ' end ::char(1) as emp_only_t

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

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (25) 1140 - 1185

,case when pbebDPvlife.benefitsubclass in ('25') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

from person_identity pi

left join person_bene_election pbe
  on pbe.personid = pi.personid

left join 
     (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('32','31','22','20','21','2Z','25')
         and benefitelection in ('E')
       group by 1) pbe_max
  on pbe_max.personid = pi.personid
 
left join person_bene_election pbestd
  on pbestd.personid = pi.personid
 and pbestd.benefitsubclass in ('32')
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
 
left join person_bene_election pbeadd
  on pbeadd.personid = pi.personid
 and pbeadd.benefitsubclass in ('22')
 and pbeadd.benefitelection in ('E')
 and pbeadd.selectedoption = 'Y' 
 and current_date between pbeadd.effectivedate and pbeadd.enddate
 and current_timestamp between pbeadd.createts and pbeadd.endts   
 
left join person_bene_election pbeblife
  on pbeblife.personid = pi.personid
 and pbeblife.benefitsubclass in ('20')
 and pbeblife.benefitelection in ('E')
 and pbeblife.selectedoption = 'Y' 
 and current_date between pbeblife.effectivedate and pbeblife.enddate
 and current_timestamp between pbeblife.createts and pbeblife.endts  
  
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
 and pbebDPvlife.benefitsubclass in ('25')
 and pbebDPvlife.benefitelection in ('E')
 and pbebDPvlife.selectedoption = 'Y' 
 and current_date between pbebDPvlife.effectivedate and pbebDPvlife.enddate
 and current_timestamp between pbebDPvlife.createts and pbebDPvlife.endts   
  
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join person_compensation pc
  on pc.personid = pi.personid
 and pc.earningscode in ('ExcHrly','RegHrly','Regular' )
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 
LEFT JOIN person_payroll ppay
  ON ppay.personid = pi.personid
 AND current_date BETWEEN ppay.effectivedate AND ppay.enddate
 AND current_timestamp BETWEEN ppay.createts AND ppay.endts      

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppay.payunitid

LEFT JOIN frequency_codes fc
  ON fc.frequencycode = pu.frequencycode
   
----- dependent data

left join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and pdr.dependentrelationship in ('D','C','DP','SP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

left join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.personid = pi.personid
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
 
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
  on pvD.personid = piD.personid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  

left join person_maritalstatus pmsd
  on pmsd.personid = pdr.dependentid
 and current_date between pmsd.effectivedate and pmsd.enddate
 and current_timestamp between pmsd.createts and pmsd.endts


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in ('32','31','22','20','21','2Z','25')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts   
  --and pi.personid in ('8654')
  --and pi.personid in ('8335', '8056','8592','8060','7596')
  and pe.emplstatus <> 'T'

union 

select distinct
 pi.personid 
,case when pdr.dependentrelationship = 'SP' then 2 else 3 end as sort_seq     
-- DEMOGRAPHICS SEGMENT 1 - 325

,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000ADZ5' ::char(8) as group_id
--,'M' ::char(1) as relationship_code
-- pdr.dependentrelationship ('S','D','C','DP','SP','FC')
,case when pdr.dependentrelationship = 'D' then 'D'
      when pdr.dependentrelationship = 'S' then 'S'
      when pdr.dependentrelationship = 'C'  and pvd.gendercode = 'M' then 'S'
      when pdr.dependentrelationship = 'C'  and pvd.gendercode = 'F' then 'D'
      when pdr.dependentrelationship = 'FC' and pvd.gendercode = 'M' then 'S' 
      when pdr.dependentrelationship = 'FC' and pvd.gendercode = 'F' then 'D' 
      when pdr.dependentrelationship = 'DP' and pvd.gendercode = 'M' then 'S' 
      when pdr.dependentrelationship = 'DP' and pvd.gendercode = 'F' then 'D' 
      when pdr.dependentrelationship = 'SP' and pvd.gendercode = 'M' then 'H'
      when pdr.dependentrelationship = 'SP' and pvd.gendercode = 'F' then 'W'
      else null end ::char(1) as relationship_code
 
,pid.identity ::char(9) as employee_id 
,pnd.lname ::char(35) as elname
,pnd.fname ::char(15) as efname
,pvd.gendercode ::char(1) as egender
,to_char(pvd.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh
,to_char(greatest(pbe.effectivedate,pbeltd.effectivedate,pbestd.effectivedate), 'YYYYMMDD')::char(8) as emp_eff_date -- position 317 date

-- BILL GROUP DATA SEGMENT 393 - 405

,to_char(greatest(pbe.effectivedate,pbeltd.effectivedate,pbestd.effectivedate), 'YYYYMMDD')::char(8) as sub_group_eff_date
,'0001' ::char(4) as sub_group

-- SALARY DATA SEGMENT 475 - 500

,' '::char(8) as basic_sal_eff_date
--,case when pc.frequencycode = 'H' then 'H' else 'A' end ::char(1) as basic_sal_mode
,' ' ::char(1) as basic_sal_mode

,to_char(0, 'FM00000000000') as basic_salary_amount

-- CLASS DATA SEGMENT 608 620

,to_char(greatest(pbe.effectivedate,pbeltd.effectivedate,pbestd.effectivedate), 'YYYYMMDD')::char(8) as class_eff_date -- position 317 date
,case when pbe.benefitelection = 'E' then 'A003' else 'A004' end ::char(4) as class_id

-- ELIGIBILITY SEGMENTS
-- BASIC LIFE (20) 810 - 832

,' ' ::char(1) as product_category_1
,' ' ::char(8) as pc_effective_date_1
,' ' ::char(2) as elig_event_1
,' ' ::char(10) as plan_id_1
,' ' ::char(1) as emp_only_1

-- BASIC AD&D (22) 865 - 887

,' ' ::char(1) as product_category_a
,' ' ::char(8) as pc_effective_date_a
,' ' ::char(2) as elig_event_a
,' ' ::char(10) as plan_id_a
,' ' ::char(1) as emp_only_a

-- BASIC STD SEGMENT (32) 920 - 942

,' ' ::char(1) as product_category_S
,' ' ::char(8) as pc_effective_date_s
,' ' ::char(2) as elig_event_s
,' ' ::char(10) as plan_id_s
,' ' ::char(1) as emp_only_s

-- BASIC LTD SEGMENT (31) 975 - 997

,' ' ::char(1) as product_category_t
,' ' ::char(8) as pc_effective_date_t
,' ' ::char(2) as elig_event_t
,' ' ::char(10) as plan_id_t
,' ' ::char(1) as emp_only_t

-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065

,' ' ::char(1) as product_category_3
,' ' ::char(8) as pc_effective_date_3
,' ' ::char(2) as elig_event_3
,' ' ::char(10) as plan_id_3
,' ' ::char(1) as emp_only_3
,' ' ::char(8) as pc_nom_effective_date_3
,null as pc_nom_amount_3

-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120

,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'T'  then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (25) 1140 - 1185

,case when pbebDPvlife.benefitsubclass in ('25') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

from person_identity pi

left join person_bene_election pbe
  on pbe.personid = pi.personid

left join 
     (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('2Z','25')
         and benefitelection in ('E')
       group by 1) pbe_max
  on pbe_max.personid = pi.personid
 
left join person_bene_election pbestd
  on pbestd.personid = pi.personid
 and pbestd.benefitsubclass in ('32')
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
 
left join person_bene_election pbeadd
  on pbeadd.personid = pi.personid
 and pbeadd.benefitsubclass in ('22')
 and pbeadd.benefitelection in ('E')
 and pbeadd.selectedoption = 'Y' 
 and current_date between pbeadd.effectivedate and pbeadd.enddate
 and current_timestamp between pbeadd.createts and pbeadd.endts   
 
left join person_bene_election pbeblife
  on pbeblife.personid = pi.personid
 and pbeblife.benefitsubclass in ('20')
 and pbeblife.benefitelection in ('E')
 and pbeblife.selectedoption = 'Y' 
 and current_date between pbeblife.effectivedate and pbeblife.enddate
 and current_timestamp between pbeblife.createts and pbeblife.endts  
  
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
 and pbebDPvlife.benefitsubclass in ('25')
 and pbebDPvlife.benefitelection in ('E')
 and pbebDPvlife.selectedoption = 'Y' 
 and current_date between pbebDPvlife.effectivedate and pbebDPvlife.enddate
 and current_timestamp between pbebDPvlife.createts and pbebDPvlife.endts   
  
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join person_compensation pc
  on pc.personid = pi.personid
 and pc.earningscode in ('ExcHrly','RegHrly','Regular' )
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 
LEFT JOIN person_payroll ppay
  ON ppay.personid = pi.personid
 AND current_date BETWEEN ppay.effectivedate AND ppay.enddate
 AND current_timestamp BETWEEN ppay.createts AND ppay.endts      

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppay.payunitid

LEFT JOIN frequency_codes fc
  ON fc.frequencycode = pu.frequencycode
   
----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pi.personid
-- and pdr.dependentrelationship in ('S','D','C','DP','SP','FC')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 -- select dependentrelationship from person_dependent_relationship group by 1;
 -- select * from dependent_relationship;

left join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.personid = pi.personid
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
 
left join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep'
 
join person_vitals pvD
  on pvD.personid = piD.personid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts 

left join person_maritalstatus pmsd
  on pmsd.personid = pdr.dependentid
 and current_date between pmsd.effectivedate and pmsd.enddate
 and current_timestamp between pmsd.createts and pmsd.endts

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in ('2Z','25')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts   
  and pe.emplstatus <> 'T'
--  and pdr.dependentrelationship in ('S','D','C','DP','SP','FC')
  and pdr.dependentrelationship in ('SP') --- if they don't want demographic data on dependents
  
  order by 1,2