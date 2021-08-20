select distinct
 pi.personid
,pu.payunitxid
,lu.key1
,lu.value1
,lu.value2
,lu.value3 
,pe.effectivedate 
,substring(pip.identity from 4 for 2) as locationid
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
,case when pa.countrycode = 'US' then 'USA' 
      when pa.countrycode = 'MX' then 'MEX' else pa.countrycode end ::char(3) as countrycode   --K
,case when pa.effectivedate > elu.lastupdatets and pa.effectivedate < pa.createts then to_char(pa.effectivedate,'yyyymmdd')
      when pn.effectivedate > elu.lastupdatets and pn.effectivedate < pn.createts then to_char(pn.effectivedate,'yyyymmdd')
      else null end ::char(8) as name_addr_chg_date --L
,to_char(pv.birthdate,'yyyymmdd') ::varchar(8) as dob --M
,pv.gendercode ::char(1) as gender  --N
,case when pm.maritalstatus = 'U' then 'Unknown' 
      when pm.maritalstatus = 'R' then 'Domestic Partner Relationship'
      when pm.maritalstatus = 'C' then 'Common Law'      
      else pm.maritalstatus end  ::varchar(50) as maritalstatus  --O
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
--8/7/2019 Add Personal email
,pnch.url ::varchar(50) as personal_email --S
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
-- 8/7/2019 Chg to Original Hire Date
,to_char(pe.emplhiredate,'yyyymmdd')::varchar(8) as doh --AD 30
-- 8/7/2019 Chg to Last Hired Date, if different than Original Hire Date
,case when pe.emplhiredate != pe.empllasthiredate then to_char(pe.empllasthiredate,'yyyymmdd') else null end ::varchar(8) as adjusted_svc_date --AE 31
,null ::char(1) as other_date  --AF32
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'yyyymmdd')else null end ::varchar(8) term_date --AG
,case when pe.emplstatus = 'T' and pe.emplevent <> 'Retire' then pe.emplevent else null end ::varchar(1) as termrsn   --AH
,case when pe.emplstatus = 'T' and pe.emplevent = 'Retire' then 'Y' else 'N' end ::varchar(1) as retire_ind --AI35
,to_char(pc.compamount,'999999999D00') ::char(13) as salary   --AJ36
,case when pc.frequencycode like 'H%' then 'HOURLY'
      when pc.frequencycode like 'A%' then 'ANNUAL' else pc.frequencycode end ::varchar(20) as earn_unit_measure --AK37
,case when pp.schedulefrequency = 'W' then 'WEEKLY'
      when pp.schedulefrequency = 'H' then 'WEEKLY'
      when pp.schedulefrequency = 'B' then 'BIWEEKLY' else null end ::varchar(25) as pay_freq --AL38
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
      when pd.eeocode = '99' then ' '
      else pd.eeocode end ::varchar(50) as eeoc  --AQ43
,pd.positiontitle ::varchar(25) as occupation  --AR
,pie.identity ::varchar(9) as memberid --AS45
,ppcW.phoneno ::varchar(10) as workphone   --AT46
,null ::char(1) as workcell --AU47
,null ::char(1) as workpager   --AV48
,coalesce(pncw.url,pnch.url) ::varchar(50) as workemail   --AW49
-- 8/7/2019 Change to blank
,' ' ::char(1) as schedhrs --AX

--,substring(pip.identity from 4 for 2)
,null ::char(1) as cust_cat_eff_date --AY51 ---date that any category change becomes effective
,'Division'::varchar(50) as cust_cat_type1 --AZ52 - 'Division' - hardcoded 
,'THERMAL' ::varchar(50) as cust_cat_value1 --BA53 - 'Thermal' - division value - case and space sensitive 
,'Location' ::varchar(50) as cust_cat_type2

--8/7/19 Add BAC28 = Molten Materials

