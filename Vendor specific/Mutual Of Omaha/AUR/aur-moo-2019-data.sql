select distinct
 pi.personid 
,pe.emplstatus 
,1 as sort_seq 
,'382 ACTIVE BENEFITS' ::varchar(30) as qsource
----------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325 --
----------------------------------
,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000BF7F' ::char(8) as group_id
,'M' ::char(1) as relationship_code
,pi.identity ::char(9) as employee_id 
,ltrim(pn.lname) ::char(35) as elname
,ltrim(pn.fname) ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh --- position 309
,to_char(greatest(pe.empllasthiredate, '2018-11-01'),'yyyymmdd') ::char(8) as emp_eff_date --- position 317    
---------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405 --
---------------------------------------
,to_char(greatest(pbe_max.effectivedate, '2018-11-01'),'yyyymmdd') ::char(8) as sub_group_eff_date --- position 393
,'0001' ::char(4) as sub_group
---------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474 --
---------------------------------------
-----------------------------------
-- SALARY DATA SEGMENT 475 - 527 --
-----------------------------------
,to_char(greatest(pc.effectivedate, '2018-11-01'),'yyyymmdd') ::char(8) as basic_sal_eff_date --- position 475
,'A' ::char(1) as basic_sal_mode
,case when pc.frequencycode = 'H' then to_char(pc.compamount  * pp.scheduledhours * 26 * 100, 'FM0000000000000000 ')
      else to_char(pc.compamount * 100, 'FM0000000000000000 ') end as basic_salary_amount -- assume decimal zero filled 
----------------------------------
-- CLASS DATA SEGMENT 608 - 620 --
----------------------------------
,to_char(greatest(pe.empllasthiredate, '2018-11-01'),'yyyymmdd') ::char(8) as class_eff_date --- position 608
,'A001'::char(4) as class_id
--------------------------------------
-- SMOKING STATUS SEGMENT 620 - 629 --
-------------------------------------- 
,to_char(greatest(pv.effectivedate,'2018-11-01'),'yyyymmdd') ::char(8) as smoker_status_effective_date --- position 620
---Values: B - Both Subscriber & Spouse Smoke ; N - Neither Smoke; S - Subscriber Only Smokes; P - Spouse Only Smokes.
,pv.smoker ::char(1) as smoker_indicator
--------------------------
-- ELIGIBILITY SEGMENTS --
--------------------------
---------------------------------------------
-- BASIC LIFE (23) 810 - 832 -- LTL0NCFLAT --
---------------------------------------------
--------------------------------------
-- BASIC STD SEGMENT (30) 920 - 942 -- 
--------------------------------------
,case when pbestd.benefitsubclass in ('30') then 'S' else ' ' end ::char(1) as product_category_S
,case when pbestd.benefitsubclass in ('30') then to_char(greatest(pbestd.effectivedate,'2018-11-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_S
,case when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'T'  then 'TM' 
      when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_S
,case when pbestd.benefitsubclass in ('30') then 'STS00NCSAL' else ' ' end ::char(10) as plan_id_S
,case when pbestd.benefitsubclass in ('30') then 'C' else ' ' end ::char(1) as emp_only_S
--------------------------------------
-- BASIC LTD SEGMENT (31) 975 - 997 --
--------------------------------------
,case when pbeltd.benefitsubclass in ('31') then 'T' else ' ' end ::char(1) as product_category_T
,case when pbeltd.benefitsubclass in ('31') then to_char(greatest(pbeltd.effectivedate,'2018-11-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_T
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_T
,case when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' else ' ' end ::char(10) as plan_id_T
,case when pbeltd.benefitsubclass in ('31') then 'C' else ' ' end ::char(1) as emp_only_T
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
-------------------------------------------------------------
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) 1195 - 1239 --
------------------------------------------------------
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z ) 1250 - 1294 --
------------------------------------------------------
---------------------------------------------------------
-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349 --
--------------------------------------------------------- 
----------------------------
-- PCSTD (30) 1360 - 1382 --
----------------------------
------------------------------------
-- VOLUNTARY LTD (31) 1415 - 1437 --
------------------------------------
------------------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2CI,2CS) 1470 - 1514 --
------------------------------------------------------------------------
-------------------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2SI,2SS) 1525 - 1569 --
-------------------------------------------------------------
-----------------------------------------
-- VOLUNTARY ACCIDENT (13) 1855 - 1877 --
-----------------------------------------

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AUR_Mutual_Of_Omaha_Carrier_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pe.personid
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E','T')
  and pbe.benefitsubclass in ('30','31')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts   
  
