select distinct

 pi.personid
,'ACTIVE EE DEP BENEFIT' ::VARCHAR(30) AS SOURCESEQ
,1 as sort_seq 

-- DEMOGRAPHICS SEGMENT 1 - 325
,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9CJ' ::char(8) as group_id
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
--- address is only applicable for Dental
,' ' ::char(30) as addr1
,' ' ::char(30) as addr2
,' ' ::char(19) as city
,' ' ::char(2) state
,' ' ::char(11) as zip
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh -- position 309

,to_char(greatest
(pe.empllasthiredate
,pbe.effectivedate
,pbebSPvlife.effectivedate
,pbebDPvlife.effectivedate
,pbeadd.effectivedate
,pbebeeci.effectivedate
,pbebspci.effectivedate 
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

-- CLASS DATA SEGMENT 608 - 620
,null as class_eff_date 
,null as class_id

-- SMOKING STATUS SEGMENT 620 - 629
,' ' ::char(8) as smoker_status_effective_date
,' ' ::char(1) as smoker_indicator

-- ELIGIBILITY SEGMENTS
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065
,' ' ::char(1) as product_category_3
,' ' ::char(8) as pc_effective_date_3
,' ' ::char(2) as elig_event_3
,' ' ::char(10) as plan_id_3
,' ' ::char(1) as emp_only_3
,' ' ::char(8) as pc_nom_effective_date_3
,null as pc_nom_amount_3

-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120
,case when pdr.dependentrelationship in ('SP','DP') and pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pdr.dependentrelationship in ('SP','DP') and pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pdr.dependentrelationship in ('SP','DP') and pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'T'  then 'TM' 
      when pdr.dependentrelationship in ('SP','DP') and pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pdr.dependentrelationship in ('SP','DP') and pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pdr.dependentrelationship in ('SP','DP') and pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pdr.dependentrelationship in ('SP','DP') and pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pdr.dependentrelationship in ('SP','DP') and pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185
,case when pdr.dependentrelationship in ('S','D','C') and pbebDPvlife.benefitsubclass in ('2X') then '5' else ' ' end ::char(1) as product_category_5
,case when pdr.dependentrelationship in ('S','D','C') and pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pdr.dependentrelationship in ('S','D','C') and pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pdr.dependentrelationship in ('S','D','C') and pbebDPvlife.benefitsubclass in ('2X') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pdr.dependentrelationship in ('S','D','C') and pbebDPvlife.benefitsubclass in ('2X') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pdr.dependentrelationship in ('S','D','C') and pbebDPvlife.benefitsubclass in ('2X') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pdr.dependentrelationship in ('S','D','C') and pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pdr.dependentrelationship in ('S','D','C') and pbebDPvlife.benefitsubclass in ('2X') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

-- VOLUNTARY AD&D COVERAGE MEMBER (27 ) 1195 - 1239

,' ' ::char(1) as product_category_c
,' ' ::char(8) as pc_effective_date_c
,' ' ::char(2) as elig_event_c
,' ' ::char(10) as plan_id_c
,' ' ::char(1) as emp_only_c
,' ' ::char(8) as pc_nom_effective_date_c
,null as pc_nom_amount_c

-- VOLUNTARY AD&D COVERAGE SPOUSE (27 ) 1250 - 1294

,case when pdr.dependentrelationship in ('SP','DP') and pbeadd.benefitsubclass in ('27') then 'e' else ' ' end ::char(1) as product_category_e
,case when pdr.dependentrelationship in ('SP','DP') and pbeadd.benefitsubclass in ('27') then to_char(pbeadd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_e
,case when pdr.dependentrelationship in ('SP','DP') and pbeadd.benefitsubclass in ('27') and pbeadd.benefitelection = 'T'  then 'TM' 
      when pdr.dependentrelationship in ('SP','DP') and pbeadd.benefitsubclass in ('27') and pbeadd.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_e
,case when pdr.dependentrelationship in ('SP','DP') and pbeadd.benefitsubclass in ('27') then 'BTA0CEEVAL' else ' ' end ::char(10) as plan_id_e
,case when pdr.dependentrelationship in ('SP','DP') and pbeadd.benefitsubclass in ('27') then 'C' else ' ' end ::char(1) as emp_only_e
,case when pdr.dependentrelationship in ('SP','DP') and pbeadd.benefitsubclass in ('27') then to_char(pbeadd.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_e
,case when pdr.dependentrelationship in ('SP','DP') and pbeadd.benefitsubclass in ('27') then to_char(pbeadd.coverageamount, 'FM0000000000') else null end as pc_nom_amount_e

-- VOLUNTARY AD&D COVERAGE DEPENDENT (27 ) 1305 - 1349

,case when pdr.dependentrelationship in ('S','D','C') and pbeadd.benefitsubclass in ('27') then 'd' else ' ' end ::char(1) as product_category_d
,case when pdr.dependentrelationship in ('S','D','C') and pbeadd.benefitsubclass in ('27') then to_char(pbeadd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_d
,case when pdr.dependentrelationship in ('S','D','C') and pbeadd.benefitsubclass in ('27') and pbeadd.benefitelection = 'T'  then 'TM' 
      when pdr.dependentrelationship in ('S','D','C') and pbeadd.benefitsubclass in ('27') and pbeadd.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_d
,case when pdr.dependentrelationship in ('S','D','C') and pbeadd.benefitsubclass in ('27') then 'BTA0CEEVAL' else ' ' end ::char(10) as plan_id_d
,case when pdr.dependentrelationship in ('S','D','C') and pbeadd.benefitsubclass in ('27') then 'C' else ' ' end ::char(1) as emp_only_d
,case when pdr.dependentrelationship in ('S','D','C') and pbeadd.benefitsubclass in ('27') then to_char(pbeadd.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_d
,case when pdr.dependentrelationship in ('S','D','C') and pbeadd.benefitsubclass in ('27') then to_char(pbeadd.coverageamount, 'FM0000000000') else null end as pc_nom_amount_d

-- VOLUNTARY STD (30) 1360 - 1382

,' ' ::char(1) as product_category_Q
,' ' ::char(8) as pc_effective_date_Q
,' ' ::char(2) as elig_event_Q
,' ' ::char(10) as plan_id_Q
,' ' ::char(1) as emp_only_Q

-- VOLUNTARY LTD (31) 1415 - 1437

,' ' ::char(1) as product_category_L
,' ' ::char(8) as pc_effective_date_L
,' ' ::char(2) as elig_event_L
,' ' ::char(10) as plan_id_L
,' ' ::char(1) as emp_only_L


-- VOLUNTARY EMPLOYEE/CHILDREN CRITICAL ILLNESS (2C) 1470 - 1514

,case when pbebeeci.benefitsubclass in ('2C') then 'A' else ' ' end ::char(1) as product_category_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(pbebeeci.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_A
,case when pbebeeci.benefitsubclass in ('2C') and pbebeeci.benefitelection = 'T'  then 'TM' 
      when pbebeeci.benefitsubclass in ('2C') and pbebeeci.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_A
,case when pbebeeci.benefitsubclass in ('2C') then '3CI00EDVAB' else ' ' end ::char(10) as plan_id_A
,case when pbebeeci.benefitsubclass in ('2C') then 'C' else ' ' end ::char(1) as emp_only_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(pbebeeci.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as elaprv_effective_date_A
,case when pbebeeci.benefitsubclass in ('2C') then to_char(pbebeeci.coverageamount, 'FM0000000000') else null end as elaprv_amount_A

-- VOLUNTARY SPOUSE CRITICAL ILLNESS (2S) 1525 - 1569

,case when pbebspci.benefitsubclass in ('2S') then 'J' else ' ' end ::char(1) as product_category_J
,case when pbebspci.benefitsubclass in ('2S') then to_char(pbebspci.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_J
,case when pbebspci.benefitsubclass in ('2S') and pbebspci.benefitelection = 'T'  then 'TM' 
      when pbebspci.benefitsubclass in ('2S') and pbebspci.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_J
,case when pbebspci.benefitsubclass in ('2S') then '3CI00SPVAB' else ' ' end ::char(10) as plan_id_J
,case when pbebspci.benefitsubclass in ('2S') then 'C' else ' ' end ::char(1) as emp_only_J
,case when pbebspci.benefitsubclass in ('2S') then to_char(pbebspci.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as elaprv_effective_date_J
,case when pbebspci.benefitsubclass in ('2S') then to_char(pbebspci.coverageamount, 'FM0000000000') else null end as elaprv_amount_J

from person_identity pi


left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_bene_election pbe
  on pbe.personid = pi.personid
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in ('2Z','2X','27','2C','2S')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts

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

left join person_bene_election pbeadd
  on pbeadd.personid = pi.personid
 and pbeadd.benefitsubclass in ('27')
 and pbeadd.benefitelection in ('E')
 and pbeadd.selectedoption = 'Y' 
 and current_date between pbeadd.effectivedate and pbeadd.enddate
 and current_timestamp between pbeadd.createts and pbeadd.endts  
 
left join person_bene_election pbebeeci
  on pbebeeci.personid = pi.personid
 and pbebeeci.benefitsubclass in ('2C')
 and pbebeeci.benefitelection in ('E')
 and pbebeeci.selectedoption = 'Y' 
 and current_date between pbebeeci.effectivedate and pbebeeci.enddate
 and current_timestamp between pbebeeci.createts and pbebeeci.endts    

left join person_bene_election pbebspci
  on pbebspci.personid = pi.personid
 and pbebspci.benefitsubclass in ('2S')
 and pbebspci.benefitelection in ('E')
 and pbebspci.selectedoption = 'Y' 
 and current_date between pbebspci.effectivedate and pbebspci.enddate
 and current_timestamp between pbebspci.createts and pbebspci.endts  

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
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
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.compamount > 0
 
left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
   
left join    
(select distinct 
  pp.personid
 ,pdx.distinctpayperiods as distinctpayperiods
 from pers_pos pp 
 left join person_compensation pc 
   on pp.personid = pc.personid
  and pc.earningscode in ('Regular','ExcHrly', 'RegHrly')
  and current_date between pc.effectivedate and pc.enddate
  and current_timestamp between pc.createts and pc.endts
  and pc.frequencycode <> 'H'       
 join (select pd.personid
           , psp.payunitid
           , sum(case when peo.etvoperatorpid is null then pd.etype_hours else 0 end) as workedhours
           , extract(year from pd.check_date) as payyear
           , count(distinct psp.payscheduleperiodid) as distinctpayperiods
        from pspay_payment_header ph
        join pspay_payment_detail pd 
          on pd.paymentheaderid = ph.paymentheaderid
         and pd.personid = ph.personid
        join pay_schedule_period psp 
          on ph.payscheduleperiodid = psp.payscheduleperiodid
         and psp.payrolltypeid = 1 ----- NORMAL
        left join pspay_etv_operators peo 
          on peo.group_key = pd.group_key
         and peo.etv_id = pd.etv_id 
         and current_timestamp between peo.createts and peo.endts
         and peo.operand = 'WS102'
         and peo.opcode = 'A'
       where extract(year from pd.check_date) = extract(year from current_date)
       group by pd.personid, extract(year from pd.check_date), psp.payunitid)pdx 
  on pp.personid = pdx.personid
  
 join frequency_codes fcpos 
   on pp.schedulefrequency = fcpos.frequencycode
 join pay_unit pu on pdx.payunitid = pu.payunitid
 join frequency_codes fcpay on pu.frequencycode = fcpay.frequencycode               
 where current_date between pp.effectivedate and pp.enddate
   and current_Timestamp between pp.createts and pp.endts
 ) payp on payp.personid = pi.personid


--- some cases where there's been a manual adj and the only info I can find for hours is for payrolltypeid = 2 

left join    
(select distinct 
  pp.personid
 ,pdx.distinctpayperiods as distinctpayperiods
 from pers_pos pp 
 left join person_compensation pc 
   on pp.personid = pc.personid
  and pc.earningscode in ('Regular','ExcHrly', 'RegHrly')
  and current_date between pc.effectivedate and pc.enddate
  and current_timestamp between pc.createts and pc.endts
  and pc.frequencycode <> 'H'       
 join (select pd.personid
           , psp.payunitid
           , sum(case when peo.etvoperatorpid is null then pd.etype_hours else 0 end) as workedhours
           , extract(year from pd.check_date) as payyear
           , count(distinct psp.payscheduleperiodid) as distinctpayperiods
        from pspay_payment_header ph
        join pspay_payment_detail pd 
          on pd.paymentheaderid = ph.paymentheaderid
         and pd.personid = ph.personid
        join pay_schedule_period psp 
          on ph.payscheduleperiodid = psp.payscheduleperiodid
         and psp.payrolltypeid = 2 ----- NORMAL
        left join pspay_etv_operators peo 
          on peo.group_key = pd.group_key
         and peo.etv_id = pd.etv_id 
         and current_timestamp between peo.createts and peo.endts
         and peo.operand = 'WS102'
         and peo.opcode = 'A'
       where extract(year from pd.check_date) = extract(year from current_date)
       group by pd.personid, extract(year from pd.check_date), psp.payunitid)pdx 
  on pp.personid = pdx.personid
  
 join frequency_codes fcpos 
   on pp.schedulefrequency = fcpos.frequencycode
 join pay_unit pu on pdx.payunitid = pu.payunitid
 join frequency_codes fcpay on pu.frequencycode = fcpay.frequencycode               
 where current_date between pp.effectivedate and pp.enddate
   and current_Timestamp between pp.createts and pp.endts
 ) payp2 on payp2.personid = pi.personid


----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and pdr.dependentrelationship in ('S','D','C','DP','SP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 -- select dependentrelationship from person_dependent_relationship group by 1;
 -- select * from dependent_relationship;

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.personid = pbe.personid
 and de.benefitsubclass in ('2Z','2X','27','2C','2S')
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
  and pe.emplstatus <> 'T'
  and pdr.dependentrelationship in ('S','D','C','DP','SP')
  and pbe.benefitsubclass in ('2Z','2X','27','2C','2S')
  and pi.personid = '920'  
  
  order by 1,2
