select distinct
 pi.personid
,pc.frequencycode
,pdr.dependentid
,de.benefitsubclass
,pbeac.benefitcoverageid
,pbehi.benefitcoverageid
,'86 Active EE SP' ::varchar(30) as sourceseq
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
----- Client Specific Field Section -----
-----------------------------------------
,'~CSF~' ::char(5) as section_code_csf
--Hourly Salary Indicator
--Client-Specific Field #1 Name
--Client-Specific Field #1 Value
,'Hourly Salary Indicator' ::char(30) as csf_field1_name
,case when pc.frequencycode = 'H' then 'Hourly' 
      when pc.frequencycode = 'A' then 'Salary' end ::char(30) as csf_field1_value
,' ' ::char(1) as csf_field2_name
,' ' ::char(1) as csf_field2_value
,' ' ::char(1) as csf_field3_name
,' ' ::char(1) as csf_field3_value
,' ' ::char(1) as csf_field4_name
,' ' ::char(1) as csf_field4_value
,' ' ::char(1) as csf_field5_name
,' ' ::char(1) as csf_field5_value   
-----------------------------------------
----- Short Term Disability Section -----
----- NON-STATUTORY                 -----
----- Section Code ~NST~            -----
-----------------------------------------
,'~NST~'::char(5) as section_code_nst
,case when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') then to_char(pbestd.effectivedate,'YYYYMMDD') else null end ::char(8) as nst_cov_effdate
,case when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pbestd.benefitelection = 'T' then to_char(pbestd.enddate,'YYYYMMDD')
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as nst_cov_term_date
,' ' ::char(1) as nst_std_covered_salary
/*
"60 - for Salaried
Core - for Hourly
Buyup - for Hourly w Buy up plan"
*/  


-- I believe the Voluntary STD plan is the Buyup plan and the ER plan is the Core plan, so STD Coverage Plan Option should be Buyup for those with the Voluntary plan
,case when pbestd.benefitsubclass in ('30') and pbestd.benefitcoverageid in ('2','5') and pc.frequencycode = 'H' and pbestd.benefitplanid = '285' then 'Buyup'
      when pbestd.benefitsubclass in ('30') and pbestd.benefitcoverageid in ('2','5') and pc.frequencycode = 'H' and pbestd.benefitplanid = '111' then 'Core'
      when pbestd.benefitsubclass in ('3Y') and pbestd.benefitcoverageid in ('2','5') and pc.frequencycode = 'H' and pbestd.benefitplanid in ('291','288') then 'Core'
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pc.frequencycode = 'A' then '60'else null end ::varchar(10) as nst_std_cvg_plan_option
,' ' ::char(1) as nst_std_req_cvg_plan_option
/*
2/20/19 chg based on Mauricio's email:
Based on Pay Unit & plan option:
1 - for AJG00 w/plan id 291 - STD Salaried
6 - for AJG01 w/o plan id 285 (core only) 
30 - for AJG01 w/plan id 285 STD Hrly Vol (Buyup plan)
24 - for AJG05 & 06 w/o plan id 285 (core only or salary)
29 - for AJG06 w/plan id 285 STD Hrly Vol (Buyup plan)
26 - for AJG15 & 16 w/o plan id 285 (core only or salary)
31 - for AJG16 w/plan id 285 STD Hrly Vol (Buyup plan)
3 - for AJG20 w/o plan id 285 (core only or salary)
27 - for AJG20 w/plan id 285 STD Hrly Vol (Buyup plan)
*/
,pu.payunitxid
,pbestd.benefitplanid
,pc.frequencycode
,case when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pu.payunitxid in ('00') and pbestd.benefitplanid = '291' then '1'     ---1 - for AJG00 w/plan id 291 - STD Salaried
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pu.payunitxid in ('01') and pbestd.benefitplanid <> '285' then '6'         ---6 - for AJG01 W/O plan id 285 (core only) *
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pu.payunitxid in ('01') and pbestd.benefitplanid = '285' then '30'              --30 - for AJG01 w/plan id 285 STD Hrly Vol (Buyup plan)
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pu.payunitxid in ('05','06') and pbestd.benefitplanid <> '285' then '24'   --24 - for AJG05 & 06 W/O plan id 285 (core only or salary) *
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pu.payunitxid in ('06') and pbestd.benefitplanid = '285' then '29'              --29 - for AJG06 w/plan id 285 STD Hrly Vol (Buyup plan)
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pu.payunitxid in ('15','16') and pbestd.benefitplanid <> '285' then '26'        --26 - for AJG15 & 16 W/O  plan id 285 (core only or salary) *
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pu.payunitxid in ('16') and pbestd.benefitplanid = '285' then '31'              --31 - for AJG16 w/plan id 285 STD Hrly Vol (Buyup plan)
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pu.payunitxid in ('20') and pbestd.benefitplanid <> '285' then '3'              ---3 - for AJG20 W/O plan id 285 (core only or salary) *
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pu.payunitxid in ('20') and pbestd.benefitplanid = '285' then '27'              --27 - for AJG20 w/plan id 285 STD Hrly Vol (Buyup plan)
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pu.payunitxid not in ('00') and pbestd.benefitplanid = '291' then '1' --- not accounted for in Lori's notes
      else null end ::char(2) as nst_ee_group_id

