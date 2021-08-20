select distinct
 pi.personid
,'310 Active EE' ::varchar(30) as sourceseq
--------------------------------------------------------------
----- Employee or Dependent Personal Information Section -----  
----- Section Code ~PII~                                 -----
--------------------------------------------------------------
,'~PII~' ::char(5) as section_code_pii
,' ' ::char(10) as customer_nbr
,'E' ::char(1) as trans_code 
,pi.identity ::char(9) as SSN
,pie.identity ::varchar(15) as empno
,' ' ::char(1) as mbrssn
,' ' ::char(1) as rel_code
,upper(pn.lname) ::varchar(30) as lname
,upper(pn.fname) ::varchar(30) as fname
,upper(pn.mname) ::char(1) as mname
,' ' ::char(1) as name_prefix
,' ' ::char(1) as name_suffix
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,pms.maritalstatus ::char(1) as marital_status
,pv.gendercode ::char(1) as gender
,pv.smoker ::char(1) AS smoker
--------------------------------------------------
----- Employment Contact Information Section -----
----- Section Code ~ECI~                     -----
--------------------------------------------------
,'~ECI~' ::char(5) as section_code_eci
,pa.streetaddress ::varchar(40) as addr1
,pa.streetaddress2 ::varchar(40) as addr2
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(10) as zip
,'840' ::char(3) as country_code
,null as mbr_mail
,null as mbr_mail2
,ppcH.phoneno ::varchar(15) as homephone
,ppcM.phoneno ::varchar(15) as cellphone
,pnch.url ::varchar(50) AS homeemail
,pncw.url ::varchar(50) AS workemail
,CASE WHEN clr.companylocationtype = 'WH' ::bpchar THEN st.stateprovincecode  
      ELSE pa.stateprovincecode END  ::char(2) AS workstatecode  
,null as work_addr
,null as work_addr2
,null as work_city
,null as work_state
,null as work_zip
,null as work_country
,ppcW.phoneno ::varchar(15) as workphone
------------------------------------------
----- Employment Information Section -----
----- Section Code ~EMI~             -----
------------------------------------------
,'~EMI~' ::char(5) as section_code_emi
,pe.emplstatus ::char(1) as employee_status
,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as doh
,null as emp_service
,to_char(pe.empllasthiredate,'YYYYMMDD')::char(8) as dor
,to_char(pe.emplsenoritydate,'YYYYMMDD')::char(8) as ohd
,null as emp_term_rsn
,null as emp_term_desc
,to_char(pe.paythroughdate,'YYYYMMDD')::char(8) as ldw
,case when pe.emplclass = 'F' then 'F ' else 'P ' end ::char(2) as emp_type
,case when pd.flsacode = 'E' then 'E ' else 'N ' END ::char(1) as exempt_type
,cast(round(pp.scheduledhours, 2)*100 as bigint)/2 sched_hrs_per_week
,lpad(coalesce(CASE when pc.frequencycode = 'A'::bpchar then cast(round(pc.compamount, 2)*100 as bigint)
                    when pc.frequencycode = 'H'::bpchar then cast(round(pc.compamount * pp.scheduledhours * fc1.annualfactor, 2)*100 as bigint)
                    else 0::numeric END,0)::text,9,'0') AS annualsalary
,'A' ::char(1) as salarybasis 
,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as salaryeffdate
,null as commision_amount
,null as bonus
,upper(pd.positiontitle)  ::char(25) as jobtitle     
,null as job_code
,pu.payunitdesc ::char(5) as payoll_code   
,null as company_code
,null as dept_code
,null as div_code
,lc.locationcode ::varchar(30) as loc_code
,null as reg_code
,null as acct_code
,'N' ::char(1) as union_ind
,null as union_name
-----------------------------------------
----- Short Term Disability Section -----
----- NON-STATUTORY                 -----
----- Section Code ~NST~            -----
-----------------------------------------
,'~NST~'::char(5) as section_code_nst
,case when pbestd.benefitsubclass in ('30','3Y') then to_char(pbestd.effectivedate,'YYYYMMDD') else null end ::char(8) as nst_cov_effdate
,case when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitelection = 'T' then to_char(pbestd.effectivedate,'YYYYMMDD')
      when pbestd.benefitsubclass in ('30','3Y') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as nst_cov_term_date
,' ' ::char(1) as nst_std_covered_salary
/*
"60 - for Salaried
Core - for Hourly
Buyup - for Hourly w Buy up plan"
*/  
,case when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'H' then 'Core'
      when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'A' then '60'
      when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'H' and pbestd.benefitplanid = '285' then 'Buyup'
      else null end ::varchar(10) as nst_std_cvg_plan_option
,' ' ::char(1) as nst_std_req_cvg_plan_option
/*
"Based on Pay Unit:
1 - for AJG00 - 01
2 - for AJG05-06
3 - for AJG20
4 - for AJG15-16"
*/
,case when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('00','01') then '1'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('05','06') then '2'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ( '20' )    then '3'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('15','16') then '4' else null end ::char(1) as nst_ee_group_id
,' '::char(1) as nst_ee_class_code 
----------------------------------------
----- Long Term Disability Section -----
----- Section Code ~LTD~           -----
----------------------------------------
,'~LTD~'::char(5) as section_code_ltd
,case when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') else null end ::char(8) as ltd_cov_effdate
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T' then to_char(pbeltd.effectivedate,'YYYYMMDD')
      when pbeltd.benefitsubclass in ('31') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as ltd_cov_term_date
,null as ltd_cov_term_rsn_code
,null as ltd_cov_term_desc    
,null as ltd_covered_salary
,case when pbeltd.benefitsubclass in ('31') then '60' else null end ::char(2) as ltd_coverage_plan_option
,null as ltd_req_cvg_plan_option
/*
"Based on Pay Unit:
1 - for AJG00 - 01
2 - for AJG05-06
3 - for AJG20
4 - for AJG15-16"
*/
,case when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('00','01') then '1'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('05','06') then '2'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ( '20' )    then '3'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('15','16') then '4' else null end ::char(1) as ltd_ee_group_id
,case when pbeltd.benefitsubclass in ('31') and pc.frequencycode = 'A' then '1'
      when pbeltd.benefitsubclass in ('31') and pc.frequencycode = 'H' then '2'else null end ::char(1) as ltd_employee_class_code
------------------------------------
----- Critical Illness Section ----- 
----- Section Code ~VCI~       -----
------------------------------------
,'~VCI~'::char(5) as section_code_vci
,case when pbeci.benefitsubclass = '1W' then to_char(pbeci.effectivedate,'YYYYMMDD') else null end ::char(8) as vci_cov_effdate
,case when pbeci.benefitsubclass = '1W' and pbeci.benefitelection = 'T' then to_char(pbeci.effectivedate,'YYYYMMDD')
      when pbeci.benefitsubclass = '1W' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as vci_cov_term_date
,null as vci_cov_term_rsn_code
,null as vci_cov_term_desc
,case when pbeci.benefitsubclass = '1W' and pbeci.benefitplanid in ('120', '126', '114') Then '10000'
      when pbeci.benefitsubclass = '1W' and pbeci.benefitplanid in ('129', '123', '132') Then '20000'
      else null End ::char(10) as vci_bene_amt
,case when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Family' then '2'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vci_coverage_tier  
,case when pbeci.benefitsubclass = '1W' then '1' else null end ::char(1) as vci_plan_number
,case when pbeci.benefitsubclass = '1W' and lc.locationid in ('1') then '7'  --- corporate
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('2') then '9'  --- elgin
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('3') then '11' --- germantown tooling
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('4') then '12' --- lake forrest
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('6') then '10' --- portland
      else null end ::char(5) as vci_employee_group_id
,case when pbeci.benefitsubclass = '1W' then '1' else null end ::char(1) as vci_employee_class
------------------------------
----- Accident Section   ----- 
----- Section Code ~VAC~ -----
------------------------------
,'~VAC~' ::char(5) as section_code_vac
,case when pbeac.benefitsubclass = '13' then to_char(pbeac.effectivedate,'YYYYMMDD') else null end ::char(8) as vac_cov_effdate
,case when pbeac.benefitsubclass = '13' and pbeac.benefitelection = 'T' then to_char(pbeac.effectivedate,'YYYYMMDD')
      when pbeac.benefitsubclass = '13' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as vac_cov_term_date
,null as vac_cov_term_rsn_code
,null as vac_cov_term_desc
,case when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Family' then '2'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vac_coverage_tier  
,case when pbeac.benefitsubclass = '13' and pbeac.benefitplanid = '135' then 'Plan 1'
      when pbeac.benefitsubclass = '13' and pbeac.benefitplanid = '138' then 'Plan 2'
      else null end ::char(6) as vac_plan_option
,case when pbeac.benefitsubclass = '13' then '1' else null end ::char(1) as vac_plan_number
,case when pbeac.benefitsubclass = '13' and lc.locationid in ('1') then '13' --- corporate
      when pbeac.benefitsubclass = '13' and lc.locationid in ('2') then '15' --- elgin
      when pbeac.benefitsubclass = '13' and lc.locationid in ('3') then '17' --- germantown tooling
      when pbeac.benefitsubclass = '13' and lc.locationid in ('4') then '18' --- lake forrest
      when pbeac.benefitsubclass = '13' and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as vac_employee_group_id
,case when pbeac.benefitsubclass = '13' then '1' else null end ::char(1) as vac_employee_class
--------------------------------------
----- Hospital Indemnity Section ----- 
----- Section Code ~HIP~         -----
--------------------------------------
,'~HIP~' ::char(5) as section_code_hip
,case when pbehi.benefitsubclass = '1Hosp' then to_char(pbehi.effectivedate,'YYYYMMDD') else null end ::char(8) as hip_cov_effdate
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitelection = 'T' then to_char(pbehi.effectivedate,'YYYYMMDD')
      when pbehi.benefitsubclass = '1Hosp' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as hip_cov_term_date
,null as hip_cov_term_rsn_code
,null as hip_cov_term_desc
,case when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee Only' then '1'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Family' then '2'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS hip_coverage_tier  
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '279' then '1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '282' then '2'
      else null end ::char(6) as hip_plan_option
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '279' then '1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '282' then '2' else null end ::char(1) as hip_plan_number
,case when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('1') then '13' --- corporate
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('2') then '15' --- elgin
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('3') then '17' --- germantown tooling
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('4') then '18' --- lake forrest
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as hip_employee_group_id
,null as hip_employee_class

