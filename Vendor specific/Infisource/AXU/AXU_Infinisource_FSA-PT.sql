SELECT
 pi.personid
,pbe.effectivedate
,pu.payunitxid
,to_char(current_timestamp,'HHMISS')::char(6) as createTime
,'ACTIVE EE' ::varchar(50) as qsource
,'4A1032' :: char(6) as employer_code
,'PT' :: char(2) as record_type 
,pi.identity:: char(9) as participant_id
,pip.identity :: char(20) as employer_employee_id
,null ::char(15) as employee_number
,rtrim(pn.lname) :: char(30) as emp_last_name
,rtrim(ltrim(pn.fname)) :: char(30) as emp_first_name
,rtrim(ltrim(pn.mname)) :: char(1) as emp_middle_in
,pv.gendercode ::char(1) as emp_gender
,NULL ::char(1) as emp_maritalstatus
,null ::char(50) as emp_mother_m_name
,to_char(pv.birthdate,'mmddyyyy')::char(8) as emp_dob
,pi.identity :: char(9) as emp_ssn
,pa.streetaddress ::char(50) as emp_addr1
,pa.streetaddress2 ::char(50) as emp_addr2
,NULL ::char(50) as emp_addr3
,NULL ::char(50) as emp_addr4
,pa.city ::char(30) as emp_city
,pa.stateprovincecode ::char(2) as emp_state
,pa.postalcode ::char(9) as emp_zip
,pa.countrycode  ::char(2) as emp_countrycode
,rtrim(ltrim(ppch.phoneno,'')) ::varchar(10) as home_phone
,rtrim(ltrim(ppco.phoneno,'')) ::varchar(10) as work_phone
,null ::char(6) as w_phone_extention
,trim(coalesce(pncw.url,pncH.url),'')::varchar(50) as emp_email
,null ::char(100) as username
,null ::char(100) as password
,to_char(pe.emplhiredate,'MMDDYYYY')::char(8) as emp_doh
,null :: char(2) as division
,null :: char(2) as hours_per_week
,CASE WHEN pe.emplclass = 'F' THEN 'Full Time'
     else null::char(9)
	end::char(9) as employee_class --send only FT employees
,case when pu.frequencycode = 'W' then 'Weekly'
      when pu.frequencycode = 'B' then 'Bi-Weekly' 
	end ::char(10) as payroll_freq
,to_char(pe.emplhiredate,'mmddyyyy')::char(8)as payrollfreq_effdate
,case when pe.emplstatus = 'A' then 'Active'
      when pe.emplstatus = 'T' then 'Terminated'
       end ::varchar(20) as participant_status
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') 
      else to_char(pe.emplhiredate,'MMDDYYYY') 
	end ::char(8) as status_eff_date
,null ::char(1) as hold_payroll_ded
,null ::char(1) as hold_employer_contrib
,null ::char(1) as incur_svcs
,null ::char(1) as final_pay_date
,null ::char(1) as final_contrib_date
,null :: char(1) as hsa_custodian
--,null :: char(1) as medicare_beneficiary
,'1' as sort_seq  

from person_identity pi

left join person_identity pip
  on pi.personid = pip.personid
 and pip.identitytype = 'EmpNo'
 and current_timestamp between pip.createts and pip.endts

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join public.person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join public.person_address pa
  on pa.personid = pi.personid
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 and pa.addresstype = 'Res'

LEFT JOIN person_phone_contacts ppch
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home' 
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts
 
LEFT JOIN person_phone_contacts ppco 
  ON ppco.personid = pi.personid 
 AND ppco.phonecontacttype = 'Work' 
 and current_date between ppco.effectivedate and ppco.enddate
 and current_timestamp between ppco.createts and ppco.endts 

LEFT JOIN person_net_contacts pncw
  ON pncw.personid = pi.personid
 AND pncw.netcontacttype = 'WRK'::bpchar
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts

LEFT JOIN person_net_contacts pncH 
  ON pncH.personid = pi.personid
 AND pncH.netcontacttype = 'HomeEmail'::bpchar
 and current_date between pncH.effectivedate and pncH.enddate
 and current_timestamp between pncH.createts and pncH.endts

left join public.person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

LEFT JOIN person_payroll pp 
  on pp.personid = pi.personid 
 and CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate 
 and CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

LEFT JOIN pay_unit pu 
   ON pu.payunitid = pp.payunitid
  AND current_timestamp between pu.createts and pu.endts

left join (select pbe.personid,pbe.benefitsubclass,pbe.benefitelection,pbe.selectedoption,pbe.eventdate,pbe.benefitplanid,pbe.benefitcoverageid,pbe.compplanid,
max(pbe.effectivedate) as effectivedate,max(pbe.enddate) as enddate,max(pbe.createts) as createts,
rank() over (partition by pbe.personid order by max(pbe.effectivedate) desc) as rank
from person_bene_election pbe
left join comp_plan_plan_year cppy 
  on cppy.compplanid = pbe.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and ?::date between cppy.planyearstart and cppy.planyearend
 where effectivedate < enddate 
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('60','61')
 and pbe.coverageamount <> 0
 and pbe.selectedoption = 'Y'
 and pbe.effectivedate between cppy.planyearstart and cppy.planyearend
 group by 1,2,3,4,5,6,7,8) pbe on pbe.personid = pe.personid and pbe.rank = 1

