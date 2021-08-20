
select

-- !!!!!!!!! Active EMPLOYEES 
-- BENEFITS ARE ACTIVE
-- THE ELIGIBILITY EVENT WILL BE BASED OFF BENEFIT STATUS

----------------------------------------------------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325
----------------------------------------------------------------------------
pi.personid
,1 as sort_seq
, to_char(current_date,'YYYYMMDD')::char(8) as trans_date  -- col 1
,'G000AVJ2' ::char(8) as group_id   -- col 2
, 'M' ::char(1) as relationship_code     -- col 3 
,pi.identity ::char(9) as employee_id     -- col 4
,pn.lname ::char(35) as elname   -- col 5
,pn.fname ::char(15) as efname      -- col 6
,case when pv.gendercode is not null then pv.gendercode else 'U' end ::char(1) as egender   -- col 7
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob   -- col 8
,to_char(greatest(pe.emplhiredate,pe.effectivedate),'YYYYMMDD') ::char(8) as doh     -- col 9
,to_char(greatest(pe.effectivedate,lookup.planyear::date),'yyyymmdd')::char(8) as emp_eff_date -- bring forward all effective date starting at 317 to reset date 11/01/2018 do not alter dates after reset date   -- col 10
----------------------------------------------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405
----------------------------------------------------------------------------
,to_char(greatest(pe.effectivedate,lookup.planyear::date),'yyyymmdd')::char(8) as sub_group_eff_date   -- col 11
,'0001' ::char(4) as sub_group     -- col 12
----------------------------------------------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474
----------------------------------------------------------------------------
,to_char(greatest(pl.effectivedate,lookup.planyear::date),'yyyymmdd')::char(8) as location_effective_date -- effectivedate of the subscribers location  -- col 13

,case when pu.payunitxid = '00' then '001'
      when pu.payunitxid = '05' then '002'
      when pu.payunitxid = '15' then '003'
      when pu.payunitxid = '10' then '004' else '' end ::char(8) as location_id     -- col 14
,case when pu.payunitxid = '00' then 'Land View'
      when pu.payunitxid = '05' then 'Two Rivers'
      when pu.payunitxid = '15' then 'Native Earth LLC'
      when pu.payunitxid = '10' then 'Royal Innovative Solut' else '' end ::char(23) as location_description       -- col 15
----------------------------------------------------------------------------
-- SALARY DATA SEGMENT 475 - 500
----------------------------------------------------------------------------
, to_char(greatest(pc.effectivedate,rankpc.effectivedate,lookup.planyear::date),'yyyymmdd')::char(8) as basic_sal_eff_date -- effective date of employee's salary compensation    -- col 16
,'A' ::char(1) as basic_sal_mode    -- col 17
,case when coalesce(pc.frequencycode,rankpc.frequencycode) = 'H' then case when pp.schedulefrequency = 'W' then to_char(coalesce(pc.compamount,rankpc.compamount) * pp.scheduledhours * 52 * 100 ,'FM0000000000000000') 
	else to_char(coalesce(pc.compamount,rankpc.compamount) * pp.scheduledhours * 26 * 100 ,'FM0000000000000000') end
	else to_char(coalesce(pc.compamount,rankpc.compamount) * 100 ,'FM0000000000000000') end as basic_salary_amount -- assume decimal zero filled     --col 18                            
----------------------------------------------------------------------------
-- ADDITONAL COMPENSATION SEGMENT 500-608
---------------------------------------------------------------------------- 
                                  
-- Commission                                      
,case when ppd2.commission is not null and ppd2.commission <> 0 then extract(year from current_date) || '0101' else null end ::char(8) as add_comp_eff_date01 -- effective date of employee's commission compensation    -- col 19
,case when ppd2.commission is not null and ppd2.commission <> 0 then 'A' else null end ::char(1) as add_comp_mode01    -- col 20
,case when ppd2.commission is not null and ppd2.commission <> 0 then '01' else null end ::char(2) as add_comp_type01   -- col 21
,case when ppd2.commission is not null and ppd2.commission > 0 then to_char(ppd2.commission * 100, 'FM0000000000000000') 
  when ppd2.commission < 0 then to_char(abs(ppd2.commission::decimal) *100,'FM0000000000000000')::char(16)
   else null end ::char(16) as add_comp_amount01 -- assume decimal zero filled     --col 22
 
 -- Bonus                                       
,case when ppd2.bonus is not null and ppd2.bonus <> 0 then extract(year from current_date) || '0101' else null end ::char(8) as add_comp_eff_date02 -- effective date of employee's bonus compensation    -- col 23
,case when ppd2.bonus is not null and ppd2.bonus <> 0 then 'A' else null end ::char(1) as add_comp_mode02    -- col 24
,case when ppd2.bonus is not null and ppd2.bonus <> 0 then '02' else null end ::char(2) as add_comp_type02   -- col 25
,case when ppd2.bonus is not null and ppd2.bonus > 0 then to_char(ppd2.bonus * 100, 'FM0000000000000000') 
   when ppd2.bonus < 0 then to_char(abs(ppd2.bonus::decimal) *100,'FM0000000000000000')::char(16)
   else null end ::char(16) as add_comp_amount02 -- assume decimal zero filled     --col 26                                        
  
 -- Overtime                                         
,case when ppd2.overtime is not null and ppd2.overtime <> 0 then extract(year from current_date) || '0101' else null end ::char(8) as add_comp_eff_date03 -- effective date of employee's commission compensation    -- col 27
,case when ppd2.overtime is not null and ppd2.overtime <> 0 then 'A' else null end ::char(1) as add_comp_mode03    -- col 28
,case when ppd2.overtime is not null and ppd2.overtime <> 0 then '03' else null end ::char(2) as add_comp_type03   -- col 29
,case when ppd2.overtime is not null and ppd2.overtime > 0 then to_char(ppd2.overtime * 100, 'FM0000000000000000')
  when ppd2.overtime < 0 then to_char(abs(ppd2.overtime::decimal) *100,'FM0000000000000000')::char(16)
  else null end ::char(16) as add_comp_amount03 -- assume decimal zero filled     --col 30
                                               
----------------------------------------------------------------------------                                               
-- CLASS DATA SEGMENT 608 620
----------------------------------------------------------------------------
,to_char(greatest(ppay.effectivedate,cppy.planyearstart::date), 'YYYYMMDD')::char(8) as class_eff_date   -- col 31

