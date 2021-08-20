select distinct

--- Active's ee should be full file - change only for terms
 pi.personid 
,0 as sort_seq 
,'Active EE' ::varchar(30) as sourceseq
-- DEMOGRAPHICS SEGMENT 1 - 325

,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000ADZ5' ::char(8) as group_id
,'M' ::char(1) as relationship_code

,pi.identity ::char(9) as employee_id 
,pn.lname ::char(35) as elname
,pn.fname ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh
,case when date_part('year',pbe_max.effectivedate) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when pbe_max.effectivedate is null then date_part('year',current_date)||'0101'
      else to_char(pbe_max.effectivedate,'yyyymmdd') end  ::char(8) as emp_eff_date -- position 317 date

-- BILL GROUP DATA SEGMENT 393 - 405

,case when date_part('year',pbe_max.effectivedate) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when pbe_max.effectivedate is null then date_part('year',current_date)||'0101'
      else to_char(pbe_max.effectivedate,'yyyymmdd') end ::char(8) as sub_group_eff_date
,'0003' ::char(4) as sub_group

-- SALARY DATA SEGMENT 475 - 500

,case when date_part('year',pbe_max.effectivedate) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when pbe_max.effectivedate is null then date_part('year',current_date)||'0101'
      else to_char(pbe_max.effectivedate,'yyyymmdd') end ::char(8) as basic_sal_eff_date

,'A' ::char(1) as basic_sal_mode

--,to_char(pc.compamount * 100, 'FM00000000000') as basic_salary_amount
,case when pc.frequencycode = 'H' then to_char((pc.compamount * 2080) * 100, 'FM0000000000000000 ')
      else to_char(pc.compamount * 100, 'FM0000000000000000 ') end as basic_salary_amount -- assume decimal zero filled 
-- CLASS DATA SEGMENT 608 620

,case when date_part('year',ppay.effectivedate) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when ppay.effectivedate is null then date_part('year',current_date)||'0101'
      else to_char(ppay.effectivedate,'yyyymmdd') end ::char(8) as class_eff_date -- position 317 date

,case when pu.payunitdesc = 'AKH00' and mef.medical_enrolled_flag = 'Y' then 'A001'
      when pu.payunitdesc = 'AKH00' then 'A002'
      when pu.payunitdesc = 'AKH05' and mef.medical_enrolled_flag = 'Y' then 'A003'
      when pu.payunitdesc = 'AKH05' then 'A004'
      when pu.payunitdesc = 'AKH15' and mef.medical_enrolled_flag = 'Y' then 'A003'
      when pu.payunitdesc = 'AKH15' then 'A004'      
      else ' ' end ::char(4) as class_id

-- ELIGIBILITY SEGMENTS
-- BASIC LIFE (20) 810 - 832

/*
The Basic Life benefits should only be populated on Employee records in Class A001 & A003 only
*/

,case when pbeblife.benefitsubclass in ('20') then '1' 
      when pbeblife.benefitsubclass in ('20') then '1' 
      when pbeblife.benefitsubclass in ('20') then '1' 
      else ' ' end ::char(1) as product_category_1
,case when pbeblife.benefitsubclass in ('20') and pbeblife.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbeblife.benefitsubclass in ('20') and pbeblife.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbeblife.benefitsubclass in ('20') and pbeblife.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbeblife.benefitsubclass in ('20') then to_char(pbeblife.effectivedate,'YYYYMMDD') 
      when pbeblife.benefitsubclass in ('20') then to_char(pbeblife.effectivedate,'YYYYMMDD') 
      when pbeblife.benefitsubclass in ('20') then to_char(pbeblife.effectivedate,'YYYYMMDD') 
      else ' ' end ::char(8) as pc_effective_date_1
,case when pbeblife.benefitsubclass in ('20') and pbeblife.benefitelection = 'T'  then 'TM' 
      when pbeblife.benefitsubclass in ('20') and pbeblife.benefitelection = 'T'  then 'TM' 
      when pbeblife.benefitsubclass in ('20') and pbeblife.benefitelection = 'T'  then 'TM' 
      when pbeblife.benefitsubclass in ('20') and pbeblife.benefitelection = 'E'  then 'EN' 
      when pbeblife.benefitsubclass in ('20') and pbeblife.benefitelection = 'E'  then 'EN' 
      when pbeblife.benefitsubclass in ('20') and pbeblife.benefitelection = 'E'  then 'EN' 
      else '  ' end ::char(2) as elig_event_1
