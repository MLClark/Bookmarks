select distinct

--- Active's ee should be full file - change only for terms
 pi.personid 
,'251 Active EE' ::varchar(30) as qsource
,0 as sort_seq 
----------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325 --
----------------------------------
,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000ADZ5' ::char(8) as group_id
,'M' ::char(1) as relationship_code
,pi.identity ::char(9) as employee_id 
,pn.lname ::char(35) as elname
,pn.fname ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh --- position 309
--- All effective dates after doh should be either 1/1/18 (Benefit Plan Year) or Last Hired Date, whichever is greater
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-01-01'),'yyyymmdd') ::char(8) as emp_eff_date --- position 317      
---------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405 --
---------------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-01-01'),'yyyymmdd') ::char(8) as sub_group_eff_date --- position 393
,'0003' ::char(4) as sub_group
---------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474 --
---------------------------------------
-----------------------------------
-- SALARY DATA SEGMENT 475 - 527 --
-----------------------------------
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-01-01'),'yyyymmdd') ::char(8) as basic_sal_eff_date --- position 475
,'A' ::char(1) as basic_sal_mode
,case when pc.frequencycode = 'H' then to_char((pc.compamount * 2080) * 100, 'FM0000000000000000 ')
      else to_char(pc.compamount * 100, 'FM0000000000000000 ') end as basic_salary_amount -- assume decimal zero filled 
--,' ' ::char(2) as first_add_comp_type
--,' ' ::char(16) as first_add_comp_amt      
----------------------------------
-- CLASS DATA SEGMENT 608 - 620 --
----------------------------------
,mef.medical_enrolled_flag as medflag
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-01-01'),'yyyymmdd') ::char(8) as class_eff_date --- position 608
,case when pu.payunitdesc = 'AKH00' and mef.medical_enrolled_flag = 'Y' then 'A001'
      when pu.payunitdesc = 'AKH00' then 'A002'
      when pu.payunitdesc = 'AKH05' and mef.medical_enrolled_flag = 'Y' then 'A003'
      when pu.payunitdesc = 'AKH05' then 'A004'
      when pu.payunitdesc = 'AKH15' and mef.medical_enrolled_flag = 'Y' then 'A003'
      when pu.payunitdesc = 'AKH15' then 'A004'      
      else ' ' end ::char(4) as class_id