from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts

join person_names pn
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

left join person_maritalstatus pms
  on pms.personid = pe.personid
 and current_date between pms.effectivedate and pms.enddate
 and current_timestamp between pms.createts and pms.endts  

left join person_phone_contacts ppch 
  on ppch.personid = pe.personid
 and ppch.phonecontacttype = 'Home'  
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 
left join person_phone_contacts ppcw 
  on ppcw.personid = pe.personid
 and ppcw.phonecontacttype = 'Work'     
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 

left join person_phone_contacts ppcm 
  on ppcm.personid = pe.personid
 and ppcm.phonecontacttype = 'Mobile'     
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 

left join person_net_contacts pncw 
  on pncw.personid = pe.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts 
 
left join person_net_contacts pnch 
  on pnch.personid = pe.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts 

LEFT JOIN person_locations pl
  ON pl.personid = pe.personid 
 AND pl.personlocationtype = 'P'::bpchar 
 AND current_date between pl.effectivedate AND pl.enddate
 AND current_timestamp between pl.createts AND pl.endts  
     
LEFT JOIN company_location_rel clr
  ON clr.locationid = pl.locationid 
 AND current_timestamp between clr.createts AND clr.endts

LEFT JOIN state_province st
  ON st.stateprovincecode = pa.stateprovincecode
 AND pa.countrycode = st.countrycode 
 
JOIN person_bene_election pbe 
  on pbe.personid = pe.personid 
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ( '1W','13','30','3Y','31','1Hosp')
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T','E')
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ( '1W','13','30','3Y','31','1Hosp') and benefitelection = 'E' and selectedoption = 'Y')  
--------------------- 
----- 10KCritNT -----
---------------------
left JOIN person_bene_election pbeci
  on pbeci.personid = pbe.personid 
 AND current_date between pbeci.effectivedate and pbeci.enddate
 AND current_timestamp between pbeci.createts and pbeci.endts
 AND pbeci.benefitsubclass IN ('1W')
 AND pbeci.selectedoption = 'Y'
 and pbeci.benefitelection <> 'W'
--------------------  
----- accident -----
--------------------
left JOIN person_bene_election pbeac
  on pbeac.personid = pbe.personid 
 AND current_date between pbeac.effectivedate and pbeac.enddate
 AND current_timestamp between pbeac.createts and pbeac.endts
 AND pbeac.benefitsubclass IN ('13')
 AND pbeac.selectedoption = 'Y' 
 and pbeac.benefitelection <> 'W'
---------------------------------  
----- Short Term Disability -----
---------------------------------
left JOIN person_bene_election pbestd
  on pbestd.personid = pbe.personid 
 AND current_date between pbestd.effectivedate and pbestd.enddate
 AND current_timestamp between pbestd.createts and pbestd.endts
 AND pbestd.benefitsubclass IN ('30','3Y')
 AND pbestd.selectedoption = 'Y' 
 and pbestd.benefitelection <> 'W' 
--------------------------------
----- Long Term Disability -----
-------------------------------- 
left JOIN person_bene_election pbeltd
  on pbeltd.personid = pbe.personid 
 AND current_date between pbeltd.effectivedate and pbeltd.enddate
 AND current_timestamp between pbeltd.createts and pbeltd.endts
 AND pbeltd.benefitsubclass IN ('31')
 AND pbeltd.selectedoption = 'Y' 
 and pbeltd.benefitelection <> 'W' 
------------------------------
----- Hospital Indemnity -----
------------------------------
left JOIN person_bene_election pbehi
  on pbehi.personid = pbe.personid 
 AND current_date between pbehi.effectivedate and pbehi.enddate
 AND current_timestamp between pbehi.createts and pbehi.endts
 AND pbehi.benefitsubclass IN ('1Hosp')
 AND pbehi.selectedoption = 'Y' 
 and pbehi.benefitelection <> 'W' 
 
left JOIN benefit_coverage_desc bcdac
  ON bcdac.benefitcoverageid = pbeac.benefitcoverageid 
 AND current_date between bcdac.effectivedate and bcdac.enddate 
 AND current_timestamp between bcdac.createts AND bcdac.endts
 
left JOIN benefit_coverage_desc bcdci
  ON bcdci.benefitcoverageid = pbeci.benefitcoverageid 
 AND current_date between bcdci.effectivedate and bcdci.enddate 
 AND current_timestamp between bcdci.createts AND bcdci.endts 

left JOIN benefit_coverage_desc bcdhi
  ON bcdhi.benefitcoverageid = pbehi.benefitcoverageid 
 AND current_date between bcdhi.effectivedate and bcdhi.enddate 
 AND current_timestamp between bcdhi.createts AND bcdhi.endts  
 
left join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 
  
left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

left join person_compensation pc
  on pc.personid = pe.personid
 and current_timestamp between pc.createts and pc.endts 
 and current_date between pc.effectivedate and pc.enddate

JOIN person_payroll ppr
  ON ppr.personid = pe.personid 
 AND current_date between ppr.effectivedate and ppr.enddate
 AND current_timestamp between ppr.createts AND ppr.endts

left join location_codes lc 
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts
 
 --select * from pay_unit
LEFT JOIN pay_unit pu
  ON pu.payunitid = ppr.payunitid
LEFT JOIN frequency_codes fc1
  ON fc1.frequencycode = pu.frequencycode
 
 
where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts 
  and pe.emplstatus = 'A'


union

select distinct
 pi.personid
,'72 Active EE DEP' ::varchar(30) as sourceseq
--------------------------------------------------------------
----- Employee or Dependent Personal Information Section -----  
--------------------------------------------------------------
,'~PII~' ::char(5) as section_code_pii
,' ' ::char(10) as customer_nbr
,'D' ::char(1) as trans_code 
,pi.identity ::char(9) as SSN
,pie.identity ::varchar(15) as empno
,pid.identity ::char(9) as mbrssn

,case when pdr.dependentrelationship in ('SP','DP','NA') then 'SP' else 'CH' end ::char(2) AS rel_code

,upper(pnd.lname) ::varchar(30) as lname
,upper(pnd.fname) ::varchar(30) as fname
,upper(pnd.mname) ::char(1) as mname
,' ' ::char(1) as name_prefix
,' ' ::char(1) as name_suffix
,to_char(pvd.birthdate,'YYYYMMDD')::char(8) as dob
,null ::char(1) as marital_status
,pvd.gendercode ::char(1) as gender
,pvd.smoker ::char(1) AS smoker
--------------------------------------------------
----- Employment Contact Information Section -----
--------------------------------------------------
,'~ECI~' ::char(5) as section_code_eci
,pad.streetaddress ::varchar(40) as addr1
,pad.streetaddress2 ::varchar(40) as addr2
,pad.city ::varchar(30) as city
,pad.stateprovincecode ::char(2) as state
,pad.postalcode ::char(10) as zip
,'840' ::char(3) as country_code
,null as mbr_mail
,null as mbr_mail2
,ppcH.phoneno ::varchar(15) as homephone
,ppcM.phoneno ::varchar(15) as cellphone
,pnch.url ::varchar(50) AS homeemail
,pncw.url ::varchar(50) AS workemail
,CASE WHEN clr.companylocationtype = 'WH' ::bpchar THEN st.stateprovincecode  
      ELSE pa.stateprovincecode END  ::char(2) AS workstatecode  
,null as work_addr
,null as work_addr2
,null as work_city
,null as work_state
,null as work_zip
,null as work_country
,ppcW.phoneno ::varchar(15) as workphone
------------------------------------------
----- Employment Information Section -----
------------------------------------------
,'~EMI~' ::char(5) as section_code_emi
,pe.emplstatus ::char(1) as employee_status
,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as doh
,null as emp_service
,to_char(pe.empllasthiredate,'YYYYMMDD')::char(8) as dor
,to_char(pe.emplsenoritydate,'YYYYMMDD')::char(8) as ohd
,null as emp_term_rsn
,null as emp_term_desc
,to_char(pe.paythroughdate,'YYYYMMDD')::char(8) as ldw
,case when pe.emplclass = 'F' then 'F ' else 'P ' end ::char(2) as emp_type
,case when pd.flsacode = 'E' then 'E ' else 'N ' END ::CHAR(1) as exempt_type
,cast(round(pp.scheduledhours, 2)*100 as bigint)/2 sched_hrs_per_week
,lpad(coalesce(CASE when pc.frequencycode = 'A'::bpchar THEN cast(round(pc.compamount, 2)*100 as bigint)
                    when pc.frequencycode = 'H'::bpchar THEN cast(round(pc.compamount * pp.scheduledhours * fc1.annualfactor, 2)*100 as bigint)
                    ELSE 0::numeric END,0)::text,9,'0') AS annualsalary
,'A' ::char(1) as salarybasis 
,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as salaryeffdate
,null as commision_amount
,null as bonus
,upper(pd.positiontitle)  ::char(25) as jobtitle     
,null as job_code
,pu.payunitdesc ::char(5) as payoll_code   
,null as company_code
,null as dept_code
,null as div_code
,lc.locationcode ::varchar(30) as loc_code
,null as reg_code
,null as acct_code
,'N' ::char(1) as union_ind
,null as union_name
-----------------------------------------
----- Short Term Disability Section -----
----- NON-STATUTORY                 -----
----- Section Code ~NST~            -----
-----------------------------------------
,'~NST~'::char(5) as section_code_nst
,case when pbestd.benefitsubclass in ('30','3Y') then to_char(pbestd.effectivedate,'YYYYMMDD') else null end ::char(8) as nst_cov_effdate
,case when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitelection = 'T' then to_char(pbestd.effectivedate,'YYYYMMDD')
      when pbestd.benefitsubclass in ('30','3Y') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as nst_cov_term_date
,' ' ::char(1) as nst_std_covered_salary
/*
"60 - for Salaried
Core - for Hourly
Buyup - for Hourly w Buy up plan"
*/  
,case when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'H' then 'Core'
      when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'A' then '60'
      when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'H' and pbestd.benefitplanid = '285' then 'Buyup'
      else null end ::varchar(10) as nst_std_cvg_plan_option
