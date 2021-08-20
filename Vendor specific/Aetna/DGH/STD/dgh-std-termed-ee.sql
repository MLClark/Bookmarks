select distinct
 pe.personid
,'67 TERMED EES' ::varchar(40) as QSOURCE
-------------------------------------------------------------------------------------------------
,pi.identity ::char(9) as ssn --1
,pi.identity ::varchar(10) as alternateid --2
,pn.lname::varchar(20) as lastname --3
,pn.fname::varchar(15) as firstname --4
,left(pn.mname,1)::char(1) as middleinitial --5
,pn.formofaddress as prefix --6
,pn.title as suffix --7
,case when pv.gendercode = 'F' then '1' 
      when pv.gendercode = 'M' then '2' end ::char(1) as gender --8
,to_char(pv.birthdate,'yyyymmdd')::char(8) as birthdate --9
,pa.streetaddress ::varchar(30) as streetaddress1 --10
,pa.streetaddress2 ::varchar(30) as streetaddress2 --11
,case when pa.countrycode in ('US', 'UM', 'VA', 'CA') then pa.city else 'ZZ' end ::varchar(50) as city --12
,case when pa.countrycode in ('US', 'UM', 'VA', 'CA') then pa.stateprovincecode else 'ZZ' end ::char(8) as statecode --13
,case when pa.countrycode in ('US', 'UM', 'VA', 'CA') then pa.postalcode else 'ZZ' end ::varchar(15) as zipcode --14
,ppch.phoneno AS homephone --15
,ppcm.phoneno AS cellphone --16
,ppcw.phoneno AS workphone --17
,to_char(pe.empllasthiredate,'YYYYMMDD')::char(8) as lasthiredate --18 most recent hire date
,to_char(pe.emplhiredate,'YYYYMMDD')::char(8) as hiredate --19 original hire date
,to_char(pe.emplsenoritydate,'YYYYMMDD')::char(8) as senoritydate --20 adjusted hire date
,case when pe.emplstatus = 'P' then 'L' else pe.emplstatus end ::char(1) as employee_status --21
,case when pe.emplstatus in ('T', 'R', 'D') then to_char(pe.effectivedate,'YYYYMMDD') end ::char(8) as termdate --22
,coalesce(pd.positiontitle,eetd.positiontitle) as positiontitle --23
,' ' ::char(1) as jobid --24
,case when la.countrycode in ('US', 'UM', 'VA', 'CA') then la.stateprovincecode else 'ZZ' end ::char(8) as workstate --25
,case when la.countrycode in ('US', 'UM', 'VA', 'CA') then la.countrycode else 'ZZ' end ::varchar(5) as workcountry --26
,pnc.url::varchar(100) as workemail --27
,' '::char(1) as supervisorid --28
,' '::char(1) as contact2 --29
,' '::char(1) as contact3 --30
,case when coalesce(pp.schedulefrequency,eetd.payfreq) = 'B' then cast(coalesce(pp.scheduledhours,eetd.scheduledhours) / 2 as dec(7,0)) 
      else cast(coalesce(pp.scheduledhours,eetd.scheduledhours) as dec(7,0)) end as scheduledhours --31
,case when coalesce(pd.flsacode,eetd.flsacode) = 'N' then '1' 
      when coalesce(pd.flsacode,eetd.flsacode) = 'E' then '0' end ::char(1) as flsastatus --32
           
,case when pc.frequencycode = 'A' then cast(pc.compamount as dec(18,2))
      when pu.frequencycode = 'B' then cast(coalesce(pc.compamount,eetd.compamount) * coalesce(fc.annualfactor,fct.annualfactor) as dec(18,2))
      when pu.frequencycode = 'W' then cast(coalesce(pc.compamount,eetd.compamount) * coalesce(fc.annualfactor,fct.annualfactor) as dec(18,2)) end as salary --33 current base salary
,'06' ::char(2) as basis --34 current salary/wage basis
,' '  ::char(1) as addition_salamt --35
,' '  ::char(1) as addition_salamt_basis --36
,' '  ::char(1) as commission_amt --37
,' '  ::char(1) as bonus_amt --38
,case when pc.frequencycode = 'H' then 'H'
      when pc.frequencycode = 'A' then 'S' end ::char(1) as grade --39 payroll basis
