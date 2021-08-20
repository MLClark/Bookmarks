select distinct
 pi.personid
,'ACTIVE EES' ::CHAR(20) AS SOURCESEQ
---- ACTIVE EES / AGENTS 
,replace(pi.identity,'-','') ::char(9) as ssn 
,pn.lname ::char(20) as lname
,pn.fname ::char(13) as fname
,pn.mname ::char(1) as mname
,pn.title ::char(4) as suffix

,replace(pa.streetaddress,',',' ')       ::char(30) as addr1
,replace(pa.streetaddress2,',',' ')      ::char(30) as addr2
,pa.city                ::char(30) as city
,pa.stateprovincecode   ::char(2) as state
,pa.postalcode          ::char(9) as zip
,case when pa.countrycode = 'US' then 'USA' end ::char(3) as country

,'' ::char(8) as addr_chg_date
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob
,pv.gendercode ::char(1) as gender

,'' ::char(1) as fill_1
,'' ::char(1) as fill_2
,replace(coalesce(ppcw.phoneno,ppc.phoneno),'-','') ::char(10) as phone_home
,'' ::char(1) as phone_cell
,'' ::char(1) as fill_3
,'' ::char(1) as fill_4
,'' ::char(1) as fill_5
,'' ::char(1) as fill_6
,'' ::char(1) as fill_7
,'' ::char(1) as fill_8
,'' ::char(1) as fill_9
,'' ::char(1) as fill_10
,'' ::char(1) as fill_11
,'' ::char(1) as fill_12
,'' ::char(1) as fill_13

,to_char(pe.emplHiredate,'yyyymmdd')  ::char(8) as Orig_hire_date 
,to_char(pe.emplservicedate,'yyyymmdd') ::char(8) as last_hire_date 
,to_char(pe.emplhiredate,'yyyymmdd') ::char(8) as adj_hire_date
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'yyyymmdd')else ''  end ::char(8) as TermDate 
,case when pe.emplstatus = 'T' and pe.empleventdetCode = 'VT'  then 'V'
	   when pe.emplstatus = 'T' and pe.empleventdetCode = 'InT' then 'I'
	   Else '' end ::char(1) as Term_Reason 	
,case when pe.emplevent = 'Retire' then 'Y' else 'N' end ::char(1) as Retired_Ind
,case when pc.frequencycode = 'A' then to_char(pc.compamount,'99999999D99') 
      when pc.frequencycode = 'H' then to_char(pc.compamount * 2080 ,'99999999D99')
	   end ::char(14) as Annsalary
,'ANNUAL' ::char(6) as EarningUnit
,'SEMIMONTHLY' ::char(12) as PayFreq
,'' ::char(8) as SalEffectiveDate
,'' ::char(1) as fill_14
,'' ::char(1) as fill_15
,'' ::char(8) as SalOverEffDate
,'' ::char(1) as fill_16
,'' ::char(1) as fill_17
,pie.identity ::char(9) as empnbr
,replace(ppcw.phoneno,'-','') ::char(10) as Work_Phone
,'' ::char(1) as fill_18
,'' ::char(1) as fill_19
,pncw.url  ::char(60) as WorkEmail  
,to_char(ppos.scheduledhours,'9999D99') ::char(8) as HoursWorked  
,'' ::char(1) as CustomCodeEffDate

,'Work Location' ::char(20) as CC1WrkLocation
,CASE WHEN lc.locationcode = 'HO' THEN 'HMNHO'
      WHEN pd.positiontitle in ('Agent','Acct Rep')  THEN 'HMNFA'
	   ELSE 'HMNFN' END::char(5) as CC1WrkLocation
,'Status' ::char(6) as Status
,CASE When pe.emplstatus =  'L' THEN 'LT'
      When pe.emplpermanency != 'P' and pd.flsacode != 'E'  THEN 'T1'   
	   ELSE 'NT' End ::char(2) as StatusCode

,'FMLA Code' ::char(9) as CCType3
,'LREN1' ::char(5) as CCType3_value

,'Group Identifier Code' ::char(22) as CCType4
,'HMN00' ::char(5) as CCType4_value