,case when pbeblife.benefitsubclass in ('20') then 'LTL0NCFLAT' 
      when pbeblife.benefitsubclass in ('20') then 'LTL0NCFLAT' 
      when pbeblife.benefitsubclass in ('20') then 'LTL0NCFLAT' 
      else ' ' end ::char(10) as plan_id_1
,case when pbeblife.benefitsubclass in ('20') then 'C' 
      when pbeblife.benefitsubclass in ('20') then 'C' 
      when pbeblife.benefitsubclass in ('20') then 'C' 
      else ' ' end ::char(1) as emp_only_1

-- BASIC AD&D (22) 865 - 887
/*
The AD&D benefits should only be populated on Employee records in Class A001 & A003 only
*/

,case when pbeadd.benefitsubclass in ('22') then 'a' 
      when pbeadd.benefitsubclass in ('22') then 'a' 
      when pbeadd.benefitsubclass in ('22') then 'a' 
      else ' ' end ::char(1) as product_category_a
,case when pbeadd.benefitsubclass in ('22') and pbeadd.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbeadd.benefitsubclass in ('22') and pbeadd.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbeadd.benefitsubclass in ('22') and pbeadd.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbeadd.benefitsubclass in ('22') then to_char(pbeadd.effectivedate,'YYYYMMDD') 
      when pbeadd.benefitsubclass in ('22') then to_char(pbeadd.effectivedate,'YYYYMMDD') 
      when pbeadd.benefitsubclass in ('22') then to_char(pbeadd.effectivedate,'YYYYMMDD') 
      else ' ' end ::char(8) as pc_effective_date_a
,case when pbeadd.benefitsubclass in ('22') and pbeadd.benefitelection = 'T'  then 'TM' 
      when pbeadd.benefitsubclass in ('22') and pbeadd.benefitelection = 'T'  then 'TM'
      when pbeadd.benefitsubclass in ('22') and pbeadd.benefitelection = 'T'  then 'TM'
      when pbeadd.benefitsubclass in ('22') and pbeadd.benefitelection = 'E'  then 'EN' 
      when pbeadd.benefitsubclass in ('22') and pbeadd.benefitelection = 'E'  then 'EN' 
      when pbeadd.benefitsubclass in ('22') and pbeadd.benefitelection = 'E'  then 'EN' 
      else '  ' end ::char(2) as elig_event_a
,case when pbeadd.benefitsubclass in ('22') then 'ATA0NCFLAT' 
      when pbeadd.benefitsubclass in ('22') then 'ATA0NCFLAT' 
      when pbeadd.benefitsubclass in ('22') then 'ATA0NCFLAT' 
      else ' ' end ::char(10) as plan_id_a
,case when pbeadd.benefitsubclass in ('22') then 'C' 
      when pbeadd.benefitsubclass in ('22') then 'C' 
      when pbeadd.benefitsubclass in ('22') then 'C' 
      else ' ' end ::char(1) as emp_only_a

-- BASIC STD SEGMENT (32) 920 - 942
,case when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'S' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'S' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'S' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'S' 
      else ' ' end ::char(1) as product_category_S
,case when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate)::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate)::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then to_char(coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate),'YYYYMMDD') 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then to_char(coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate),'YYYYMMDD') 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate)::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate)::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then to_char(coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate),'YYYYMMDD') 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then to_char(coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate),'YYYYMMDD') 
      else ' ' end ::char(8) as pc_effective_date_s
,case when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'T'  then 'TM' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'T'  then 'TM' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'E'  then 'EN' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'E'  then 'EN' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'T'  then 'TM' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'T'  then 'TM' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'E'  then 'EN' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'E'  then 'EN' 
      else '  ' end ::char(2) as elig_event_s
,case when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'STS00NCSAL' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'STS00NCSAL' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'STS00NCSAL' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'STS00NCSAL' 
      else ' ' end ::char(10) as plan_id_s
,case when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'C' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'C'
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'C' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'C' 
      else ' ' end ::char(1) as emp_only_s


-- BASIC LTD SEGMENT (31) 975 - 997
,case when pbeltd.benefitsubclass in ('31') then 'T' 
      when pbeltd.benefitsubclass in ('31') then 'T' 
      when pbeltd.benefitsubclass in ('31') then 'T' 
      when pbeltd.benefitsubclass in ('31') then 'T' 
      else ' ' end ::char(1) as product_category_t
,case when pbeltd.benefitsubclass in ('31') and pbeltd.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbeltd.benefitsubclass in ('31') and pbeltd.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD')
      when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD')
      when pbeltd.benefitsubclass in ('31') and pbeltd.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbeltd.benefitsubclass in ('31') and pbeltd.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD')
      when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD')
      else ' ' end ::char(8) as pc_effective_date_t
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T'  then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' 
      else ' ' end ::char(2) as elig_event_t