,' '  ::char(1) as pay_grade_level --40
,to_char(coalesce(pc.effectivedate, eetd.compeffectivedate ),'YYYYMMDD')::char(8) as salarydate --41
,' '  ::char(1) as cso1 --42
,' '  ::char(1) as cso2
,' '  ::char(1) as cso3
,' '  ::char(1) as cso4
,' '  ::char(1) as cso5
,' '  ::char(1) as cso6
,' '  ::char(1) as cso7
,' '  ::char(1) as cso8 --49
--- had to use salarygrade to determine union status
,case when sg.grade in ('6') then 'NonUnion' else 'Union' end::varchar(20) as unionidentifier --50
,lc.locationcode ::char(3) as locationcode --51
,pe.emplclass ::char(1) as employmentclass --52
,' '  ::char(1) as medical_carrier --53
,' '  ::char(1) as mental_health_carrier --54
,' '  ::char(1) as bank_transit_number --55
,' '  ::char(1) as bank_acct_number --56
,' '  ::char(1) as account_type --57
,' '  ::char(1) as total_differentials --58

---- << For these 6 fields: include EEs not in Woodridge Union (sg.grade = '1') 
-------------------------------------------------------------------------------
-----  STD AREA
-------------------------------------------------------------------------------
,sg.grade
,case when sg.grade = '1' then ' ' else '0473296' end ::char(7) as STD1controlnumber --59
,case when sg.grade = '1' then ' ' else '014' end ::char(3) as STD1suffix --60
,case when sg.grade = '1' then ' ' 
      when sg.grade <> '1' and lc.locationcode in ('7YZ','7XK','7VK') then '00003' 
      when sg.grade <> '1' and lc.locationcode not in ('7YZ','7XK','7VK') then '00002' end ::char(5) as STD1account --61

 /*
I reread the Coding Supplement and made a slight change to the spec.  STD Plan ID should be 201 for all Salaried AND Non-exempt, 
instead of Salaried Non-exempt. Therefore, Salaried Exempt, Salaried Non-exempt and Hourly Non-exempt should be 201
Jared Johnson is missing the STD Account, which should be 00003 for locations 7YZ, 7XK or 7VK and 00002 for all others. 
He is in Location 7XK so Account should be 00003

201 - for Salaried & Non-exempt 
202 - for Hourly Non-Union
203 - for FT Hourly Union 7B9
204 - for Hourly Union 7C7
205 - for Union 7DE

*/
,case when sg.grade  = '1' then ' '
      when pc.frequencycode = 'A' then '201' --201 - for Salaried & Non-exempt 
      when pc.frequencycode = 'H' and sg.grade in ('6') then '202' --202 - for Hourly Non-Union (grade 6)
      when sg.grade not in ('6')  and pe.emplclass = 'F' and pc.frequencycode = 'H' and lc.locationcode in ('7B9') then '203' --203 - for FT Hourly Union 7B9
      when pc.frequencycode = 'H' and sg.grade not in ('6') and lc.locationcode in ('7C7') then '204' --204 - for Hourly Union 7C7
      when sg.grade not in ('6') and lc.locationcode in ('7DE') then '205' --205 - for Union 7DE      
      when pd.flsacode = 'N' then '201' --201 - for Salaried & Non-exempt 
      else '?' end ::char(3) as STD1planid --62
      
,case when sg.grade = '1' then ' ' else to_char(greatest(pe.empllasthiredate,date_trunc('year', now())),'yyyymmdd') end ::char(8) as std1_effectivedate --63 update 4/9 January 1 or current year or empl last hire date which ever is greatest
,case when sg.grade = '1' then ' ' 
      when pe.emplstatus in ('R','T') then to_char(pe.effectivedate,'yyyymmdd') else ' ' end ::char(8) as std1_term_date --64 not determined in kettle


