select distinct
 pi.personid 
,case when pdr.dependentrelationship in ('SP','NA','DP') then 2 else 3 end as sort_seq 
,'6 ACTIVE EE TERMED DEP' ::CHAR(20)
----------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325 --
----------------------------------
,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9Y2' ::char(8) as group_id
,case when pdr.dependentrelationship IN ('ND','D')  then 'D'
      when pdr.dependentrelationship IN ('NS','S')  then 'S'
      when pdr.dependentrelationship IN ('NC','C')  and pvd.gendercode = 'F' then 'D'
      when pdr.dependentrelationship IN ('NC','C')  and pvd.gendercode = 'M' then 'S'
      when pdr.dependentrelationship IN ('NA','DP') and pvd.gendercode = 'F' then 'W'
      when pdr.dependentrelationship IN ('NA','DP') and pvd.gendercode = 'M' then 'H'     
      when pdr.dependentrelationship = 'SP' and pvd.gendercode = 'F' then 'W'
      when pdr.dependentrelationship = 'SP' and pvd.gendercode = 'M' then 'H'       
      end ::char(1) as relationship_code
,pi.identity ::char(9) as employee_id 
,ltrim(pnd.lname) ::char(35) as elname
,ltrim(pnd.fname) ::char(15) as efname
,pvd.gendercode ::char(1) as egender
,to_char(pvd.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh --- position 309
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-01-01'),'yyyymmdd') ::char(8) as emp_eff_date --- position 317    
---------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405 --
---------------------------------------
---- This section should be blank for dep 3-21-2018
,null as sub_group_eff_date
,null as sub_group
---------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474 --
---------------------------------------
,null as location_effective_date
,null as location_id
,null as location_description  
-----------------------------------
-- SALARY DATA SEGMENT 475 - 527 --
-----------------------------------
,null as basic_sal_eff_date
,null as basic_sal_mode
,null as basic_salary_amount
----------------------------------
-- CLASS DATA SEGMENT 608 - 620 --
----------------------------------
,null as class_eff_date 
,null as class_id
--------------------------------------
-- SMOKING STATUS SEGMENT 620 - 629 --
-------------------------------------- 
,null as smoker_status_effective_date
,null as smoker_indicator
--------------------------
-- ELIGIBILITY SEGMENTS --
--------------------------
---------------------------------------------
-- BASIC LIFE (23) 810 - 832 -- LTL0NCFLAT --
---------------------------------------------
,null as product_category_1
,null as pc_effective_date_1
,null as elig_event_1
,null as plan_id_1
,null as emp_only_1
------------------------------------------------------------------------
-- BASIC AD&D (23) 865 - 887 -- ATA0NCFLAT -- map the same as basic life 
------------------------------------------------------------------------
,null as product_category_a
,null as pc_effective_date_a
,null as elig_event_a
,null as plan_id_a
,null as emp_only_a
--------------------------------------
-- BASIC STD SEGMENT (??) 920 - 942 --
--------------------------------------
--------------------------------------
-- BASIC LTD SEGMENT (??) 975 - 997 --
--------------------------------------
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
,null as product_category_3
,null as pc_effective_date_3
,null as elig_event_3
,null as plan_id_3
,null as emp_only_3
,null as pc_nom_effective_date_3
,null as pc_nom_amount_3
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
,null as product_category_4
,null as pc_effective_date_4
,null as elig_event_4
,null as plan_id_4
,null as emp_only_4
,null as pc_nom_effective_date_4
,null as pc_nom_amount_4
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
-------------------------------------------------------------
,null as product_category_5
,null as pc_effective_date_5
,null as elig_event_5
,null as plan_id_5
,null as emp_only_5
,null as pc_nom_effective_date_5
,null as pc_nom_amount_5
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) 1195 - 1239 --
------------------------------------------------------
,null as product_category_c
,null as pc_effective_date_c
,null as elig_event_c
,null as plan_id_c
,null as emp_only_c
,null as pc_nom_effective_date_c
,null as pc_nom_amount_c
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z ) 1250 - 1294 --
------------------------------------------------------
,null as product_category_e
,null as pc_effective_date_e
,null as elig_event_e
,null as plan_id_e
,null as emp_only_e
,null as pc_nom_effective_date_e
,null as pc_nom_amount_e
---------------------------------------------------------
-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349 --
--------------------------------------------------------- 
,null as product_category_d
,null as pc_effective_date_d
,null as elig_event_d
,null as plan_id_d
,null as emp_only_d
,null as pc_nom_effective_date_d
,null as pc_nom_amount_d
----------------------------
-- PCSTD (30) 1360 - 1382 --
----------------------------
,null as product_category_Q
,null as pc_effective_date_Q
,null as elig_event_Q
,null as plan_id_Q
,null as emp_only_Q
------------------------------------
-- VOLUNTARY LTD (31) 1415 - 1437 --
------------------------------------
,null as product_category_L
,null as pc_effective_date_L
,null as elig_event_L
,null as plan_id_L
,null as emp_only_L
------------------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2CI,2CS) 1470 - 1514 --
------------------------------------------------------------------------
,null as product_category_A
,null as pc_effective_date_A
,null as elig_event_A
,null as plan_id_A
,null as emp_only_A
,null as elaprv_effective_date_A
,null as elaprv_amount_A
-------------------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2SI,2SS) 1525 - 1569 --
-------------------------------------------------------------
,null as product_category_J
,null as pc_effective_date_J
,null as elig_event_J
,null as plan_id_J
,null as emp_only_J
,null as elaprv_effective_date_J
,null as elaprv_amount_J
-----------------------------------------
-- VOLUNTARY ACCIDENT (13) 1855 - 1877 --
-----------------------------------------
,null as product_category_g
,null as pc_effective_date_g
,null as elig_event_g
,null as plan_id_g
,null as emp_only_g