,lu.value1 ::varchar(50) as cust_cat_value2
/*
,case when pu.payunitxid = '00' then 'AUGUSTA AND EMPORIA SAL'
      when pu.payunitxid = '05' then 'AUGUSTA UNION'
      when pu.payunitxid = '10' then 'AUGUSTA AND EMPORIA SAL'
      when pu.payunitxid = '15' then 'EMPORIA UNION'
      when pu.payunitxid = '20' then 'GIRARD'
      when pu.payunitxid = '25' then 'ELKHART'
      when pu.payunitxid = '28' then 'MOLTEN MATERIALS'
      when pu.payunitxid = '29' then 'MORGANITE INDUSTRIES' ----- mlc 12/19 - adding pay group bac29
      END ::varchar(50) as cust_cat_value2 --BC55
*/      
-- 8/7/19 Change to 'Employment Class'
,'Employment Class' ::varchar(50)  as cust_cat_type3 --BB54
-- 8/7/19 Change to: Value of Employment Class:Full Time Part Time Seasonal All other classes should default to Seasonal
,pe.emplclass
,case when pe.emplclass = 'F' then 'Full Time' 
      when pe.emplclass = 'P' then 'Part Time' else 'Seasonal' end ::varchar(50) as cust_cat_value3

,'STD CLASSIFICATION' ::varchar(50)  as cust_cat_type4
,CASE WHEN pc.frequencycode = 'A' then 'SALARY' else 'HOURLY' end ::varchar(50) as cust_cat_value4
-- 8/7/19 Change to 'Company Name'
,'Company Name' ::varchar(50) as cust_cat_type5 --BH(60)

,lu.value3 ::varchar(50) as cust_cat_value5
--,case when pu.payunitxid = '28' then 'Morganite Crucible Inc.'
--      when pu.payunitxid = '29' then 'Morganite Industries' ----- mlc 12/19 - adding pay group bac29   
--      else 'Thermal Ceramics Inc.' end ::varchar(50) as cust_cat_value5

,'Union Status' ::varchar(50)  as cust_cat_type6 --BB54
,lu.value2 ::varchar(50) as cust_cat_value6
--,case when pu.payunitxid in ('00','10','20','25','28','29') then 'NON UNION' ----- mlc 12/19 - adding pay group bac29
--      when pu.payunitxid in ('05','15') then 'UNION' END ::varchar(50) as cust_cat_value6

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
      
,elu.lastupdatets

from person_identity pi
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BAC_Benefitfocus_Demographic_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

left join person_compensation pc
  on pc.personid = pi.personid 
 and pc.earningscode <> 'BenBase'
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 
left join pers_pos pp
  on pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 

left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 
 and pd.effectivedate < pd.enddate
 
left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts

left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and ppch.phonecontacttype = 'Home'  
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.effectivedate - interval '1 day' <> ppch.enddate
 
left join person_phone_contacts ppcw 
  on ppcw.personid = pi.personid
 and ppcw.phonecontacttype = 'Work'     
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 
 and ppcw.effectivedate - interval '1 day' <> ppcw.enddate
 
left join person_phone_contacts ppcb 
  on ppcb.personid = pi.personid
 and ppcb.phonecontacttype = 'BUSN'    
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.effectivedate - interval '1 day' <> ppcb.enddate
    
left join person_phone_contacts ppcm 
  on ppcm.personid = pi.personid
 and ppcm.phonecontacttype = 'Mobile'     
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.effectivedate - interval '1 day' <> ppcm.enddate

left join person_net_contacts pncw
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts
 and pncw.effectivedate - interval '1 day' <> pncw.enddate     
 
left JOIN person_net_contacts pnch 
  ON pnch.personid = pi.personid 
 AND pnch.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnch.effectivedate and pnch.enddate
 AND current_timestamp between pnch.createts and pnch.enddate  
 
LEFT JOIN person_payroll ppay
  ON ppay.personid = pi.personid
 AND current_date BETWEEN ppay.effectivedate AND ppay.enddate
 AND current_timestamp BETWEEN ppay.createts AND ppay.endts      

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppay.payunitid  
  
left join ( select lkup.lookupid,lkup.key1,lkup.value1,lkup.value2,lkup.value3
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname = 'BAC_Benefitfocus_Demographic_Export'
      ) lu on lu.key1 = pu.payunitxid
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'-- and pe.emplpermanency <> 'T'
 

union

select distinct
 pi.personid
,pu.payunitxid
,lu.key1
,lu.value1
,lu.value2
,lu.value3 
,pe.effectivedate
,substring(pip.identity from 4 for 2) as locationid
,'TERMED EE' ::varchar(30) as qsource 
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
,case when pa.countrycode = 'US' then 'USA' 
      when pa.countrycode = 'MX' then 'MEX' else pa.countrycode end ::char(3) as countrycode   --K