WHERE pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and pbe.benefitelection in ('E') 
  and pe.emplstatus not in ('T','R')

union ------------------------------------------------------------------------------------------------------------

--termed employees
SELECT
 pi.personid
,pbe.effectivedate
,pu.payunitxid
,to_char(current_timestamp,'HHMISS')::char(6) as createTime
,'TERMED EE' ::varchar(50) as qsource 
,'4A1032' :: char(6) as employer_code
,'PT' :: char(2) as record_type 
,pi.identity:: char(9) as participant_id
,pip.identity :: char(20) as employer_employee_id
,null ::char(15) as employee_number
,rtrim(pn.lname) :: char(30) as emp_last_name
,rtrim(ltrim(pn.fname)) :: char(30) as emp_first_name
,rtrim(ltrim(pn.mname)) :: char(1) as emp_middle_in
,pv.gendercode ::char(1) as emp_gender
,NULL ::char(1) as emp_maritalstatus
,null ::char(50) as emp_mother_m_name
,to_char(pv.birthdate,'mmddyyyy')::char(8) as emp_dob
,pi.identity :: char(9) as emp_ssn
,pa.streetaddress ::char(50) as emp_addr1
,pa.streetaddress2 ::char(50) as emp_addr2
,NULL ::char(50) as emp_addr3
,NULL ::char(50) as emp_addr4
,pa.city ::char(30) as emp_city
,pa.stateprovincecode ::char(2) as emp_state
,pa.postalcode ::char(9) as emp_zip
,pa.countrycode  ::char(2) as emp_countrycode
,rtrim(ltrim(ppch.phoneno,'')) ::varchar(10) as home_phone
,rtrim(ltrim(ppco.phoneno,'')) ::varchar(10) as work_phone
,null ::char(6) as w_phone_extention
,trim(coalesce(pncw.url,pncH.url),'')::varchar(50) as emp_email
,null ::char(100) as username
,null ::char(100) as password
,to_char(pe.emplhiredate,'MMDDYYYY')::char(8) as emp_doh
,null :: char(2) as division
,null :: char(2) as hours_per_week
,CASE WHEN pe.emplclass = 'F' and pe.emplstatus = 'T' THEN 'Full Time'--
      else null::char(9)
	end::char(9) as employee_class --send only FT employees
,case when pu.frequencycode = 'W' then 'Weekly'
      when pu.frequencycode = 'B' then 'Bi-Weekly' 
	end ::char(10) as payroll_freq
,to_char(pe.emplhiredate,'mmddyyyy')::char(8)as payrollfreq_effdate
,case when pe.emplstatus = 'A' then 'Active'
      when pe.emplstatus = 'T' then 'Terminated'
       end ::varchar(20) as participant_status
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') 
      else to_char(pe.emplhiredate,'MMDDYYYY') 
	end ::char(8) as status_eff_date
,null ::char(1) as hold_payroll_ded
,null ::char(1) as hold_employer_contrib
,null ::char(1) as incur_svcs
,null ::char(1) as final_pay_date
,null ::char(1) as final_contrib_date
,null :: char(1) as hsa_custodian
--,null :: char(1) as medicare_beneficiary
,'1' as sort_seq  

from person_identity pi

left join person_identity pip
  on pi.personid = pip.personid
 and pip.identitytype = 'EmpNo'
 and current_timestamp between pip.createts and pip.endts

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join public.person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join public.person_address pa
  on pa.personid = pi.personid
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 and pa.addresstype = 'Res'

LEFT JOIN person_phone_contacts ppch
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home' 
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts
 
LEFT JOIN person_phone_contacts ppco 
  ON ppco.personid = pi.personid 
 AND ppco.phonecontacttype = 'Work' 
 and current_date between ppco.effectivedate and ppco.enddate
 and current_timestamp between ppco.createts and ppco.endts 

LEFT JOIN person_net_contacts pncw
  ON pncw.personid = pi.personid
 AND pncw.netcontacttype = 'WRK'::bpchar
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts

LEFT JOIN person_net_contacts pncH 
  ON pncH.personid = pi.personid
 AND pncH.netcontacttype = 'HomeEmail'::bpchar
 and current_date between pncH.effectivedate and pncH.enddate
 and current_timestamp between pncH.createts and pncH.endts

left join public.person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

LEFT JOIN person_payroll pp 
  on pp.personid = pi.personid 
 and CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate 
 and CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

LEFT JOIN pay_unit pu 
   ON pu.payunitid = pp.payunitid
  AND current_timestamp between pu.createts and pu.endts

left join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'T'
 and pbe.coverageamount <> 0
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

left join comp_plan_plan_year cppy 
  on cppy.compplanid = pbe.compplanid
 and cppy.compplanplanyeartype = 'Bene'
 and ?::date between cppy.planyearstart and cppy.planyearend

WHERE pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pbe.effectivedate between cppy.planyearstart and cppy.planyearend
  and pe.emplstatus in ('T','R')

order by 1