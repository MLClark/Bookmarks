select distinct
 pi.personid
,pe.effectivedate 
,'ACTIVE EE' ::varchar(30) as qsource 
,pi.identity ::char(9) as ssn --A
,pn.lname ::varchar(50) as lname --B
,pn.fname ::varchar(50) as fname --C
,pn.mname ::char(1) as mname  --D
,null ::char(1) as suffix   --E
,replace(pa.streetaddress,',',' ') ::varchar(50) as addr1  --F
,replace(pa.streetaddress2,',',' ') ::varchar(50) as addr2 --G
,pa.city ::varchar(50) as city   --H
,pa.stateprovincecode ::char(2) as state  --I
,pa.postalcode ::varchar(10) as zip --J
,case when pa.countrycode = 'US' then 'USA' end ::char(3) as countrycode   --K
,case when pa.effectivedate >= elu.lastupdatets then to_char(pa.effectivedate,'yyyymmdd')
      when pn.effectivedate >= elu.lastupdatets then to_char(pn.effectivedate,'yyyymmdd') else null end ::char(8) as name_addr_chg_date --L
--,to_char(greatest(pa.effectivedate,pn.effectivedate),'yyyymmdd') ::char(8) as name_addr_chg_date --L
,to_char(pv.birthdate,'yyyymmdd') ::varchar(8) as dob --M
,pv.gendercode ::char(1) as gender  --N
,case when pm.maritalstatus = 'U' then 'Unknown' 
      when pm.maritalstatus = 'M' then 'Married' 
      when pm.maritalstatus = 'S' then 'Single' 
      when pm.maritalstatus = 'R' then 'Domestic Partner Relationship'
      when pm.maritalstatus = 'C' then 'Common Law'      
      else 'Unknown' end  ::varchar(50) as maritalstatus  --O
,case when pv.ethniccode = 'N' then 'Unspecified'
      when pv.ethniccode = 'I' then 'Native American'
      when pv.ethniccode = 'A' then 'Asian'
      when pv.ethniccode = 'B' then 'Black'
      when pv.ethniccode = 'H' then 'Hispanic'
      when pv.ethniccode = 'P' then 'Caribbean Islander'
      when pv.ethniccode = 'W' then 'White'
      else 'Other' end ::varchar(20) as ethnicity  --P

,ppch.phoneno ::varchar(15) as homephone  --Q
,ppcm.phoneno ::varchar(15) as cellphone  --R
,pnch.url ::varchar(100) as personal_email --S
,null ::char(1) as emer_name   --T
,null ::char(1) as emer_rel --U
,null ::char(1) as emer_phone  --V
,null ::char(1) as emer_alt_phone --W
,null ::char(1) as emer_addr1  --X
,null ::char(1) as emer_addr2  --Y
,null ::char(1) as emer_city   --Z
,null ::char(1) as emer_state  --AA
,null ::char(1) as emer_zip --AB
,null ::char(1) as emer_country   --AC
,to_char(pe.emplhiredate,'yyyymmdd')::varchar(8) as doh --AD 30
,case when pe.emplhiredate <> pe.emplservicedate then to_char(pe.emplservicedate,'yyyymmdd') else ' ' end ::varchar(8) as adjusted_svc_date --AE 31
,null ::char(1) as other_date  --AF32
,case when pe.emplstatus in ('R','T') then to_char(pe.effectivedate,'yyyymmdd')else null end ::varchar(8) term_date --AG
,case when pe.emplstatus in ('R','T')  and pe.emplevent <> 'Retire' then pe.emplevent else null end ::varchar(1) as termrsn   --AH
,case when pe.emplstatus in ('R','T')  and pe.emplevent = 'Retire' then 'Y' else 'N' end ::varchar(1) as retire_ind --AI35
,to_char(pc.compamount,'999999999D00') ::char(13) as salary   --AJ36
,case when pc.frequencycode like 'H%' then 'HOURLY'
      when pc.frequencycode like 'A%' then 'ANNUAL' else pc.frequencycode end ::varchar(20) as earn_unit_measure --AK37