,' ' ::char(1) as nst_std_req_cvg_plan_option
/*
"Based on Pay Unit:
1 - for AJG00 - 01
2 - for AJG05-06
3 - for AJG20
4 - for AJG15-16"
*/
,case when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('00','01') then '1'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('05','06') then '2'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ( '20' )    then '3'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('15','16') then '4' else null end ::char(1) as nst_ee_group_id
,' '::char(1) as nst_ee_class_code 
----------------------------------------
----- Long Term Disability Section -----
----- Section Code ~LTD~           -----
----------------------------------------
,'~LTD~'::char(5) as section_code_ltd
,case when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') else null end ::char(8) as ltd_cov_effdate
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T' then to_char(pbeltd.effectivedate,'YYYYMMDD')
      when pbeltd.benefitsubclass in ('31') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as ltd_cov_term_date
,null as ltd_cov_term_rsn_code
,null as ltd_cov_term_desc    
,null as ltd_covered_salary
,case when pbeltd.benefitsubclass in ('31') then '60' else null end ::char(2) as ltd_coverage_plan_option
,null as ltd_req_cvg_plan_option
/*
"Based on Pay Unit:
1 - for AJG00 - 01
2 - for AJG05-06
3 - for AJG20
4 - for AJG15-16"
*/
,case when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('00','01') then '1'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('05','06') then '2'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ( '20' )    then '3'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('15','16') then '4' else null end ::char(1) as ltd_ee_group_id
,case when pbeltd.benefitsubclass in ('31') and pc.frequencycode = 'A' then '1'
      when pbeltd.benefitsubclass in ('31') and pc.frequencycode = 'H' then '2'else null end ::char(1) as ltd_employee_class_code
------------------------------------
----- Critical Illness Section ----- 
----- Section Code ~VCI~       -----
------------------------------------
,'~VCI~'::char(5) as section_code_vci
,case when pbeci.benefitsubclass = '1W' then to_char(pbeci.effectivedate,'YYYYMMDD') else null end ::char(8) as vci_cov_effdate
,case when pbeci.benefitsubclass = '1W' and pbeci.benefitelection = 'T' then to_char(pbeci.effectivedate,'YYYYMMDD')
      when pbeci.benefitsubclass = '1W' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as vci_cov_term_date
,null as vci_cov_term_rsn_code
,null as vci_cov_term_desc
,case when pbeci.benefitsubclass = '1W' and pbeci.benefitplanid in ('120', '126', '114') Then '10000'
      when pbeci.benefitsubclass = '1W' and pbeci.benefitplanid in ('129', '123', '132') Then '20000'
      else null End ::char(10) as vci_bene_amt
,case when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Family' then '2'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vci_coverage_tier  
,case when pbeci.benefitsubclass = '1W' then '1' else null end ::char(1) as vci_plan_number
,case when pbeci.benefitsubclass = '1W' and lc.locationid in ('1') then '7'  --- corporate
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('2') then '9'  --- elgin
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('3') then '11' --- germantown tooling
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('4') then '12' --- lake forrest
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('6') then '10' --- portland
      else null end ::char(5) as vci_employee_group_id
,case when pbeci.benefitsubclass = '1W' then '1' else null end ::char(1) as vci_employee_class
------------------------------
----- Accident Section   ----- 
----- Section Code ~VAC~ -----
------------------------------
,'~VAC~' ::char(5) as section_code_vac
,case when pbeac.benefitsubclass = '13' then to_char(pbeac.effectivedate,'YYYYMMDD') else null end ::char(8) as vac_cov_effdate
,case when pbeac.benefitsubclass = '13' and pbeac.benefitelection = 'T' then to_char(pbeac.effectivedate,'YYYYMMDD')
      when pbeac.benefitsubclass = '13' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as vac_cov_term_date
,null as vac_cov_term_rsn_code
,null as vac_cov_term_desc
,case when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Family' then '2'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vac_coverage_tier  
,case when pbeac.benefitsubclass = '13' and pbeac.benefitplanid = '135' then 'Plan 1'
      when pbeac.benefitsubclass = '13' and pbeac.benefitplanid = '138' then 'Plan 2'
      else null end ::char(6) as vac_plan_option
,case when pbeac.benefitsubclass = '13' then '1' else null end ::char(1) as vac_plan_number
,case when pbeac.benefitsubclass = '13' and lc.locationid in ('1') then '13' --- corporate
      when pbeac.benefitsubclass = '13' and lc.locationid in ('2') then '15' --- elgin
      when pbeac.benefitsubclass = '13' and lc.locationid in ('3') then '17' --- germantown tooling
      when pbeac.benefitsubclass = '13' and lc.locationid in ('4') then '18' --- lake forrest
      when pbeac.benefitsubclass = '13' and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as vac_employee_group_id
,case when pbeac.benefitsubclass = '13' then '1' else null end ::char(1) as vac_employee_class
--------------------------------------
----- Hospital Indemnity Section ----- 
----- Section Code ~HIP~         -----
--------------------------------------
,'~HIP~' ::char(5) as section_code_hip
,case when pbehi.benefitsubclass = '1Hosp' then to_char(pbehi.effectivedate,'YYYYMMDD') else null end ::char(8) as hip_cov_effdate
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitelection = 'T' then to_char(pbehi.effectivedate,'YYYYMMDD')
      when pbehi.benefitsubclass = '1Hosp' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as hip_cov_term_date
,null as hip_cov_term_rsn_code
,null as hip_cov_term_desc
,case when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee Only' then '1'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Family' then '2'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS hip_coverage_tier  
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '279' then '1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '282' then '2'
      else null end ::char(6) as hip_plan_option
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '279' then '1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '282' then '2' else null end ::char(1) as hip_plan_number
,case when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('1') then '13' --- corporate
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('2') then '15' --- elgin
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('3') then '17' --- germantown tooling
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('4') then '18' --- lake forrest
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as hip_employee_group_id
,null as hip_employee_class

from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts

join person_names pn
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

left join person_maritalstatus pms
  on pms.personid = pe.personid
 and current_date between pms.effectivedate and pms.enddate
 and current_timestamp between pms.createts and pms.endts  

left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_phone_contacts where phonecontacttype = 'Home'and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, phoneno) ppch on ppch.personid = pe.personid and ppch.rank = 1
 
left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_phone_contacts where phonecontacttype = 'Work' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, phoneno) ppcw on ppcw.personid = pe.personid and ppcw.rank = 1

left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_phone_contacts where phonecontacttype = 'Mobile' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, phoneno) ppcm on ppcm.personid = pe.personid and ppcm.rank = 1

left join person_net_contacts pncw 
  on pncw.personid = pe.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts 
 
left join person_net_contacts pnch 
  on pnch.personid = pe.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts 

LEFT JOIN person_locations pl
  ON pl.personid = pe.personid 
 AND pl.personlocationtype = 'P'::bpchar 
 AND current_date between pl.effectivedate AND pl.enddate
 AND current_timestamp between pl.createts AND pl.endts  

left join location_codes lc 
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts
      
LEFT JOIN company_location_rel clr
  ON clr.locationid = pl.locationid 
 AND current_timestamp between clr.createts AND clr.endts

LEFT JOIN state_province st
  ON st.stateprovincecode = pa.stateprovincecode
 AND pa.countrycode = st.countrycode 
 
JOIN person_bene_election pbe 
  on pbe.personid = pe.personid 
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ( '1W','13','30','3Y','31','1Hosp')
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T','E')
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ( '1W','13','30','3Y','31','1Hosp') and benefitelection = 'E' and selectedoption = 'Y')  
--------------------- 
----- 10KCritNT -----
---------------------          
left JOIN person_bene_election pbeci
  on pbeci.personid = pbe.personid 
 AND current_date between pbeci.effectivedate and pbeci.enddate
 AND current_timestamp between pbeci.createts and pbeci.endts
 AND pbeci.benefitsubclass IN ('1W')
 AND pbeci.selectedoption = 'Y'
 and pbeci.benefitelection <> 'W'
 and pbeci.benefitcoverageid > '1'
--------------------  
----- accident -----
--------------------
left JOIN person_bene_election pbeac
  on pbeac.personid = pbe.personid 
 AND current_date between pbeac.effectivedate and pbeac.enddate
 AND current_timestamp between pbeac.createts and pbeac.endts
 AND pbeac.benefitsubclass IN ('13')
 AND pbeac.selectedoption = 'Y' 
 and pbeac.benefitelection <> 'W'
 and pbeac.benefitcoverageid > '1'
---------------------------------  
----- Short Term Disability -----
---------------------------------
left JOIN person_bene_election pbestd
  on pbestd.personid = pbe.personid 
 AND current_date between pbestd.effectivedate and pbestd.enddate
 AND current_timestamp between pbestd.createts and pbestd.endts
 AND pbestd.benefitsubclass IN ('30','3Y')
 AND pbestd.selectedoption = 'Y' 
 and pbestd.benefitelection <> 'W'  
 and pbestd.benefitcoverageid > '1'
--------------------------------
----- Long Term Disability -----
-------------------------------- 
left JOIN person_bene_election pbeltd
  on pbeltd.personid = pbe.personid 
 AND current_date between pbeltd.effectivedate and pbeltd.enddate
 AND current_timestamp between pbeltd.createts and pbeltd.endts
 AND pbeltd.benefitsubclass IN ('31')
 AND pbeltd.selectedoption = 'Y' 
 and pbeltd.benefitelection <> 'W'  
 and pbeltd.benefitcoverageid > '1'
------------------------------
----- Hospital Indemnity -----
------------------------------
left JOIN person_bene_election pbehi
  on pbehi.personid = pbe.personid 
 AND current_date between pbehi.effectivedate and pbehi.enddate
 AND current_timestamp between pbehi.createts and pbehi.endts
 AND pbehi.benefitsubclass IN ('1Hosp')
 AND pbehi.selectedoption = 'Y' 
 and pbehi.benefitelection <> 'W'  
 and pbehi.benefitcoverageid > '1'
 
left JOIN benefit_coverage_desc bcdac
  ON bcdac.benefitcoverageid = pbeac.benefitcoverageid 
 AND current_date between bcdac.effectivedate and bcdac.enddate 
 AND current_timestamp between bcdac.createts AND bcdac.endts
 
left JOIN benefit_coverage_desc bcdci
  ON bcdci.benefitcoverageid = pbeci.benefitcoverageid 
 AND current_date between bcdci.effectivedate and bcdci.enddate 
 AND current_timestamp between bcdci.createts AND bcdci.endts 

left JOIN benefit_coverage_desc bcdhi
  ON bcdhi.benefitcoverageid = pbehi.benefitcoverageid 
 AND current_date between bcdhi.effectivedate and bcdhi.enddate 
 AND current_timestamp between bcdhi.createts AND bcdhi.endts   
 