,'' ::char(1) as CCType5
,'' ::char(1) as CCType5_value
,'' ::char(1) as CCType6
,'' ::char(1) as CCType6_value
,'' ::char(1) as CCType7
,'' ::char(1) as CCType7_value
,'' ::char(1) as CCType8
,'' ::char(1) as CCType8_value
,'' ::char(1) as CCType9
,'' ::char(1) as CCType9_value
,'' ::char(1) as CCType10
,'' ::char(1) as CCType10_value
,'' ::char(1) as CCType11
,'' ::char(1) as CCType11_value
,'' ::char(1) as CCType12
,'' ::char(1) as CCType12_value
,'' ::char(1) as CCType13
,'' ::char(1) as CCType13_value
,'' ::char(1) as CCType14
,'' ::char(1) as CCType14_value
,'' ::char(1) as CCType15
,'' ::char(1) as CCType15_value
--,ed.feedid
,'D' ::char(1) as record_type
 
from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
  
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

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_phone_contacts ppc
  on ppc.personid = pi.personid
 and ppc.phonecontacttype = 'Home'
 and current_date between ppc.effectivedate and ppc.enddate
 and current_timestamp between ppc.createts and ppc.endts
 and ppc.countrycode is not null

left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and ppcw.phonecontacttype = 'Work'
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts
 and ppcw.countrycode is not null
 
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.enddate 
 and pncw.endts > current_date

left JOIN pers_pos ppos 
  ON ppos.personid = pe.personid 
 and current_date between ppos.effectivedate and ppos.enddate  
 AND current_timestamp between ppos.createts AND ppos.endts 
 AND ppos.persposrel = 'Occupies'::bpchar

left JOIN position_desc pd 
  ON pd.positionid = ppos.positionid
 AND current_date between pd.effectivedate AND pd.enddate 
 AND current_timestamp between pd.createts AND pd.endts 

left join (select pc.personid, max(pc.percomppid) as percomppid
  from person_compensation pc
  join pers_pos pp
    on pp.personid = pc.personid
   and pp.positionid = pc.positionid
   and current_date between pp.effectivedate and pp.enddate
   and current_timestamp between pp.createts and pp.endts
where pc.earningscode <> 'BenBase'
 and pc.positionid = pp.positionid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 group by 1) activepc on activepc.personid = pe.personid

left join person_compensation pc 
  on pc.personid = pe.personid
 and pc.earningscode <> 'BenBase'
 and pc.positionid = ppos.positionid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 and pc.personid = activepc.personid
 and pc.percomppid = activepc.percomppid

LEFT JOIN primarylocation pl
  ON pl.personid = pe.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_codes lc
  ON lc.locationid = pl.locationid
 AND current_date between lc.effectivedate and lc.enddate
 AND current_timestamp between lc.createts and lc.endts

JOIN edi.edi_last_update ed on ed.feedId = 'HMN_BenefitFocus_Census_File_Export'

where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and pd.positiontitle not like 'Intern %'
  and pe.emplstatus in ('L','A','P')
  
union

select distinct
 pi.personid
,'ACTIVE AGENTS' ::CHAR(20) AS SOURCESEQ
---- ACTIVE EES / AGENTS 
,replace(pi.identity,'-','') ::char(9) as ssn 
,pn.lname ::char(20) as lname
,pn.fname ::char(13) as fname
,pn.mname ::char(1) as mname
,pn.title ::char(4) as suffix

,replace(pa.streetaddress,',',' ')       ::char(30) as addr1
,replace(pa.streetaddress2,',',' ')      ::char(30) as addr2
,pa.city                ::char(30) as city
,pa.stateprovincecode   ::char(2) as state
,pa.postalcode          ::char(9) as zip
,case when pa.countrycode = 'US' then 'USA' end ::char(3) as country

,'' ::char(8) as addr_chg_date
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob
,pv.gendercode ::char(1) as gender

,'' ::char(1) as fill_1
,'' ::char(1) as fill_2
,replace(coalesce(ppcw.phoneno,ppc.phoneno),'-','') ::char(10) as phone_home
,'' ::char(1) as phone_cell
,'' ::char(1) as fill_3
,'' ::char(1) as fill_4
,'' ::char(1) as fill_5
,'' ::char(1) as fill_6
,'' ::char(1) as fill_7
,'' ::char(1) as fill_8
,'' ::char(1) as fill_9
,'' ::char(1) as fill_10
,'' ::char(1) as fill_11
,'' ::char(1) as fill_12
,'' ::char(1) as fill_13

,to_char(pe.emplHiredate,'yyyymmdd')  ::char(8) as Orig_hire_date 
,to_char(pe.emplservicedate,'yyyymmdd') ::char(8) as last_hire_date 
,to_char(pe.emplhiredate,'yyyymmdd') ::char(8) as adj_hire_date
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'yyyymmdd')else ''  end ::char(8) as TermDate 
,case when pe.emplstatus = 'T' and pe.empleventdetCode = 'VT'  then 'V'
	   when pe.emplstatus = 'T' and pe.empleventdetCode = 'InT' then 'I'
	   Else '' end ::char(1) as Term_Reason 	