,case when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' 
      when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' 
      when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' 
      when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' 
      else ' ' end ::char(10) as plan_id_t
,case when pbeltd.benefitsubclass in ('31') then 'C' 
      when pbeltd.benefitsubclass in ('31') then 'C' 
      when pbeltd.benefitsubclass in ('31') then 'C' 
      when pbeltd.benefitsubclass in ('31') then 'C' 
      else ' ' end ::char(1) as emp_only_t

-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065

,case when pbebeevlife.benefitsubclass in ('21') then '3' else ' ' end ::char(1) as product_category_3
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.effectivedate,'YYYYMMDD') 
      else ' ' end ::char(8) as pc_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'T'  then 'TM' 
      when pbebeevlife.benefitsubclass in ('21') and pbebeevlife.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_3
,case when pbebeevlife.benefitsubclass in ('21') then 'ETL0CEEVAL' else ' ' end ::char(10) as plan_id_3
,case when pbebeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_3
,case when pbebeevlife.benefitsubclass in ('21') then to_char(pbebeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_3

-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120

,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') 
      else ' ' end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'T'  then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (25) 1140 - 1185

,case when pbebDPvlife.benefitsubclass in ('25') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.effectivedate::date < '2018-01-01' then date_part('year',current_date)||'0101'
      when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') 
      else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'T'  then 'TM' 
      when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AKH_Mutual_Of_Omaha_STD_LTD_Export'

left join person_bene_election pbe
  on pbe.personid = pi.personid
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in ('30','32','31','22','20','21','2Z','25')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts     

left join 
     (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('30','32','31','22','20','21','2Z','25')
         and benefitelection in ('E')
       group by 1) pbe_max
  on pbe_max.personid = pbe.personid
 
left join person_bene_election pbestaffstd
  on pbestaffstd.personid = pbe.personid
 and pbestaffstd.benefitsubclass in ('30')
 and pbestaffstd.benefitelection in ('E','T')
 and pbestaffstd.selectedoption = 'Y' 
 and date_part('year',pbestaffstd.enddate) >= date_part('year',current_date) 
 and current_date between pbestaffstd.effectivedate and pbestaffstd.enddate
 and current_timestamp between pbestaffstd.createts and pbestaffstd.endts  
 and pbestaffstd.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('30') and benefitelection = 'E' and selectedoption = 'Y' and date_part('year',enddate) >= date_part('year',current_date))  

left join person_bene_election pbeerstd
  on pbeerstd.personid = pbe.personid
 and pbeerstd.benefitsubclass in ('32')
 and pbeerstd.benefitelection in ('E','T')
 and pbeerstd.selectedoption = 'Y' 
 and date_part('year',pbeerstd.enddate) >= date_part('year',current_date) 
 and current_date between pbeerstd.effectivedate and pbeerstd.enddate
 and current_timestamp between pbeerstd.createts and pbeerstd.endts  
 and pbeerstd.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
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
  
--- adding medical join even tho this feed has nothing to do with medical - need to know if enrolled in med to set class id 

