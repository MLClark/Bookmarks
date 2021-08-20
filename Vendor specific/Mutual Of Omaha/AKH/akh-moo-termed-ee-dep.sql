select distinct
 pi.personid 
,'11 Termed EE Dep' ::varchar(30) as qsource 
,1 as sort_seq 
----------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325 --
----------------------------------
,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000ADZ5' ::char(8) as group_id
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
,null as doh
--- All effective dates after doh should be either 1/1/18 (Benefit Plan Year) or Last Hired Date, whichever is greater
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-01-01'),'yyyymmdd') ::char(8) as emp_eff_date --- position 317
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
----------------------------------
-- CLASS DATA SEGMENT 608 - 620 --
----------------------------------
,null as class_eff_date 
,' ' as med_flag
,null as class_id
--------------------------------------
-- SMOKING STATUS SEGMENT 620 - 629 --
--------------------------------------      
--------------------------
-- ELIGIBILITY SEGMENTS --
--------------------------
----------------------------------------------------------------------
-- BASIC LIFE (20) 810 - 832 -- LTL0NCFLAT (Class A001 & A003 only) --
----------------------------------------------------------------------
,' ' ::char(1) as product_category_1
,' ' ::char(8) as pc_effective_date_1
,' ' ::char(2) as elig_event_1
,' ' ::char(10) as plan_id_1
,' ' ::char(1) as emp_only_1
----------------------------------------------------------------------
-- BASIC AD&D (22) 865 - 887 -- ATA0NCFLAT (Class A001 & A003 only) --
----------------------------------------------------------------------
,' ' ::char(1) as product_category_a
,' ' ::char(8) as pc_effective_date_a
,' ' ::char(2) as elig_event_a
,' ' ::char(10) as plan_id_a
,' ' ::char(1) as emp_only_a
-----------------------------------------------------------------------------
-- BASIC STD SEGMENT (32) 920 - 942 -- STS00NCSAL (Class A003 & A004 only) --
-----------------------------------------------------------------------------
,' ' ::char(1) as product_category_S
,' ' ::char(8) as pc_effective_date_s
,' ' ::char(2) as elig_event_s
,' ' ::char(10) as plan_id_s
,' ' ::char(1) as emp_only_s
-----------------------------------------------------------------------------
-- BASIC LTD SEGMENT (31) 975 - 997 -- TTT00NCSAL (Class A003 & A004 only) --
-----------------------------------------------------------------------------
,' ' ::char(1) as product_category_t
,' ' ::char(8) as pc_effective_date_t
,' ' ::char(2) as elig_event_t
,' ' ::char(10) as plan_id_t
,' ' ::char(1) as emp_only_t
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
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (25) 1140 - 1185 --
-------------------------------------------------------------
,' ' ::char(1) as product_category_5
,' ' ::char(8) as pc_effective_date_5
,' ' ::char(2) as elig_event_5
,' ' ::char(10) as plan_id_5
,' ' ::char(1) as emp_only_5
,' ' ::char(8) as pc_nom_effective_date_5
,null as pc_nom_amount_5

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AKH_Mutual_Of_Omaha_STD_LTD_Export'

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and date_part('year',effectivedate)=date_part('year',current_date)
                         and benefitsubclass in ('2Z','25') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 


left JOIN 
(select distinct personid, enddate, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('2Z','25')
   and enddate < '2199-12-30'
   and benefitelection = 'E'
   and selectedoption = 'Y'
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and effectivedate < enddate
   group by 1,2)
 pbe_max on pbe_max.personid = pbe.personid                     

-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('2Z')
              and benefitelection in ('E') and selectedoption = 'Y'
              and current_timestamp between createts and endts
              and effectivedate < enddate
              and date_part('year',effectivedate)>='2018'              
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount) pbebSPvlife on pbebSPvlife.personid = pbe.personid and pbebSPvlife.rank = 1 
         
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X)   
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('25')
              and benefitelection in ('E') and selectedoption = 'Y'
              and current_timestamp between createts and endts
              and effectivedate < enddate
              and date_part('year',effectivedate)>='2018'              
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount) pbebDPvlife on pbebDPvlife.personid = pbe.personid and pbebDPvlife.rank = 1 
            
 
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
 and pdr.effectivedate < pdr.enddate
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
  and pe.emplstatus in ('R', 'T')
  and pdr.dependentrelationship in ('S','D','C','DP','SP','NA','NS','ND','NC')
  and pbe.benefitsubclass in ('2Z','25')  
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
   --and pe.personid = '7894'