,null ::char(8) as name_addr_chg_date --L
,to_char(pv.birthdate,'yyyymmdd') ::varchar(8) as dob --M
,pv.gendercode ::char(1) as gender  --N
,case when pm.maritalstatus = 'U' then 'Unknown' 
      when pm.maritalstatus = 'R' then 'Domestic Partner Relationship'
      when pm.maritalstatus = 'C' then 'Common Law'
      else pm.maritalstatus end  ::varchar(50) as maritalstatus  --O
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
--8/7/2019 Add Personal email
,pnch.url ::varchar(50) as personal_email --S
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
-- 8/7/2019 Chg to Original Hire Date
,to_char(pe.emplhiredate,'yyyymmdd')::varchar(8) as doh --AD 30
-- 8/7/2019 Chg to Last Hired Date, if different than Original Hire Date
,case when pe.emplhiredate != pe.empllasthiredate then to_char(pe.empllasthiredate,'yyyymmdd') else null end ::varchar(8) as adjusted_svc_date --AE 31
,null ::char(1) as other_date  --AF32
,case when pe.emplstatus in ('R','T') then to_char(pe.effectivedate,'yyyymmdd')else null end ::varchar(8) term_date --AG
,case when pe.emplstatus in ('R','T') then pe.emplevent else null end ::varchar(1) as termrsn   --AH
,case when pe.emplstatus = 'R' then 'Y'
      when pe.emplstatus = 'T' and pe.emplevent = 'Retire' then 'Y' else 'N' end ::varchar(1) as retire_ind --AI35
,to_char(pcrank.compamount,'999999999D00') ::char(13) as salary   --AJ36 as salary   --AJ36
,case when pcrank.frequencycode like 'H%' then 'HOURLY'
      when pcrank.frequencycode like 'A%' then 'ANNUAL' else pcrank.frequencycode end ::varchar(20) as earn_unit_measure --AK37
,case when pprank.schedulefrequency = 'W' then 'WEEKLY'
      when pprank.schedulefrequency = 'H' then 'WEEKLY'
      when pprank.schedulefrequency = 'B' then 'BIWEEKLY' else null end ::varchar(25) as pay_freq --AL38
,to_char(pcrank.effectivedate,'yyyymmdd') ::varchar(8) as earn_amt_eff_dt   --AM 39 - comp effectivedate 
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
      when pd.eeocode = '99' then ' '
      else pd.eeocode end ::varchar(50) as eeoc  --AQ43
,pd.positiontitle ::varchar(25) as occupation  --AR
,pie.identity ::varchar(9) as memberid --AS45
,ppcW.phoneno ::varchar(10) as workphone   --AT46
,null ::char(1) as workcell --AU47
,null ::char(1) as workpager   --AV48
,coalesce(pncw.url,pnch.url) ::varchar(50) as workemail   --AW49
-- 8/7/2019 Change to blank
,' ' ::char(1) as schedhrs --AX
--,substring(pip.identity from 4 for 2)
,null ::char(1) as cust_cat_eff_date --AY51 ---date that any category change becomes effective
,'Division'::varchar(50) as cust_cat_type1 --AZ52 - 'Division' - hardcoded 
,'THERMAL' ::varchar(50) as cust_cat_value1 --BA53 - 'Thermal' - division value - case and space sensitive 
,'Location' ::varchar(50) as cust_cat_type2
--8/7/19 Add BAC28 = Molten Materials
,lu.value1 ::varchar(50) as cust_cat_value2
/*
,case when pu.payunitxid = '00' then 'AUGUSTA AND EMPORIA SAL'
      when pu.payunitxid = '05' then 'AUGUSTA UNION'
      when pu.payunitxid = '10' then 'AUGUSTA AND EMPORIA SAL'
      when pu.payunitxid = '15' then 'EMPORIA UNION'
      when pu.payunitxid = '20' then 'GIRARD'
      when pu.payunitxid = '25' then 'ELKHART'
      when pu.payunitxid = '28' then 'MOLTEN MATERIALS'
      when pu.payunitxid = '29' then 'MORGANITE INDUSTRIES' ----- mlc 12/19 - adding pay group bac29      
      END ::varchar(50) as cust_cat_value2 --BC55
*/
-- 8/7/19 Change to 'Employment Class'
,'Employment Class' ::varchar(50)  as cust_cat_type3 --BB54
-- 8/7/19 Change to: Value of Employment Class:Full Time Part Time Seasonal All other classes should default to Seasonal
,pe.emplclass
,case when pe.emplclass = 'F' then 'Full Time' 
      when pe.emplclass = 'P' then 'Part Time' else 'Seasonal' end ::varchar(50) as cust_cat_value3

