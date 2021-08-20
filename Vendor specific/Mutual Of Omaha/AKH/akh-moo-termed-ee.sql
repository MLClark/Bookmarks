select distinct
 pi.personid 
,'16 Termed EE' ::varchar(30) as qsource
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
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh
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
,to_char(greatest(pbe_max.effectivedate, pe.empllasthiredate, '2018-01-01'),'yyyymmdd') ::char(8) as class_eff_date --- position 608
,mef.medical_enrolled_flag as med_flag
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
-- BASIC AD&D (22) 865 - 887 -- ATA0NCFLAT (Class A001 & A003 only) -- map the same as basic life 
----------------------------------------------------------------------
,case when pbeblife.benefitsubclass in ('20') then 'a' else ' ' end ::char(1) as product_category_a
,case when pbeblife.benefitsubclass in ('20') then to_char(greatest(pbeblife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_a
,case when pbeblife.benefitsubclass in ('20')  and pbeblife.benefitelection = 'T'  then 'TM' 
      when pbeblife.benefitsubclass in ('20')  and pbeblife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_a
,case when pbeblife.benefitsubclass in ('20') then 'ATA0NCFLAT' else ' ' end ::char(10) as plan_id_a
,case when pbeblife.benefitsubclass in ('20') then 'C' else ' ' end ::char(1) as emp_only_a
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
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' end ::char(2) as elig_event_t
,case when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' else ' ' end ::char(10) as plan_id_t
,case when pbeltd.benefitsubclass in ('31') then 'C' else ' ' end ::char(1) as emp_only_t
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
,case when pbebeevlife.benefitsubclass in ('21') then '3' else ' ' end ::char(1) as product_category_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'T' then 'TM' end ::char(2) as elig_event_3
,case when pbebeevlife.benefitsubclass in ('21') then 'ETL0CEEVAL' else ' ' end ::char(10) as plan_id_3
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(greatest(pbebeevlife.effectivedate,'2018-01-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_3
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'T'  then 'TM' end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(greatest(pbebSPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (25) 1140 - 1185 --
-------------------------------------------------------------
,case when pbebDPvlife.benefitsubclass in ('25') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'T'  then 'TM' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(greatest(pbebDPvlife.effectivedate,'2018-01-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AKH_Mutual_Of_Omaha_STD_LTD_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and date_part('year',effectivedate)=date_part('year',current_date)
                         and benefitsubclass in ('32','31','22','20','21','2Z','25') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 


left JOIN 
(select distinct personid, enddate, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('32','31','22','20','21','2Z','25')
   and benefitelection  <> 'W'
   and selectedoption = 'Y'
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and effectivedate < enddate
   group by 1,2)
 pbe_max on pbe_max.personid = pbe.personid
 

----- ERSTD (32)          
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('32')
              and benefitelection <> 'W' and selectedoption = 'Y'
              and current_timestamp between createts and endts
              and effectivedate < enddate
              and date_part('year',effectivedate)>='2018'
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount) pbestd on pbestd.personid = pbe.personid and pbestd.rank = 1 

----- ERLTD (31)
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('31')
              and benefitelection <> 'W' and selectedoption = 'Y'
              and current_timestamp between createts and endts
              and effectivedate < enddate
              and date_part('year',effectivedate)>='2018'
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount) pbeltd on pbeltd.personid = pbe.personid and pbeltd.rank = 1 
 
----- BasicADD (22)   
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('22')
              and benefitelection <> 'W' and selectedoption = 'Y'
              and current_timestamp between createts and endts
              and effectivedate < enddate
              and date_part('year',effectivedate)>='2018'
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount) pbeadd on pbeadd.personid = pbe.personid and pbeadd.rank = 1 

----- BLIFE (20)  
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('20')
              and benefitelection <> 'W' and selectedoption = 'Y'
              and current_timestamp between createts and endts
              and effectivedate < enddate
              and date_part('year',effectivedate)>='2018'
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount) pbeblife on pbeblife.personid = pbe.personid and pbeblife.rank = 1  

----- EESuppLife (21)  
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('21')
              and benefitelection <> 'W' and selectedoption = 'Y'
              and current_timestamp between createts and endts
              and effectivedate < enddate
              and date_part('year',effectivedate)>='2018'
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount) pbebeevlife on pbebeevlife.personid = pbe.personid and pbebeevlife.rank = 1 

---- Spouse Vol Life (2Z)
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('2Z')
              and benefitelection <> 'W' and selectedoption = 'Y'
              and current_timestamp between createts and endts
              and effectivedate < enddate
              and date_part('year',effectivedate)>='2018'
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount) pbebSPvlife on pbebSPvlife.personid = pbe.personid and pbebSPvlife.rank = 1 

---- Dependent Vol Life (25) 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('25')
              and benefitelection <> 'W' and selectedoption = 'Y'
              and current_timestamp between createts and endts
              and effectivedate < enddate
              and date_part('year',effectivedate)>='2018'
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount) pbebDPvlife on pbebDPvlife.personid = pbe.personid and pbebDPvlife.rank = 1 

--- adding medical join even tho this feed has nothing to do with medical - need to know if enrolled in med to set class id 
left join (select distinct personid,benefitelection,benefitsubclass, case when benefitsubclass = '10' and benefitelection = 'E' then 'Y' else 'N' end as medical_enrolled_flag
             from person_bene_election
            where benefitsubclass in ('10')
              and current_date between effectivedate and enddate
              and current_timestamp between createts and endts
              and benefitelection <> 'W' and selectedoption = 'Y'
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

left join (select personid, compamount, frequencycode, max(effectivedate) as effecitvedate, max(enddate) as enddate,
                  rank() over (partition by personid order by max(effectivedate) desc) as rank
             from person_compensation where current_timestamp between createts and endts 
            group by personid, compamount, frequencycode) pc on pc.personid = pi.personid and pc.rank = 1 

left join (select personid, scheduledhours, max(effectivedate) as effectivedate, max(enddate) as enddate,
                  rank() over (partition by personid order by max(effectivedate) desc) as rank
            from pers_pos where current_timestamp between createts and endts 
           group by personid, scheduledhours) pp on pp.personid = pi.personid and pp.rank = 1     
 
LEFT JOIN person_payroll ppay
  ON ppay.personid = pi.personid
 AND current_date BETWEEN ppay.effectivedate AND ppay.enddate
 AND current_timestamp BETWEEN ppay.createts AND ppay.endts      

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppay.payunitid

LEFT JOIN frequency_codes fc
  ON fc.frequencycode = pu.frequencycode

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('R','T')
  and pbe.benefitsubclass in ('32','31','22','20','21','2Z','25')    
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 