,case when pe.emplevent = 'Retire' then 'Y' else 'N' end ::char(1) as Retired_Ind
,case when xppd.positiontitle in ('Agent','Acct Rep') then to_char((agent.commission),'99999999D99')
	   end ::char(14) as Annsalary
,'ANNUAL' ::char(6) as EarningUnit
,'SEMIMONTHLY' ::char(12) as PayFreq
,'' ::char(8) as SalEffectiveDate
,'' ::char(1) as fill_14
,'' ::char(1) as fill_15
,'' ::char(8) as SalOverEffDate
,'' ::char(1) as fill_16
,'' ::char(1) as fill_17
,pie.identity ::char(9) as empnbr
,replace(ppcw.phoneno,'-','') ::char(10) as Work_Phone
,'' ::char(1) as fill_18
,'' ::char(1) as fill_19
,pncw.url  ::char(60) as WorkEmail  
,to_char(ppos.scheduledhours,'9999D99') ::char(8) as HoursWorked  
,'' ::char(1) as CustomCodeEffDate

,'Work Location' ::char(20) as CC1WrkLocation
,CASE WHEN lc.locationcode = 'HO' THEN 'HMNHO'
      WHEN pd.positiontitle in ('Agent','Acct Rep')  THEN 'HMNFA'
	   ELSE 'HMNFN' END::char(5) as CC1WrkLocation
,'Status' ::char(6) as Status
,CASE When pe.emplstatus =  'L' THEN 'LT'
      When pe.emplpermanency != 'P' and pd.flsacode != 'E'  THEN 'T1'   
	   ELSE 'NT' End ::char(2) as StatusCode

,'FMLA Code' ::char(9) as CCType3
,'LREN1' ::char(5) as CCType3_value

,'Group Identifier Code' ::char(22) as CCType4
,'HMN00' ::char(5) as CCType4_value

,'' ::char(1) as CCType5
,'' ::char(1) as CCType5_value
,'' ::char(1) as CCType6
,'' ::char(1) as CCType6_value
,'' ::char(1) as CCType7
,'' ::char(1) as CCType7_value
,'' ::char(1) as CCType8
,'' ::char(1) as CCType8_value
,'' ::char(1) as CCType9
,'' ::char(1) as CCType9_value
,'' ::char(1) as CCType10
,'' ::char(1) as CCType10_value
,'' ::char(1) as CCType11
,'' ::char(1) as CCType11_value
,'' ::char(1) as CCType12
,'' ::char(1) as CCType12_value
,'' ::char(1) as CCType13
,'' ::char(1) as CCType13_value
,'' ::char(1) as CCType14
,'' ::char(1) as CCType14_value
,'' ::char(1) as CCType15
,'' ::char(1) as CCType15_value
--,ed.feedid
,'D' ::char(1) as record_type
 
from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
  
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

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_phone_contacts ppc
  on ppc.personid = pi.personid
 and ppc.phonecontacttype = 'Home'
 and current_date between ppc.effectivedate and ppc.enddate
 and current_timestamp between ppc.createts and ppc.endts
 and ppc.countrycode is not null

left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and ppcw.phonecontacttype = 'Work'
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts
 and ppcw.countrycode is not null
 
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

-- select * from person_net_contacts where personid = '67852'
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.enddate 
 and pncw.endts > current_date

left JOIN pers_pos ppos 
  ON ppos.personid = pe.personid 
 and current_date between ppos.effectivedate and ppos.enddate  
 AND current_timestamp between ppos.createts AND ppos.endts 
 AND ppos.persposrel = 'Occupies'::bpchar

left JOIN position_desc pd 
  ON pd.positionid = ppos.positionid
 AND current_date between pd.effectivedate AND pd.enddate 
 AND current_timestamp between pd.createts AND pd.endts 

left join person_compensation pc 
  on pc.personid = pe.personid
 and pc.earningscode <> 'BenBase'
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 

LEFT JOIN primarylocation pl
  ON pl.personid = pe.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_codes lc
  ON lc.locationid = pl.locationid
 AND current_date between lc.effectivedate and lc.enddate
 AND current_timestamp between lc.createts and lc.endts

join dxpersonpositiondet xppd
  on xppd.personid = pe.personid

 and current_date between xppd.effectivedate and xppd.enddate
 and current_timestamp between xppd.createts and xppd.endts
 