left join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 
  
left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

left join person_compensation pc
  on pc.personid = pe.personid
 and current_timestamp between pc.createts and pc.endts 
 and current_date between pc.effectivedate and pc.enddate

JOIN person_payroll ppr
  ON ppr.personid = pe.personid 
 AND current_date between ppr.effectivedate and ppr.enddate
 AND current_timestamp between ppr.createts AND ppr.endts
 
 --select * from pay_unit
LEFT JOIN pay_unit pu
  ON pu.payunitid = ppr.payunitid
LEFT JOIN frequency_codes fc1
  ON fc1.frequencycode = pu.frequencycode
 

----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
 
 -- select * from dependent_enrollment where personid = '10108';
join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep'   
 
join person_vitals pvd
  on pvd.personid = pdr.dependentid
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts 

left join person_address pad
  on pad.personid = pdr.dependentid
 and pad.addresstype = 'Res'
 and current_date between pad.effectivedate and pad.enddate 
 and current_timestamp between pad.createts and pad.endts 
 
where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
  and pdr.dependentrelationship <> 'X'
  and ((pdr.dependentrelationship in ('S','D','C','NS','ND','NC') and pvd.birthdate > current_date - interval '26 years')
   or (pdr.dependentrelationship in ('SP','DP','NA')))  

union 

select distinct
 pi.personid
,'129 TERMED EE' ::varchar(30) as sourceseq
--------------------------------------------------------------
----- Employee or Dependent Personal Information Section -----  
--------------------------------------------------------------
,'~PII~' ::char(5) as section_code_pii
,' ' ::char(10) as customer_nbr
,'E' ::char(1) as trans_code 
,pi.identity ::char(9) as SSN
,pie.identity ::varchar(15) as empno
,' ' ::char(1) as mbrssn
,' ' ::char(1) as rel_code
,upper(pn.lname) ::varchar(30) as lname
,upper(pn.fname) ::varchar(30) as fname
,upper(pn.mname) ::char(1) as mname
,' ' ::char(1) as name_prefix
,' ' ::char(1) as name_suffix
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,pms.maritalstatus ::char(1) as marital_status
,pv.gendercode ::char(1) as gender
,pv.smoker ::char(1) AS smoker
--------------------------------------------------
----- Employment Contact Information Section -----
--------------------------------------------------
,'~ECI~' ::char(5) as section_code_eci
,pa.streetaddress ::varchar(40) as addr1
,pa.streetaddress2 ::varchar(40) as addr2
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(10) as zip
,'840' ::char(3) as country_code
,null as mbr_mail
,null as mbr_mail2
,ppcH.phoneno ::varchar(15) as homephone
,ppcM.phoneno ::varchar(15) as cellphone
,pnch.url ::varchar(50) AS homeemail
,pncw.url ::varchar(50) AS workemail
,CASE WHEN clr.companylocationtype = 'WH' ::bpchar THEN st.stateprovincecode  
      ELSE pa.stateprovincecode END  ::char(2) AS workstatecode  
,null as work_addr
,null as work_addr2
,null as work_city
,null as work_state
,null as work_zip
,null as work_country
,ppcW.phoneno ::varchar(15) as workphone
------------------------------------------
----- Employment Information Section -----
------------------------------------------
,'~EMI~' ::char(5) as section_code_emi
,pe.emplstatus ::char(1) as employee_status
,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as doh
,null as emp_service
,to_char(pe.empllasthiredate,'YYYYMMDD')::char(8) as dor
,to_char(pe.emplservicedate,'YYYYMMDD')::char(8) as ohd
,null as emp_term_rsn
,null as emp_term_desc
,to_char(pe.paythroughdate,'YYYYMMDD')::char(8) as ldw
,case when pe.emplclass = 'F' then 'F ' else 'P ' end ::char(2) as emp_type
,case when pd.flsacode = 'E' then 'E ' else 'N ' END ::CHAR(1) as exempt_type
,cast(round(pp.scheduledhours, 2)*100 as bigint)/2 sched_hrs_per_week
--,pc.compamount
,lpad(coalesce(CASE when pc.frequencycode = 'A'::bpchar THEN cast(round(pc.compamount, 2)*100 as bigint)
                    when pc.frequencycode = 'H'::bpchar THEN cast(round(pc.compamount * pp.scheduledhours * fc1.annualfactor, 2)*100 as bigint)
                    ELSE 0::numeric END,0)::text,9,'0') AS annualsalary
,'A' ::char(1) as salarybasis 
,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as salaryeffdate
,null as commision_amount
,null as bonus
,upper(pd.positiontitle)  ::char(25) as jobtitle     
,null as job_code
,pu.payunitdesc ::char(5) as payoll_code   
,null as company_code
,null as dept_code
,null as div_code
,lc.locationcode ::varchar(30) as loc_code
,null as reg_code
,null as acct_code
,'N' ::char(1) as union_ind
,null as union_name
-----------------------------------------
----- Short Term Disability Section -----
----- NON-STATUTORY                 -----
----- Section Code ~NST~            -----
-----------------------------------------
,'~NST~'::char(5) as section_code_nst
,case when pbestd.benefitsubclass in ('30','3Y') then to_char(pbestd.effectivedate,'YYYYMMDD') else null end ::char(8) as nst_cov_effdate
,case when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitelection = 'T' then to_char(pbestd.effectivedate,'YYYYMMDD')
      when pbestd.benefitsubclass in ('30','3Y') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as nst_cov_term_date
,' ' ::char(1) as nst_std_covered_salary
/*
"60 - for Salaried
Core - for Hourly
Buyup - for Hourly w Buy up plan"
*/  
,case when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'H' then 'Core'
      when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'A' then '60'
      when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'H' and pbestd.benefitplanid = '285' then 'Buyup'
      else null end ::varchar(10) as nst_std_cvg_plan_option
,' ' ::char(1) as nst_std_req_cvg_plan_option
/*
"Based on Pay Unit:
1 - for AJG00 - 01
2 - for AJG05-06
3 - for AJG20
4 - for AJG15-16"
*/
,case when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('00','01') then '1'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('05','06') then '2'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ( '20' )    then '3'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('15','16') then '4' else null end ::char(1) as nst_ee_group_id
,' '::char(1) as nst_ee_class_code 
----------------------------------------
----- Long Term Disability Section -----
----- Section Code ~LTD~           -----
----------------------------------------
,'~LTD~'::char(5) as section_code_ltd
,case when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') else null end ::char(8) as ltd_cov_effdate
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T' then to_char(pbeltd.effectivedate,'YYYYMMDD')
      when pbeltd.benefitsubclass in ('31') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as ltd_cov_term_date
,null as ltd_cov_term_rsn_code
,null as ltd_cov_term_desc    
,null as ltd_covered_salary
,case when pbeltd.benefitsubclass in ('31') then '60' else null end ::char(2) as ltd_coverage_plan_option
,null as ltd_req_cvg_plan_option
/*
"Based on Pay Unit:
1 - for AJG00 - 01
2 - for AJG05-06
3 - for AJG20
4 - for AJG15-16"
*/
,case when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('00','01') then '1'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('05','06') then '2'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ( '20' )    then '3'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('15','16') then '4' else null end ::char(1) as ltd_ee_group_id
,case when pbeltd.benefitsubclass in ('31') and pc.frequencycode = 'A' then '1'
      when pbeltd.benefitsubclass in ('31') and pc.frequencycode = 'H' then '2'else null end ::char(1) as ltd_employee_class_code
------------------------------------
----- Critical Illness Section ----- 
----- Section Code ~VCI~       -----
------------------------------------
,'~VCI~'::char(5) as section_code_vci
,case when pbeci.benefitsubclass = '1W' then to_char(pbeci.effectivedate,'YYYYMMDD') else null end ::char(8) as vci_cov_effdate
,case when pbeci.benefitsubclass = '1W' and pbeci.benefitelection = 'T' then to_char(pbeci.effectivedate,'YYYYMMDD')
      when pbeci.benefitsubclass = '1W' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as vci_cov_term_date
,null as vci_cov_term_rsn_code
,null as vci_cov_term_desc
,case when pbeci.benefitsubclass = '1W' and pbeci.benefitplanid in ('120', '126', '114') Then '10000'
      when pbeci.benefitsubclass = '1W' and pbeci.benefitplanid in ('129', '123', '132') Then '20000'
      else null End ::char(10) as vci_bene_amt
,case when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Family' then '2'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vci_coverage_tier  
,case when pbeci.benefitsubclass = '1W' then '1' else null end ::char(1) as vci_plan_number
,case when pbeci.benefitsubclass = '1W' and lc.locationid in ('1') then '7'  --- corporate
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('2') then '9'  --- elgin
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('3') then '11' --- germantown tooling
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('4') then '12' --- lake forrest
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('6') then '10' --- portland
      else null end ::char(5) as vci_employee_group_id
,case when pbeci.benefitsubclass = '1W' then '1' else null end ::char(1) as vci_employee_class
------------------------------
----- Accident Section   ----- 
----- Section Code ~VAC~ -----
------------------------------
,'~VAC~' ::char(5) as section_code_vac
,case when pbeac.benefitsubclass = '13' then to_char(pbeac.effectivedate,'YYYYMMDD') else null end ::char(8) as vac_cov_effdate
,case when pbeac.benefitsubclass = '13' and pbeac.benefitelection = 'T' then to_char(pbeac.effectivedate,'YYYYMMDD')
      when pbeac.benefitsubclass = '13' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as vac_cov_term_date
,null as vac_cov_term_rsn_code
,null as vac_cov_term_desc
,case when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Family' then '2'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vac_coverage_tier  
,case when pbeac.benefitsubclass = '13' and pbeac.benefitplanid = '135' then 'Plan 1'
      when pbeac.benefitsubclass = '13' and pbeac.benefitplanid = '138' then 'Plan 2'
      else null end ::char(6) as vac_plan_option
,case when pbeac.benefitsubclass = '13' then '1' else null end ::char(1) as vac_plan_number
,case when pbeac.benefitsubclass = '13' and lc.locationid in ('1') then '13' --- corporate
      when pbeac.benefitsubclass = '13' and lc.locationid in ('2') then '15' --- elgin
      when pbeac.benefitsubclass = '13' and lc.locationid in ('3') then '17' --- germantown tooling
      when pbeac.benefitsubclass = '13' and lc.locationid in ('4') then '18' --- lake forrest
      when pbeac.benefitsubclass = '13' and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as vac_employee_group_id