left join (select distinct personid,benefitelection,benefitsubclass,
  case when benefitsubclass = '10' and benefitelection = 'E' then 'Y' else 'N' end as medical_enrolled_flag
  from person_bene_election
 where benefitsubclass in ('10')
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and benefitelection = 'E'
   order by 1 ) as mef on mef.personid = pbe.personid 
  
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


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
  and pbe.benefitsubclass in ('30','32','31','22','20','21','2Z','25')
  --and (pe.effectivedate >= elu.lastupdatets::DATE 
   --or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
   
union

select distinct
 pi.personid 
,0 as sort_seq 
,'Termed EE' ::varchar(30) as sourceseq
-- DEMOGRAPHICS SEGMENT 1 - 325


,to_char(current_date,'YYYYMMDD')::char(8) as trans_date
,'G000ADZ5' ::char(8) as group_id
,'M' ::char(1) as relationship_code

,pi.identity ::char(9) as employee_id 
,pn.lname ::char(35) as elname
,pn.fname ::char(15) as efname
,pv.gendercode ::char(1) as egender
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh
,case when date_part('year',pbe_max.effectivedate) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when pbe_max.effectivedate is null then date_part('year',current_date)||'0101'
      else to_char(pbe_max.effectivedate,'yyyymmdd') end ::char(8) as emp_eff_date -- position 317 date

-- BILL GROUP DATA SEGMENT 393 - 405

,case when date_part('year',pbe_max.effectivedate) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when pbe_max.effectivedate is null then date_part('year',current_date)||'0101'
      else to_char(pbe_max.effectivedate,'yyyymmdd') end ::char(8) as sub_group_eff_date
      
,'0003' ::char(4) as sub_group

-- SALARY DATA SEGMENT 475 - 500

,case when date_part('year',pbe_max.effectivedate) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when pbe_max.effectivedate is null then date_part('year',current_date)||'0101'
      else to_char(pbe_max.effectivedate,'yyyymmdd') end ::char(8)  as basic_sal_eff_date
      
--,case when pc.frequencycode = 'H' then 'H' else 'A' end ::char(1) as basic_sal_mode
,'A' ::char(1) as basic_sal_mode

--,to_char(pc.compamount * 100, 'FM00000000000') as basic_salary_amount
,case when pc.frequencycode = 'H' then to_char((pc.compamount * 2080) * 100, 'FM0000000000000000 ')
      else to_char(pc.compamount * 100, 'FM0000000000000000 ') end as basic_salary_amount -- assume decimal zero filled 
-- CLASS DATA SEGMENT 608 620

,case when date_part('year',ppay.effectivedate) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when ppay.effectivedate is null then date_part('year',current_date)||'0101'
      else to_char(ppay.effectivedate,'yyyymmdd') end ::char(8) as class_eff_date -- position 317 date
      
--,case when pbe.benefitelection = 'E' then 'A003' else 'A004' end ::char(4) as class_id
,case when pu.payunitdesc = 'AKH00' and mef.medical_enrolled_flag = 'Y' then 'A001'
      when pu.payunitdesc = 'AKH00' then 'A002'
      when pu.payunitdesc = 'AKH05' and mef.medical_enrolled_flag = 'Y' then 'A003'
      when pu.payunitdesc = 'AKH05' then 'A004'
      when pu.payunitdesc = 'AKH15' and mef.medical_enrolled_flag = 'Y' then 'A003'
      when pu.payunitdesc = 'AKH15' then 'A004'      
      else ' ' end ::char(4) as class_id


-- ELIGIBILITY SEGMENTS
-- BASIC LIFE (20) 810 - 832

,case when pbeblife.benefitsubclass in ('20') then '1' 
      when pbeblife.benefitsubclass in ('20') then '1' 
      when pbeblife.benefitsubclass in ('20') then '1' 
      else ' ' end ::char(1) as product_category_1
,case when pbeblife.benefitsubclass in ('20') then to_char(pbeblife.effectivedate,'YYYYMMDD') 
      when pbeblife.benefitsubclass in ('20') then to_char(pbeblife.effectivedate,'YYYYMMDD') 
      when pbeblife.benefitsubclass in ('20') then to_char(pbeblife.effectivedate,'YYYYMMDD') 
      else ' ' end ::char(8) as pc_effective_date_1
,case when pbeblife.benefitsubclass in ('20') then 'TM' 
      when pbeblife.benefitsubclass in ('20') then 'TM' 
      when pbeblife.benefitsubclass in ('20') then 'TM' 
      when pbeblife.benefitsubclass in ('20') and pbeblife.benefitelection = 'E'  then 'EN' 
      when pbeblife.benefitsubclass in ('20') and pbeblife.benefitelection = 'E'  then 'EN' 
      when pbeblife.benefitsubclass in ('20') and pbeblife.benefitelection = 'E'  then 'EN' 
      else '  ' end ::char(2) as elig_event_1
,case when pbeblife.benefitsubclass in ('20') then 'LTL0NCFLAT' 
      when pbeblife.benefitsubclass in ('20') then 'LTL0NCFLAT' 
      when pbeblife.benefitsubclass in ('20') then 'LTL0NCFLAT' 
      else ' ' end ::char(10) as plan_id_1
,case when pbeblife.benefitsubclass in ('20') then 'C' 
      when pbeblife.benefitsubclass in ('20') then 'C' 
      when pbeblife.benefitsubclass in ('20') then 'C' 
      else ' ' end ::char(1) as emp_only_1

-- BASIC AD&D (22) 865 - 887

,case when pbeadd.benefitsubclass in ('22') then 'a' 
      when pbeadd.benefitsubclass in ('22') then 'a'
      when pbeadd.benefitsubclass in ('22') then 'a'
      else ' ' end ::char(1) as product_category_a
,case when pbeadd.benefitsubclass in ('22') then to_char(pbeadd.effectivedate,'YYYYMMDD') 
      when pbeadd.benefitsubclass in ('22') then to_char(pbeadd.effectivedate,'YYYYMMDD') 
      when pbeadd.benefitsubclass in ('22') then to_char(pbeadd.effectivedate,'YYYYMMDD') 
      else ' ' end ::char(8) as pc_effective_date_a
,case when pbeadd.benefitsubclass in ('22') then 'TM' 
      when pbeadd.benefitsubclass in ('22') then 'TM' 
      when pbeadd.benefitsubclass in ('22') then 'TM' 
      when pbeadd.benefitsubclass in ('22') and pbeadd.benefitelection = 'E'  then 'EN' 
      when pbeadd.benefitsubclass in ('22') and pbeadd.benefitelection = 'E'  then 'EN' 
      when pbeadd.benefitsubclass in ('22') and pbeadd.benefitelection = 'E'  then 'EN' 
      else '  ' end ::char(2) as elig_event_a
,case when pbeadd.benefitsubclass in ('22') then 'ATA0NCFLAT' 
      when pbeadd.benefitsubclass in ('22') then 'ATA0NCFLAT' 
      when pbeadd.benefitsubclass in ('22') then 'ATA0NCFLAT' 
      else ' ' end ::char(10) as plan_id_a
,case when pbeadd.benefitsubclass in ('22') then 'C' 
      when pbeadd.benefitsubclass in ('22') then 'C' 
      when pbeadd.benefitsubclass in ('22') then 'C' 
      else ' ' end ::char(1) as emp_only_a

-- BASIC STD SEGMENT (32) 920 - 942
,case when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'S' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'S' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'S' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'S' 
      else ' ' end ::char(1) as product_category_S
,case when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then to_char(coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate),'YYYYMMDD') 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then to_char(coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate),'YYYYMMDD') 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then to_char(coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate),'YYYYMMDD') 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then to_char(coalesce(pbestaffstd.effectivedate,pbeerstd.effectivedate),'YYYYMMDD') 
      else ' ' end ::char(8) as pc_effective_date_s