,'STD CLASSIFICATION' ::varchar(50)  as cust_cat_type4
,CASE WHEN pcrank.frequencycode = 'A' then 'SALARY' else 'HOURLY' end ::varchar(50) as cust_cat_value4

-- 8/7/19 Change to 'Company Name'
,'Company Name' ::varchar(50) as cust_cat_type5 --BH(60)
,lu.value3 ::varchar(50) as cust_cat_value5
--,case when pu.payunitxid = '28' then 'Morganite Crucible Inc.'
--      when pu.payunitxid = '29' then 'Morganite Industries' ----- mlc 12/19 - adding pay group bac29   
--      else 'Thermal Ceramics Inc.' end ::varchar(50) as cust_cat_value5

,'Union Status' ::varchar(50)  as cust_cat_type6 --BB54
,lu.value2 ::varchar(50) as cust_cat_value6
--,case when pu.payunitxid in ('00','10','20','25','28','29') then 'NON UNION' ----- mlc 12/19 - adding pay group bac29
--      when pu.payunitxid in ('05','15') then 'UNION' END ::varchar(50) as cust_cat_value6

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
      
,elu.lastupdatets

from person_identity pi
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BAC_Benefitfocus_Demographic_Export'

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

left join person_compensation pc
  on pc.personid = pi.personid 
 and pc.earningscode <> 'BenBase'
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 
----- Last compensation date and increase amount
left join 
--- select * from edi.edi_last_update;
(SELECT personid, compamount, frequencycode, increaseamount, compevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_compensation pc1
            LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BAC_Benefitfocus_Demographic_Export'
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate <= elu.lastupdatets::DATE
            GROUP BY personid, compamount, frequencycode, increaseamount, compevent ) as pcrank on pcrank.personid = pe.personid and pcrank.rank = 1    

left join 
(select personid, scheduledhours, schedulefrequency, positionid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
   from pers_pos              
   LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BAC_Benefitfocus_Demographic_Export'
    AND current_timestamp BETWEEN createts AND endts
    and effectivedate <= elu.lastupdatets::DATE
  GROUP BY personid, scheduledhours, schedulefrequency, positionid ) as pprank on pprank.personid = pe.personid and pprank.rank = 1

left join position_desc pd
  on pd.positionid = pprank.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 
 
left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts

left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and ppch.phonecontacttype = 'Home'  
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.effectivedate - interval '1 day' <> ppch.enddate
 -- select phonecontacttype from person_phone_contacts group by 1
left join person_phone_contacts ppcw 
  on ppcw.personid = pi.personid
 and ppcw.phonecontacttype = 'Work'     
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 
 and ppcw.effectivedate - interval '1 day' <> ppcw.enddate
 
left join person_phone_contacts ppcb 
  on ppcb.personid = pi.personid
 and ppcb.phonecontacttype = 'BUSN'    
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.effectivedate - interval '1 day' <> ppcb.enddate
    
left join person_phone_contacts ppcm 
  on ppcm.personid = pi.personid
 and ppcm.phonecontacttype = 'Mobile'     
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.effectivedate - interval '1 day' <> ppcm.enddate
--- select netcontacttype from person_net_contacts group by 1
left join person_net_contacts pncw
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts
 and pncw.effectivedate - interval '1 day' <> pncw.enddate     
 
left JOIN person_net_contacts pnch 
  ON pnch.personid = pi.personid 
 AND pnch.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnch.effectivedate and pnch.enddate
 AND current_timestamp between pnch.createts and pnch.enddate   

LEFT JOIN person_payroll ppay
  ON ppay.personid = pi.personid
 AND current_date BETWEEN ppay.effectivedate AND ppay.enddate
 AND current_timestamp BETWEEN ppay.createts AND ppay.endts      

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppay.payunitid 

left join ( select lkup.lookupid,lkup.key1,lkup.value1,lkup.value2,lkup.value3
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname = 'BAC_Benefitfocus_Demographic_Export'
      ) lu on lu.key1 = pu.payunitxid  
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus IN ('R','T')
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets 
  and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) 
  and date_part('year',pe.effectivedate)=date_part('year',current_date))
 
 --- This union pulls mainly mexico temp employees - Lori said to comment out for now
  order by 1