/*
2/20/19 chg based on Mauricio's email:
Based on Slary/Hourly Indicator and Plan Option:
3 - for Salaried
4 - for Hourly w/o plan id 285 (core only) 
5 - for Hourly w/ plan id 285 (Buyup plan)
*/
,case when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pc.frequencycode = 'A' then '3'
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pc.frequencycode = 'H' and pbestd.benefitplanid =  '285' then '4' 
      when pbestd.benefitsubclass in ('30','3Y') and pbestd.benefitcoverageid in ('2','5') and pc.frequencycode = 'H' and pbestd.benefitplanid <> '285' then '5' else null end ::char(1) as nst_ee_class_code 
----------------------------------------
----- Long Term Disability Section -----
----- Section Code ~LTD~           -----
----------------------------------------
,'~LTD~'::char(5) as section_code_ltd
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitcoverageid in ('2','5') then to_char(pbeltd.effectivedate,'YYYYMMDD') else null end ::char(8) as ltd_cov_effdate
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitcoverageid in ('2','5') and pbeltd.benefitelection = 'T' then to_char(pbeltd.enddate,'YYYYMMDD')
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitcoverageid in ('2','5') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as ltd_cov_term_date
,null as ltd_cov_term_rsn_code
,null as ltd_cov_term_desc    
,null as ltd_covered_salary
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitcoverageid in ('2','5') then '60' else null end ::char(2) as ltd_coverage_plan_option
,null as ltd_req_cvg_plan_option
/*
"Based on Pay Unit:
1 - for AJG00 - 01
2 - for AJG05-06
3 - for AJG20
4 - for AJG15-16"
--- added
5 - for AJG10
*/
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitcoverageid in ('2','5') and pu.payunitxid in ('00','01','25') then '1'
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitcoverageid in ('2','5') and pu.payunitxid in ('05','06') then '2'
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitcoverageid in ('2','5') and pu.payunitxid in ('20') then '3'
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitcoverageid in ('2','5') and pu.payunitxid in ('15','16') then '4' 
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitcoverageid in ('2','5') and pu.payunitxid in ('10','11') then '5' else null end ::char(1) as ltd_ee_group_id
,case when pbeltd.benefitsubclass in ('31') and pbeltd.benefitcoverageid in ('2','5') and pc.frequencycode = 'A' then '1'
      when pbeltd.benefitsubclass in ('31') and pbeltd.benefitcoverageid in ('2','5') and pc.frequencycode = 'H' then '2'else null end ::char(1) as ltd_employee_class_code
------------------------------------
----- Critical Illness Section ----- 
----- Section Code ~VCI~       -----
------------------------------------
,'~VCI~'::char(5) as section_code_vci
,case when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') then to_char(pbeci.effectivedate,'YYYYMMDD') else null end ::char(8) as vci_cov_effdate
,case when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and pbeci.benefitelection = 'T' then to_char(pbeci.enddate,'YYYYMMDD')
      when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as vci_cov_term_date
,null as vci_cov_term_rsn_code
,null as vci_cov_term_desc
,case when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and pbeci.benefitplanid in ('120', '126', '114') Then '10000'
      when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and pbeci.benefitplanid in ('129', '123', '132') Then '20000'
      else null End ::char(10) as vci_bene_amt
,case when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and bcdci.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and bcdci.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and bcdci.benefitcoveragedesc = 'Family' then '2'
      when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and bcdci.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vci_coverage_tier  
,case when pbeci.benefitsubclass = '1W' then '1' else null end ::char(1) as vci_plan_number
,case when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and lc.locationid in ('1') then '7'  --- corporate
      when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and lc.locationid in ('2') then '9'  --- elgin
      when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and lc.locationid in ('3') then '11' --- germantown tooling
      when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and lc.locationid in ('4') then '12' --- lake forrest
      when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') and lc.locationid in ('6') then '10' --- portland
      else null end ::char(5) as vci_employee_group_id