,case when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'TM' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'TM' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'E'  then 'EN' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'E'  then 'EN' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'TM' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'TM' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'E'  then 'EN' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') and coalesce(pbestaffstd.benefitelection,pbeerstd.benefitelection) = 'E'  then 'EN' 
      else '  ' end ::char(2) as elig_event_s
,case when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'STS00NCSAL' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'STS00NCSAL'
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'STS00NCSAL' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'STS00NCSAL' 
      else ' ' end ::char(10) as plan_id_s
,case when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'C' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'C' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'C' 
      when coalesce(pbestaffstd.benefitsubclass,pbeerstd.benefitsubclass) in ('30','32') then 'C' 
      else ' ' end ::char(1) as emp_only_s

-- BASIC LTD SEGMENT (31) 975 - 997

,case when pbeltd.benefitsubclass in ('31') then 'T' 
      when pbeltd.benefitsubclass in ('31') then 'T' 
      when pbeltd.benefitsubclass in ('31') then 'T' 
      when pbeltd.benefitsubclass in ('31') then 'T' 
      else ' ' end ::char(1) as product_category_t
,case when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') 
      when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') 
      when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') 
      when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') 
      else ' ' end ::char(8) as pc_effective_date_t
,case when pbeltd.benefitsubclass in ('31') then 'TM' 
      when pbeltd.benefitsubclass in ('31') then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' 
      when pbeltd.benefitsubclass in ('31') then 'TM' 
      when pbeltd.benefitsubclass in ('31') then 'TM' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'E'  then 'EN' 
      else ' ' end ::char(2) as elig_event_t
,case when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' 
      when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' 
      when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' 
      when pbeltd.benefitsubclass in ('31') then 'TTT00NCSAL' 
      else ' ' end ::char(10) as plan_id_t
,case when pbeltd.benefitsubclass in ('31') then 'C' 
      when pbeltd.benefitsubclass in ('31') then 'C' 
      when pbeltd.benefitsubclass in ('31') then 'C' 
      when pbeltd.benefitsubclass in ('31') then 'C' 
      else ' ' end ::char(1) as emp_only_t

-- VOLUNTARY TERM LIFE COVERAGE MEMBER (21) 1030 - 1065

