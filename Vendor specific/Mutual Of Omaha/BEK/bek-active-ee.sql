select distinct
 pi.personid 
,'ACTIVE EE BENEFIT' ::VARCHAR(20) AS SOURCESEQ
,0 as sort_seq 
-- DEMOGRAPHICS SEGMENT 1 - 325

,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000B9K3' ::char(8) as group_id
,'M' ::char(1) as relationship_code

,pi.identity ::char(9) as employee_id 
,pn.lname ::char(35) as elname
,pn.fname ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
-- Address fields are only required if Dental is covered, but can be provided for all if easier
,case when pbedent.benefitsubclass = '11' then pa.streetaddress else ' '  end ::char(30) as addr1
,case when pbedent.benefitsubclass = '11' then pa.streetaddress2 else ' ' end ::char(30) as addr2
,case when pbedent.benefitsubclass = '11' then pa.city else ' ' end ::char(19) as city
,case when pbedent.benefitsubclass = '11' then pa.stateprovincecode else ' ' end ::char(2) state
,case when pbedent.benefitsubclass = '11' then pa.postalcode else ' ' end ::char(11) as zip

,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh -- position 309

,to_char(greatest
(pe.empllasthiredate
,pbe.effectivedate
,pbelife.effectivedate
,pbestd.effectivedate
,pbeltd.effectivedate
,pbebeevlife.effectivedate
,pbebSPvlife.effectivedate
,pbebDPvlife.effectivedate 
), 'YYYYMMDD')::char(8) as emp_eff_date -- Either 1/1/18 (Benefit Plan Year) or Last Hired Date, whichever is greater

-- BILL GROUP DATA SEGMENT 393 - 405
,to_char(greatest
(pe.empllasthiredate
,pbe.effectivedate
,pbelife.effectivedate
,pbestd.effectivedate
,pbeltd.effectivedate
,pbebeevlife.effectivedate
,pbebSPvlife.effectivedate
,pbebDPvlife.effectivedate 
), 'YYYYMMDD')::char(8) as sub_group_eff_date -- Either 1/1/18 (Benefit Plan Year) or Last Hired Date, whichever is greater
,'0001' ::char(4) as sub_group

-- EMPLOYMENT DATA SEGMENT 405 - 474

-- SALARY DATA SEGMENT 475 - 527

,to_char(greatest
(pe.effectivedate
,pbe.effectivedate
,pbelife.effectivedate
,pbestd.effectivedate
,pbeltd.effectivedate
,pbebeevlife.effectivedate
,pbebSPvlife.effectivedate
,pbebDPvlife.effectivedate 
), 'YYYYMMDD')::char(8) as  basic_sal_eff_date -- Either 1/1/18 (Benefit Plan Year) or Salary Effective Date, whichever is greater
,'A' ::char(1) as basic_sal_mode

,case when pc.frequencycode = 'H' then to_char(((pc.compamount * pp.scheduledhours) * 24)*100, 'FM0000000000000000')
      else to_char(pc.compamount * 100, 'FM0000000000000000') end ::char(16) as basic_salary_amount -- assume decimal zero fill
      
,' ' ::char(2) as first_add_comp_type
,' ' ::char(16) as first_add_comp_amt

      
-- CLASS DATA SEGMENT 608 620

,to_char(greatest
(pe.effectivedate
,pbe.effectivedate
,pbelife.effectivedate
,pbestd.effectivedate
,pbeltd.effectivedate
,pbebeevlife.effectivedate
,pbebSPvlife.effectivedate
,pbebDPvlife.effectivedate 
), 'YYYYMMDD')::char(8) as class_eff_date -- Either 1/1/18 (Benefit Plan Year) or Salary Effective Date (if Salary Amount changed to make EE earnings over $100K), whichever is greater

,case when pi.personid = '139' then 'A001'
      when pc.compamount >= 100000.00 then 'A002'
      else 'A003' end ::char(4) as class_id 
-- Class ID: A001 for Owner (Eric Lund is only owner-Teleshia looking into how this is tracked in eHCM), A002 EE's over $100K, A003 All Others
-- Dental Benefit Wait Period / Late Entrant: Usually N, but if New Hire in current Plan Year enrolled in Dental 
-- more than 31 days from Hire Date, this field will be Y
--,age(current_date,pe.effectivedate) as age
--- dental late entrant waiting period indicator
,case when date_part('year',pe.effectivedate) = date_part('year',current_date) and pbedent.benefitsubclass = '11' 
           and age(current_date,pe.effectivedate) > '1 mon' then 'Y' else 'N' end ::char(1) as dent_prd_wait_prd

-- SMOKING STATUS SEGMENT 620 -629