,' ' ::char(1) as STD2controlnumber
,' ' ::char(1) as STD2suffix
,' ' ::char(1) as STD2account
,' ' ::char(1) as STD2planid
,' ' ::char(1) as std2_effectivedate
,' ' ::char(1) as std2_term_date
,' ' ::char(1) as statcontrolnumber
,' ' ::char(1) as statsuffix
,' ' ::char(1) as stataccount
,' ' ::char(1) as statplanid
,' ' ::char(1) as stat_effectivedate
,' ' ::char(1) as stat_term_date
,' ' ::char(1) as ltd1controlnumber
,' ' ::char(1) as ltd1suffix
,' ' ::char(1) as ltd1account
,' ' ::char(1) as ltd1planid
,' ' ::char(1) as ltd1_effectivedate
,' ' ::char(1) as ltd1_term_date
,' ' ::char(1) as ltd2controlnumber
,' ' ::char(1) as ltd2suffix
,' ' ::char(1) as ltd2account
,' ' ::char(1) as ltd2planid
,' ' ::char(1) as ltd2_effectivedate
,' ' ::char(1) as ltd2_term_date
,lc.locationcode::varchar(20) as reportinglevel1 --89
,' ' ::char(1) as reportinglevel2
,' ' ::char(1) as reportinglevel3
,' ' ::char(1) as reportinglevel4
,' ' ::char(1) as reportinglevel5
,' ' ::char(1) as reportinglevel6
,' ' ::char(1) as reportinglevel7
,' ' ::char(1) as reportinglevel8
,' ' ::char(1) as reportinglevel9
,' ' ::char(1) as reportinglevel10
,' ' ::char(1) as reportinglevel11
,' ' ::char(1) as reportinglevel12
,' ' ::char(1) as hours
,' ' ::char(1) as pp_frequency
,' ' ::char(1) as periodstartdate
,' ' ::char(1) as periodenddate
,' ' ::char(1) as key_employee
,' ' ::char(1) as work_schedule_name
,' ' ::char(1) as work_sched_eff_date
,' ' ::char(1) as usage_time
,' ' ::char(1) as reg_prd_basis
,' ' ::char(1) as cumulative_hours
,' ' ::char(1) as cumulative_hours_weeks
,' ' ::char(1) as flight_crew
,' ' ::char(1) as fmla_radius

--- << For these 4 fields, include all eligible EEs
,'0473296' ::varchar(7) as FMLAControlNum --115
,'050' ::char(3) as FMLASuffix --116

,case when lc.locationcode in ('7YZ','7XK','7VK') then '00003' 
      when lc.locationcode not in ('7YZ','7XK','7VK') then '00002' end ::char(5) as FMLAAccount --117

,'301' ::char(3) as FMLAPlanId --118
      
,' ' ::char(1) as pflcontrolnumber
,' ' ::char(1) as pflsuffix
,' ' ::char(1) as pflaccount
,' ' ::char(1) as pflplanid
,' ' ::char(1) as pfl_effectivedate
,' ' ::char(1) as pfl_term_date


from person_employment pe

join person_identity pi
  on pi.personid = pe.personid
 and pi.identitytype = 'SSN'
 and current_timestamp between pi.createts and pi.endts

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

left join person_phone_contacts ppch 
  on ppch.personid = pe.personid 
 and ppch.phonecontacttype = 'Home'
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts

left join person_phone_contacts ppcm 
  on ppcm.personid = pe.personid 
 and ppcm.phonecontacttype = 'Mobile'
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts
 
left join person_phone_contacts ppcw
  on ppcw.personid = pe.personid 
 and ppcw.phonecontacttype = 'Work'
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts

left join person_net_contacts pnc 
  on pnc.personid = pe.personid 
 and pnc.netcontacttype = 'WRK' 
 and current_date between pnc.effectivedate and pnc.enddate
 and current_timestamp between pnc.createts and pnc.endts
 
left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate <= enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1

left join (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode) pd on pd.positionid = pp.positionid and pd.rank = 1       

left join (select personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
             from person_compensation where effectivedate <= enddate AND current_timestamp BETWEEN createts AND endts 
            group by personid, compamount, increaseamount, compevent, frequencycode, earningscode) as pc on pc.personid = pe.personid and pc.rank = 1   

left join (select personid, locationid, max(effectivedate) as effectivedate, rank() over (partition by personid order by max(createts)desc) as rank
             from person_locations where current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, locationid) pl on pl.personid = pe.personid and pl.rank = 1
            
left join location_codes lc 
  on lc.locationid = pl.locationid 
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts
 
left join location_address la 
  on la.locationid = pl.locationid 
 and current_date between la.effectivedate and la.enddate
 and current_timestamp between la.createts and la.endts
 
left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts
 
left join pay_unit pu on pu.payunitid = ppl.payunitid
left join frequency_codes fc on fc.frequencycode = pc.frequencycode
left join edi.etl_employment_term_data eetd on eetd.personid = pe.personid 
left join frequency_codes fct on fct.frequencycode = eetd.frequencycode

left join salary_grade sg
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts 

/*
Criteria:
All active employees with Scheduled hours of 30 or more, excluding future-dated new hires, Contractors and Seasonal Employees.  
Terminations and Loss of Coverage (such as Fulltime to Parttime <30 hours) to be sent for 90 days after Termination or Loss of Coverage Date, then drop off the file.
*/
where pe.emplstatus in ('T', 'R', 'D') and pe.effectivedate < pe.enddate and pe.enddate >= '2199-12-30' and current_timestamp between pe.createts and pe.endts and current_date - interval '90 days' <= pe.effectivedate     
