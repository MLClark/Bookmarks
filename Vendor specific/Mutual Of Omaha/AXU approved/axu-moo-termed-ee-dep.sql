select distinct

 pi.personid
,elu.lastupdatets  
,'Termed EE Dep' ::varchar(30) as sourceseq 

,1 as sort_seq 
----------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325 --
----------------------------------
,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9CJ' ::char(8) as group_id
,case when pdr.dependentrelationship in ('D','ND') then 'D'
      when pdr.dependentrelationship in ('S','NS') then 'S'
      when pdr.dependentrelationship in ('C','NC')  and pvd.gendercode = 'M' then 'S'
      when pdr.dependentrelationship in ('C','NC')  and pvd.gendercode = 'F' then 'D'
      when pdr.dependentrelationship in ('DP','NA','SP') and pvd.gendercode = 'M' then 'H' 
      when pdr.dependentrelationship in ('DP','NA','SP') and pvd.gendercode = 'F' then 'W' 
      else null end ::char(1) as relationship_code 
      
,pi.identity ::char(9) as employee_id 
,pnd.lname ::char(35) as elname
,pnd.fname ::char(15) as efname
,pvd.gendercode ::char(1) as egender
,to_char(pvd.birthdate,'YYYYMMDD')::char(8) as dob
--- address is only applicable if ee has Dental
,' ' ::char(30) as addr1
,' ' ::char(30) as addr2
,' ' ::char(19) as city
,' ' ::char(2) state
,' ' ::char(11) as zip
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh -- position 309
--- All effective dates after doh should be either 5/1/18 (Benefit Plan Year) or Last Hired Date, whichever is greater
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-05-01'),'yyyymmdd') ::char(8) as emp_eff_date --- position 317
---------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405 --
---------------------------------------
,null as sub_group_eff_date
,null as sub_group
---------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474 --
---------------------------------------
-----------------------------------
-- SALARY DATA SEGMENT 475 - 527 --
-----------------------------------
,null as basic_sal_eff_date
,null as basic_sal_mode
,null as basic_salary_amount
,' ' ::char(2) as first_add_comp_type
,' ' ::char(16) as first_add_comp_amt
----------------------------------
-- CLASS DATA SEGMENT 608 - 620 --
----------------------------------
,null as class_eff_date 
,null as class_id
--------------------------------------
-- SMOKING STATUS SEGMENT 620 - 629 --
--------------------------------------
,' ' ::char(8) as smoker_status_effective_date
,' ' ::char(1) as smoker_indicator
--------------------------
-- ELIGIBILITY SEGMENTS --
--------------------------
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
,' ' ::char(1) as product_category_3
,' ' ::char(8) as pc_effective_date_3
,' ' ::char(2) as elig_event_3
,' ' ::char(10) as plan_id_3
,' ' ::char(1) as emp_only_3
,' ' ::char(8) as pc_nom_effective_date_3
,null as pc_nom_amount_3
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
,' ' ::char(1) as product_category_4
,' ' ::char(8) as pc_effective_date_4
,' ' ::char(2) as elig_event_4
,' ' ::char(10) as plan_id_4
,' ' ::char(1) as emp_only_4
,' ' ::char(8) as pc_nom_effective_date_4
,null as pc_nom_amount_4
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
-------------------------------------------------------------
,' ' ::char(1) as product_category_5
,' ' ::char(8) as pc_effective_date_5
,' ' ::char(2) as elig_event_5
,' ' ::char(10) as plan_id_5
,' ' ::char(1) as emp_only_5
,' ' ::char(8) as pc_nom_effective_date_5
,null as pc_nom_amount_5
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (27 ) 1195 - 1239 --
------------------------------------------------------
,' ' ::char(1) as product_category_c
,' ' ::char(8) as pc_effective_date_c
,' ' ::char(2) as elig_event_c
,' ' ::char(10) as plan_id_c
,' ' ::char(1) as emp_only_c
,' ' ::char(8) as pc_nom_effective_date_c
,null as pc_nom_amount_c
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (27 ) 1250 - 1294 --
------------------------------------------------------
,' ' ::char(1) as product_category_e
,' ' ::char(8) as pc_effective_date_e
,' ' ::char(2) as elig_event_e
,' ' ::char(10) as plan_id_e
,' ' ::char(1) as emp_only_e
,' ' ::char(8) as pc_nom_effective_date_e
,null as pc_nom_amount_e
---------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE DEPENDENT (27 ) 1305 - 1349 --
---------------------------------------------------------
,' ' ::char(1) as product_category_d
,' ' ::char(8) as pc_effective_date_d
,' ' ::char(2) as elig_event_d
,' ' ::char(10) as plan_id_d
,' ' ::char(1) as emp_only_d
,' ' ::char(8) as pc_nom_effective_date_d
,null as pc_nom_amount_d
------------------------------------
-- VOLUNTARY STD (30) 1360 - 1382 --
------------------------------------
,' ' ::char(1) as product_category_Q
,' ' ::char(8) as pc_effective_date_Q
,' ' ::char(2) as elig_event_Q
,' ' ::char(10) as plan_id_Q
,' ' ::char(1) as emp_only_Q
------------------------------------
-- VOLUNTARY LTD (31) 1415 - 1437 --
------------------------------------
,' ' ::char(1) as product_category_L
,' ' ::char(8) as pc_effective_date_L
,' ' ::char(2) as elig_event_L
,' ' ::char(10) as plan_id_L
,' ' ::char(1) as emp_only_L
-------------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2C) 1470 - 1514 --
-------------------------------------------------------------------
,' ' ::char(1) as product_category_A
,' ' ::char(8) as pc_effective_date_A
,' ' ::char(2) as elig_event_A
,' ' ::char(10) as plan_id_A
,' ' ::char(1) as emp_only_A
,' ' ::char(8) as elaprv_effective_date_A
,null as elaprv_amount_A
--------------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2S) 1525 - 1569 --
--------------------------------------------------------
,' ' ::char(1) as product_category_J
,' ' ::char(8) as pc_effective_date_J
,' ' ::char(2) as elig_event_J
,' ' ::char(10) as plan_id_J
,' ' ::char(1) as emp_only_J
,' ' ::char(8) as elaprv_effective_date_J
,null as elaprv_amount_J
-----------------------------------------
-- VOLUNTARY ACCIDENT (13) 1865 - 1877 --
-----------------------------------------
,' ' ::char(1) as product_category_g
,' ' ::char(8) as pc_effective_date_g
,' ' ::char(2) as elig_event_g
,' ' ::char(10) as plan_id_g
,' ' ::char(1) as family_cvg_ind_g 


