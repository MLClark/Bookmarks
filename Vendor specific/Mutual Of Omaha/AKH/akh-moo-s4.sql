select distinct
 pi.personid 
,case when pdr.dependentrelationship = 'SP' then 2 else 3 end as sort_seq  
,'Termed EE Dep' ::varchar(30) as sourceseq 
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
 
,pi.identity ::char(9) as employee_id 
,pnd.lname ::char(35) as elname
,pnd.fname ::char(15) as efname
,pvd.gendercode ::char(1) as egender
,to_char(pvd.birthdate,'YYYYMMDD')::char(8) as dob
,null as doh
,to_char(greatest(pbe.effectivedate,pbeltd.effectivedate,pbestd.effectivedate), 'YYYYMMDD')::char(8) as emp_eff_date -- position 317 date

-- BILL GROUP DATA SEGMENT 393 - 405

,null as sub_group_eff_date
,null as sub_group

-- SALARY DATA SEGMENT 475 - 500

,null as basic_sal_eff_date
--,case when pc.frequencycode = 'H' then 'H' else 'A' end ::char(1) as basic_sal_mode
,null as basic_sal_mode

,null as basic_salary_amount

-- CLASS DATA SEGMENT 608 620

,null as class_eff_date 
,null as class_id


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

,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection in ('W','T')  then 'SE' 
      when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pdr.dependentrelationship = 'SP' and pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185

,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('25') then '5' else ' ' end ::char(1) as product_category_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection in ('W','T') then 'SE' 
      when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('25') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('25') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pdr.dependentrelationship <> 'SP' and pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5


from person_identity pi

left join person_bene_election pbe
  on pbe.personid = pi.personid
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in ('2Z','25')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts 
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('32','31','22','20','21','2Z','25') and benefitelection = 'E' and selectedoption = 'Y')       

left join 
     (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('2Z','25')
         and benefitelection in ('E')
       group by 1) pbe_max
  on pbe_max.personid = pbe.personid
  
left join person_bene_election pbestd
  on pbestd.personid = pbe.personid
 and pbestd.benefitsubclass in ('32')
 and pbestd.benefitelection in ('E','T')
 and pbestd.selectedoption = 'Y' 
 and date_part('year',pbestd.enddate) >= date_part('year',current_date) 
 and current_date between pbestd.effectivedate and pbestd.enddate
 and current_timestamp between pbestd.createts and pbestd.endts  
 and pbestd.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('32') and benefitelection = 'E' and selectedoption = 'Y' and date_part('year',enddate) >= date_part('year',current_date))  
 
left join person_bene_election pbeltd
  on pbeltd.personid = pbe.personid
 and pbeltd.benefitsubclass in ('31')
 and pbeltd.benefitelection in ('E','T')
 and pbeltd.selectedoption = 'Y' 
 and date_part('year',pbeltd.enddate) >= date_part('year',current_date) 
 and current_date between pbeltd.effectivedate and pbeltd.enddate
 and current_timestamp between pbeltd.createts and pbeltd.endts 
 and pbeltd.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('31') and benefitelection = 'E' and selectedoption = 'Y' and date_part('year',enddate) >= date_part('year',current_date)) 
 
left join person_bene_election pbeadd
  on pbeadd.personid = pbe.personid
 and pbeadd.benefitsubclass in ('22')
 and pbeadd.benefitelection in ('E','T')
 and pbeadd.selectedoption = 'Y' 
 and date_part('year',pbeadd.enddate) >= date_part('year',current_date) 
 and current_date between pbeadd.effectivedate and pbeadd.enddate
 and current_timestamp between pbeadd.createts and pbeadd.endts   
 and pbeadd.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('22') and benefitelection = 'E' and selectedoption = 'Y' and date_part('year',enddate) >= date_part('year',current_date)) 
 
left join person_bene_election pbeblife
  on pbeblife.personid = pbe.personid
 and pbeblife.benefitsubclass in ('20')
 and pbeblife.benefitelection in ('E','T')
 and pbeblife.selectedoption = 'Y' 
 and date_part('year',pbeblife.enddate) >= date_part('year',current_date)
 and current_date between pbeblife.effectivedate and pbeblife.enddate
 and current_timestamp between pbeblife.createts and pbeblife.endts  
 and pbeblife.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('20') and benefitelection = 'E' and selectedoption = 'Y' and date_part('year',enddate) >= date_part('year',current_date)) 
  
left join person_bene_election pbebeevlife
  on pbebeevlife.personid = pbe.personid
 and pbebeevlife.benefitsubclass in ('21')
 and pbebeevlife.benefitelection in ('E','T')
 and pbebeevlife.selectedoption = 'Y'  
 and current_date between pbebeevlife.effectivedate and pbebeevlife.enddate
 and current_timestamp between pbebeevlife.createts and pbebeevlife.endts 
 and pbebeevlife.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('21') and benefitelection = 'E' and selectedoption = 'Y' and date_part('year',enddate) >= date_part('year',current_date)) 

left join person_bene_election pbebSPvlife
  on pbebSPvlife.personid = pbe.personid
 and pbebSPvlife.benefitsubclass in ('2Z')
 and pbebSPvlife.benefitelection in ('E','T')
 and pbebSPvlife.selectedoption = 'Y' 
 and date_part('year',pbebSPvlife.enddate) >= date_part('year',current_date) 
 and current_date between pbebSPvlife.effectivedate and pbebSPvlife.enddate
 and current_timestamp between pbebSPvlife.createts and pbebSPvlife.endts  
 and pbebSPvlife.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('2Z') and benefitelection = 'E' and selectedoption = 'Y' and date_part('year',enddate) >= date_part('year',current_date)) 
 
left join person_bene_election pbebDPvlife
  on pbebDPvlife.personid = pbe.personid
 and pbebDPvlife.benefitsubclass in ('25')
 and pbebDPvlife.benefitelection in ('E','T')
 and pbebDPvlife.selectedoption = 'Y' 
 and date_part('year',pbebDPvlife.enddate) >= date_part('year',current_date)
 and current_date between pbebDPvlife.effectivedate and pbebDPvlife.enddate
 and current_timestamp between pbebDPvlife.createts and pbebDPvlife.endts  
 and pbebDPvlife.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('25') and benefitelection = 'E' and selectedoption = 'Y')  
  

  
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
  and pe.emplstatus = 'T'
  and pdr.dependentrelationship in ('S','D','C','DP','SP','FC')
  and pbe.benefitsubclass in ('32','31','22','20','21','2Z','25')   
  order by 1,2