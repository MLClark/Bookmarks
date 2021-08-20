SELECT distinct
 pi.personid
,pe.emplstatus
,'PT' ::char(2) as record_type
,pi.identity ::char(9) as participant_id
,pi.identity ::char(20) as employer_employee_id
,' ' ::char(1) as employee_number
,rtrim(pn.lname) ::varchar(30) as emp_last_name
,rtrim(ltrim(pn.fname)) ::varchar(30) as emp_first_name
,rtrim(ltrim(pn.mname)) ::char(1) as emp_middle_in
,pv.gendercode ::char(1) as emp_gender
,pm.maritalstatus ::char(1) as emp_maritalstatus
,' ' ::char(1) as emp_mother_m_name
,to_char(pv.birthdate,'mmddyyyy')::char(8) as emp_dob
,pi.identity ::char(9) as emp_ssn
,pa.streetaddress  ::varchar(50) as emp_addr1
,pa.streetaddress2 ::varchar(50) as emp_addr2
,pa.streetaddress3 ::varchar(50) as emp_addr3
,pa.streetaddress4 ::varchar(50) as emp_addr4
,pa.city ::varchar(30) as emp_city
,pa.stateprovincecode ::char(2) as emp_state
,pa.postalcode ::char(9) as emp_zip
,pa.countrycode  ::char(2) as emp_countrycode
,rtrim(ltrim(ppch.phoneno,'')) ::varchar(10) as home_phone
,rtrim(ltrim(ppcw.phoneno,'')) ::varchar(10) as work_phone
,' ' ::char(1) as w_phone_extention
,trim(coalesce(pncw.url,pncH.url),'')::varchar(50) as emp_email
,' ' ::char(1) as username
,' ' ::char(1) as password
,to_char(pe.emplhiredate,'MMDDYYYY')::char(8) as emp_doh
,'Chef Works Inc.' ::varchar(100) as division
,trunc(pp.scheduledhours * 24 / 52) as hours_per_week
,'Class' ::varchar(9) as employee_class
,'BiWeekly' ::varchar(10) as payroll_freq

,to_char(pe.emplhiredate,'mmddyyyy')::char(8)as payrollfreq_effdate
,case when pe.emplstatus = 'A' then 'Active'
      when pe.emplstatus = 'T' then 'Terminated'
       end ::varchar(20) as participant_status

,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'MMDDYYYY') 
      else to_char(pe.emplhiredate,'MMDDYYYY') end ::char(8) as status_eff_date
,' ' ::char(1) as hold_payroll_ded
,' ' ::char(1) as hold_employer_contrib
,' ' ::char(1) as incur_svcs
,' ' ::char(1) as final_pay_date
,' ' ::char(1) as final_contrib_date
,' ' ::char(1) as hsa_custodian
,' ' ::char(1) as medicare_beneficiary
,' ' ::char(1) as medicare_id
,' ' ::char(1) as exchange_integration_id
,' ' ::char(1) as reporting_hierarc_level_1
,' ' ::char(1) as reporting_hierarc_level_2
,' ' ::char(1) as reporting_hierarc_level_3
,' ' ::char(1) as reporting_hierarc_level_4
,' ' ::char(1) as cdd_citizenship
,' ' ::char(1) as cdd_county
,' ' ::char(1) as cdd_employment_status
,' ' ::char(1) as cdd_employer
,' ' ::char(1) as cdd_job_title
,to_char(pe.emplhiredate,'mmddyyyy')::char(8) as class_effective_date
,'1' ::char as sort_seq  
,to_char(current_date,'MMDDYYYY') ::char(8) as create_date
,to_char(current_timestamp,'HHMMSS')::char(6) as create_time

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'ASP_Optum_FSA_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection <> 'W'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
  and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and current_date between effectivedate and enddate
                          and benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
  
left join person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
-- select * from person_maritalstatus where personid = '4060';
left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts

left join person_address pa
  on pa.personid = pi.personid
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 and pa.addresstype = 'Res'

LEFT JOIN person_phone_contacts ppch
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home' 
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts
 -- select phonecontacttype from person_phone_contacts group by 1;
left join person_phone_contacts ppcw
  ON ppcw.personid = pi.personid 
 AND ppcw.phonecontacttype = 'Main' 
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 
 -- select netcontacttype from person_net_contacts group by 1;
left join person_net_contacts pncw
  on pncw.personid = pi.personid
 and pncw.netcontacttype = 'WRK'::bpchar
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts

left join person_net_contacts pncH 
  on pncH.personid = pi.personid
 and pncH.netcontacttype = 'HomeEmail'::bpchar
 and current_date between pncH.effectivedate and pncH.enddate
 and current_timestamp between pncH.createts and pncH.endts

left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pe.personid and pp.rank = 1

join personbenoptioncostl poc 
  on poc.personid = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'P'


where pi.identitytype = 'SSN'
   and current_timestamp between pi.createts and pi.endts
   and pbe.coverageamount <> 0
   and (pbe.effectivedate >= elu.lastupdatets::DATE 
    or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
--and pe.personid = '4374'

order by 1