from person_identity pi
--- only need look back date on terms 
left join edi.edi_last_update elu on elu.feedid = 'AXU_Mutual_Of_Omaha_Carrier_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'T'
 and pbe.benefitsubclass in ('21','2Z','2X','30','31','2C','2S','13')
 and current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 --and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and date_part('year',effectivedate)=date_part('year',current_date)
 --                        and benefitsubclass in ('2Z','2X','2S') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

left JOIN (select distinct personid, enddate, max(effectivedate) as effectivedate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
             from person_bene_election where benefitsubclass in ('21','2Z','2X','30','31','2C','2S','13') and benefitelection  = 'T' and selectedoption = 'Y'
              and current_date between effectivedate and enddate  and current_timestamp between createts and endts
            group by 1,2) pbe_max on pbe_max.personid = pbe.personid    

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
----- dependent data
left join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 and pdr.dependentrelationship in ('DP','SP','NA','D','S','C','ND','NS','NC')

left JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
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
 
where pi.identitytype = 'SSN' and ((piD.identity != pi.identity) or (piD.identity is null))
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('R', 'T')
  and (pbe.effectivedate >= coalesce(?::timestamp::date,elu.lastupdatets::date) or (pbe.createts::date > coalesce(?::timestamp::date,elu.lastupdatets::date) and pbe.effectivedate < coalesce(?::timestamp::date,elu.lastupdatets::date,'2017-01-01')) )  
  and pe.personid = '787'
 -- AND de.selectedoption = 'Y'
  -- Spouse or DP with 
  --    1. accident (13) coverage for either family or EE+SP
  --    2. spouse ci (2S) and / or spouse vol life (2Z) coverage 
  and ((pdr.dependentrelationship in ('DP','SP','NA') and pbe.benefitcoverageid in ('5','2') and pbe.benefitsubclass in ('13')) or (pdr.dependentrelationship in ('DP','SP','NA') and pbe.benefitsubclass in ('2Z','2S'))
   -- Dependent must be 26 years or under and 
  --    1. accident (13) coverage for either family or EE+CC
  --    2. child vol life (2X) coverage  
   or ((pdr.dependentrelationship in ('D','S','C','ND','NS','NC') and pbe.benefitcoverageid in ('5','3','16','17') and pbe.benefitsubclass in ('13') and pvd.birthdate >= current_date ::DATE - interval '26 years')
   or  (pdr.dependentrelationship in ('D','S','C','ND','NS','NC') and pbe.benefitsubclass in ('2X')and pvd.birthdate >= current_date ::DATE - interval '26 years')))
  --- only need look back date on terms 

   