,'BIWEEKLY' ::varchar(25) as pay_freq --AL38
,to_char(pc.effectivedate,'yyyymmdd') ::varchar(8) as earn_amt_eff_dt   --AM 39 - comp effectivedate 
,null as salovrdamt  --AN 40 - not used 
,null as salovrduom  --AO 41 - not used      
,null as salovrdamtdt --AP 42 - not used 
,case when pd.eeocode = '11' then 'OFFICIALS AND MANAGERS'
      when pd.eeocode = '12' then 'OFFICIALS AND MANAGERS'
      when pd.eeocode = '20' then 'PROFESSIONALS'
      when pd.eeocode = '30' then 'TECHNICIANS'
      when pd.eeocode = '40' then 'SALES PERSONNEL'
      when pd.eeocode = '50' then 'OPERATIVES SEMI-SKILLED WORKERS' 
      when pd.eeocode = '60' then 'CRAFT SKILLED WORKERS'
      when pd.eeocode = '70' then 'OPERATIVES SEMI-SKILLED WORKERS' 
      when pd.eeocode = '80' then 'LABORERS'
      when pd.eeocode = '90' then 'SERVICE EMPLOYEES'
      when pd.eeocode = '99' then ' '
      else pd.eeocode end ::varchar(50) as eeoc  --AQ43
,pd.positiontitle ::varchar(25) as occupation  --AR
,pie.identity ::varchar(9) as memberid --AS45
,ppcW.phoneno ::varchar(10) as workphone   --AT46
,null ::char(1) as workcell --AU47
,null ::char(1) as workpager   --AV48
,pncw.url ::varchar(50) as workemail   --AW49
,' '  ::char(1) as schedhrs --AX
--,substring(pip.identity from 4 for 2)
-- select * from person_locations order by personid, effectivedate;
-- select * from person_employment
,case when elu.lastupdatets <= ploc.effectivedate then to_char(ploc.effectivedate,'yyyy-mm-dd')
      when elu.lastupdatets <= pe.effectivedate then to_char(pe.effectivedate,'yyyy-mm-dd') else null end as cust_cat_eff_date --AY51 ---date that any category change becomes effective
,'Division'::varchar(50) as cust_cat_type1 --AZ52 - 'Division' - hardcoded 
,'TECH - Morgan Advanced Ceramics (MAC)' ::varchar(50) as cust_cat_value1 --BA53 

,'Location' ::varchar(50) as cust_cat_type2
,lc.locationcode
,case when lc.locationcode = '7B4' then 'TECH - GBU (MAC)'
      when lc.locationcode = '7B8' then 'TECH - ALLENTOWN (MAC)'
      when lc.locationcode = '7B9' then 'TECH - BEDFORD (MAC)'
      when lc.locationcode = '7BC' then 'TECH - FAIRFIELD (MAC)'
      when lc.locationcode = '7C7' then 'TECH - HAYWARD CERAMICS (MAC)'
      when lc.locationcode = '7C8' then 'TECH - HAYWARD METALS (MAC)'
      when lc.locationcode = '7C9' then 'TECH - HUDSON (MAC)'
      when lc.locationcode = '7DD' then 'TECH - LATROBE (MAC)'
      when lc.locationcode = '7DE' then 'TECH - LATROBE (MAC)'
      when lc.locationcode = '7E6' then 'TECH - NEW BEDFORD (MAC)'
      when lc.locationcode = 'AXE' then 'TECH - AUBURN (MAC)'
      when lc.locationcode = 'E39' then 'TECH - IT NA (MAC)'
      /* Added 1/25/19
        7VK =     TECH - CERTECH TWINSBURG (MAC)
        7XK =     TECH - CERTECH WILKESBARRE (MAC)
        7YZ =     TECH - CERTECH WOODRIDGE (MAC)
      */
      when lc.locationcode = '7VK' then 'TECH - CERTECH TWINSBURG (MAC)'
      when lc.locationcode = '7XK' then 'TECH - CERTECH WILKESBARRE (MAC)'
      when lc.locationcode = '7YZ' then 'TECH - CERTECH WOODRIDGE (MAC)' else ' ' END ::varchar(50) as cust_cat_value2
      