,case when pbeevlife.benefitsubclass in ('21') then '3' else ' ' end ::char(1) as product_category_3
,case when pbeevlife.benefitsubclass in ('21') then to_char(pbeevlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_3
,case when pbeevlife.benefitsubclass in ('21') then 'TM' 
      when pbeevlife.benefitsubclass in ('21') and pbeevlife.benefitelection = 'E'  then 'EN' else ' ' end ::char(2) as elig_event_3
,case when pbeevlife.benefitsubclass in ('21') then 'ETL0CEEVAL' else ' ' end ::char(10) as plan_id_3
,case when pbeevlife.benefitsubclass in ('21') then 'C' else ' ' end ::char(1) as emp_only_3
,case when pbeevlife.benefitsubclass in ('21') then to_char(pbeevlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_3
,case when pbeevlife.benefitsubclass in ('21') then to_char(pbeevlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_3

-- VOLUNTARY TERM LIFE COVERAGE SPOUSE (2Z) 1085 - 1120

,case when pbebSPvlife.benefitsubclass in ('2Z') then '4' else ' ' end ::char(1) as product_category_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'TM' 
      when pbebSPvlife.benefitsubclass in ('2Z') and pbebSPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'ETL0CSPVAL' else ' ' end ::char(10) as plan_id_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then 'C' else ' ' end ::char(1) as emp_only_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.effectivedate,'YYYYMMDD') else '  ' end ::char(8) as pc_nom_effective_date_4
,case when pbebSPvlife.benefitsubclass in ('2Z') then to_char(pbebSPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_4

-- VOLUNTARY TERM LIFE COVERAGE DEPENDENT (25) 1140 - 1185

,case when pbebDPvlife.benefitsubclass in ('25') then '5' else ' ' end ::char(1) as product_category_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'TM' 
      when pbebDPvlife.benefitsubclass in ('25') and pbebDPvlife.benefitelection = 'E'  then 'EN' else '  ' end ::char(2) as elig_event_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'ETL0CDPVAL' else ' ' end ::char(10) as plan_id_5
,case when pbebDPvlife.benefitsubclass in ('25') then 'C' else ' ' end ::char(1) as emp_only_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as pc_nom_effective_date_5
,case when pbebDPvlife.benefitsubclass in ('25') then to_char(pbebDPvlife.coverageamount, 'FM0000000000') else null end as pc_nom_amount_5

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AKH_Mutual_Of_Omaha_STD_LTD_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
                    
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('30','32','31','22','20','21','2Z','25')
              and benefitelection in ('E') and selectedoption = 'Y'
              and effectivedate - interval '1 day' <> enddate
            group by 1,2,3,4) rankpbe on rankpbe.personid = pe.personid and rankpbe.rank = 1  
            
            
join person_bene_election pbe
  on pbe.personid = rankpbe.personid 
  and pbe.benefitelection in ('E','T')
  and pbe.benefitsubclass in ('30','32','31','22','20','21','2Z','25')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts    
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('30','32','31','22','20','21','2Z','25') and benefitelection = 'E' and selectedoption = 'Y') 

join 
     (select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('30','32','31','22','20','21','2Z','25')
         and benefitelection in ('E','T')
       group by 1) pbe_max
  on pbe_max.personid = pbe.personid
 
----- Staff STDER (30)                        
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('30')
              and benefitelection in ('E','T') and selectedoption = 'Y'
              and effectivedate - interval '1 day' <> enddate
            group by 1,2,3,4) rankrststd on rankrststd.personid = pbe.personid and rankrststd.rank = 1   
 
left join person_bene_election pbestaffstd
  on pbestaffstd.personid = rankrststd.personid
 and pbestaffstd.personbeneelectionpid = rankrststd.personbeneelectionpid 

----- ERSTD (32)                        
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('32')
              and benefitelection in ('E','T') and selectedoption = 'Y'
              and effectivedate - interval '1 day' <> enddate
            group by 1,2,3,4) rankerstd on rankerstd.personid = pbe.personid and rankerstd.rank = 1    
            
left join person_bene_election pbeerstd
  on pbeerstd.personid = rankerstd.personid
 and pbeerstd.personbeneelectionpid = rankerstd.personbeneelectionpid

----- ERLTD (31)                        
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('31')
              and benefitelection in ('E','T') and selectedoption = 'Y'
              and effectivedate - interval '1 day' <> enddate
            group by 1,2,3,4) rankerltd on rankerltd.personid = pbe.personid and rankerltd.rank = 1                           
 
left join person_bene_election pbeltd
  on pbeltd.personid = rankerltd.personid
 and pbeltd.personbeneelectionpid = rankerltd.personbeneelectionpid
 
----- BasicADD (22)                        
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('22')
              and benefitelection in ('E','T') and selectedoption = 'Y'
              and effectivedate - interval '1 day' <> enddate
            group by 1,2,3,4) rankbadd on rankbadd.personid = pbe.personid and rankbadd.rank = 1                         
 