left join ( select personid, SUM(ETV_AMOUNT) commission
              from pspay_payment_detail
             where DATE_PART('YEAR',CHECK_DATE) = date_part('year',current_date - interval '1 year')
               and etv_id like ('E%') and etv_id not in ('ECB','EC8','EC9')
               group by 1
          ) agent on agent.personid = pi.personid

JOIN edi.edi_last_update ed on ed.feedId = 'HMN_BenefitFocus_Census_File_Export'

where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and xppd.positiontitle in ('Agent')
  and pe.emplstatus in ('L','A','P')
  --and pe.personid = '65469'
  

union 

select distinct
 pi.personid
,'TERMED EMPLOYEES' ::CHAR(20) AS SOURCESEQ 
--- TERMED EMPLOYEES
,replace(pi.identity,'-','') ::char(9) as ssn 
,pn.lname ::char(20) as lname
,pn.fname ::char(13) as fname
,pn.mname ::char(1) as mname
,pn.title ::char(4) as suffix

,replace(pa.streetaddress,',',' ')       ::char(30) as addr1
,replace(pa.streetaddress2,',',' ')      ::char(30) as addr2
,pa.city                ::char(30) as city
,pa.stateprovincecode   ::char(2) as state
,pa.postalcode          ::char(9) as zip
,case when pa.countrycode = 'US' then 'USA' end ::char(3) as country

,'' ::char(8) as addr_chg_date
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob
,pv.gendercode ::char(1) as gender

,'' ::char(1) as fill_1
,'' ::char(1) as fill_2
,replace(coalesce(ppcw.phoneno,ppc.phoneno),'-','') ::char(10) as phone_home
,'' ::char(1) as phone_cell
,'' ::char(1) as fill_3
,'' ::char(1) as fill_4
,'' ::char(1) as fill_5
,'' ::char(1) as fill_6
,'' ::char(1) as fill_7
,'' ::char(1) as fill_8
,'' ::char(1) as fill_9
,'' ::char(1) as fill_10
,'' ::char(1) as fill_11
,'' ::char(1) as fill_12
,'' ::char(1) as fill_13

,to_char(pe.emplHiredate,'yyyymmdd')  ::char(8) as Orig_hire_date 
,to_char(pe.emplservicedate,'yyyymmdd') ::char(8) as last_hire_date 
,to_char(pe.emplhiredate,'yyyymmdd') ::char(8) as adj_hire_date
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'yyyymmdd')else ''  end ::char(8) as TermDate 
,case when pe.emplstatus = 'T' and pe.empleventdetCode = 'VT'  then 'V'
	   when pe.emplstatus = 'T' and pe.empleventdetCode = 'InT' then 'I'
	   Else '' end ::char(1) as Term_Reason 	
,case when pe.emplevent = 'Retire' then 'Y' else 'N' end ::char(1) as Retired_Ind
,case when pct.frequencycode = 'A' then to_char(pct.compamount,'99999999D99') 
      when pct.frequencycode = 'H' then to_char(pct.compamount * 2080 ,'99999999D99')
       end ::char(14) as Annsalary
,'ANNUAL' ::char(6) as EarningUnit
,'SEMIMONTHLY' ::char(12) as PayFreq
,'' ::char(8) as SalEffectiveDate
,'' ::char(1) as fill_14
,'' ::char(1) as fill_15
,'' ::char(8) as SalOverEffDate
,'' ::char(1) as fill_16
,'' ::char(1) as fill_17
,pie.identity ::char(9) as empnbr
,replace(ppcw.phoneno,'-','') ::char(10) as Work_Phone
,'' ::char(1) as fill_18
,'' ::char(1) as fill_19
,pncw.url  ::char(60) as WorkEmail  
,to_char(ppost.scheduledhours,'9999D99') ::char(8) as HoursWorked  
,'' ::char(1) as CustomCodeEffDate

,'Work Location' ::char(20) as CC1WrkLocation
,CASE WHEN lc.locationcode = 'HO' THEN 'HMNHO'
      WHEN pdt.positiontitle in ('Agent','Acct Rep')  THEN 'HMNFA'
	   ELSE 'HMNFN' END::char(5) as CC1WrkLocation
,'Status' ::char(6) as Status
,CASE When pe.emplstatus =  'L' THEN 'LT'
      When pe.emplpermanency != 'P' and pdt.flsacode != 'E'  THEN 'T1'   
	   ELSE 'NT' End ::char(2) as StatusCode