,case when pbeci.benefitsubclass = '1W' and pbeltd.benefitcoverageid in ('2','5') then '1' else null end ::char(1) as vci_employee_class
------------------------------
----- Accident Section   ----- 
----- Section Code ~VAC~ -----
------------------------------
,'~VAC~' ::char(5) as section_code_vac
,case when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') then to_char(pbeac.effectivedate,'YYYYMMDD') else null end ::char(8) as vac_cov_effdate
,case when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and pbeac.benefitelection = 'T' then to_char(pbeac.enddate,'YYYYMMDD')
      when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as vac_cov_term_date
,null as vac_cov_term_rsn_code
,null as vac_cov_term_desc
,case when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and bcdac.benefitcoveragedesc = 'Employee Only' then '1'
      when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and bcdac.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and bcdac.benefitcoveragedesc = 'Family' then '2'
      when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and bcdac.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS vac_coverage_tier  
,case when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and pbeac.benefitplanid = '135' then 'Plan 1'
      when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and pbeac.benefitplanid = '138' then 'Plan 2'
      else null end ::char(6) as vac_plan_option
,case when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') then '1' else null end ::char(1) as vac_plan_number
,case when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and lc.locationid in ('1') then '13' --- corporate
      when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and lc.locationid in ('2') then '15' --- elgin
      when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and lc.locationid in ('3') then '17' --- germantown tooling
      when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and lc.locationid in ('4') then '18' --- lake forrest
      when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as vac_employee_group_id
,case when pbeac.benefitsubclass = '13' and pbeac.benefitcoverageid in ('2','5') then '1' else null end ::char(1) as vac_employee_class
--------------------------------------
----- Hospital Indemnity Section ----- 
----- Section Code ~HIP~         -----
--------------------------------------
,'~HIP~' ::char(5) as section_code_hip
,pbehi.benefitsubclass 
,pbehi.benefitplanid
,pu.payunitxid
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') then to_char(pbehi.effectivedate,'YYYYMMDD') else null end ::char(8) as hip_cov_effdate
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and pbehi.benefitelection = 'T' then to_char(pbehi.enddate,'YYYYMMDD')
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD')
      else null end ::char(8) as hip_cov_term_date
,null as hip_cov_term_rsn_code
,null as hip_cov_term_desc

/*
2/28/2019 chg based on Mauricio's email:
Based on Coverage Tier:
1 - EE only
2 - EE + Family
3 - EE + Spouse
4 - EE + Children
*/
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and bcdhi.benefitcoveragedesc = 'Employee Only' then '1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and bcdhi.benefitcoveragedesc = 'Employee + Spouse' then '3'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and bcdhi.benefitcoveragedesc = 'Family' then '2'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and bcdhi.benefitcoveragedesc = 'Employee + Children' then '4'  
      else null end ::char(1) AS hip_coverage_tier  
      
/*
3/4/19 chg based on Mauricio's email:
Low = Plan 1 
Mid = Plan 2
*/      
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and pbehi.benefitplanid = '279' then 'Plan 1'
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and pbehi.benefitplanid = '282' then 'Plan 2'
      else null end ::char(6) as hip_plan_option
/*
3/4/19 chg based on Mauricio's email:
1 - for All
*/      
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') then '1' else null end ::char(1) as hip_plan_number

/*
2/28/19 chg based on Mauricio's email:
Based on Pay Unit:
19 - for AJG00 - 01
20 - for AJG05-06
21 - for AJG20
22 - for AJG15-16
23 - for AJG10-11
*/      
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and pu.payunitxid in ('00','01') then '19'  
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and pu.payunitxid in ('05','06') then '20' 
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and pu.payunitxid in ('20') then '21'  
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and pu.payunitxid in ('15','16') then '22'  
      when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') and pu.payunitxid in ('10','11') then '23'  
      else null end ::char(5) as hip_employee_group_id
      
,case when pbehi.benefitsubclass = '1Hosp' and pbehi.benefitcoverageid in ('2','5') then '1' else null end ::char(1) as hip_employee_class

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
 and pbe.benefitcoverageid > '1' 
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
 
 -- select * from dependent_enrollment where personid = '10186';
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
  and pe.emplstatus in ('A','L')
  and pdr.dependentrelationship <> 'X'
  and (pdr.dependentrelationship in ('SP','DP','NA'))
  --and pe.personid = '10186'
 order by 1