left join person_bene_election pbeadd
  on pbeadd.personid = rankbadd.personid
 and pbeadd.personbeneelectionpid = rankbadd.personbeneelectionpid
 
----- BLIFE (20)   
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('20')
              and benefitelection in ('E','T') and selectedoption = 'Y'
              and effectivedate - interval '1 day' <> enddate
            group by 1,2,3,4) rankblife on rankblife.personid = pbe.personid and rankblife.rank = 1
 
left join person_bene_election pbeblife
  on pbeblife.personid = rankblife.personid
 and pbeblife.personbeneelectionpid = rankblife.personbeneelectionpid
 
----- EESuppLife (21)  
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        from person_bene_election
       where benefitsubclass in  ('21')
         and benefitelection in ('E','T') and selectedoption = 'Y'
         and effectivedate - interval '1 day' <> enddate
         group by 1,2,3,4) rankeslife on rankeslife.personid = pbe.personid and rankeslife.rank = 1 

left join person_bene_election pbeevlife
  on pbeevlife.personid = rankeslife.personid
 and pbeevlife.personbeneelectionpid = rankeslife.personbeneelectionpid

---- Spouse Vol Life 2Z
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('2Z')
              and benefitelection in ('E','T') and selectedoption = 'Y'
              and effectivedate - interval '1 day' <> enddate
            group by 1,2,3,4) rankspvlife on rankspvlife.personid = pbe.personid and rankspvlife.rank = 1    
 
left join person_bene_election pbebSPvlife
  on pbebSPvlife.personid = rankspvlife.personid
 and pbebSPvlife.personbeneelectionpid = rankspvlife.personbeneelectionpid
 
---- Dependent Vol Life (25) 
left join (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('25')
              and benefitelection in ('E','T') and selectedoption = 'Y'
              and effectivedate - interval '1 day' <> enddate
            group by 1,2,3,4) rankdpvlife on rankdpvlife.personid = pbe.personid and rankdpvlife.rank = 1   
 
left join person_bene_election pbebDPvlife
  on pbebDPvlife.personid = rankdpvlife.personid
 and pbebDPvlife.personbeneelectionpid = rankdpvlife.personbeneelectionpid
  
--- adding medical join even tho this feed has nothing to do with medical - need to know if enrolled in med to set class id 

left join (select distinct personid,benefitelection,benefitsubclass,
  case when benefitsubclass = '10' and benefitelection = 'E' then 'Y' else 'N' end as medical_enrolled_flag
  from person_bene_election
 where benefitsubclass in ('10')
   --and current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and benefitelection = 'E' and planyearenddate > current_date
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

left join (select personid, max(percomppid) as percomppid
  from person_compensation where earningscode <> 'BenBase'
   and current_timestamp between createts and endts
   group by 1) as maxcompid on maxcompid.personid = pe.personid 

join person_compensation pc
  on pc.personid = maxcompid.personid
 and pc.percomppid = maxcompid.percomppid
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
  and pe.emplstatus in ('R','T')
  and pbe.benefitsubclass in ('30','32','31','22','20','21','2Z','25')    
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 



union

select distinct
 pi.personid 
,case when pdr.dependentrelationship = 'SP' then 2 else 3 end as sort_seq  
,'Active EE Spouse' ::varchar(30) as sourceseq
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
--,to_char(greatest(pbe.effectivedate,pbebSPvlife.effectivedate), 'YYYYMMDD')::char(8) as emp_eff_date -- position 317 date


      
,case when greatest(date_part('year',pbe.effectivedate),date_part('year',pbebSPvlife.effectivedate)) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when greatest(pbe.effectivedate,pbebSPvlife.effectivedate) is null then date_part('year',current_date)||'0101'
      else to_char(greatest(pbe.effectivedate,pbebSPvlife.effectivedate), 'YYYYMMDD') end ::char(8) as emp_eff_date -- position 317 date

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

,' ' ::char(1) as product_category_5
,' ' ::char(8) as pc_effective_date_5
,' ' ::char(2) as elig_event_5
,' ' ::char(10) as plan_id_5
,' ' ::char(1) as emp_only_5
,' ' ::char(8) as pc_nom_effective_date_5
,null as pc_nom_amount_5


from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AKH_Mutual_Of_Omaha_STD_LTD_Export'

join person_bene_election pbe
  on pbe.personid = pi.personid
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in ('2Z')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts     
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('2Z') and benefitelection = 'E' and selectedoption = 'Y')   

 
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
 
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts


   
----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and pdr.dependentrelationship in ('DP','SP')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

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
  and pe.emplstatus= 'A'
  and pdr.dependentrelationship in ('DP','SP')
  and pbe.benefitsubclass in ('2Z') 
  and pbe.benefitelection = 'E' 
  --and (pe.effectivedate >= elu.lastupdatets::DATE 
   --or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
  
  UNION

select distinct
 pi.personid 
,case when pdr.dependentrelationship = 'SP' then 2 else 3 end as sort_seq  
,'Active EE Dep' ::varchar(30) as sourceseq
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
--,to_char(greatest(pbe.effectivedate,pbebDPvlife.effectivedate), 'YYYYMMDD')::char(8) as emp_eff_date -- position 317 date

,case when greatest(date_part('year',pbe.effectivedate),date_part('year',pbebDPvlife.effectivedate)) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when greatest(pbe.effectivedate,pbebDPvlife.effectivedate) is null then date_part('year',current_date)||'0101'
      else to_char(greatest(pbe.effectivedate,pbebDPvlife.effectivedate), 'YYYYMMDD') end ::char(8) as emp_eff_date -- position 317 date

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

,' ' ::char(1) as product_category_4
,' ' ::char(8) as pc_effective_date_4
,' ' ::char(2) as elig_event_4
,' ' ::char(10) as plan_id_4
,' ' ::char(1) as emp_only_4
,' ' ::char(8) as pc_nom_effective_date_4
,null as pc_nom_amount_4

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

left join edi.edi_last_update elu on elu.feedid = 'AKH_Mutual_Of_Omaha_STD_LTD_Export'

join person_bene_election pbe
  on pbe.personid = pi.personid
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in ('25')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts     
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('2Z','25') and benefitelection = 'E' and selectedoption = 'Y')   