,'FMLA Code' ::char(9) as CCType3
,'LREN1' ::char(5) as CCType3_value

,'Group Identifier Code' ::char(22) as CCType4
,'HMN00' ::char(5) as CCType4_value

,'' ::char(1) as CCType5
,'' ::char(1) as CCType5_value
,'' ::char(1) as CCType6
,'' ::char(1) as CCType6_value
,'' ::char(1) as CCType7
,'' ::char(1) as CCType7_value
,'' ::char(1) as CCType8
,'' ::char(1) as CCType8_value
,'' ::char(1) as CCType9
,'' ::char(1) as CCType9_value
,'' ::char(1) as CCType10
,'' ::char(1) as CCType10_value
,'' ::char(1) as CCType11
,'' ::char(1) as CCType11_value
,'' ::char(1) as CCType12
,'' ::char(1) as CCType12_value
,'' ::char(1) as CCType13
,'' ::char(1) as CCType13_value
,'' ::char(1) as CCType14
,'' ::char(1) as CCType14_value
,'' ::char(1) as CCType15
,'' ::char(1) as CCType15_value
--,ed.feedid
,'D' ::char(1) as record_type
 
from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
  
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts  

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_phone_contacts ppc
  on ppc.personid = pi.personid
 and ppc.phonecontacttype = 'Home'
 and current_date between ppc.effectivedate and ppc.enddate
 and current_timestamp between ppc.createts and ppc.endts
 and ppc.countrycode is not null

left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and ppcw.phonecontacttype = 'Work'
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts
 and ppcw.countrycode is not null

LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.enddate 
 and pncw.endts > current_date

left join (select personid, max(percomppid) as percomppid
  from person_compensation where earningscode <> 'BenBase'
   and current_timestamp between createts and endts
   group by 1) as maxcompid on maxcompid.personid = pe.personid
   
left join person_compensation pct 
  on pct.personid = maxcompid.personid
 and pct.percomppid = maxcompid.percomppid

left JOIN pers_pos ppost 
  ON ppost.personid = maxcompid.personid 
 AND ppost.persposrel = 'Occupies'::bpchar

left JOIN position_desc pdt
  ON pdt.positionid = ppost.positionid
 AND current_timestamp between pdt.createts AND pdt.endts 

LEFT JOIN primarylocation pl
  ON pl.personid = pe.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_codes lc
  ON lc.locationid = pl.locationid
 AND current_date between lc.effectivedate and lc.enddate
 AND current_timestamp between lc.createts and lc.endts

left join personemploymentdet ped
  on ped.personid = pe.personid
 and ped.emplstatus = 'T'
 
 and current_date between ped.effectivedate and ped.enddate
 and current_timestamp between ped.createts and ped.endts 

JOIN edi.edi_last_update ed on ed.feedId = 'HMN_BenefitFocus_Census_File_Export'

where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and pe.emplstatus = 'T'
  and date_part('year',pe.effectivedate) >= date_part('year',current_date - interval '1 years')
  and ped.emplpermanency <> 'T'
  --and pi.personid not in ('66055','64237','66307','63411','66288')
 -- and pi.personid = '66055'