left join 
     (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('30','31')
         and benefitelection in ('E') and selectedoption = 'Y'
       group by 1) pbe_max
  on pbe_max.personid = pbe.personid  
----------------
-- PCSTD (30) --
---------------- 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('30') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbestd on pbestd.personid = pbe.personid and pbestd.rank = 1 
------------------------  
-- VOLUNTARY LTD (31) --
------------------------    
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('31') and benefitelection in ('E','T') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbeltd on pbeltd.personid = pbe.personid and pbeltd.rank = 1 
   
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join (select personid, compamount, frequencycode, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts) desc) as rank
             from person_compensation where current_timestamp between createts and endts and current_date between effectivedate and enddate and compamount <> 0 and enddate >= '2199-12-30'
            group by personid, compamount, frequencycode) pc on pc.personid = pi.personid and pc.rank = 1 

left join (select personid, scheduledhours, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts) desc) as rank
            from pers_pos where current_timestamp between createts and endts 
           group by personid, scheduledhours) pp on pp.personid = pi.personid and pp.rank = 1   
 
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
   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus not in ('R', 'T')    
  
  UNION
  
select distinct
 pi.personid 
,pe.emplstatus
,1 as sort_seq 
,'9 TERMED EE BENEFITS' ::varchar(30) as qsource
----------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325 --
----------------------------------
,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000BF7F' ::char(8) as group_id
,'M' ::char(1) as relationship_code
,pi.identity ::char(9) as employee_id 
,ltrim(pn.lname) ::char(35) as elname
,ltrim(pn.fname) ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh --- position 309
,to_char(greatest(pe.empllasthiredate, '2018-11-01'),'yyyymmdd') ::char(8) as emp_eff_date --- position 317    
---------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405 --
---------------------------------------
,to_char(greatest(pbe_max.effectivedate, '2018-11-01'),'yyyymmdd') ::char(8) as sub_group_eff_date --- position 393
,'0001' ::char(4) as sub_group
---------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474 --
---------------------------------------
-----------------------------------
-- SALARY DATA SEGMENT 475 - 527 --
-----------------------------------
,to_char(greatest(pc.effectivedate, '2018-11-01'),'yyyymmdd') ::char(8) as basic_sal_eff_date --- position 475
,'A' ::char(1) as basic_sal_mode
,case when pc.frequencycode = 'H' then to_char(pc.compamount  * least(pp.scheduledhours,80) * 26 * 100, 'FM0000000000000000 ')
      else to_char(pc.compamount * 100, 'FM0000000000000000 ') end as basic_salary_amount -- assume decimal zero filled 