,case when pbeac.benefitsubclass = '13' then '1' else null end ::char(1) as vac_employee_class
--------------------------------------
----- Hospital Indemnity Section ----- 
----- Section Code ~HIP~         -----
--------------------------------------
,'~HIP~' ::char(5) as section_code_hip
,case when pbehi.benefitsubclass = '1Hosp' then to_char(pbehi.effectivedate,'YYYYMMDD') else null end ::char(8) as hip_cov_effdate
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitelection = 'T' then to_char(pbehi.effectivedate,'YYYYMMDD')
      when pbehi.benefitsubclass = '1Hosp' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as hip_cov_term_date
,null as hip_cov_term_rsn_code
,null as hip_cov_term_desc
,case when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee Only' then '1'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Family' then '2'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS hip_coverage_tier  
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '279' then '1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '282' then '2'
      else null end ::char(6) as hip_plan_option
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '279' then '1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '282' then '2' else null end ::char(1) as hip_plan_number
,case when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('1') then '13' --- corporate
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('2') then '15' --- elgin
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('3') then '17' --- germantown tooling
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('4') then '18' --- lake forrest
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as hip_employee_group_id
,null as hip_employee_class

from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts

join person_names pn
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

left join person_maritalstatus pms
  on pms.personid = pe.personid
 and current_date between pms.effectivedate and pms.enddate
 and current_timestamp between pms.createts and pms.endts  
 
left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Home' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppch on ppch.personid = pe.personid and ppch.rank = 1
 
left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Work' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppcw on ppcw.personid = pe.personid and ppcw.rank = 1

left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Mobile' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppcm on ppcm.personid = pe.personid and ppcm.rank = 1 

left join person_net_contacts pncw 
  on pncw.personid = pe.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts 
 
left join person_net_contacts pnch 
  on pnch.personid = pe.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts 

LEFT JOIN person_locations pl
  ON pl.personid = pe.personid 
 AND pl.personlocationtype = 'P'::bpchar 
 AND current_date between pl.effectivedate AND pl.enddate
 AND current_timestamp between pl.createts AND pl.endts  

left join location_codes lc 
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts 
     
LEFT JOIN company_location_rel clr
  ON clr.locationid = pl.locationid 
 AND current_timestamp between clr.createts AND clr.endts

LEFT JOIN state_province st
  ON st.stateprovincecode = pa.stateprovincecode
 AND pa.countrycode = st.countrycode 
 
JOIN person_bene_election pbe 
  on pbe.personid = pe.personid 
 --AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ('1W','13','30','3Y','31','1Hosp')
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 and pbe.effectivedate < pbe.enddate
 and pbe.effectivedate < pe.effectivedate
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and effectivedate < enddate
                         and benefitsubclass in ('1W','13','30','3Y','31','1Hosp') and benefitelection = 'E' and selectedoption = 'Y')   
--------------------- 
----- 10KCritNT -----
---------------------     
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '1W' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid) pbeci on pbeci.personid = pbe.personid and pbeci.rank = 1            
--------------------  
----- accident -----
--------------------
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass = '13' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid) pbeac on pbeac.personid = pbe.personid and pbeac.rank = 1 
---------------------------------  
----- Short Term Disability -----
--------------------------------- 
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass in ('30','3Y') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid) pbestd on pbestd.personid = pbe.personid and pbestd.rank = 1 
--------------------------------
----- Long Term Disability -----
--------------------------------
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass in ('31') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid) pbeltd on pbeltd.personid = pbe.personid and pbeltd.rank = 1 
------------------------------
----- Hospital Indemnity -----
------------------------------
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass in ('1Hosp') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid) pbehi on pbehi.personid = pbe.personid and pbehi.rank = 1


left JOIN benefit_coverage_desc bcdci
  ON bcdci.benefitcoverageid = pbeci.benefitcoverageid 
 AND current_date between bcdci.effectivedate and bcdci.enddate 
 AND current_timestamp between bcdci.createts AND bcdci.endts  

left JOIN benefit_coverage_desc bcdac
  ON bcdac.benefitcoverageid = pbeac.benefitcoverageid 
 AND current_date between bcdac.effectivedate and bcdac.enddate 
 AND current_timestamp between bcdac.createts AND bcdac.endts   

left JOIN benefit_coverage_desc bcdhi
  ON bcdhi.benefitcoverageid = pbehi.benefitcoverageid 
 AND current_date between bcdhi.effectivedate and bcdhi.enddate 
 AND current_timestamp between bcdhi.createts AND bcdhi.endts  
                       
left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts

left join (select personid, max(perspospid) as perspospid from pers_pos group by 1 ) as maxpp on maxpp.personid = pe.personid 

left join pers_pos pp 
  on pp.personid = pe.personid
 and pp.perspospid = maxpp.perspospid
 and current_timestamp between pp.createts and pp.endts 
  
left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

left join (select personid, max(percomppid) as percomppid from person_compensation group by 1 ) as maxpc on maxpc.personid = pe.personid 

left join person_compensation pc
  on pc.personid = pe.personid
 and pc.percomppid = maxpc.percomppid
 and current_timestamp between pc.createts and pc.endts
 
left JOIN person_payroll ppr
  ON ppr.personid = pe.personid 
 AND current_date between ppr.effectivedate and ppr.enddate
 AND current_timestamp between ppr.createts AND ppr.endts

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppr.payunitid
LEFT JOIN frequency_codes fc1
  ON fc1.frequencycode = pu.frequencycode
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus in ('R','T')
  and pe.effectivedate >= current_date - interval '1 year'

  
union


select distinct
 pi.personid
,'14 TERMED EE DEP' ::varchar(30) as sourceseq
--------------------------------------------------------------
----- Employee or Dependent Personal Information Section -----  
--------------------------------------------------------------
,'~PII~' ::char(5) as section_code_pii
,' ' ::char(10) as customer_nbr
,'D' ::char(1) as trans_code 
,pi.identity ::char(9) as SSN
,pie.identity ::varchar(15) as empno
,pid.identity ::char(9) as mbrssn

,case when pdr.dependentrelationship in ('SP','DP','NA') then 'SP' else 'CH' end ::char(2) AS rel_code

,upper(pnd.lname) ::varchar(30) as lname
,upper(pnd.fname) ::varchar(30) as fname
,upper(pnd.mname) ::char(1) as mname
,' ' ::char(1) as name_prefix
,' ' ::char(1) as name_suffix
,to_char(pvd.birthdate,'YYYYMMDD')::char(8) as dob
,null ::char(1) as marital_status
,pvd.gendercode ::char(1) as gender
,pvd.smoker ::char(1) AS smoker
--------------------------------------------------
----- Employment Contact Information Section -----
--------------------------------------------------
,'~ECI~' ::char(5) as section_code_eci
,pa.streetaddress ::varchar(40) as addr1
,pa.streetaddress2 ::varchar(40) as addr2
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(10) as zip
,'840' ::char(3) as country_code
,null as mbr_mail
,null as mbr_mail2
,ppcH.phoneno ::varchar(15) as homephone
,ppcM.phoneno ::varchar(15) as cellphone
,pnch.url ::varchar(50) AS homeemail
,pncw.url ::varchar(50) AS workemail
,CASE WHEN clr.companylocationtype = 'WH' ::bpchar THEN st.stateprovincecode  
      ELSE pa.stateprovincecode END  ::char(2) AS workstatecode  
,null as work_addr
,null as work_addr2
,null as work_city
,null as work_state
,null as work_zip
,null as work_country
,ppcW.phoneno ::varchar(15) as workphone
------------------------------------------
----- Employment Information Section -----
------------------------------------------
,'~EMI~' ::char(5) as section_code_emi
,pe.emplstatus ::char(1) as employee_status
,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as doh
,null as emp_service
,to_char(pe.empllasthiredate,'YYYYMMDD')::char(8) as dor
,to_char(pe.emplsenoritydate,'YYYYMMDD')::char(8) as ohd
,null as emp_term_rsn
,null as emp_term_desc
,to_char(pe.paythroughdate,'YYYYMMDD')::char(8) as ldw
,case when pe.emplclass = 'F' then 'F ' else 'P ' end ::char(2) as emp_type
,case when pd.flsacode = 'E' then 'E ' else 'N ' END ::CHAR(1) as exempt_type
,cast(round(pp.scheduledhours, 2)*100 as bigint)/2 sched_hrs_per_week
,lpad(coalesce(CASE when pc.frequencycode = 'A'::bpchar THEN cast(round(pc.compamount, 2)*100 as bigint)
                    when pc.frequencycode = 'H'::bpchar THEN cast(round(pc.compamount * pp.scheduledhours * fc1.annualfactor, 2)*100 as bigint)
                    ELSE 0::numeric END,0)::text,9,'0') AS annualsalary
,'A' ::char(1) as salarybasis 
,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as salaryeffdate
,null as commision_amount
,null as bonus
,upper(pd.positiontitle)  ::char(25) as jobtitle     
,null as job_code
,pu.payunitdesc ::char(5) as payoll_code   
,null as company_code
,null as dept_code
,null as div_code
,lc.locationcode ::varchar(30) as loc_code
,null as reg_code
,null as acct_code
,'N' ::char(1) as union_ind
,null as union_name
-----------------------------------------
----- Short Term Disability Section -----
----- NON-STATUTORY                 -----
----- Section Code ~NST~            -----
-----------------------------------------
,'~NST~'::char(5) as section_code_nst
,case when pbestd.benefitsubclass in ('30','3Y') then to_char(pbestd.effectivedate,'YYYYMMDD') else null end ::char(8) as nst_cov_effdate
,case when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitelection = 'T' then to_char(pbestd.effectivedate,'YYYYMMDD')
      when pbestd.benefitsubclass in ('30','3Y') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as nst_cov_term_date
,' ' ::char(1) as nst_std_covered_salary
/*
"60 - for Salaried
Core - for Hourly
Buyup - for Hourly w Buy up plan"
*/  
,case when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'H' then 'Core'
      when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'A' then '60'
      when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'H' and pbestd.benefitplanid = '285' then 'Buyup'
      else null end ::varchar(10) as nst_std_cvg_plan_option