--------------------------------------
-- SMOKING STATUS SEGMENT 620 - 629 --
--------------------------------------      
--------------------------
-- ELIGIBILITY SEGMENTS --
--------------------------
----------------------------------------------------------------------
-- BASIC LIFE (20) 810 - 832 -- LTL0NCFLAT (Class A001 & A003 only) --
----------------------------------------------------------------------
,case when pbeblife.benefitsubclass in ('20') then '1' else ' ' end ::char(1) as product_category_1
,case when pbeblife.benefitsubclass in ('20') then to_char(greatest(pbeblife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_1
,case when pbeblife.benefitsubclass in ('20')  and pbeblife.benefitelection = 'T'  then 'TM' 
      when pbeblife.benefitsubclass in ('20')  and pbeblife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_1
,case when pbeblife.benefitsubclass in ('20') then 'LTL0NCFLAT' else ' ' end ::char(10) as plan_id_1
,case when pbeblife.benefitsubclass in ('20') then 'C' else ' ' end ::char(1) as emp_only_1
----------------------------------------------------------------------
-- BASIC AD&D (22) 865 - 887 -- ATA0NCFLAT (Class A001 & A003 only) --
----------------------------------------------------------------------
,case when pbeadd.benefitsubclass in ('22') then 'a' else ' ' end ::char(1) as product_category_a
,case when pbeadd.benefitsubclass in ('22') then to_char(greatest(pbeadd.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_a
,case when pbeadd.benefitsubclass in ('22')  and pbeadd.benefitelection = 'T'  then 'TM' 
      when pbeadd.benefitsubclass in ('22')  and pbeadd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_a
,case when pbeadd.benefitsubclass in ('22') then 'ATA0NCFLAT' else ' ' end ::char(10) as plan_id_a
,case when pbeadd.benefitsubclass in ('22') then 'C' else ' ' end ::char(1) as emp_only_a
-----------------------------------------------------------------------------
-- BASIC STD SEGMENT (32) 920 - 942 -- STS00NCSAL (Class A003 & A004 only) --
-----------------------------------------------------------------------------
,case when pbestd.benefitsubclass in ('32') then 'S' else ' ' end ::char(1) as product_category_S
,case when pbestd.benefitsubclass in ('32') then to_char(greatest(pbestd.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_s
,case when pbestd.benefitsubclass in ('32')  and pbestd.benefitelection = 'T'  then 'TM' 
      when pbestd.benefitsubclass in ('32')  and pbestd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_s
,case when pbestd.benefitsubclass in ('32') then 'STS00NCSAL' else ' ' end ::char(10) as plan_id_s
,case when pbestd.benefitsubclass in ('32') then 'C' else ' ' end ::char(1) as emp_only_s
-----------------------------------------------------------------------------
-- BASIC LTD SEGMENT (31) 975 - 997 -- TTT00NCSAL (Class A003 & A004 only) --
-----------------------------------------------------------------------------
,case when pbeltd.benefitsubclass in ('31') then 'T' else ' ' end ::char(1) as product_category_t
,case when pbeltd.benefitsubclass in ('31') then to_char(greatest(pbeltd.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_t
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_t
,case when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' else ' ' end ::char(10) as plan_id_t
,case when pbeltd.benefitsubclass in ('31') then 'C' else ' ' end ::char(1) as emp_only_t
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
,case when pbebeevlife.benefitsubclass in ('21') then '3' else ' ' end ::char(1) as product_category_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'T'  then 'TM' 
      when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_3
,case when pbebeevlife.benefitsubclass in ('21') then 'ETL0CEEVAL' else ' ' end ::char(10) as plan_id_3
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-01-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_3
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'T'  then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (25) 1140 - 1185 --
-------------------------------------------------------------
,case when pbebDPvlife.benefitsubclass in ('25') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AKH_Mutual_Of_Omaha_STD_LTD_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.effectivedate is not null
 and pbe.benefitelection in ('E')
 and pbe.benefitsubclass in ('32','31','22','20','21','2Z','25')
 and pbe.selectedoption = 'Y' 
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

left join 
     (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('32','31','22','20','21','2Z','25')
         and benefitelection in ('E') and selectedoption = 'Y'
       group by 1) pbe_max
  on pbe_max.personid = pbe.personid
 
left join person_bene_election pbestd
  on pbestd.personid = pbe.personid
 and pbestd.benefitsubclass in ('32')
 and pbestd.benefitelection in ('E')
 and pbestd.selectedoption = 'Y' 
 and current_date between pbestd.effectivedate and pbestd.enddate
 and current_timestamp between pbestd.createts and pbestd.endts  
                          
left join person_bene_election pbeltd
  on pbeltd.personid = pbe.personid
 and pbeltd.benefitsubclass in ('31')
 and pbeltd.benefitelection in ('E')
 and pbeltd.selectedoption = 'Y' 
 and current_date between pbeltd.effectivedate and pbeltd.enddate
 and current_timestamp between pbeltd.createts and pbeltd.endts   
 
left join person_bene_election pbeadd
  on pbeadd.personid = pbe.personid
 and pbeadd.benefitsubclass in ('27')
 and pbeadd.benefitelection in ('E')
 and pbeadd.selectedoption = 'Y' 
 and current_date between pbeadd.effectivedate and pbeadd.enddate
 and current_timestamp between pbeadd.createts and pbeadd.endts  
 
left join person_bene_election pbeblife
  on pbeblife.personid = pbe.personid
 and pbeblife.benefitsubclass in ('20')
 and pbeblife.benefitelection in ('E')
 and pbeblife.selectedoption = 'Y' 
 and current_date between pbeblife.effectivedate and pbeblife.enddate
 and current_timestamp between pbeblife.createts and pbeblife.endts   

left join person_bene_election pbebeevlife
  on pbebeevlife.personid = pbe.personid
 and pbebeevlife.benefitsubclass in ('21')
 and pbebeevlife.benefitelection in ('E')
 and pbebeevlife.selectedoption = 'Y' 
 and current_date between pbebeevlife.effectivedate and pbebeevlife.enddate
 and current_timestamp between pbebeevlife.createts and pbebeevlife.endts   
 
left join person_bene_election pbebSPvlife
  on pbebSPvlife.personid = pbe.personid
 and pbebSPvlife.benefitsubclass in ('2Z')
 and pbebSPvlife.benefitelection in ('E')
 and pbebSPvlife.selectedoption = 'Y' 
 and current_date between pbebSPvlife.effectivedate and pbebSPvlife.enddate
 and current_timestamp between pbebSPvlife.createts and pbebSPvlife.endts  

left join person_bene_election pbebDPvlife
  on pbebDPvlife.personid = pbe.personid
 and pbebDPvlife.benefitsubclass in ('25')
 and pbebDPvlife.benefitelection in ('E')
 and pbebDPvlife.selectedoption = 'Y' 
 and current_date between pbebDPvlife.effectivedate and pbebDPvlife.enddate
 and current_timestamp between pbebDPvlife.createts and pbebDPvlife.endts   
  
--- adding medical join even tho this feed has nothing to do with medical - need to know if enrolled in med to set class id 

left join (select distinct personid,benefitelection,benefitsubclass, case when benefitsubclass = '10' and benefitelection = 'E' then 'Y' else 'N' end as medical_enrolled_flag
             from person_bene_election
            where benefitsubclass in ('10')
              and current_date between effectivedate and enddate
              and current_timestamp between createts and endts
              and benefitelection = 'E' and selectedoption = 'Y'
            order by 1 ) as mef on mef.personid = pbe.personid 
  
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


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
  and pe.personid = '10655'