----------------------------------
-- CLASS DATA SEGMENT 608 - 620 --
----------------------------------
,to_char(greatest(pe.empllasthiredate, '2018-11-01'),'yyyymmdd') ::char(8) as class_eff_date --- position 608
,'A001'::char(4) as class_id
--------------------------------------
-- SMOKING STATUS SEGMENT 620 - 629 --
-------------------------------------- 
,to_char(greatest(pv.effectivedate,'2018-11-01'),'yyyymmdd') ::char(8) as smoker_status_effective_date --- position 620
---Values: B - Both Subscriber & Spouse Smoke ; N - Neither Smoke; S - Subscriber Only Smokes; P - Spouse Only Smokes.
,pv.smoker ::char(1) as smoker_indicator
--------------------------
-- ELIGIBILITY SEGMENTS --
--------------------------
---------------------------------------------
-- BASIC LIFE (23) 810 - 832 -- LTL0NCFLAT --
---------------------------------------------
--------------------------------------
-- BASIC STD SEGMENT (30) 920 - 942 -- 
--------------------------------------
,case when pbestd.benefitsubclass in ('30') then 'S' else ' ' end ::char(1) as product_category_S
,case when pbestd.benefitsubclass in ('30') then to_char(greatest(pbestd.enddate,'2018-11-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_S
,case when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'T'  then 'TM' 
      when pbestd.benefitsubclass in ('30') and pe.emplstatus in ('R','T') then 'TM' else '  ' end ::char(2) as elig_event_S
,case when pbestd.benefitsubclass in ('30') then 'STS00NCSAL' else ' ' end ::char(10) as plan_id_S
,case when pbestd.benefitsubclass in ('30') then 'C' else ' ' end ::char(1) as emp_only_S
--------------------------------------
-- BASIC LTD SEGMENT (31) 975 - 997 --
--------------------------------------
,case when pbeltd.benefitsubclass in ('31') then 'T' else ' ' end ::char(1) as product_category_T
,case when pbeltd.benefitsubclass in ('31') then to_char(greatest(pbeltd.enddate,'2018-11-01'),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_T
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pe.emplstatus in ('R','T') then 'TM' else '  ' end ::char(2) as elig_event_T
,case when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' else ' ' end ::char(10) as plan_id_T
,case when pbeltd.benefitsubclass in ('31') then 'C' else ' ' end ::char(1) as emp_only_T
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065 --
----------------------------------------------------------
----------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120 --
----------------------------------------------------------
-------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185 --
-------------------------------------------------------------
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (21 ) 1195 - 1239 --
------------------------------------------------------
------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z ) 1250 - 1294 --
------------------------------------------------------
---------------------------------------------------------
-- VOLUNTARTY AD&D COVERAGE DEPENDENT (2X) 1305 - 1349 --
--------------------------------------------------------- 
----------------------------
-- PCSTD (30) 1360 - 1382 --
----------------------------
------------------------------------
-- VOLUNTARY LTD (31) 1415 - 1437 --
------------------------------------
------------------------------------------------------------------------
-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2CI,2CS) 1470 - 1514 --
------------------------------------------------------------------------
-------------------------------------------------------------
-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2SI,2SS) 1525 - 1569 --
-------------------------------------------------------------
-----------------------------------------
-- VOLUNTARY ACCIDENT (13) 1855 - 1877 --
-----------------------------------------

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AUR_Mutual_Of_Omaha_Carrier_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join (select personid, benefitsubclass, benefitelection, personbeneelectionpid, selectedoption, createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('30','31') and benefitelection in ('E') and selectedoption = 'Y' and effectivedate < enddate
            group by 1,2,3,4,5,6) pbe on pbe.personid = pe.personid and pbe.rank = 1   

left join (select personid, max(effectivedate) as effectivedate
             from person_bene_election 
            where effectivedate < enddate
              and current_timestamp between createts and endts
              and benefitsubclass in ('30','31')
              and benefitelection in ('E')
              and selectedoption = 'Y'
            group by 1) pbe_max
      on pbe_max.personid = pbe.personid   
----------------
-- PCSTD (30) --
---------------- 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('30') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbestd on pbestd.personid = pbe.personid and pbestd.rank = 1 
------------------------  
-- VOLUNTARY LTD (31) --
------------------------    
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('31') and benefitelection in ('E') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and coverageamount > 0
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbeltd on pbeltd.personid = pbe.personid and pbeltd.rank = 1 
   
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join (select personid, compamount, frequencycode, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts) desc) as rank
             from person_compensation where createts < endts and effectivedate < enddate and compamount <> 0 
            group by personid, compamount, frequencycode) pc on pc.personid = pi.personid and pc.rank = 1 

left join (select personid, scheduledhours, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts) desc) as rank
            from pers_pos where current_timestamp between createts and endts and effectivedate < enddate
           group by personid, scheduledhours) pp on pp.personid = pi.personid and pp.rank = 1  
 
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
   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('R', 'T')    
  --- only need look back date on terms 
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')))
   
   order by 1