join person_bene_election pbebDPvlife
  on pbebDPvlife.personid = pbe.personid
 and pbebDPvlife.benefitsubclass in ('25')
 and pbebDPvlife.benefitelection in ('E','T')
 and pbebDPvlife.selectedoption = 'Y' 
 and date_part('year',pbebDPvlife.enddate) >= date_part('year',current_date)
 and current_date between pbebDPvlife.effectivedate and pbebDPvlife.enddate
 and current_timestamp between pbebDPvlife.createts and pbebDPvlife.endts  
 and pbebDPvlife.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('25') and benefitelection = 'E' and selectedoption = 'Y')  

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts


   
----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and pdr.dependentrelationship in ('S','D','C')
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

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
  and pe.emplstatus = 'A'
  and pdr.dependentrelationship in ('S','D','C')
  and pbe.benefitsubclass in ('25') 
  and pbe.benefitelection = 'E' 
  --and (pe.effectivedate >= elu.lastupdatets::DATE 
   --or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
     
union

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
,case when greatest(pbe.effectivedate,pbeltd.effectivedate,pbestd.effectivedate)::date < '2018-01-01' then date_part('year',current_date)||'0101'
      else to_char(greatest(pbe.effectivedate,pbeltd.effectivedate,pbestd.effectivedate), 'YYYYMMDD') end ::char(8) as emp_eff_date -- position 317 date

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

left join edi.edi_last_update elu on elu.feedid = 'AKH_Mutual_Of_Omaha_STD_LTD_Export'

left join person_bene_election pbe
  on pbe.personid = pi.personid
  and pbe.effectivedate is not null
  and pbe.benefitelection in ('E')
  and pbe.benefitsubclass in ('2Z','25')
  and pbe.selectedoption = 'Y' 
  and current_date between pbe.effectivedate and pbe.enddate
  and current_timestamp between pbe.createts and pbe.endts 
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('30','32','31','22','20','21','2Z','25') and benefitelection = 'E' and selectedoption = 'Y')       

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
 and pbestd.benefitsubclass in ('30','32')
 and pbestd.benefitelection in ('E','T')
 and pbestd.selectedoption = 'Y' 
 and date_part('year',pbestd.enddate) >= date_part('year',current_date) 
 and current_date between pbestd.effectivedate and pbestd.enddate
 and current_timestamp between pbestd.createts and pbestd.endts  
 and pbestd.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('30','32') and benefitelection = 'E' and selectedoption = 'Y' and date_part('year',enddate) >= date_part('year',current_date))  
 
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
  and pe.emplstatus in ('R', 'T')
  and pdr.dependentrelationship in ('S','D','C','DP','SP')
  and pbe.benefitsubclass in ('30','32','31','22','20','21','2Z','25')  
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )   
   
  order by 1,2  