,' ' ::char(1) as nst_std_req_cvg_plan_option
/*
"Based on Pay Unit:
1 - for AJG00 - 01
2 - for AJG05-06
3 - for AJG20
4 - for AJG15-16"
*/
,case when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('00','01') then '1'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('05','06') then '2'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ( '20' )    then '3'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('15','16') then '4' else null end ::char(1) as nst_ee_group_id
,' '::char(1) as nst_ee_class_code 
----------------------------------------
----- Long Term Disability Section -----
----- Section Code ~LTD~           -----
----------------------------------------
,'~LTD~'::char(5) as section_code_ltd
,case when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') else null end ::char(8) as ltd_cov_effdate
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T' then to_char(pbeltd.effectivedate,'YYYYMMDD')
      when pbeltd.benefitsubclass in ('31') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as ltd_cov_term_date
,null as ltd_cov_term_rsn_code
,null as ltd_cov_term_desc    
,null as ltd_covered_salary
,case when pbeltd.benefitsubclass in ('31') then '60' else null end ::char(2) as ltd_coverage_plan_option
,null as ltd_req_cvg_plan_option
/*
"Based on Pay Unit:
1 - for AJG00 - 01
2 - for AJG05-06
3 - for AJG20
4 - for AJG15-16"
*/
,case when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('00','01') then '1'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('05','06') then '2'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ( '20' )    then '3'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('15','16') then '4' else null end ::char(1) as ltd_ee_group_id
,case when pbeltd.benefitsubclass in ('31') and pc.frequencycode = 'A' then '1'
      when pbeltd.benefitsubclass in ('31') and pc.frequencycode = 'H' then '2'else null end ::char(1) as ltd_employee_class_code
------------------------------------
----- Critical Illness Section ----- 
----- Section Code ~VCI~       -----
------------------------------------
,'~VCI~'::char(5) as section_code_vci
,case when pbeci.benefitsubclass = '1W' then to_char(pbeci.effectivedate,'YYYYMMDD') else null end ::char(8) as vci_cov_effdate
,case when pbeci.benefitsubclass = '1W' and pbeci.benefitelection = 'T' then to_char(pbeci.effectivedate,'YYYYMMDD')
      when pbeci.benefitsubclass = '1W' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as vci_cov_term_date
,null as vci_cov_term_rsn_code
,null as vci_cov_term_desc
,case when pbeci.benefitsubclass = '1W' and pbeci.benefitplanid in ('120', '126', '114') Then '10000'
      when pbeci.benefitsubclass = '1W' and pbeci.benefitplanid in ('129', '123', '132') Then '20000'
      else null End ::char(10) as vci_bene_amt
,case when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Family' then '2'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vci_coverage_tier  
,case when pbeci.benefitsubclass = '1W' then '1' else null end ::char(1) as vci_plan_number
,case when pbeci.benefitsubclass = '1W' and lc.locationid in ('1') then '7'  --- corporate
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('2') then '9'  --- elgin
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('3') then '11' --- germantown tooling
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('4') then '12' --- lake forrest
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('6') then '10' --- portland
      else null end ::char(5) as vci_employee_group_id
,case when pbeci.benefitsubclass = '1W' then '1' else null end ::char(1) as vci_employee_class
------------------------------
----- Accident Section   ----- 
----- Section Code ~VAC~ -----
------------------------------
,'~VAC~' ::char(5) as section_code_vac
,case when pbeac.benefitsubclass = '13' then to_char(pbeac.effectivedate,'YYYYMMDD') else null end ::char(8) as vac_cov_effdate
,case when pbeac.benefitsubclass = '13' and pbeac.benefitelection = 'T' then to_char(pbeac.effectivedate,'YYYYMMDD')
      when pbeac.benefitsubclass = '13' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as vac_cov_term_date
,null as vac_cov_term_rsn_code
,null as vac_cov_term_desc
,case when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Family' then '2'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vac_coverage_tier  
,case when pbeac.benefitsubclass = '13' and pbeac.benefitplanid = '135' then 'Plan 1'
      when pbeac.benefitsubclass = '13' and pbeac.benefitplanid = '138' then 'Plan 2'
      else null end ::char(6) as vac_plan_option
,case when pbeac.benefitsubclass = '13' then '1' else null end ::char(1) as vac_plan_number
,case when pbeac.benefitsubclass = '13' and lc.locationid in ('1') then '13' --- corporate
      when pbeac.benefitsubclass = '13' and lc.locationid in ('2') then '15' --- elgin
      when pbeac.benefitsubclass = '13' and lc.locationid in ('3') then '17' --- germantown tooling
      when pbeac.benefitsubclass = '13' and lc.locationid in ('4') then '18' --- lake forrest
      when pbeac.benefitsubclass = '13' and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as vac_employee_group_id
,case when pbeac.benefitsubclass = '13' then '1' else null end ::char(1) as vac_employee_class
--------------------------------------
----- Hospital Indemnity Section ----- 
----- Section Code ~HIP~         -----
--------------------------------------
,'~HIP~' ::char(5) as section_code_hip
,case when pbehi.benefitsubclass = '1Hosp' then to_char(pbehi.effectivedate,'YYYYMMDD') else null end ::char(8) as hip_cov_effdate
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitelection = 'T' then to_char(pbehi.effectivedate,'YYYYMMDD')
      when pbehi.benefitsubclass = '1Hosp' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as hip_cov_term_date
,null as hip_cov_term_rsn_code
,null as hip_cov_term_desc
,case when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee Only' then '1'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Family' then '2'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS hip_coverage_tier  
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '279' then '1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '282' then '2'
      else null end ::char(6) as hip_plan_option
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '279' then '1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '282' then '2' else null end ::char(1) as hip_plan_number
,case when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('1') then '13' --- corporate
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('2') then '15' --- elgin
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('3') then '17' --- germantown tooling
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('4') then '18' --- lake forrest
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as hip_employee_group_id
,null as hip_employee_class
      
from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts

join person_names pn
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

left join person_maritalstatus pms
  on pms.personid = pe.personid
 and current_date between pms.effectivedate and pms.enddate
 and current_timestamp between pms.createts and pms.endts  

left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Home' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppch on ppch.personid = pe.personid and ppch.rank = 1
 
left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Work' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppcw on ppcw.personid = pe.personid and ppcw.rank = 1

left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Mobile' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppcm on ppcm.personid = pe.personid and ppcm.rank = 1

left join person_net_contacts pncw 
  on pncw.personid = pe.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts 
 
left join person_net_contacts pnch 
  on pnch.personid = pe.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts 

LEFT JOIN person_locations pl
  ON pl.personid = pe.personid 
 AND pl.personlocationtype = 'P'::bpchar 
 AND current_date between pl.effectivedate AND pl.enddate
 AND current_timestamp between pl.createts AND pl.endts  

left join location_codes lc 
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts 
      
LEFT JOIN company_location_rel clr
  ON clr.locationid = pl.locationid 
 AND current_timestamp between clr.createts AND clr.endts

LEFT JOIN state_province st
  ON st.stateprovincecode = pa.stateprovincecode
 AND pa.countrycode = st.countrycode 
 
JOIN person_bene_election pbe 
  on pbe.personid = pe.personid 
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ('1W','13','30','3Y','31','1Hosp')
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 and pbe.effectivedate < pbe.enddate
 and pbe.effectivedate < pe.effectivedate
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and effectivedate < enddate
                         and benefitsubclass in ('1W','13','30','3Y','31','1Hosp') and benefitelection = 'E' and selectedoption = 'Y')  
--------------------- 
----- 10KCritNT -----
---------------------        
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass = '1W' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate 
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid) pbeci on pbeci.personid = pbe.personid and pbeci.rank = 1 
--------------------  
----- accident -----
--------------------
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass = '13' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid) pbeac on pbeac.personid = pbe.personid and pbeac.rank = 1 
---------------------------------  
----- Short Term Disability -----
--------------------------------- 
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass in ('30','3Y') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid) pbestd on pbestd.personid = pbe.personid and pbestd.rank = 1 
--------------------------------
----- Long Term Disability -----
--------------------------------
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass in ('31') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid) pbeltd on pbeltd.personid = pbe.personid and pbeltd.rank = 1 
------------------------------
----- Hospital Indemnity -----
------------------------------
left join (select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, max(effectivedate) as effectivedate, max(enddate) as enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            from person_bene_election where benefitsubclass in ('1Hosp') and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
           group by personid, benefitelection, benefitcoverageid,benefitsubclass,benefitplanid) pbehi on pbehi.personid = pbe.personid and pbehi.rank = 1 
           
left JOIN benefit_coverage_desc bcdci
  ON bcdci.benefitcoverageid = pbeci.benefitcoverageid 
 AND current_date between bcdci.effectivedate and bcdci.enddate 
 AND current_timestamp between bcdci.createts AND bcdci.endts   
 
left JOIN benefit_coverage_desc bcdac
  ON bcdac.benefitcoverageid = pbeac.benefitcoverageid 
 AND current_date between bcdac.effectivedate and bcdac.enddate 
 AND current_timestamp between bcdac.createts AND bcdac.endts

left JOIN benefit_coverage_desc bcdhi
  ON bcdhi.benefitcoverageid = pbehi.benefitcoverageid 
 AND current_date between bcdhi.effectivedate and bcdhi.enddate 
 AND current_timestamp between bcdhi.createts AND bcdhi.endts  
           
left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts

left join (select personid, max(perspospid) as perspospid from pers_pos group by 1 ) as maxpp on maxpp.personid = pe.personid 

left join pers_pos pp 
  on pp.personid = pe.personid
 and pp.perspospid = maxpp.perspospid
 and pp.effectivedate < pp.enddate
 and current_timestamp between pp.createts and pp.endts 
  
left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

left join (select personid, max(percomppid) as percomppid from person_compensation group by 1 ) as maxpc on maxpc.personid = pe.personid 

left join person_compensation pc
  on pc.personid = pe.personid
 and pc.percomppid = maxpc.percomppid
 and pc.effectivedate < pc.enddate
 and current_timestamp between pc.createts and pc.endts
 
left JOIN person_payroll ppr
  ON ppr.personid = pe.personid 
 AND current_date between ppr.effectivedate and ppr.enddate
 AND current_timestamp between ppr.createts AND ppr.endts
 
 --select * from pay_unit
LEFT JOIN pay_unit pu
  ON pu.payunitid = ppr.payunitid
LEFT JOIN frequency_codes fc1
  ON fc1.frequencycode = pu.frequencycode
 

