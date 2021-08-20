select distinct
 PI.PERSONID
,'ACTIVE DEP CHILDREN BENEFIT' ::VARCHAR(20) AS SOURCESEQ 
,case when pdr.dependentrelationship = 'SP' then 2 else 3 end as sort_seq    
-- DEMOGRAPHICS SEGMENT 1 - 325

,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9K3' ::char(8) as group_id
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

,pi.identity ::char(9) as employee_id 
,pnd.lname ::char(35) as elname
,pnd.fname ::char(15) as efname
,pvd.gendercode ::char(1) as egender
,to_char(pvd.birthdate,'YYYYMMDD')::char(8) as dob
-- Address fields are only required if Dental is covered, but can be provided for all if easier
,case when pbedent.benefitsubclass = '11' then pa.streetaddress else ' '  end ::char(30) as addr1
,case when pbedent.benefitsubclass = '11' then pa.streetaddress2 else ' ' end ::char(30) as addr2
,case when pbedent.benefitsubclass = '11' then pa.city else ' ' end ::char(19) as city
,case when pbedent.benefitsubclass = '11' then pa.stateprovincecode else ' ' end ::char(2) state
,case when pbedent.benefitsubclass = '11' then pa.postalcode else ' ' end ::char(11) as zip

,null as doh -- position 309

,to_char(greatest
(pe.empllasthiredate
,pbedent.effectivedate
,pbebDPvlife.effectivedate 
), 'YYYYMMDD')::char(8) as emp_eff_date -- Either 1/1/18 (Benefit Plan Year) or Last Hired Date, whichever is greater

-- BILL GROUP DATA SEGMENT 393 - 405
,null as sub_group_eff_date
,null as sub_group

-- EMPLOYMENT DATA SEGMENT 405 - 474

-- SALARY DATA SEGMENT 475 - 527

,null as basic_sal_eff_date

,null as basic_sal_mode

,null as basic_salary_amount

,' ' ::char(2) as first_add_comp_type
,' ' ::char(16) as first_add_comp_amt

      
-- CLASS DATA SEGMENT 608 620

,null as class_eff_date 
,null as class_id 

--,age(current_date,pe.effectivedate) as age
--- dental late entrant waiting period indicator
,' ' ::char(1) as dent_prd_wait_prd

-- SMOKING STATUS SEGMENT 620 -629


-- ELIGIBILITY SEGMENTS
-- DENTAL (11) 755 - 777
,' ' ::char(1) as product_category_D
,' ' ::char(8) as pc_effective_date_D
,' ' ::char(2) as elig_event_D
,' ' ::char(10) as plan_id_D
,' ' ::char(1) as emp_only_D

-- BASIC LIFE (20) 810 - 832
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,' ' ::char(1) as product_category_1
,' ' ::char(8) as pc_effective_date_1
,' ' ::char(2) as elig_event_1
,' ' ::char(10) as plan_id_1
,' ' ::char(1) as emp_only_1

-- BASIC AD&D (20) 865 - 887
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,' ' ::char(1) as product_category_a
,' ' ::char(8) as pc_effective_date_a
,' ' ::char(2) as elig_event_a
,' ' ::char(10) as plan_id_a
,' ' ::char(1) as emp_only_a

-- BASIC STD SEGMENT (30) 920 - 942
,' ' ::char(1) as product_category_S
,' ' ::char(8) as pc_effective_date_S
,' ' ::char(2) as elig_event_S
,' ' ::char(10) as plan_id_S
,' ' ::char(1) as emp_only_S

-- BASIC LTD SEGMENT (31) 975 - 997
,' ' ::char(1) as product_category_T
,' ' ::char(8) as pc_effective_date_T
,' ' ::char(2) as elig_event_T
,' ' ::char(10) as plan_id_T
,' ' ::char(1) as emp_only_T

-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065
,' ' ::char(1) as product_category_3
,' ' ::char(8) as pc_effective_date_3
,' ' ::char(2) as elig_event_3
,' ' ::char(10) as plan_id_3
,' ' ::char(1) as emp_only_3
,' ' ::char(8) as pc_nom_effective_date_3
,null as pc_nom_amount_3

-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120
,' ' ::char(1) as product_category_4
,' ' ::char(8) as pc_effective_date_4
,' ' ::char(2) as elig_event_4
,' ' ::char(10) as plan_id_4
,' ' ::char(1) as emp_only_4
,' ' ::char(8) as pc_nom_effective_date_4
,null as pc_nom_amount_4

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185
,' ' ::char(1) as product_category_5
,' ' ::char(8) as pc_effective_date_5
,' ' ::char(2) as elig_event_5
,' ' ::char(10) as plan_id_5
,' ' ::char(1) as emp_only_5
,' ' ::char(8) as pc_nom_effective_date_5
,null as pc_nom_amount_5

-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) 1195 - 1239

-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z) 1250 - 1294

-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349

-- PCSTD (30) 1360 - 1382

-- VOLUNTARY LTD (31) 1415 - 1437

-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2CI,2CS) 1470 - 1514

-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2SI,2SS) 1525 - 1569

-- VOLUNTARY ACCIDENT (13) 1855 - 1877

from person_identity pi

join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.effectivedate is not null
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('11','25')
 and pbe.selectedoption = 'Y' 
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts   

left join person_bene_election pbedent
  on pbedent.personid = pi.personid
 and pbedent.benefitsubclass in ('11')
 and pbedent.benefitelection  <> 'W'
 and pbedent.selectedoption = 'Y' 
 and current_date between pbedent.effectivedate and pbedent.enddate
 and current_timestamp between pbedent.createts and pbedent.endts  


left join person_bene_election pbebDPvlife
  on pbebDPvlife.personid = pi.personid
 and pbebDPvlife.benefitsubclass in ('25')
 and pbebDPvlife.benefitelection <> 'W'
 and pbebDPvlife.selectedoption = 'Y' 
 and current_date between pbebDPvlife.effectivedate and pbebDPvlife.enddate
 and current_timestamp between pbebDPvlife.createts and pbebDPvlife.endts   

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

  
----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.personid = pbe.personid
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
  and pe.emplstatus <> 'T'
  and (pdr.dependentrelationship in ('S','D','C','NC','ND','NS') and pvd.birthdate > current_date - interval '26 years')  
  and pe.personid = '310'