from person_identity pi

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in  ('2Z','2X','13','2SI','2SS')
 and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'
 and pbe.benefitcoverageid > '1'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

left join 
     (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('2Z','2X','13','2SI','2SS')
         and benefitelection in ('E') and selectedoption = 'Y'
       group by 1) pbe_max
  on pbe_max.personid = pbe.personid   

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts   
   
----- dependent data

left join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 and pdr.dependentrelationship in ('D','C','S','DP','SP','NA','ND','NS','NC') --- NA,ND,NS,NC ARE DP DOMESTIC PARTNER

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 and current_timestamp between de.createts and de.endts
 and de.dependentid in 
 ( select distinct de.dependentid as dependentid
    from dependent_enrollment de 
    join person_names pne
      on pne.personid = de.personid
     and pne.nametype = 'Legal'
     and current_date between pne.effectivedate and pne.enddate
     and current_timestamp between pne.createts and pne.endts
    join person_names pnd
      on pnd.personid = de.dependentid
     and pnd.nametype = 'Dep'
     and current_date between pnd.effectivedate and pnd.enddate
     and current_timestamp between pnd.createts and pnd.endts  
     and pnd.effectivedate < pnd.enddate  
    join person_vitals pvd
      on pvd.personid = de.dependentid
     and current_date between pvd.effectivedate and pvd.enddate
     and current_timestamp between pvd.createts and pvd.endts
    join person_dependent_relationship pdr
      on pdr.personid = de.personid
     and pdr.dependentid = de.dependentid
     and current_date between pdr.effectivedate and pdr.enddate
     and current_timestamp between pdr.createts and pdr.endts
     and pdr.effectivedate < pdr.enddate
    join person_employment pe
      on pe.personid = de.personid
     and current_date between pe.effectivedate and pe.enddate
     and current_timestamp between pe.createts and pe.endts
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in ('2Z','2X','13','2SI','2SS')
     and pbe.selectedoption = 'Y'
        
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts   
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('2Z','2X','13','2SI','2SS')
    and pe.emplstatus = 'A'
    and pbe.benefitelection <> 'W' 
    and date_part('year',de.enddate)=date_part('year',current_date)
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
       and pdr.effectivedate < pdr.enddate
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.effectivedate < de.enddate
       and de.benefitsubclass in ('2Z','2X','13','2SI','2SS')
   )
)  


-----------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) --&-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z ) --
-----------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2Z') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebSPvlife on pbebSPvlife.personid = pbe.personid and pbebSPvlife.rank = 1 
-----------------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) --&-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) --
-----------------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2X') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebDPvlife on pbebDPvlife.personid = pbe.personid and pbebDPvlife.rank = 1   
-------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2SI,2SS) --
-------------------------------------------------  
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2SI') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbe2si on pbe2si.personid = pbe.personid and pbe2si.rank = 1 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2SS') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbe2ss on pbe2ss.personid = pbe.personid and pbe2ss.rank = 1    

left join (select distinct de.personid, de.dependentid, de.benefitsubclass, de.effectivedate, de.selectedoption, pdr.dependentrelationship, bcd.benefitcoveragedesc
              from dependent_enrollment de
              join person_dependent_relationship pdr
                on pdr.personid = de.personid
               and pdr.dependentrelationship in ('D','C','S','DP','SP','NA','ND','NS','NC') --- NA,ND,NS,NC ARE DP DOMESTIC PARTNER
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
  and ((pdr.dependentrelationship in ('DP','SP','NA'))
   or  (pdr.dependentrelationship in ('D','S','C','ND','NS','NC') and pvd.birthdate >= current_date ::DATE - interval '26 years'))
  and pe.emplstatus = 'T'