----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and pdr.effectivedate < pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 and de.effectivedate < de.enddate
 and current_timestamp between de.createts and de.endts
 
join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep'   
 
join person_vitals pvd
  on pvd.personid = pdr.dependentid
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts 

left join person_address pad
  on pad.personid = pdr.personid
 and pad.addresstype = 'Res'
 and pad.effectivedate < pad.enddate 
 and current_timestamp between pad.createts and pad.endts 
 
where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts 
  and pe.emplstatus in ('R','T')
  and pe.effectivedate >= current_date - interval '1 year'
  and pdr.dependentrelationship <> 'X'
  and ((pdr.dependentrelationship in ('S','D','C','NS','ND','NC') and pvd.birthdate > current_date - interval '26 years')
   or (pdr.dependentrelationship in ('SP','DP','NA')))  

union 

select distinct
 pi.personid
,'1 Active EE Termed Dep' ::varchar(30) as sourceseq
--------------------------------------------------------------
----- Employee or Dependent Personal Information Section -----  
--------------------------------------------------------------
,'~PII~' ::char(5) as section_code_pii
,' ' ::char(10) as customer_nbr
,'D' ::char(1) as trans_code 
,pi.identity ::char(9) as SSN
,pie.identity ::varchar(15) as empno
,pid.identity ::char(9) as mbrssn
,case when pdr.dependentrelationship in ('SP','DP','NA','X') then 'SP' else 'CH' end ::char(2) AS rel_code
,upper(pnd.lname) ::varchar(30) as lname
,upper(pnd.fname) ::varchar(30) as fname
,upper(pnd.mname) ::char(1) as mname
,' ' ::char(1) as name_prefix
,' ' ::char(1) as name_suffix
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,null ::char(1) as marital_status
,pvd.gendercode ::char(1) as gender
,pvd.smoker ::char(1) AS smoker
--------------------------------------------------
----- Employment Contact Information Section -----
--------------------------------------------------
,'~ECI~' ::char(5) as section_code_eci
,pa.streetaddress ::varchar(40) as addr1
,pa.streetaddress2 ::varchar(40) as addr2
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(10) as zip
,'840' ::char(3) as country_code
,null as mbr_mail
,null as mbr_mail2
,ppcH.phoneno ::varchar(15) as homephone
,ppcM.phoneno ::varchar(15) as cellphone
,pnch.url ::varchar(50) AS homeemail
,pncw.url ::varchar(50) AS workemail
,CASE WHEN clr.companylocationtype = 'WH' ::bpchar THEN st.stateprovincecode  
      ELSE pa.stateprovincecode END  ::char(2) AS workstatecode  
,null as work_addr
,null as work_addr2
,null as work_city
,null as work_state
,null as work_zip
,null as work_country
,ppcW.phoneno ::varchar(15) as workphone
------------------------------------------
----- Employment Information Section -----
------------------------------------------
,'~EMI~' ::char(5) as section_code_emi
,pe.emplstatus ::char(1) as employee_status
,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as doh
,null as emp_service
,to_char(pe.empllasthiredate,'YYYYMMDD')::char(8) as dor
,to_char(pe.emplsenoritydate,'YYYYMMDD')::char(8) as ohd
,null as emp_term_rsn
,null as emp_term_desc
,to_char(pe.paythroughdate,'YYYYMMDD')::char(8) as ldw
,case when pe.emplclass = 'F' then 'F ' else 'P ' end ::char(2) as emp_type
,case when pd.flsacode = 'E' then 'E ' else 'N ' END ::CHAR(1) as exempt_type
,cast(round(pp.scheduledhours, 2)*100 as bigint)/2 sched_hrs_per_week
,lpad(coalesce(CASE when pc.frequencycode = 'A'::bpchar THEN cast(round(pc.compamount, 2)*100 as bigint)
                    when pc.frequencycode = 'H'::bpchar THEN cast(round(pc.compamount * pp.scheduledhours * fc1.annualfactor, 2)*100 as bigint)
                    ELSE 0::numeric END,0)::text,9,'0') AS annualsalary
,'A' ::char(1) as salarybasis 
,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as salaryeffdate
,null as commision_amount
,null as bonus
,upper(pd.positiontitle)  ::char(25) as jobtitle     
,null as job_code
,pu.payunitdesc ::char(5) as payoll_code   
,null as company_code
,null as dept_code
,null as div_code
,lc.locationcode ::varchar(30) as loc_code
,null as reg_code
,null as acct_code
,'N' ::char(1) as union_ind
,null as union_name
-----------------------------------------
----- Short Term Disability Section -----
----- NON-STATUTORY                 -----
----- Section Code ~NST~            -----
-----------------------------------------
,'~NST~'::char(5) as section_code_nst
,case when pbestd.benefitsubclass in ('30','3Y') then to_char(pbestd.effectivedate,'YYYYMMDD') else null end ::char(8) as nst_cov_effdate
,case when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitelection = 'T' then to_char(pbestd.effectivedate,'YYYYMMDD')
      when pbestd.benefitsubclass in ('30','3Y') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as nst_cov_term_date
,' ' ::char(1) as nst_std_covered_salary
/*
"60 - for Salaried
Core - for Hourly
Buyup - for Hourly w Buy up plan"
*/  
,case when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'H' then 'Core'
      when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'A' then '60'
      when pbestd.benefitsubclass in ('30','3Y') and pc.frequencycode = 'H' and pbestd.benefitplanid = '285' then 'Buyup'
      else null end ::varchar(10) as nst_std_cvg_plan_option
,' ' ::char(1) as nst_std_req_cvg_plan_option
/*
"Based on Pay Unit:
1 - for AJG00 - 01
2 - for AJG05-06
3 - for AJG20
4 - for AJG15-16"
*/
,case when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('00','01') then '1'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('05','06') then '2'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ( '20' )    then '3'
      when pbestd.benefitsubclass in ('30','3Y') and pu.payunitxid in ('15','16') then '4' else null end ::char(1) as nst_ee_group_id
,' '::char(1) as nst_ee_class_code 
----------------------------------------
----- Long Term Disability Section -----
----- Section Code ~LTD~           -----
----------------------------------------
,'~LTD~'::char(5) as section_code_ltd
,case when pbeltd.benefitsubclass in ('31') then to_char(pbeltd.effectivedate,'YYYYMMDD') else null end ::char(8) as ltd_cov_effdate
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitelection = 'T' then to_char(pbeltd.effectivedate,'YYYYMMDD')
      when pbeltd.benefitsubclass in ('31') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as ltd_cov_term_date
,null as ltd_cov_term_rsn_code
,null as ltd_cov_term_desc    
,null as ltd_covered_salary
,case when pbeltd.benefitsubclass in ('31') then '60' else null end ::char(2) as ltd_coverage_plan_option
,null as ltd_req_cvg_plan_option
/*
"Based on Pay Unit:
1 - for AJG00 - 01
2 - for AJG05-06
3 - for AJG20
4 - for AJG15-16"
*/
,case when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('00','01') then '1'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('05','06') then '2'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ( '20' )    then '3'
      when pbeltd.benefitsubclass in ('31') and pu.payunitxid in ('15','16') then '4' else null end ::char(1) as ltd_ee_group_id
,case when pbeltd.benefitsubclass in ('31') and pc.frequencycode = 'A' then '1'
      when pbeltd.benefitsubclass in ('31') and pc.frequencycode = 'H' then '2'else null end ::char(1) as ltd_employee_class_code
------------------------------------
----- Critical Illness Section ----- 
----- Section Code ~VCI~       -----
------------------------------------
,'~VCI~'::char(5) as section_code_vci
,case when pbeci.benefitsubclass = '1W' then to_char(de1w.effectivedate,'YYYYMMDD') else null end ::char(8) as vci_cov_effdate
,case when pbeci.benefitsubclass = '1W' then to_char(de1w.enddate,'YYYYMMDD') else null end ::char(8) as vci_cov_term_date
,null as vci_cov_term_rsn_code
,null as vci_cov_term_desc
,case when pbeci.benefitsubclass = '1W' and pbeci.benefitplanid in ('120', '126', '114') Then '10000'
      when pbeci.benefitsubclass = '1W' and pbeci.benefitplanid in ('129', '123', '132') Then '20000'
      else null End ::char(10) as vci_bene_amt
,case when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Family' then '2'
      when pbeci.benefitsubclass = '1W' and bcdci.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vci_coverage_tier  
,case when pbeci.benefitsubclass = '1W' then '1' else null end ::char(1) as vci_plan_number
,case when pbeci.benefitsubclass = '1W' and lc.locationid in ('1') then '7'  --- corporate
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('2') then '9'  --- elgin
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('3') then '11' --- germantown tooling
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('4') then '12' --- lake forrest
      when pbeci.benefitsubclass = '1W' and lc.locationid in ('6') then '10' --- portland
      else null end ::char(5) as vci_employee_group_id
,case when pbeci.benefitsubclass = '1W' then '1' else null end ::char(1) as vci_employee_class
------------------------------
----- Accident Section   ----- 
----- Section Code ~VAC~ -----
------------------------------
,'~VAC~' ::char(5) as section_code_vac
,case when pbeac.benefitsubclass = '13' then to_char(de13.effectivedate,'YYYYMMDD') else null end ::char(8) as vac_cov_effdate
,case when pbeac.benefitsubclass = '13' then to_char(de13.enddate,'YYYYMMDD') else null end ::char(8) as vac_cov_term_date
,null as vac_cov_term_rsn_code
,null as vac_cov_term_desc
,case when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Family' then '2'
      when pbeac.benefitsubclass = '13' and bcdac.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vac_coverage_tier  
,case when pbeac.benefitsubclass = '13' and pbeac.benefitplanid = '135' then 'Plan 1'
      when pbeac.benefitsubclass = '13' and pbeac.benefitplanid = '138' then 'Plan 2'
      else null end ::char(6) as vac_plan_option
,case when pbeac.benefitsubclass = '13' then '1' else null end ::char(1) as vac_plan_number
,case when pbeac.benefitsubclass = '13' and lc.locationid in ('1') then '13' --- corporate
      when pbeac.benefitsubclass = '13' and lc.locationid in ('2') then '15' --- elgin
      when pbeac.benefitsubclass = '13' and lc.locationid in ('3') then '17' --- germantown tooling
      when pbeac.benefitsubclass = '13' and lc.locationid in ('4') then '18' --- lake forrest
      when pbeac.benefitsubclass = '13' and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as vac_employee_group_id