/*
union 

select distinct
---- ACTIVE - FUTURE DATED 
 pi.personid
,'ACTIVE FUTURE DATED' ::CHAR(20) AS SOURCESEQ 

,replace(pi.identity,'-','') ::char(9) as ssn 
,pn.lname ::char(20) as lname
,pn.fname ::char(13) as fname
,pn.mname ::char(1) as mname
,pn.title ::char(4) as suffix

,replace(pa.streetaddress,',',' ')       ::char(30) as addr1
,replace(pa.streetaddress2,',',' ')      ::char(30) as addr2
,pa.city                ::char(30) as city
,pa.stateprovincecode   ::char(2) as state
,pa.postalcode          ::char(9) as zip
,case when pa.countrycode = 'US' then 'USA' end ::char(3) as country

,'' ::char(8) as addr_chg_date
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob
,pv.gendercode ::char(1) as gender

,'' ::char(1) as fill_1
,'' ::char(1) as fill_2
,replace(coalesce(ppcw.phoneno,ppc.phoneno),'-','') ::char(10) as phone_home
,'' ::char(1) as phone_cell
,'' ::char(1) as fill_3
,'' ::char(1) as fill_4
,'' ::char(1) as fill_5
,'' ::char(1) as fill_6
,'' ::char(1) as fill_7
,'' ::char(1) as fill_8
,'' ::char(1) as fill_9
,'' ::char(1) as fill_10
,'' ::char(1) as fill_11
,'' ::char(1) as fill_12
,'' ::char(1) as fill_13

,to_char(pe.emplHiredate,'yyyymmdd')  ::char(8) as Orig_hire_date 
,to_char(pe.emplservicedate,'yyyymmdd') ::char(8) as last_hire_date 
,to_char(pe.emplhiredate,'yyyymmdd') ::char(8) as adj_hire_date
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'yyyymmdd')else ''  end ::char(8) as TermDate 
,case when pe.emplstatus = 'T' and pe.empleventdetCode = 'VT'  then 'V'
	   when pe.emplstatus = 'T' and pe.empleventdetCode = 'InT' then 'I'
	   Else '' end ::char(1) as Term_Reason 	
,case when pe.emplevent = 'Retire' then 'Y' else 'N' end ::char(1) as Retired_Ind
,case when pc.frequencycode = 'A' then to_char(pc.compamount,'99999999D99') 
      when pc.frequencycode = 'H' then to_char(pc.compamount * 2080 ,'99999999D99')
	   end ::char(14) as Annsalary
,'ANNUAL' ::char(6) as EarningUnit
,'SEMIMONTHLY' ::char(12) as PayFreq
,'' ::char(8) as SalEffectiveDate
,'' ::char(1) as fill_14
,'' ::char(1) as fill_15
,'' ::char(8) as SalOverEffDate
,'' ::char(1) as fill_16
,'' ::char(1) as fill_17
,pie.identity ::char(9) as empnbr
,replace(ppcw.phoneno,'-','') ::char(10) as Work_Phone
,'' ::char(1) as fill_18
,'' ::char(1) as fill_19
,pncw.url  ::char(60) as WorkEmail  
,to_char(ppos.scheduledhours,'9999D99') ::char(8) as HoursWorked  
,'' ::char(1) as CustomCodeEffDate

,'Work Location' ::char(20) as CC1WrkLocation
,CASE WHEN lc.locationcode = 'HO' THEN 'HMNHO'
      WHEN pd.positiontitle in ('Agent','Acct Rep')  THEN 'HMNFA'
	   ELSE 'HMNFN' END::char(5) as CC1WrkLocation
,'Status' ::char(6) as Status
,CASE When pe.emplstatus =  'L' THEN 'LT'
      When pe.emplpermanency != 'P' and pd.flsacode != 'E'  THEN 'T1'   
	   ELSE 'NT' End ::char(2) as StatusCode

,'FMLA Code' ::char(9) as CCType3
,'LREN1' ::char(5) as CCType3_value

,'Group Identifier Code' ::char(22) as CCType4
,'HMN00' ::char(5) as CCType4_value

,'' ::char(1) as CCType5
,'' ::char(1) as CCType5_value
,'' ::char(1) as CCType6
,'' ::char(1) as CCType6_value
,'' ::char(1) as CCType7
,'' ::char(1) as CCType7_value
,'' ::char(1) as CCType8
,'' ::char(1) as CCType8_value
,'' ::char(1) as CCType9
,'' ::char(1) as CCType9_value
,'' ::char(1) as CCType10
,'' ::char(1) as CCType10_value
,'' ::char(1) as CCType11
,'' ::char(1) as CCType11_value
,'' ::char(1) as CCType12
,'' ::char(1) as CCType12_value
,'' ::char(1) as CCType13
,'' ::char(1) as CCType13_value
,'' ::char(1) as CCType14
,'' ::char(1) as CCType14_value
,'' ::char(1) as CCType15
,'' ::char(1) as CCType15_value
--,ed.feedid
,'D' ::char(1) as record_type
 
from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_employment pe
  on pe.personid = pi.personid
 and current_date <= pe.effectivedate 
 and pe.enddate >= '2199-12-30'
 and current_timestamp between pe.createts and pe.endts  
  
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date <= pn.effectivedate 
 and pn.enddate >= '2199-12-30'
 and current_timestamp between pn.createts and pn.endts 

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date <= pa.effectivedate 
 and pa.enddate >= '2199-12-30'
 and current_timestamp between pa.createts and pa.endts

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date <= pv.effectivedate 
 and pv.enddate >= '2199-12-30'
 and current_timestamp between pv.createts and pv.endts 

left join person_phone_contacts ppc
  on ppc.personid = pi.personid
 and ppc.phonecontacttype = 'Home'
 and current_date <= ppc.effectivedate 
 and ppc.enddate >= '2199-12-30'
 and current_timestamp between ppc.createts and ppc.endts
 and ppc.countrycode is not null

left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and ppcw.phonecontacttype = 'Work'
 and current_date <= ppcw.effectivedate 
 and ppcw.enddate >= '2199-12-30'
 and current_timestamp between ppcw.createts and ppcw.endts
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date <= pncw.effectivedate 
 and pncw.enddate >= '2199-12-30'
 AND current_timestamp between pncw.createts and pncw.enddate 
 and pncw.endts > current_date

left JOIN pers_pos ppos 
  ON ppos.personid = pe.personid 
 and current_date <= ppos.effectivedate 
 and ppos.enddate >= '2199-12-30'
 AND current_timestamp between ppos.createts AND ppos.endts 
 AND ppos.persposrel = 'Occupies'::bpchar

left JOIN position_desc pd 
  ON pd.positionid = ppos.positionid
 AND current_date between pd.effectivedate AND pd.enddate 
 AND current_timestamp between pd.createts AND pd.endts 

left join person_compensation pc 
  on pc.personid = pe.personid
 and pc.earningscode <> 'BenBase'
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 

LEFT JOIN primarylocation pl
  ON pl.personid = pe.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_codes lc
  ON lc.locationid = pl.locationid
 AND current_date between lc.effectivedate and lc.enddate
 AND current_timestamp between lc.createts and lc.endts

JOIN edi.edi_last_update ed on ed.feedId = 'HMN_BenefitFocus_Census_File_Export'

where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and pd.positiontitle not like 'Intern %'
  and pe.emplstatus in ('L', 'A')
  --and pe.personid = '68004'

--union

select distinct
---- ACTIVE INTERNS
 pi.personid
,'ACTIVE INTERNS' ::CHAR(20) AS SOURCESEQ
,replace(pi.identity,'-','') ::char(9) as ssn 
,pn.lname ::char(20) as lname
,pn.fname ::char(13) as fname
,pn.mname ::char(1) as mname
,pn.title ::char(4) as suffix

,replace(pa.streetaddress,',',' ')       ::char(30) as addr1
,replace(pa.streetaddress2,',',' ')      ::char(30) as addr2
,pa.city                ::char(30) as city
,pa.stateprovincecode   ::char(2) as state
,pa.postalcode          ::char(9) as zip
,case when pa.countrycode = 'US' then 'USA' end ::char(3) as country

,'' ::char(8) as addr_chg_date
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob
,pv.gendercode ::char(1) as gender

,'' ::char(1) as fill_1
,'' ::char(1) as fill_2
,replace(coalesce(ppcw.phoneno,ppc.phoneno),'-','') ::char(10) as phone_home
,'' ::char(1) as phone_cell
,'' ::char(1) as fill_3
,'' ::char(1) as fill_4
,'' ::char(1) as fill_5
,'' ::char(1) as fill_6
,'' ::char(1) as fill_7
,'' ::char(1) as fill_8
,'' ::char(1) as fill_9
,'' ::char(1) as fill_10
,'' ::char(1) as fill_11
,'' ::char(1) as fill_12
,'' ::char(1) as fill_13

,to_char(pe.emplHiredate,'yyyymmdd')  ::char(8) as Orig_hire_date 
,to_char(pe.emplservicedate,'yyyymmdd') ::char(8) as last_hire_date 
,to_char(pe.emplhiredate,'yyyymmdd') ::char(8) as adj_hire_date
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'yyyymmdd')else ''  end ::char(8) as TermDate 
,case when pe.emplstatus = 'T' and pe.empleventdetCode = 'VT'  then 'V'
	   when pe.emplstatus = 'T' and pe.empleventdetCode = 'InT' then 'I'
	   Else '' end ::char(1) as Term_Reason 	
,case when pe.emplevent = 'Retire' then 'Y' else 'N' end ::char(1) as Retired_Ind
,case when pc.frequencycode = 'A' then to_char(pc.compamount,'99999999D99') 
      when pc.frequencycode = 'H' then to_char(pc.compamount * 2080 ,'99999999D99')
	   end ::char(14) as Annsalary
,'ANNUAL' ::char(6) as EarningUnit
,'SEMIMONTHLY' ::char(12) as PayFreq
,'' ::char(8) as SalEffectiveDate
,'' ::char(1) as fill_14
,'' ::char(1) as fill_15
,'' ::char(8) as SalOverEffDate
,'' ::char(1) as fill_16
,'' ::char(1) as fill_17
,pie.identity ::char(9) as empnbr
,replace(ppcw.phoneno,'-','') ::char(10) as Work_Phone
,'' ::char(1) as fill_18
,'' ::char(1) as fill_19
,pncw.url  ::char(60) as WorkEmail  
,to_char(ppos.scheduledhours,'9999D99') ::char(8) as HoursWorked  
,'' ::char(1) as CustomCodeEffDate

,'Work Location' ::char(20) as CC1WrkLocation
,CASE WHEN lc.locationcode = 'HO' THEN 'HMNHO'
      WHEN pd.positiontitle in ('Agent','Acct Rep')  THEN 'HMNFA'
	   ELSE 'HMNFN' END::char(5) as CC1WrkLocation
,'Status' ::char(6) as Status
,CASE When pe.emplstatus =  'L' THEN 'LT'
      When pe.emplpermanency != 'P' and pd.flsacode != 'E'  THEN 'T1'   
	   ELSE 'NT' End ::char(2) as StatusCode

,'FMLA Code' ::char(9) as CCType3
,'LREN1' ::char(5) as CCType3_value

,'Group Identifier Code' ::char(22) as CCType4
,'HMN00' ::char(5) as CCType4_value

,'' ::char(1) as CCType5
,'' ::char(1) as CCType5_value
,'' ::char(1) as CCType6
,'' ::char(1) as CCType6_value
,'' ::char(1) as CCType7
,'' ::char(1) as CCType7_value
,'' ::char(1) as CCType8
,'' ::char(1) as CCType8_value
,'' ::char(1) as CCType9
,'' ::char(1) as CCType9_value
,'' ::char(1) as CCType10
,'' ::char(1) as CCType10_value
,'' ::char(1) as CCType11
,'' ::char(1) as CCType11_value
,'' ::char(1) as CCType12
,'' ::char(1) as CCType12_value
,'' ::char(1) as CCType13
,'' ::char(1) as CCType13_value
,'' ::char(1) as CCType14
,'' ::char(1) as CCType14_value
,'' ::char(1) as CCType15
,'' ::char(1) as CCType15_value
--,ed.feedid
,'D' ::char(1) as record_type
 
from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
  
left join person_employment pe
  on pe.personid = pi.personid
 and current_date <= pe.effectivedate 
 and pe.enddate >= '2199-12-30'
 and current_timestamp between pe.createts and pe.endts 
   
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date <= pn.effectivedate 
 and pn.enddate >= '2199-12-30'
 and current_timestamp between pn.createts and pn.endts 

left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date <= pa.effectivedate 
 and pa.enddate >= '2199-12-30'
 and current_timestamp between pa.createts and pa.endts

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date <= pv.effectivedate 
 and pv.enddate >= '2199-12-30'
 and current_timestamp between pv.createts and pv.endts 

left join person_phone_contacts ppc
  on ppc.personid = pi.personid
 and ppc.phonecontacttype = 'Home'
 and current_date <= ppc.effectivedate 
 and ppc.enddate >= '2199-12-30'
 and current_timestamp between ppc.createts and ppc.endts
 and ppc.countrycode is not null

left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and ppcw.phonecontacttype = 'Work'
 and current_date <= ppcw.effectivedate 
 and ppcw.enddate >= '2199-12-30'
 and current_timestamp between ppcw.createts and ppcw.endts
 and ppcw.countrycode is not null

LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date <= pncw.effectivedate 
 and pncw.enddate >= '2199-12-30'
 AND current_timestamp between pncw.createts and pncw.enddate 

left JOIN pers_pos ppos 
  ON ppos.personid = pe.personid 
 and current_date <= ppos.effectivedate 
 and ppos.enddate >= '2199-12-30' 
 AND current_timestamp between ppos.createts AND ppos.endts 
 AND ppos.persposrel = 'Occupies'::bpchar

left JOIN position_desc pd 
  ON pd.positionid = ppos.positionid
 AND current_date between pd.effectivedate AND pd.enddate 
 AND current_timestamp between pd.createts AND pd.endts 

left join person_compensation pc 
  on pc.personid = pe.personid
 and pc.earningscode <> 'BenBase'
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 

LEFT JOIN primarylocation pl
  ON pl.personid = pe.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_codes lc
  ON lc.locationid = pl.locationid
 AND current_date between lc.effectivedate and lc.enddate
 AND current_timestamp between lc.createts and lc.endts


JOIN edi.edi_last_update ed on ed.feedId = 'HMN_BenefitFocus_Census_File_Export'

where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and pd.positiontitle like 'Intern %'
  and pe.emplstatus in ('L', 'A')
  --and pe.personid = '67973'

*/


order by 1

;

