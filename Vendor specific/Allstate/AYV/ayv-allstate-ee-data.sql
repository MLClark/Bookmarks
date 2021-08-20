select distinct
 pi.personid
,'ACTIVE EE' ::varchar(50) as qsource
,pi.identity ::char(9) as ssn -- col a
,pn.lname ::varchar(25) as lname -- col b
,pn.fname ::varchar(25) as fname -- col c
,pn.mname ::char(1) as mname -- col d
,pv.gendercode ::char(1) as gender -- col e
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob -- col f
,to_char(pe.empllasthiredate,'yyyymmdd')::char(8) as doh -- col g
,case when pa.streetaddress2 is null then '"'||pa.streetaddress||'"' else '"'||pa.streetaddress || ', '||pa.streetaddress2 ||'"'end ::varchar(71) as addr -- col h
,pa.city ::varchar(20) as city -- col i
,pa.stateprovincecode ::char(2) as state -- col j
,pa.postalcode ::char(9) as zip -- col k
,upper(pd.positiontitle)  ::varchar(35) as jobtitle -- col l
,'Strategic Link Consulting' ::char(26) as employer -- col m
,'A' ::char(1) as plan_designation -- col n

/*
For Accident, use Coverage Tier
For Critical Illness, based on Plan ID:
- 320 = I or C
- 332 = I or C
- 335 = S or F
- 338 = S or F
Depends on if the EE has Dependent Children up to age 26
*/
--,pbe.benefitsubclass
--,pbe.benefitplanid
--,pbe.benefitcoverageid
--- at time of writing the coverage id all null and no enrolled dep.
,case when pbe.benefitplanid = '320' and pbe.benefitcoverageid is null then 'I'
      when pbe.benefitplanid = '332' and pbe.benefitcoverageid is null then 'I'
      when pbe.benefitplanid = '335' and pbe.benefitcoverageid is null then 'S'
      when pbe.benefitplanid = '338' and pbe.benefitcoverageid is null then 'S' end ::char(1) as coverage_level -- col o

,'N' ::char(1) as section_125
,to_char(cast(poc.employeerate * 100 as int),'FM000000') ::char(6) as total_mode_premium -- col q remove leading zeros in kettle
,to_char(pbe.effectivedate,'yyyymmdd')::char(8) as first_ded_date -- col r
,to_char(pbe.effectivedate,'yyyymmdd')::char(8) as requested_issue_date -- col s
,null as filler_t
,null as servicing_agent_nbr -- col u
,null as servicing_agent_split -- col v
,null as writing_agent_nbr -- col w
,null as writing_agent_split -- col x
,null as other_agent1_nbr -- col y
,null as other_agent1_split -- col z
,null as other_agent2_nbr -- col aa
,null as other_agent2_split -- col ab
,null as other_agent3_nbr -- col ac
,null as other_agent3_split -- col ad
,to_char(pbe.createts,'yyyymmdd')::char(8) as signed_date -- col ae
,'Kennesaw GA' ::char(12) as signed_city_state -- col af
,'35339' ::char(5) as case_nbr -- col ag
,case when pbe.benefitsubclass = '26' then 'N' 
      when pbe.benefitsubclass = '13' then 'G' end ::char(1) as product_type -- col ah

,'?' as status_code -- col ai
,'?' as status_change_date -- col aj
--,case when pc.frequencycode = 'H' then cast((pc.compamount * pp.scheduledhours) * 26 as dec(18,2)) else cast(pc.compamount as dec(18,2)) end as annual_salary -- col ak
,null as annual_salary -- col ak
/*
Critical Illness only, based on Plan ID:
- 320 = Y
- 332 = N
- 335 = N
- 338 = Y
*/
,case when pbe.benefitplanid in ('320','338') then 'Y'
     when pbe.benefitplanid in ('332','335') then 'N' end ::char(1) as ci_tobacco_question -- col al
,null as ci_tobacco_details -- col am
,to_char(cast(pbe.coverageamount as int),'FM00000000') ::char(8) as ci_face_amount -- col an
,null as ind_product_question -- col ao
,null as ind_product_policy_nbr -- col ap
,null as term_cvg_question -- col aq
,null as ind_product_term_date -- col ar
,'26' ::char(2) as prem_ded_mode -- col as
,'?' ::char(1) as active_at_work -- col at
,null as employeeid -- col au
,to_char(pe.empllasthiredate,'yyyymmdd')::char(8) as rehire_date -- col av
,null as marital_status -- col aw
,null as comp_health_care_question -- col ax
,null as electronic_delivery -- col ay
,null as email_address -- col az
,null as remarks -- col ba
,null as monthly_salary -- col bb
,null as monthly_benefit -- col bc
,null as replacement -- col bd
,null as company_name -- col be
,null as existing_insurance -- col bf
,null as applied_insurance -- col bg
,null as year_issued -- col bh
,null as monthly_benefit -- col bi
,null as elimination_period -- col bj
,null as benefit_period_months -- col bk
,null as medInsInForce_question1 -- col bl
,null as medInsInForce_question2 -- col bm

from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('26')
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

left join benefit_coverage_desc bcd
  on bcd.benefitcoverageid = pbe.benefitcoverageid
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts

left join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts    
 
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 
  
left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 
 
left join personbenoptioncostl poc
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'P'         

left join person_compensation pc
  on pc.personid = pe.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.earningscode <> 'BenBase' 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('T','R')