,case when pbeac.benefitsubclass = '13' then '1' else null end ::char(1) as vac_employee_class
--------------------------------------
----- Hospital Indemnity Section ----- 
----- Section Code ~HIP~         -----
--------------------------------------
,'~HIP~' ::char(5) as section_code_hip
,case when pbehi.benefitsubclass = '1Hosp' then to_char(pbehi.effectivedate,'YYYYMMDD') else null end ::char(8) as hip_cov_effdate
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitelection = 'T' then to_char(pbehi.effectivedate,'YYYYMMDD')
      when pbehi.benefitsubclass = '1Hosp' and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as hip_cov_term_date
,null as hip_cov_term_rsn_code
,null as hip_cov_term_desc
,case when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee Only' then '1'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Family' then '2'
      when pbehi.benefitsubclass = '1Hosp' and bcdhi.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS hip_coverage_tier  
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '279' then '1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '282' then '2'
      else null end ::char(6) as hip_plan_option
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '279' then '1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitplanid = '282' then '2' else null end ::char(1) as hip_plan_number
,case when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('1') then '13' --- corporate
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('2') then '15' --- elgin
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('3') then '17' --- germantown tooling
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('4') then '18' --- lake forrest
      when pbehi.benefitsubclass = '1Hosp' and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as hip_employee_group_id
,null as hip_employee_class
 
from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts

join person_names pn
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

left join person_maritalstatus pms
  on pms.personid = pe.personid
 and current_date between pms.effectivedate and pms.enddate
 and current_timestamp between pms.createts and pms.endts  

left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_phone_contacts where phonecontacttype = 'Home'and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, phoneno) ppch on ppch.personid = pe.personid and ppch.rank = 1
 
left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_phone_contacts where phonecontacttype = 'Work' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, phoneno) ppcw on ppcw.personid = pe.personid and ppcw.rank = 1

left join ( select personid, phoneno, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_phone_contacts where phonecontacttype = 'Mobile' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, phoneno) ppcm on ppcm.personid = pe.personid and ppcm.rank = 1

left join person_net_contacts pncw 
  on pncw.personid = pe.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts 
 
left join person_net_contacts pnch 
  on pnch.personid = pe.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts 

LEFT JOIN person_locations pl
  ON pl.personid = pe.personid 
 AND pl.personlocationtype = 'P'::bpchar 
 AND current_date between pl.effectivedate AND pl.enddate
 AND current_timestamp between pl.createts AND pl.endts  
     
LEFT JOIN company_location_rel clr
  ON clr.locationid = pl.locationid 
 AND current_timestamp between clr.createts AND clr.endts

LEFT JOIN state_province st
  ON st.stateprovincecode = pa.stateprovincecode
 AND pa.countrycode = st.countrycode 
 
JOIN person_bene_election pbe 
  on pbe.personid = pe.personid 
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ('1W','13','30','3Y','31','1Hosp')
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T','E')
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('1W','13','30','3Y','31','1Hosp') and benefitelection = 'E' and selectedoption = 'Y')  
--------------------- 
----- 10KCritNT -----
---------------------              
left JOIN person_bene_election pbeci
  on pbeci.personid = pbe.personid 
 AND current_date between pbeci.effectivedate and pbeci.enddate
 AND current_timestamp between pbeci.createts and pbeci.endts
 AND pbeci.benefitsubclass IN ('1W')
 AND pbeci.selectedoption = 'Y'
 and pbeci.benefitelection <> 'W'
 and pbeci.benefitcoverageid > '1'
--------------------  
----- accident -----
--------------------
left JOIN person_bene_election pbeac
  on pbeac.personid = pbe.personid 
 AND current_date between pbeac.effectivedate and pbeac.enddate
 AND current_timestamp between pbeac.createts and pbeac.endts
 AND pbeac.benefitsubclass IN ('13')
 AND pbeac.selectedoption = 'Y' 
 and pbeac.benefitelection <> 'W'
 and pbeac.benefitcoverageid > '1'
---------------------------------  
----- Short Term Disability -----
---------------------------------
left JOIN person_bene_election pbestd
  on pbestd.personid = pbe.personid 
 AND current_date between pbestd.effectivedate and pbestd.enddate
 AND current_timestamp between pbestd.createts and pbestd.endts
 AND pbestd.benefitsubclass IN ('30','3Y')
 AND pbestd.selectedoption = 'Y' 
 and pbestd.benefitelection <> 'W'  
 and pbestd.benefitcoverageid > '1' 
--------------------------------
----- Long Term Disability -----
--------------------------------
left JOIN person_bene_election pbeltd
  on pbeltd.personid = pbe.personid 
 AND current_date between pbeltd.effectivedate and pbeltd.enddate
 AND current_timestamp between pbeltd.createts and pbeltd.endts
 AND pbeltd.benefitsubclass IN ('31')
 AND pbeltd.selectedoption = 'Y' 
 and pbeltd.benefitelection <> 'W'  
 and pbeltd.benefitcoverageid > '1' 
------------------------------
----- Hospital Indemnity -----
------------------------------
left JOIN person_bene_election pbehi
  on pbehi.personid = pbe.personid 
 AND current_date between pbehi.effectivedate and pbehi.enddate
 AND current_timestamp between pbehi.createts and pbehi.endts
 AND pbehi.benefitsubclass IN ('1Hosp')
 AND pbehi.selectedoption = 'Y' 
 and pbehi.benefitelection <> 'W'  
 and pbehi.benefitcoverageid > '1' 
 
left JOIN benefit_coverage_desc bcdac
  ON bcdac.benefitcoverageid = pbeac.benefitcoverageid 
 AND current_date between bcdac.effectivedate and bcdac.enddate 
 AND current_timestamp between bcdac.createts AND bcdac.endts
 
left JOIN benefit_coverage_desc bcdci
  ON bcdci.benefitcoverageid = pbeci.benefitcoverageid 
 AND current_date between bcdci.effectivedate and bcdci.enddate 
 AND current_timestamp between bcdci.createts AND bcdci.endts 
 
left JOIN benefit_coverage_desc bcdhi
  ON bcdhi.benefitcoverageid = pbehi.benefitcoverageid 
 AND current_date between bcdhi.effectivedate and bcdhi.enddate 
 AND current_timestamp between bcdhi.createts AND bcdhi.endts  
 
left join pers_pos pp 
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 
  
left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

left join person_compensation pc
  on pc.personid = pe.personid
 and current_timestamp between pc.createts and pc.endts 
 and current_date between pc.effectivedate and pc.enddate

JOIN person_payroll ppr
  ON ppr.personid = pe.personid 
 AND current_date between ppr.effectivedate and ppr.enddate
 AND current_timestamp between ppr.createts AND ppr.endts

left join location_codes lc 
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts
 
 --select * from pay_unit
LEFT JOIN pay_unit pu
  ON pu.payunitid = ppr.payunitid
LEFT JOIN frequency_codes fc1
  ON fc1.frequencycode = pu.frequencycode
 

----- dependent data

join person_dependent_relationship pdr
  on pdr.personid = pe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

join dependent_enrollment de
  on de.dependentid = pdr.dependentid
 and de.benefitsubclass = pbe.benefitsubclass
 and de.personid = pi.personid
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts
--- yes I'm hardcoding this on purpose this is the earliest day I need to go back to get termed dependents for Regina 
 and de.enddate >= '2017-01-01' 
 and de.dependentid in 
 ( select distinct de.dependentid as dependentid
    from dependent_enrollment de 
    join person_names pne
      on pne.personid = de.personid
     and pne.nametype = 'Legal'
     and current_date between pne.effectivedate and pne.enddate
     and current_timestamp between pne.createts and pne.endts
    join person_names pnd
      on pnd.personid = de.dependentid
     and pnd.nametype = 'Dep'
     and current_date between pnd.effectivedate and pnd.enddate
     and current_timestamp between pnd.createts and pnd.endts    
    join person_vitals pvd
      on pvd.personid = de.dependentid
     and current_date between pvd.effectivedate and pvd.enddate
     and current_timestamp between pvd.createts and pvd.endts 
    join person_dependent_relationship pdr
      on pdr.personid = de.personid
     and pdr.dependentid = de.dependentid
     and current_date between pdr.effectivedate and pdr.enddate
     and current_timestamp between pdr.createts and pdr.endts
    join person_employment pe
      on pe.personid = de.personid
     and current_date between pe.effectivedate and pe.enddate
     and current_timestamp between pe.createts and pe.endts
    join person_bene_election pbe
      on pbe.personid = de.personid
     and pbe.benefitsubclass in ('1W','13','1Hosp')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('1W','13','1Hosp')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid  
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
          ------------------------------------------------------------------------
          -- issue with new enrollee's not identitfied with prior year coverage --
          -- had to check if dependent is enrolled in next plan year            --
          ------------------------------------------------------------------------
     where ((current_date between de.effectivedate and de.enddate and current_timestamp between de.createts and de.endts)
        or (de.effectivedate > current_date and de.enddate >= '2199-12-30'))
       and de.benefitsubclass in ('1W','13','1Hosp')) 
)  

left join (select personid, dependentid, effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
             from dependent_enrollment where benefitsubclass = '13' and selectedoption = 'Y' and enddate < '2199-12-30'
            group by personid, dependentid, effectivedate) de13 on de13.personid = de.personid and de13.dependentid = de.dependentid 
 
left join (select personid, dependentid, effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
             from dependent_enrollment where benefitsubclass = '1W' and selectedoption = 'Y' and enddate < '2199-12-30'
            group by personid, dependentid, effectivedate) de1w on de1w.personid = de.personid and de1w.dependentid = de.dependentid  

left join (select personid, dependentid, effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
             from dependent_enrollment where benefitsubclass = '1Hosp' and selectedoption = 'Y' and enddate < '2199-12-30'
            group by personid, dependentid, effectivedate) dehi on dehi.personid = de.personid and dehi.dependentid = de.dependentid            
 
join person_identity piD
  on piD.personid = pdr.dependentid
 and piD.identitytype = 'SSN'
 and current_timestamp between piD.createts and piD.endts 
 
join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnD.createts and pnD.endts
 and pnD.nametype = 'Dep'   
 
join person_vitals pvd
  on pvd.personid = pdr.dependentid
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts 
  
 
where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
  order by personid, ssn,trans_code desc, rel_code desc, mbrssn
  
  

                                                                                                                                                