-- ELIGIBILITY SEGMENTS
-- DENTAL (11) 755 - 777
,case when pbedent.benefitsubclass in ('11') then 'D' else ' ' end ::char(1) as product_category_D
,case when pbedent.benefitsubclass in ('11') then to_char(pbedent.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_D
,case when pbedent.benefitsubclass in ('11') and pbedent.benefitelection = 'T'  then 'TM' 
      when pbedent.benefitsubclass in ('11') and pbedent.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_D
,case when pbedent.benefitsubclass in ('11') then 'DTP0000200' else ' ' end ::char(10) as plan_id_D
,case when pbedent.benefitsubclass in ('11') and bcd.benefitcoveragedesc = 'Family' then 'A' 
      when pbedent.benefitsubclass in ('11') and bcd.benefitcoveragedesc = 'Employee + Spouse' then 'B' 
      when pbedent.benefitsubclass in ('11') and bcd.benefitcoveragedesc = 'Employee Only' then 'C' 
      when pbedent.benefitsubclass in ('11') and bcd.benefitcoveragedesc = 'Employee + Children' then 'D' 
      else ' ' end ::char(1) as emp_only_D


-- BASIC LIFE (20) 810 - 832
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,case when pbelife.benefitsubclass in ('20') then '1' else ' ' end ::char(1) as product_category_1
,case when pbelife.benefitsubclass in ('20') then to_char(pbelife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_1
,case when pbelife.benefitsubclass in ('20') and pbelife.benefitelection = 'T'  then 'TM' 
      when pbelife.benefitsubclass in ('20') and pbelife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_1
,case when pbelife.benefitsubclass in ('20') then 'LTL0NCFLAT' else ' ' end ::char(10) as plan_id_1
,case when pbelife.benefitsubclass in ('20') then 'C' else ' ' end ::char(1) as emp_only_1

-- BASIC AD&D (20) 865 - 887
---- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
,case when pbelife.benefitsubclass in ('20') then 'a' else ' ' end ::char(1) as product_category_a
,case when pbelife.benefitsubclass in ('20') then to_char(pbelife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_a
,case when pbelife.benefitsubclass in ('20') and pbelife.benefitelection = 'T'  then 'TM' 
      when pbelife.benefitsubclass in ('20') and pbelife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_a
,case when pbelife.benefitsubclass in ('20') then 'ATA0NCFLAT' else ' ' end ::char(10) as plan_id_a
,case when pbelife.benefitsubclass in ('20') then 'C' else ' ' end ::char(1) as emp_only_a

-- BASIC STD SEGMENT (30) 920 - 942
,case when pbestd.benefitsubclass in ('30') then 'S' else ' ' end ::char(1) as product_category_S
,case when pbestd.benefitsubclass in ('30') then to_char(pbestd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_S
,case when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'T'  then 'TM' 
      when pbestd.benefitsubclass in ('30') and pbestd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_S
,case when pbestd.benefitsubclass in ('30') then 'STS00NCSAL' else ' ' end ::char(10) as plan_id_S
,case when pbestd.benefitsubclass in ('30') then 'C' else ' ' end ::char(1) as emp_only_S

-- BASIC LTD SEGMENT (31) 975 - 997
,case when pbeltd.benefitsubclass in ('31') then 'T' else ' ' end ::char(1) as product_category_T
,case when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_T
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_T
,case when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' else ' ' end ::char(10) as plan_id_T
,case when pbeltd.benefitsubclass in ('31') then 'C' else ' ' end ::char(1) as emp_only_T

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

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (2X) 1140 - 1185
,case when pbebDPvlife.benefitsubclass in ('25') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

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
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in ('11','20','30','31','21','2Z','25')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts   
   
left join person_bene_election pbedent
  on pbedent.personid = pi.personid
 and pbedent.benefitsubclass in ('11')
 and pbedent.benefitelection in ('E')
 and pbedent.selectedoption = 'Y' 
 and current_date between pbedent.effectivedate and pbedent.enddate
 and current_timestamp between pbedent.createts and pbedent.endts  

left join (select pbe.personid,bcd.benefitcoveragedesc,bcd.benefitcoverageid       
  from person_bene_election pbe
  join benefit_coverage_desc bcd
    on bcd.benefitcoverageid = pbe.benefitcoverageid
   and current_date between bcd.effectivedate and bcd.enddate
   and current_timestamp between bcd.createts and bcd.endts  
 where pbe.benefitsubclass = '11'
   and pbe.benefitelection in ('E')
   and pbe.selectedoption = 'Y'
   group by 1,2,3
   ) bcd on bcd.personid = pbe.personid 
        and bcd.benefitcoverageid = pbedent.benefitcoverageid  

left join person_bene_election pbelife
  on pbelife.personid = pi.personid
 and pbelife.benefitsubclass in ('20')
 and pbelife.benefitelection in ('E')
 and pbelife.selectedoption = 'Y' 
 and current_date between pbelife.effectivedate and pbelife.enddate
 and current_timestamp between pbelife.createts and pbelife.endts  

left join person_bene_election pbestd
  on pbestd.personid = pi.personid
 and pbestd.benefitsubclass in ('30')
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
-- and pc.earningscode in ('ExcHrly','RegHrly','Regular' )
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.compamount > 0
 --and pc.compevent not in ('Add','Pos')
 
left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
  
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
  and pe.emplstatus <> 'T'
  --and pi.personid = '213'