-- salaried A001 | full-time hourly not at Two Rivers A002 | Full-time hourly at Two Rivers A003
, case when (pd.grade = '2' or pufv.ufid = '1' or coalesce(pc.frequencycode,rankpc.frequencycode) <> 'H')  then  'A001'
		when coalesce(pc.frequencycode,rankpc.frequencycode) = 'H' and pd.grade <> '2' and pu.payunitxid <> '05' then 'A002' 
		when coalesce(pc.frequencycode,rankpc.frequencycode) = 'H' and pd.grade <> '2' and pu.payunitxid = '05' then 'A003'  
        	else null end ::char(4) as class_id      -- col 32       
----------------------------------------------------------------------------                                              
-- ELIGIBILITY SEGMENTS
-- BASIC LIFE (23) 810 - 832
-- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
----------------------------------------------------------------------------
,case when pbelife.benefitsubclass in ('23') then '1' else ' ' end ::char(1) as product_category_1  -- col 33
,case when pbelife.benefitsubclass in ('23') then to_char(greatest(pbelife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_1   -- col 34
,case when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'T'  then 'TM' 
      when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_1   -- col 35
,case when pbelife.benefitsubclass in ('23') then 'LTL0NCFLAT' else ' ' end ::char(10) as plan_id_1     -- col 36
,case when pbelife.benefitsubclass in ('23') then 'C' else ' ' end ::char(1) as emp_only_1      -- col 37
----------------------------------------------------------------------------
-- BASIC AD&D (23) 865 - 887
-- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
----------------------------------------------------------------------------
,case when pbelife.benefitsubclass in ('23') then 'a' else ' ' end ::char(1) as product_category_a      -- col 38
,case when pbelife.benefitsubclass in ('23') then to_char(greatest(pbelife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_a   -- col 39
,case when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'T'  then 'TM' 
      when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_a   -- col 40
,case when pbelife.benefitsubclass in ('23') then 'ATA0NCFLAT' else ' ' end ::char(10) as plan_id_a     -- col 41
,case when pbelife.benefitsubclass in ('23') then 'C' else ' ' end ::char(1) as emp_only_a      -- col 42
----------------------------------------------------------------------------
-- BASIC LTD SEGMENT (31,32) 975 - 997
----------------------------------------------------------------------------                         
,case when pbeltd.benefitsubclass in ('31','32','3Z') then 'T' else ' ' end ::char(1) as product_category_T      -- col 43
,case when pbeltd.benefitsubclass in ('31','32','3Z') then to_char(greatest(pbeltd.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_T    -- col 44
,case when pbeltd.benefitsubclass in ('31','32','3Z') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31','32','3Z') and pbeltd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_T    -- col 45
,case when pbeltd.benefitsubclass in ('31','32','3Z') then 'TTT00NCSAL' else ' ' end ::char(10) as plan_id_T     -- col 46
,case when pbeltd.benefitsubclass in ('31','32','3Z') then 'C' else ' ' end ::char(1) as emp_only_T      -- col 47
----------------------------------------------------------------------------                                               
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21,2L) 1030 - 1065
----------------------------------------------------------------------------
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then '3' else ' ' end ::char(1) as product_category_3     -- col 48
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then to_char(greatest(pbebeevlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_3      -- col 49
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection = 'T'  and pbebeevlife.coverageamount <> 0 then 'TM' 
      when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection = 'E'  and pbebeevlife.coverageamount <> 0 then 'EN' else ' ' end ::char(2) as elig_event_3   -- col 50
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then 'ETL0CEEVAL' else ' ' end ::char(10) as plan_id_3        -- col 51
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_3     -- col 52
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection <> 'W' and pbebeevlife.coverageamount <> 0 then to_char(greatest(pbebeevlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_3   -- col 53
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection <> 'W' and pbebeevlife.coverageamount <> 0 then to_char(pbebeevlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_3      -- col 54
----------------------------------------------------------------------------                                        
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z,2V) 1085 - 1120
----------------------------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then '4' else ' ' end ::char(1) as product_category_4     -- col 55
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then to_char(greatest(pbebSPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4      -- col 56
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection = 'T'  and pbebSPvlife.coverageamount <> 0 then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection = 'E'  and pbebSPvlife.coverageamount <> 0 then 'EN' else '  ' end ::char(2) as elig_event_4      -- col 57
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4        -- col 58
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_4     -- col 59
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection <> 'W' and pbebSPvlife.coverageamount <> 0 then to_char(greatest(pbebSPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4   -- col 60
,case when pbebspvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection <> 'W' and pbebSPvlife.coverageamount <> 0 then to_char(pbebspvlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_4     -- col 61
----------------------------------------------------------------------------                                          
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (25,2C) 1140 - 1185
----------------------------------------------------------------------------
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then '5' else ' ' end ::char(1) as product_category_5     -- col 62
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then to_char(greatest(pbebDPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5  -- col 63
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection = 'T'  and pbebDPvlife.coverageamount <> 0 then 'TM' 
      when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection = 'E'  and pbebDPvlife.coverageamount <> 0 then 'EN' else '  ' end ::char(2) as elig_event_5  -- col 64
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5    -- col 65
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_5     -- col 66
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection <> 'W' and pbebDPvlife.coverageamount <> 0 then to_char(greatest(pbebDPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5    -- col 67
,case when pbebdpvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection <> 'W' and pbebDPvlife.coverageamount <> 0 then to_char(pbebdpvlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_5     -- col 68
----------------------------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (21,2L) 1195 - 1239
----------------------------------------------------------------------------
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then 'c' else ' ' end ::char(1) as product_category_c     -- col 69
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then to_char(greatest(pbebeevlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_c  -- col 70
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection = 'T'  and pbebeevlife.coverageamount <> 0 then 'TM' 
      when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection = 'E'  and pbebeevlife.coverageamount <> 0 then 'EN' else ' ' end ::char(2) as elig_event_c   -- col 71
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then 'BTA0CEEVAL' else ' ' end ::char(10) as plan_id_c    -- col 72
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_c     -- col 73
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection <> 'W' and pbebeevlife.coverageamount <> 0 then to_char(greatest(pbebeevlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_c   -- col 74
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection <> 'W' and pbebeevlife.coverageamount <> 0 then to_char(pbebeevlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_c      -- col 75
----------------------------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z,2V) 1250 - 1294
----------------------------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then 'e' else ' ' end ::char(1) as product_category_e     -- col 76
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then to_char(greatest(pbebSPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_e      -- col 77
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection = 'T'  and pbebSPvlife.coverageamount <> 0 then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection = 'E'  and pbebSPvlife.coverageamount <> 0 then 'EN' else '  ' end ::char(2) as elig_event_e      -- col 78
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then 'BTA0CSPVAL' else ' ' end ::char(10) as plan_id_e        -- col 79
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_e         -- col 80
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection <> 'W' and pbebSPvlife.coverageamount <> 0 then to_char(greatest(pbebSPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_e    -- col 81
,case when pbebspvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection <> 'W' and pbebSPvlife.coverageamount <> 0 then to_char(pbebspvlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_e      -- col 82
----------------------------------------------------------------------------
-- VOLUNTARTY AD&D COVERAGE DEPENDENT (25,2C) 1305 - 1349
----------------------------------------------------------------------------
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then 'd' else ' ' end ::char(1) as product_category_d      -- col 83
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then to_char(greatest(pbebDPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_d       -- col 84
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection = 'T'  and pbebDPvlife.coverageamount <> 0 then 'TM' 
      when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection = 'E'  and pbebDPvlife.coverageamount <> 0 then 'EN' else '  ' end ::char(2) as elig_event_d       -- col 85
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then 'BTA0CDPVAL' else ' ' end ::char(10) as plan_id_d         -- col 86
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_d          -- col 87
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection <> 'W' and pbebDPvlife.coverageamount <> 0 then to_char(greatest(pbebDPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_d     -- col 88
,case when pbebdpvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection <> 'W' and pbebDPvlife.coverageamount <> 0 then to_char(pbebdpvlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_d      -- col 89
----------------------------------------------------------------------------                                             
-- DEP LIFE-BASIC NON CONTRIB (2X,2Y) 1635 - 1656
----------------------------------------------------------------------------                                             
,case when pbedlb.benefitsubclass in ('2X','2Y') then '6' else ' ' end ::char(1) as product_category_6       -- col 90
,case when pbedlb.benefitsubclass in ('2X','2Y') then to_char(greatest(pbedlb.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_6    -- col 91
,case when pbedlb.benefitsubclass in ('2X','2Y') and pbedlb.benefitelection = 'T'  then 'TM' 
      when pbedlb.benefitsubclass in ('2X','2Y') and pbedlb.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_6     -- col 92
,case when pbedlb.benefitsubclass in ('2X','2Y') then 'LTL00NCDEP' else ' ' end ::char(10) as plan_id_6     -- col 93
,case when pbedlb.benefitsubclass in ('2X','2Y') then 'C' else ' ' end ::char(1) as emp_only_6               -- col 94                        
               
                                                                           
from person_identity pi
----------------------------------------------------------------------------
-- POSITION JOINS
----------------------------------------------------------------------------
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

LEFT join (select personid, schedulefrequency, scheduledhours, positionid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
 RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
from pers_pos pp
 where current_timestamp between pp.createts and pp.endts
 group by 1,2,3,4) pp on pp.personid = pe.personid and pp.rank = 1

 left join (select positionid, grade,MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
 RANK() OVER (PARTITION BY positionid ORDER BY MAX(effectivedate) DESC) AS RANK
 from position_desc
 where effectivedate < enddate and current_timestamp between createts and endts
 group by 1,2) pd on pd.positionid = pp.positionid and pd.rank = 1
 
----------------------------------------------------------------------------
-- LOOKUP JOIN
----------------------------------------------------------------------------
LEFT JOIN  (select lp.lookupid, value1 as planyear from edi.lookup lp
    join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'MutualofOmahaPlanYearStart' 
	where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    ) lookup on lookup.lookupid is not null        
                     
----------------------------------------------------------------------------
-- BENEFIT ELECTION JOINS
----------------------------------------------------------------------------
left join (select personid,benefitsubclass,benefitelection,selectedoption,compplanid,max(createts) as createts,max(endts) as endts,MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
from person_bene_election
where effectivedate is not null and benefitelection in ('E','T')
  and benefitsubclass in  ('23','31','32','21','2L','2Z','2V','25','2C','2X','2Y','3Z')
  and selectedoption = 'Y'
  and effectivedate < enddate and current_timestamp between createts and endts
  group by 1,2,3,4,5) pbe on pbe.personid = pe.personid and pbe.rank = 1 

----------------------------------------------------------------------------
-- PLANYEAR JOIN
----------------------------------------------------------------------------
LEFT JOIN comp_plan_plan_year cppy on pbe.compplanid = cppy.compplanid and cppy.compplanplanyeartype = 'Bene'
and ?::date between cppy.planyearstart and cppy.planyearend

-------------------------------------------
-- Life AD&D --
-------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('23') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate 
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbelife on pbelife.personid = pbe.personid and pbelife.rank = 1  
------------------------  
-- VOLUNTARY LTD (31) --
------------------------                                                
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('31','32','3Z') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection <> 'W'
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbeltd on pbeltd.personid = pbe.personid and pbeltd.rank = 1  
-----------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21,2L) --&-- VOLUNTARY AD&D COVERAGE MEMBER (21,2L) --
-----------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('21','2L') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection <> 'W'
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebeevlife on pbebeevlife.personid = pbe.personid and pbebeevlife.rank = 1
-----------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z,2V) --&-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z,2V) --
-----------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2Z','2V') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebSPvlife on pbebSPvlife.personid = pbe.personid and pbebSPvlife.rank = 1
-----------------------------------------------------------------------------------------------
-- BASIC LIFE CHILD (25,2C) --
-----------------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('25','2C') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection <> 'W'
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebDPvlife on pbebDPvlife.personid = pbe.personid and pbebDPvlife.rank = 1   
-----------------------------------------------------------------------------------------------
-- BASIC LIFE SPOUSE/CHILD (2X,2Y) --
-----------------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2X','2Y') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate 
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbedlb on pbedlb.personid = pbe.personid and pbedlb.rank = 1 
------------------------------------                                              
-- PERSONAL INFO JOINS --
------------------------------------                                              
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
 left join person_dependent_relationship pdr
 on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
--------------------------------------------------------
-- COMPENSATION JOIN --
--------------------------------------------------------
 LEFT JOIN 
(select personid, positionid, compamount, frequencycode, earningscode, Max(effectivedate) as effectivedate, max(enddate) as enddate,
 rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_compensation
 where enddate > effectivedate AND current_timestamp between createts and endts
 group by 1,2,3,4,5)
 as rankpc ON pi.personid = rankpc.personid and rankpc.rank = 1
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOIN TO FIX TRUCKER ISSUE WITH BENBASE SALARY AND HOURLY AMOUNTS - CONFIRMED BENBASE IS ACTUAL SALARY FOR THOSE WITH BENBASE --
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 LEFT JOIN (select personid,earningscode,frequencycode,compamount,positionid, Max(effectivedate) as effectivedate, max(enddate) as enddate,
 rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_compensation 
 where effectivedate < enddate
 and current_timestamp between createts and endts
 and earningscode = 'BenBase'
group by 1,2,3,4,5) pc on pc.personid = pi.personid

----------------------------------------------------------------------------
-- COMPANY JOINS
----------------------------------------------------------------------------
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
and current_timestamp between pu.createts and pu.endts

LEFT JOIN frequency_codes fc
  ON fc.frequencycode = pu.frequencycode

-----------------------------------------------------------------------------------
-- JOIN TO CALCULATE EXTRA PAY AMOUNTS (OVERTIME,BONUS,COMMISSION) --
-----------------------------------------------------------------------------------
left join (select ppd1.personid, sum(case when ppd1.etv_id in ('E02') then ppd1.etv_amount else '0000000000000000' end) as overtime, 
				sum(case when ppd1.etv_id in('E61') then ppd1.etv_amount else '0000000000000000' end) as bonus, 
				sum(case when ppd1.etv_id in ('E62') then ppd1.etv_amount else '0000000000000000' end) as commission
		from pspay_payment_detail ppd1
			LEFT JOIN  (select lp.lookupid, value1 as planyear from edi.lookup lp
			join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'MutualofOmahaPlanYearStart' 
			where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts 
			) lookup on lookup.lookupid is not null 
		where ppd1.check_date between lookup.planyear::date and current_date
		group by ppd1.personid)ppd2 on ppd2.personid = pe.personid
-----------------------------------------------------------------------------------
-- JOIN TO CATEGORIZE KEY EMPS AS A001 --
-----------------------------------------------------------------------------------
left join person_user_field_vals pufv on pufv.personid = pi.personid 
and pufv.ufid in (select ufid from user_field_desc where ufname = 'KEYEMP') and pufv.ufvalue = 'Y' 
and current_date between pufv.effectivedate and pufv.enddate 
and current_timestamp between pufv.createts and pufv.endts
/*
-----------------------------------------------------------------------------------
-- JOIN TO CALCULATE THE LAST COVERAGEAMOUNT PRIOR TO THE AGE REDUCTION FOR EE'S --
-----------------------------------------------------------------------------------
left join (
select pbc.personid,pbe.benefitelection,pbe.benefitsubclass,pbc.personage,pbe.coverageamount,pbc.benefitagecovfactor
,case when pbc.benefitagecovfactor <> 0 then Round(pbe.coverageamount * (1/pbc.benefitagecovfactor ),2) else 0.00 end as originamt
from personbencalcoptionsasof pbc
join person_bene_election pbe on pbe.personid = pbc.personid
   and current_date between pbe.effectivedate and pbe.enddate
   and current_timestamp between pbe.createts and pbe.endts
   and pbe.benefitelection in ('E','T')
   and pbe.benefitsubclass = pbc.benefitsubclass
   and pbe.benefitplanid = pbc.benefitplanid
where pbc.asofdate = current_date 
and pbc.personage >= 65
and pbe.benefitsubclass in ('21','2L')
) pbcee on pbcee.personid = pbebeevlife.personid
-----------------------------------------------------------------------------------
-- JOIN TO CALCULATE THE LAST COVERAGEAMOUNT PRIOR TO THE AGE REDUCTION FOR SP'S --
-----------------------------------------------------------------------------------
left join (
select pbc.personid,pbe.benefitelection,pbe.benefitsubclass,pbc.personage,pbe.coverageamount,pbc.benefitagecovfactor
,case when pbc.benefitagecovfactor <> 0 then Round(pbe.coverageamount * (1/pbc.benefitagecovfactor ),2) else 0.00 end as originamt
from personbencalcoptionsasof pbc
join person_bene_election pbe on pbe.personid = pbc.personid
   and current_date between pbe.effectivedate and pbe.enddate
   and current_timestamp between pbe.createts and pbe.endts
   and pbe.benefitelection in ('E','T')
   and pbe.benefitsubclass = pbc.benefitsubclass
   and pbe.benefitplanid = pbc.benefitplanid
where pbc.asofdate = current_date 
and pbc.personage >= 65
and pbe.benefitsubclass in ('2Z','2V')
) pbcsp on pbcsp.personid = pbebSPvlife.personid
-----------------------------------------------------------------------------------
-- JOIN TO CALCULATE THE LAST COVERAGEAMOUNT PRIOR TO THE AGE REDUCTION FOR DP'S --
-----------------------------------------------------------------------------------
left join (
select pbc.personid,pbe.benefitelection,pbe.benefitsubclass,pbc.personage,pbe.coverageamount,pbc.benefitagecovfactor
,case when pbc.benefitagecovfactor <> 0 then Round(pbe.coverageamount * (1/pbc.benefitagecovfactor ),2) else 0.00 end as originamt
from personbencalcoptionsasof pbc
join person_bene_election pbe on pbe.personid = pbc.personid
   and current_date between pbe.effectivedate and pbe.enddate
   and current_timestamp between pbe.createts and pbe.endts
   and pbe.benefitelection in ('E','T')
   and pbe.benefitsubclass = pbc.benefitsubclass
   and pbe.benefitplanid = pbc.benefitplanid
where pbc.asofdate = current_date 
and pbc.personage >= 65
and pbe.benefitsubclass in ('25','2C')
) pbcdp on pbcdp.personid = pbebDPvlife.personid
*/
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pbe.benefitelection <> 'W'  
  and pe.emplstatus not in ('R','T')


  UNION -- --------------------------------------------------------------------------------------------------------------------------------------


select

-- !!!!!!!!!  TERMED EMPLOYEES 
-- BENEFITS MAY / MAYNOT BE ACTIVE
-- THE ELIGIBILITY EVENT WILL BE BASED OFF EMPLOYEE STATUS NOT BENEFIT STATUS

----------------------------------------------------------------------------
-- DEMOGRAPHICS SEGMENT 1 - 325
----------------------------------------------------------------------------
pi.personid
,1 as sort_seq
, to_char(current_date,'YYYYMMDD')::char(8) as trans_date  -- col 1
,'G000AVJ2' ::char(8) as group_id   -- col 2
, 'M' ::char(1) as relationship_code     -- col 3 
,pi.identity ::char(9) as employee_id     -- col 4
,pn.lname ::char(35) as elname   -- col 5
,pn.fname ::char(15) as efname      -- col 6
,case when pv.gendercode is not null then pv.gendercode else 'U' end ::char(1) as egender   -- col 7
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob   -- col 8
,to_char(greatest(pe.emplhiredate,pe.effectivedate),'YYYYMMDD') ::char(8) as doh     -- col 9
,to_char(greatest(pe.effectivedate,lookup.planyear::date),'yyyymmdd')::char(8) as emp_eff_date -- bring forward all effective date starting at 317 to reset date 11/01/2018 do not alter dates after reset date   -- col 10
----------------------------------------------------------------------------
-- BILL GROUP DATA SEGMENT 393 - 405
----------------------------------------------------------------------------
,to_char(greatest(pe.effectivedate,lookup.planyear::date),'yyyymmdd')::char(8) as sub_group_eff_date   -- col 11
,'0001' ::char(4) as sub_group     -- col 12
----------------------------------------------------------------------------
-- EMPLOYMENT DATA SEGMENT 405 - 474
----------------------------------------------------------------------------
,to_char(greatest(pl.effectivedate,lookup.planyear::date),'yyyymmdd')::char(8) as location_effective_date -- effectivedate of the subscribers location  -- col 13

,case when pu.payunitxid = '00' then '001'
      when pu.payunitxid = '05' then '002'
      when pu.payunitxid = '15' then '003'
      when pu.payunitxid = '10' then '004' else '' end ::char(8) as location_id     -- col 14
,case when pu.payunitxid = '00' then 'Land View'
      when pu.payunitxid = '05' then 'Two Rivers'
      when pu.payunitxid = '15' then 'Native Earth LLC'
      when pu.payunitxid = '10' then 'Royal Innovative Solut' else '' end ::char(23) as location_description       -- col 15
----------------------------------------------------------------------------
-- SALARY DATA SEGMENT 475 - 500
----------------------------------------------------------------------------
, to_char(greatest(pc.effectivedate,rankpc.effectivedate,lookup.planyear::date),'yyyymmdd')::char(8) as basic_sal_eff_date -- effective date of employee's salary compensation    -- col 16
,'A' ::char(1) as basic_sal_mode    -- col 17
,case when coalesce(pc.frequencycode,rankpc.frequencycode) = 'H' then case when pp.schedulefrequency = 'W' then to_char(coalesce(pc.compamount,rankpc.compamount) * pp.scheduledhours * 52 * 100 ,'FM0000000000000000') 
	else to_char(coalesce(pc.compamount,rankpc.compamount) * pp.scheduledhours * 26 * 100 ,'FM0000000000000000') end
	else to_char(coalesce(pc.compamount,rankpc.compamount) * 100 ,'FM0000000000000000') end as basic_salary_amount -- assume decimal zero filled     --col 18                            
----------------------------------------------------------------------------
-- ADDITONAL COMPENSATION SEGMENT 500-608
---------------------------------------------------------------------------- 
                                  
-- Commission                                      
,case when ppd2.commission is not null and ppd2.commission <> 0 then extract(year from current_date) || '0101' else null end ::char(8) as add_comp_eff_date01 -- effective date of employee's commission compensation    -- col 19
,case when ppd2.commission is not null and ppd2.commission <> 0 then 'A' else null end ::char(1) as add_comp_mode01    -- col 20
,case when ppd2.commission is not null and ppd2.commission <> 0 then '01' else null end ::char(2) as add_comp_type01   -- col 21
,case when ppd2.commission is not null and ppd2.commission > 0 then to_char(ppd2.commission * 100, 'FM0000000000000000') 
  when ppd2.commission < 0 then to_char(abs(ppd2.commission::decimal) *100,'FM0000000000000000')::char(16)
   else null end ::char(16) as add_comp_amount01 -- assume decimal zero filled     --col 22
 
 -- Bonus                                       
,case when ppd2.bonus is not null and ppd2.bonus <> 0 then extract(year from current_date) || '0101' else null end ::char(8) as add_comp_eff_date02 -- effective date of employee's bonus compensation    -- col 23
,case when ppd2.bonus is not null and ppd2.bonus <> 0 then 'A' else null end ::char(1) as add_comp_mode02    -- col 24
,case when ppd2.bonus is not null and ppd2.bonus <> 0 then '02' else null end ::char(2) as add_comp_type02   -- col 25
,case when ppd2.bonus is not null and ppd2.bonus > 0 then to_char(ppd2.bonus * 100, 'FM0000000000000000') 
   when ppd2.bonus < 0 then to_char(abs(ppd2.bonus::decimal) *100,'FM0000000000000000')::char(16)
   else null end ::char(16) as add_comp_amount02 -- assume decimal zero filled     --col 26                                        
  
 -- Overtime                                         
,case when ppd2.overtime is not null and ppd2.overtime <> 0 then extract(year from current_date) || '0101' else null end ::char(8) as add_comp_eff_date03 -- effective date of employee's commission compensation    -- col 27
,case when ppd2.overtime is not null and ppd2.overtime <> 0 then 'A' else null end ::char(1) as add_comp_mode03    -- col 28
,case when ppd2.overtime is not null and ppd2.overtime <> 0 then '03' else null end ::char(2) as add_comp_type03   -- col 29
,case when ppd2.overtime is not null and ppd2.overtime > 0 then to_char(ppd2.overtime * 100, 'FM0000000000000000')
  when ppd2.overtime < 0 then to_char(abs(ppd2.overtime::decimal) *100,'FM0000000000000000')::char(16)
  else null end ::char(16) as add_comp_amount03 -- assume decimal zero filled     --col 30
                                               
----------------------------------------------------------------------------                                               
-- CLASS DATA SEGMENT 608 620
----------------------------------------------------------------------------
,to_char(greatest(ppay.effectivedate,cppy.planyearstart::date), 'YYYYMMDD')::char(8) as class_eff_date   -- col 31

-- salaried A001 | full-time hourly not at Two Rivers A002 | Full-time hourly at Two Rivers A003
, case when (pd.grade = '2' or pufv.ufid = '1' or coalesce(pc.frequencycode,rankpc.frequencycode) <> 'H')  then  'A001'
		when coalesce(pc.frequencycode,rankpc.frequencycode) = 'H' and pd.grade <> '2' and pu.payunitxid <> '05' then 'A002' 
		when coalesce(pc.frequencycode,rankpc.frequencycode) = 'H' and pd.grade <> '2' and pu.payunitxid = '05' then 'A003'  
        	else null end ::char(4) as class_id      -- col 32       
----------------------------------------------------------------------------                                              
-- ELIGIBILITY SEGMENTS
-- BASIC LIFE (23) 810 - 832
-- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
----------------------------------------------------------------------------
,case when pbelife.benefitsubclass in ('23') then '1' else ' ' end ::char(1) as product_category_1  -- col 33
,case when pbelife.benefitsubclass in ('23') then to_char(greatest(pbelife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_1   -- col 34
,case when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'T'  then 'TM' 
      when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_1   -- col 35
,case when pbelife.benefitsubclass in ('23') then 'LTL0NCFLAT' else ' ' end ::char(10) as plan_id_1     -- col 36
,case when pbelife.benefitsubclass in ('23') then 'C' else ' ' end ::char(1) as emp_only_1      -- col 37
----------------------------------------------------------------------------
-- BASIC AD&D (23) 865 - 887
-- Note pbelife contains Mutual of Omaha - Basic Life and AD&D 10k so duplicating the information in both segments
----------------------------------------------------------------------------
,case when pbelife.benefitsubclass in ('23') then 'a' else ' ' end ::char(1) as product_category_a      -- col 38
,case when pbelife.benefitsubclass in ('23') then to_char(greatest(pbelife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_a   -- col 39
,case when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'T'  then 'TM' 
      when pbelife.benefitsubclass in ('23') and pbelife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_a   -- col 40
,case when pbelife.benefitsubclass in ('23') then 'ATA0NCFLAT' else ' ' end ::char(10) as plan_id_a     -- col 41
,case when pbelife.benefitsubclass in ('23') then 'C' else ' ' end ::char(1) as emp_only_a      -- col 42
----------------------------------------------------------------------------
-- BASIC LTD SEGMENT (31,32) 975 - 997
----------------------------------------------------------------------------                         
,case when pbeltd.benefitsubclass in ('31','32','3Z') then 'T' else ' ' end ::char(1) as product_category_T      -- col 43
,case when pbeltd.benefitsubclass in ('31','32','3Z') then to_char(greatest(pbeltd.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_T    -- col 44
,case when pbeltd.benefitsubclass in ('31','32','3Z') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31','32','3Z') and pbeltd.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_T    -- col 45
,case when pbeltd.benefitsubclass in ('31','32','3Z') then 'TTT00NCSAL' else ' ' end ::char(10) as plan_id_T     -- col 46
,case when pbeltd.benefitsubclass in ('31','32','3Z') then 'C' else ' ' end ::char(1) as emp_only_T      -- col 47
----------------------------------------------------------------------------                                               
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21,2L) 1030 - 1065
----------------------------------------------------------------------------
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then '3' else ' ' end ::char(1) as product_category_3     -- col 48
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then to_char(greatest(pbebeevlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_3      -- col 49
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection = 'T'  and pbebeevlife.coverageamount <> 0 then 'TM' 
      when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection = 'E'  and pbebeevlife.coverageamount <> 0 then 'EN' else ' ' end ::char(2) as elig_event_3   -- col 50
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then 'ETL0CEEVAL' else ' ' end ::char(10) as plan_id_3        -- col 51
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_3     -- col 52
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection in ('T','R') and pbebeevlife.coverageamount <> 0 then to_char(greatest(pbebeevlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_3   -- col 53
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then to_char(pbebeevlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_3      -- col 54
----------------------------------------------------------------------------                                        
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z,2V) 1085 - 1120
----------------------------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then '4' else ' ' end ::char(1) as product_category_4     -- col 55
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then to_char(greatest(pbebSPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4      -- col 56
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection = 'T'  and pbebSPvlife.coverageamount <> 0 then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection = 'E'  and pbebSPvlife.coverageamount <> 0 then 'EN' else '  ' end ::char(2) as elig_event_4      -- col 57
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4        -- col 58
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_4     -- col 59
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection in ('T','R') and pbebSPvlife.coverageamount <> 0 then to_char(greatest(pbebSPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4   -- col 60
,case when pbebspvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then to_char(pbebspvlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_4     -- col 61
----------------------------------------------------------------------------                                          
-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (25,2C) 1140 - 1185
----------------------------------------------------------------------------
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then '5' else ' ' end ::char(1) as product_category_5     -- col 62
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then to_char(greatest(pbebDPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5  -- col 63
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection = 'T'  and pbebDPvlife.coverageamount <> 0 then 'TM' 
      when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection = 'E'  and pbebDPvlife.coverageamount <> 0 then 'EN' else '  ' end ::char(2) as elig_event_5  -- col 64
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5    -- col 65
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_5     -- col 66
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection in ('T','R') and pbebDPvlife.coverageamount <> 0 then to_char(greatest(pbebDPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5    -- col 67
,case when pbebdpvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then to_char(pbebdpvlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_5     -- col 68
----------------------------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE MEMBER (21,2L) 1195 - 1239
----------------------------------------------------------------------------
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then 'c' else ' ' end ::char(1) as product_category_c     -- col 69
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then to_char(greatest(pbebeevlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_c  -- col 70
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection = 'T'  and pbebeevlife.coverageamount <> 0 then 'TM' 
      when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection = 'E'  and pbebeevlife.coverageamount <> 0 then 'EN' else ' ' end ::char(2) as elig_event_c   -- col 71
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then 'BTA0CEEVAL' else ' ' end ::char(10) as plan_id_c    -- col 72
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_c     -- col 73
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.benefitelection in ('T','R') and pbebeevlife.coverageamount <> 0 then to_char(greatest(pbebeevlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_c   -- col 74
,case when pbebeevlife.benefitsubclass in ('21','2L') and pbebeevlife.coverageamount <> 0 then to_char(pbebeevlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_c      -- col 75
----------------------------------------------------------------------------
-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z,2V) 1250 - 1294
----------------------------------------------------------------------------
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then 'e' else ' ' end ::char(1) as product_category_e     -- col 76
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then to_char(greatest(pbebSPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_e      -- col 77
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection = 'T'  and pbebSPvlife.coverageamount <> 0 then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection = 'E'  and pbebSPvlife.coverageamount <> 0 then 'EN' else '  ' end ::char(2) as elig_event_e      -- col 78
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then 'BTA0CSPVAL' else ' ' end ::char(10) as plan_id_e        -- col 79
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_e         -- col 80
,case when pbebSPvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.benefitelection in ('T','R') and pbebSPvlife.coverageamount <> 0 then to_char(greatest(pbebSPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_e    -- col 81
,case when pbebspvlife.benefitsubclass in ('2Z','2V') and pbebSPvlife.coverageamount <> 0 then to_char(pbebspvlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_e      -- col 82
----------------------------------------------------------------------------
-- VOLUNTARTY AD&D COVERAGE DEPENDENT (25,2C) 1305 - 1349
----------------------------------------------------------------------------
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then 'd' else ' ' end ::char(1) as product_category_d      -- col 83
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then to_char(greatest(pbebDPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_d       -- col 84
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection = 'T'  and pbebDPvlife.coverageamount <> 0 then 'TM' 
      when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection = 'E'  and pbebDPvlife.coverageamount <> 0 then 'EN' else '  ' end ::char(2) as elig_event_d       -- col 85
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then 'BTA0CDPVAL' else ' ' end ::char(10) as plan_id_d         -- col 86
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then 'C' else ' ' end ::char(1) as emp_only_d          -- col 87
,case when pbebDPvlife.benefitsubclass in ('25','2C') and pbebDPvlife.benefitelection in ('T','R') and pbebDPvlife.coverageamount <> 0 then to_char(greatest(pbebDPvlife.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_d     -- col 88
,case when pbebdpvlife.benefitsubclass in ('25','2C') and pbebDPvlife.coverageamount <> 0 then to_char(pbebdpvlife.coverageamount, 'FM0000000000') else '' end ::char(10) as pc_nom_amount_d      -- col 89
----------------------------------------------------------------------------                                             
-- DEP LIFE-BASIC NON CONTRIB (2X,2Y) 1635 - 1656
----------------------------------------------------------------------------                                             
,case when pbedlb.benefitsubclass in ('2X','2Y') then '6' else ' ' end ::char(1) as product_category_6       -- col 90
,case when pbedlb.benefitsubclass in ('2X','2Y') then to_char(greatest(pbedlb.effectivedate,lookup.planyear::date),'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_6    -- col 91
,case when pbedlb.benefitsubclass in ('2X','2Y') and pbedlb.benefitelection = 'T'  then 'TM' 
      when pbedlb.benefitsubclass in ('2X','2Y') and pbedlb.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_6     -- col 92
,case when pbedlb.benefitsubclass in ('2X','2Y') then 'LTL00NCDEP' else ' ' end ::char(10) as plan_id_6     -- col 93
,case when pbedlb.benefitsubclass in ('2X','2Y') then 'C' else ' ' end ::char(1) as emp_only_6               -- col 94                        
               
                                                                           
from person_identity pi
----------------------------------------------------------------------------
-- POSITION JOINS
----------------------------------------------------------------------------
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

LEFT join (select personid, schedulefrequency, scheduledhours, positionid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
 RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
from pers_pos pp
 where current_timestamp between pp.createts and pp.endts
 group by 1,2,3,4) pp on pp.personid = pe.personid and pp.rank = 1

 left join (select positionid, grade,MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
 RANK() OVER (PARTITION BY positionid ORDER BY MAX(effectivedate) DESC) AS RANK
 from position_desc
 where effectivedate < enddate and current_timestamp between createts and endts
 group by 1,2) pd on pd.positionid = pp.positionid and pd.rank = 1
 
----------------------------------------------------------------------------
-- LOOKUP JOIN
----------------------------------------------------------------------------
LEFT JOIN  (select lp.lookupid, value1 as planyear from edi.lookup lp
    join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'MutualofOmahaPlanYearStart' 
	where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts
    ) lookup on lookup.lookupid is not null    
                                                              
----------------------------------------------------------------------------
-- BENEFIT ELECTION JOINS
----------------------------------------------------------------------------
left join (select personid,benefitsubclass,benefitelection,selectedoption,compplanid,max(createts) as createts,max(endts) as endts,MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
from person_bene_election
where effectivedate is not null and benefitelection in ('E','T')
  and benefitsubclass in  ('23','31','32','21','2L','2Z','2V','25','2C','2X','2Y','3Z')
  and selectedoption = 'Y'
  and effectivedate < enddate and current_timestamp between createts and endts
  group by 1,2,3,4,5) pbe on pbe.personid = pe.personid and pbe.rank = 1 

----------------------------------------------------------------------------
-- PLANYEAR JOIN
----------------------------------------------------------------------------
LEFT JOIN comp_plan_plan_year cppy on pbe.compplanid = cppy.compplanid and cppy.compplanplanyeartype = 'Bene'
and ?::date between cppy.planyearstart and cppy.planyearend

-------------------------------------------
-- Life AD&D --
-------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('23') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate 
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbelife on pbelife.personid = pbe.personid and pbelife.rank = 1  
------------------------  
-- VOLUNTARY LTD (31) --
------------------------                                                
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('31','32','3Z') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection <> 'W'
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbeltd on pbeltd.personid = pbe.personid and pbeltd.rank = 1  
-----------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21,2L) --&-- VOLUNTARY AD&D COVERAGE MEMBER (21,2L) --
-----------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('21','2L') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection <> 'W'
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebeevlife on pbebeevlife.personid = pbe.personid and pbebeevlife.rank = 1
-----------------------------------------------------------------------------------------
-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z,2V) --&-- VOLUNTARY AD&D COVERAGE SPOUSE (2Z,2V) --
-----------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2Z','2V') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebSPvlife on pbebSPvlife.personid = pbe.personid and pbebSPvlife.rank = 1
-----------------------------------------------------------------------------------------------
-- BASIC LIFE CHILD (25,2C) --
-----------------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('25','2C') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and benefitelection <> 'W'
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbebDPvlife on pbebDPvlife.personid = pbe.personid and pbebDPvlife.rank = 1   
-----------------------------------------------------------------------------------------------
-- BASIC LIFE SPOUSE/CHILD (2X,2Y) --
-----------------------------------------------------------------------------------------------
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('2X','2Y') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate 
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount) pbedlb on pbedlb.personid = pbe.personid and pbedlb.rank = 1 
------------------------------------                                              
-- PERSONAL INFO JOINS --
------------------------------------                                              
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
 left join person_dependent_relationship pdr
 on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
--------------------------------------------------------
-- COMPENSATION JOIN --
--------------------------------------------------------
 LEFT JOIN 
(select personid, positionid, compamount, frequencycode, earningscode, Max(effectivedate) as effectivedate, max(enddate) as enddate,
 rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_compensation
 where enddate > effectivedate AND current_timestamp between createts and endts
 group by 1,2,3,4,5)
 as rankpc ON pi.personid = rankpc.personid and rankpc.rank = 1
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOIN TO FIX TRUCKER ISSUE WITH BENBASE SALARY AND HOURLY AMOUNTS - CONFIRMED BENBASE IS ACTUAL SALARY FOR THOSE WITH BENBASE --
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 LEFT JOIN (select personid,earningscode,frequencycode,compamount,positionid, Max(effectivedate) as effectivedate, max(enddate) as enddate,
 rank() over (partition by personid order by max(effectivedate) desc) as rank
 from person_compensation 
 where effectivedate < enddate
 and current_timestamp between createts and endts
 and earningscode = 'BenBase'
group by 1,2,3,4,5) pc on pc.personid = pi.personid

----------------------------------------------------------------------------
-- COMPANY JOINS
----------------------------------------------------------------------------
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
and current_timestamp between pu.createts and pu.endts

LEFT JOIN frequency_codes fc
  ON fc.frequencycode = pu.frequencycode

-----------------------------------------------------------------------------------
-- JOIN TO CALCULATE EXTRA PAY AMOUNTS (OVERTIME,BONUS,COMMISSION) --
-----------------------------------------------------------------------------------
left join (select ppd1.personid, sum(case when ppd1.etv_id in ('E02') then ppd1.etv_amount else '0000000000000000' end) as overtime, 
				sum(case when ppd1.etv_id in('E61') then ppd1.etv_amount else '0000000000000000' end) as bonus, 
				sum(case when ppd1.etv_id in ('E62') then ppd1.etv_amount else '0000000000000000' end) as commission
		from pspay_payment_detail ppd1
			LEFT JOIN  (select lp.lookupid, value1 as planyear from edi.lookup lp
			join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'MutualofOmahaPlanYearStart' 
			where current_date between lp.effectivedate and lp.enddate and current_timestamp between lp.createts and lp.endts 
			) lookup on lookup.lookupid is not null 
		where ppd1.check_date between lookup.planyear::date and current_date
		group by ppd1.personid)ppd2 on ppd2.personid = pe.personid
-----------------------------------------------------------------------------------
-- JOIN TO CATEGORIZE KEY EMPS AS A001 --
-----------------------------------------------------------------------------------
left join person_user_field_vals pufv on pufv.personid = pi.personid 
and pufv.ufid in (select ufid from user_field_desc where ufname = 'KEYEMP') and pufv.ufvalue = 'Y' 
and current_date between pufv.effectivedate and pufv.enddate 
and current_timestamp between pufv.createts and pufv.endts

/*
-----------------------------------------------------------------------------------
-- JOIN TO CALCULATE THE LAST COVERAGEAMOUNT PRIOR TO THE AGE REDUCTION FOR EE'S --
-----------------------------------------------------------------------------------
left join (
select pbc.personid,pbe.benefitelection,pbe.benefitsubclass,pbc.personage,pbe.coverageamount,pbc.benefitagecovfactor
,case when pbc.benefitagecovfactor <> 0 then Round(pbe.coverageamount * (1/pbc.benefitagecovfactor ),2) else 0.00 end as originamt
from personbencalcoptionsasof pbc
join person_bene_election pbe on pbe.personid = pbc.personid
   and current_date between pbe.effectivedate and pbe.enddate
   and current_timestamp between pbe.createts and pbe.endts
   and pbe.benefitelection in ('E','T')
   and pbe.benefitsubclass = pbc.benefitsubclass
   and pbe.benefitplanid = pbc.benefitplanid
where pbc.asofdate = current_date 
and pbc.personage >= 65
and pbe.benefitsubclass in ('21','2L')
) pbcee on pbcee.personid = pbebeevlife.personid
-----------------------------------------------------------------------------------
-- JOIN TO CALCULATE THE LAST COVERAGEAMOUNT PRIOR TO THE AGE REDUCTION FOR SP'S --
-----------------------------------------------------------------------------------
left join (
select pbc.personid,pbe.benefitelection,pbe.benefitsubclass,pbc.personage,pbe.coverageamount,pbc.benefitagecovfactor
,case when pbc.benefitagecovfactor <> 0 then Round(pbe.coverageamount * (1/pbc.benefitagecovfactor ),2) else 0.00 end as originamt
from personbencalcoptionsasof pbc
join person_bene_election pbe on pbe.personid = pbc.personid
   and current_date between pbe.effectivedate and pbe.enddate
   and current_timestamp between pbe.createts and pbe.endts
   and pbe.benefitelection in ('E','T')
   and pbe.benefitsubclass = pbc.benefitsubclass
   and pbe.benefitplanid = pbc.benefitplanid
where pbc.asofdate = current_date 
and pbc.personage >= 65
and pbe.benefitsubclass in ('2Z','2V')
) pbcsp on pbcsp.personid = pbebSPvlife.personid
-----------------------------------------------------------------------------------
-- JOIN TO CALCULATE THE LAST COVERAGEAMOUNT PRIOR TO THE AGE REDUCTION FOR DP'S --
-----------------------------------------------------------------------------------
left join (
select pbc.personid,pbe.benefitelection,pbe.benefitsubclass,pbc.personage,pbe.coverageamount,pbc.benefitagecovfactor
,case when pbc.benefitagecovfactor <> 0 then Round(pbe.coverageamount * (1/pbc.benefitagecovfactor ),2) else 0.00 end as originamt
from personbencalcoptionsasof pbc
join person_bene_election pbe on pbe.personid = pbc.personid
   and current_date between pbe.effectivedate and pbe.enddate
   and current_timestamp between pbe.createts and pbe.endts
   and pbe.benefitelection in ('E','T')
   and pbe.benefitsubclass = pbc.benefitsubclass
   and pbe.benefitplanid = pbc.benefitplanid
where pbc.asofdate = current_date 
and pbc.personage >= 65
and pbe.benefitsubclass in ('25','2C')
) pbcdp on pbcdp.personid = pbebDPvlife.personid
*/

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and (pbe.effectivedate >= ?::date								
   or (pbe.createts >= ?::date and pbe.effectivedate < coalesce(?::date, '2017-01-01')) )   
  and pbe.benefitelection <> 'W'
  and pe.emplstatus in ('R','T')

order by 6