,'Union Status' ::varchar(50)  as cust_cat_type3 --BB54
,case when sg.grade in ('6') then 'NON UNION' else 'UNION' end::varchar(20) as cust_cat_value3 

,'Employment Class' ::varchar(50)  as cust_cat_type4
/*
        1/25/19 modified emplclass - added seasonal 
*/
,case when pe.emplclass = 'F' then 'Full Time' 
      when pe.emplclass = 'T' then 'Seasonal'
      when pe.emplclass = 'P' then 'Part Time' end ::varchar(50) as cust_cat_value4       

,'Company Name' ::varchar(50)  as cust_cat_type5 --BB54
,pu.employertaxid
,case when pu.employertaxid = '94-3146877' then 'Morgan Advanced Ceramics Inc.' 
      when pu.employertaxid = '52-2133955' then 'Certech Inc.' end ::varchar(50) as cust_cat_value5

,null ::char(1) as cust_cat_type6
,null ::char(1) as cust_cat_value6
,null ::char(1) as cust_cat_type7
,null ::char(1) as cust_cat_value7
,null ::char(1) as cust_cat_type8
,null ::char(1) as cust_cat_value8
,null ::char(1) as cust_cat_type9
,null ::char(1) as cust_cat_value9
,null ::char(1) as cust_cat_type10
,null ::char(1) as cust_cat_value10
,null ::char(1) as cust_cat_type11
,null ::char(1) as cust_cat_value11
,null ::char(1) as cust_cat_type12
,null ::char(1) as cust_cat_value12
,null ::char(1) as cust_cat_type13
,null ::char(1) as cust_cat_value13
,null ::char(1) as cust_cat_type14
,null ::char(1) as cust_cat_value14
,null ::char(1) as cust_cat_type15
,null ::char(1) as cust_cat_value15
      
 
from person_identity pi
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'DGH_Benefitfocus_Demographic_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts 
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join  (SELECT personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
             FROM person_compensation WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts 
            GROUP BY personid, compamount, increaseamount, compevent, frequencycode, earningscode) as pc on pc.personid = pe.personid and pc.rank = 1 

left join pers_pos pp
  on pp.personid = pe.personid 
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 

left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 
 and pd.effectivedate < pd.enddate 
 
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_maritalstatus pm
  on pm.personid = pe.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 

left join person_phone_contacts ppch 
  on ppch.personid = pe.personid
 and ppch.phonecontacttype = 'Home'  
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.effectivedate - interval '1 day' <> ppch.enddate
 --select * from person_phone_contacts where phonecontacttype = 'Work'     
left join person_phone_contacts ppcw 
  on ppcw.personid = pe.personid
 and ppcw.phonecontacttype = 'Work'     
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 
 and ppcw.effectivedate - interval '1 day' <> ppcw.enddate
 
left join person_phone_contacts ppcb 
  on ppcb.personid = pe.personid
 and ppcb.phonecontacttype = 'BUSN'    
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.effectivedate - interval '1 day' <> ppcb.enddate
    
left join person_phone_contacts ppcm 
  on ppcm.personid = pe.personid
 and ppcm.phonecontacttype = 'Mobile'     
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.effectivedate - interval '1 day' <> ppcm.enddate

left join person_net_contacts pncw
  on pncw.personid = pe.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts
 and pncw.effectivedate - interval '1 day' <> pncw.enddate     
 
 left JOIN person_net_contacts pnch 
  ON pnch.personid = pe.personid 
 AND pnch.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnch.effectivedate and pnch.enddate
 AND current_timestamp between pnch.createts and pnch.enddate 

left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts
 
left join person_locations ploc
  on ploc.personid = pe.personid
 and current_date between ploc.effectivedate and ploc.enddate
 and current_timestamp between ploc.createts and ploc.endts
 
left join location_codes lc
  on lc.locationid = ploc.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts 

left join pay_unit pu on pu.payunitid = ppl.payunitid
left join frequency_codes fc on fc.frequencycode = pc.frequencycode
left join edi.etl_employment_term_data eetd on eetd.personid = pe.personid 
left join frequency_codes fct on fct.frequencycode = eetd.frequencycode

left join salary_grade sg
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'