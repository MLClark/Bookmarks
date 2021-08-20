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
------------------------------------
----- Critical Illness Section ----- 
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
----------------------------
----- Accident Section ----- 
----------------------------
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
,'1' ::char(1) as vac_plan_number
,case when pbeac.benefitsubclass = '13' and lc.locationid in ('1') then '13' --- corporate
      when pbeac.benefitsubclass = '13' and lc.locationid in ('2') then '15' --- elgin
      when pbeac.benefitsubclass = '13' and lc.locationid in ('3') then '17' --- germantown tooling
      when pbeac.benefitsubclass = '13' and lc.locationid in ('4') then '18' --- lake forrest
      when pbeac.benefitsubclass = '13' and lc.locationid in ('6') then '16' --- portland
      else null end ::char(5) as vac_employee_group_id
,case when pbeac.benefitsubclass = '13' then '1' else null end ::char(1) as vac_employee_class
     
 
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

left join ( select personid, phoneno, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
  from person_phone_contacts
  where phonecontacttype = 'Home'
   and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   group by personid, phoneno) ppch on ppch.personid = pe.personid and ppch.rank = 1
 
left join ( select personid, phoneno, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
  from person_phone_contacts
  where phonecontacttype = 'Work'
   and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   group by personid, phoneno) ppcw on ppcw.personid = pe.personid and ppcw.rank = 1

left join ( select personid, phoneno, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
  from person_phone_contacts
  where phonecontacttype = 'Mobile'
   and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
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
 AND pbe.benefitsubclass IN ( '1W','13')
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T','E')
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ( '1W','13') and benefitelection = 'E' and selectedoption = 'Y')  
 
-- 10KCritNT           
left JOIN person_bene_election pbeci
  on pbeci.personid = pbe.personid 
 AND current_date between pbeci.effectivedate and pbeci.enddate
 AND current_timestamp between pbeci.createts and pbeci.endts
 AND pbeci.benefitsubclass IN ('1W')
 AND pbeci.selectedoption = 'Y'
 and pbeci.benefitelection <> 'W'
 and pbeci.benefitcoverageid > '1'
  
--- accident
left JOIN person_bene_election pbeac
  on pbeac.personid = pbe.personid 
 AND current_date between pbeac.effectivedate and pbeac.enddate
 AND current_timestamp between pbeac.createts and pbeac.endts
 AND pbeac.benefitsubclass IN ('13')
 AND pbeac.selectedoption = 'Y' 
 and pbeac.benefitelection <> 'W'
 and pbeac.benefitcoverageid > '1'

left JOIN benefit_coverage_desc bcdac
  ON bcdac.benefitcoverageid = pbeac.benefitcoverageid 
 AND current_date between bcdac.effectivedate and bcdac.enddate 
 AND current_timestamp between bcdac.createts AND bcdac.endts
 
left JOIN benefit_coverage_desc bcdci
  ON bcdci.benefitcoverageid = pbeci.benefitcoverageid 
 AND current_date between bcdci.effectivedate and bcdci.enddate 
 AND current_timestamp between bcdci.createts AND bcdci.endts 
 
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
     and pbe.benefitsubclass in ('1W','13')
     and pbe.selectedoption = 'Y'
     and current_date between pbe.effectivedate and pbe.enddate
     and current_timestamp between pbe.createts and pbe.endts     
   where current_timestamp between de.createts and de.endts
    and de.benefitsubclass in ('1W','13')
    and pdr.dependentrelationship in ('S','D','C','NS','ND','NC')
    and pe.emplstatus = 'A'
    and pbe.benefitelection = 'E'
   -- and pe.personid = '9707'
    and de.dependentid not in 
   (select distinct de.dependentid from dependent_enrollment de
      join person_dependent_relationship pdr
        on pdr.personid = de.personid
       and pdr.dependentid = de.dependentid
       and current_date between pdr.effectivedate and pdr.enddate
       and current_timestamp between pdr.createts and pdr.endts
     where current_date between de.effectivedate and de.enddate
       and current_timestamp between de.createts and de.endts
       and de.benefitsubclass in ('1W','13')
       and pdr.dependentrelationship in ('S','D','C','NS','ND','NC')
   )
)  

left join (select personid, dependentid, effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from dependent_enrollment
 where benefitsubclass = '13'
   and selectedoption = 'Y'
   and enddate < '2199-12-30'
 group by personid, dependentid, effectivedate) de13 on de13.personid = de.personid and de13.dependentid = de.dependentid 
 
left join (select personid, dependentid, effectivedate, max(enddate) as enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from dependent_enrollment
 where benefitsubclass = '1W'
   and selectedoption = 'Y'
   and enddate < '2199-12-30'
 group by personid, dependentid, effectivedate) de1w on de1w.personid = de.personid and de1w.dependentid = de.dependentid  
 
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
  