select distinct
-- Only employees enrolled in the HDHP plan should be included with hsa eligibility 
 pi.personid
,'2' ::char(1) as sort_seq 
,pbemed.benefitplanid
 
 -- 1 - Demographic Information
 
,'146534' ::char(7) as employer_id
,' ' ::char(10) as division
,pi.identity ::char(9) as member_number 
,pi.identity ::char(9) as ssn
,pn.fname ::char(20) as fname
,pn.lname ::char(20) as lname
,pn.mname ::char(1) as mname
,to_char(pv.birthdate,'MM/DD/YYYY')::char(10) as dob
,to_char(pe.emplservicedate,'MM/DD/YYYY')::char(10) as doh
--,to_char(pe.empllasthiredate,'MM/DD/YYYY')::char(10) as ldoh
--,to_char(pe.emplservicedate,'MM/DD/YYYY')::char(10) as sdoh
,pv.gendercode ::char(1) as gender
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'MM/DD/YYYY')::char(10) end as employee_status_date
,case when pe.emplstatus = 'T' then 'T' else ' ' ::char(1) end as employee_status
,coalesce(pa.streetaddress,pam.streetaddress) ::char(50) as addr1
,coalesce(pa.streetaddress2,pam.streetaddress2) ::char(50) as addr2
,coalesce(pa.city,pam.city) ::char(20) as city
,coalesce(pa.stateprovincecode,pam.stateprovincecode) ::char(2) as state
,coalesce(pa.postalcode,pam.postalcode) ::char(10) as zip
,case when coalesce(pa.countrycode,pam.countrycode) = 'US' then 'USA' else ' ' end ::char(3) as country
,'0771742' ::char(7) as control
,'011' ::char(3) as suffix
,'201' ::char(3) as account
,' ' ::char(10) as copay_code_med
,' ' ::char(10) as copay_code_dnt
,' ' ::char(10) as copay_code_vsn
,' ' ::char(10) as copay_code_rx
,case when bcd.benefitcoveragedesc = 'Employee Only' then 'I' else 'F' end ::char(1) as coverage_level
,' ' ::char(81) as fill81
,pncw.url::char(50) as email_address
,' ' ::char(10) as payroll_schedule_id
,' ' ::char(17) as bank_account_number
,' ' ::char(17) as bank_routing_number
,' ' ::char(3) as bank_account_type
,' ' ::char(15) as drivers_license_number
,' ' ::char(2) as drivers_license_issue_authority

-- 2 - Election Information

--,to_char(pbemed.effectivedate,'MM/DD/YYYY')::char(10) as plan_year_eff_date
-- plan year effective date needs to be the start of the current plan year not be based on effective date of coverage.
,to_char(date_trunc('year', current_date),'mm/dd/yyyy')::char(10) as plan_year_eff_date
,'16' ::char(2) as account_type
,to_char(pbemed.effectivedate,'MM/DD/YYYY')::char(10) as election_eff_date
,' ' ::char(8) as annual_ded
,' ' ::char(8) as annual_contrib
,' ' ::char(8) as sched_ded
,' ' ::char(8) as sched_contrib
,' ' ::char(1) as debit_card_selected
,' ' ::char(1) as auto_pay_dental
,' ' ::char(1) as auto_pay_healthcare
,' ' ::char(1) as auto_pay_vision
,' ' ::char(1) as auto_pay_rx
,' ' ::char(1) as fsa_first
,' ' ::char(10) as election_exp_date
,' ' ::char(10) as ltdfsa_ded_med_date

-- 3 - Additional Service Information

,'F' ::char(1) as commuter_transit
,'F' ::char(1) as commuter_parking
,' ' ::char(1) as wellness_status
,' ' ::char(10) as wellness_location





from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'BEK_PayFlex_HSA_Eligibility_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 --and pe.emplstatus <> 'T'

join person_bene_election pbemed
  on pbemed.personid = pe.personid
 and current_date between pbemed.effectivedate and pbemed.enddate
 and current_timestamp between pbemed.createts and pbemed.endts
 and pbemed.benefitelection <> 'W' 
 and pbemed.selectedoption = 'Y'   
 and pbemed.benefitsubclass in ('10')
 and pbemed.benefitplanid in ('9')
 and (pbemed.effectivedate >= elu.lastupdatets::DATE 
  or (pbemed.createts > elu.lastupdatets and pbemed.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
  
 
left JOIN benefit_plan_desc bpd
  on bpd.benefitsubclass = pbemed.benefitsubclass
 and bpd.benefitplanid = pbemed.benefitplanid 
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts 
  
left JOIN benefit_coverage_desc bcd 
  on bcd.benefitcoverageid = pbemed.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 
 
left join person_names pn
  on pn.personid = pe.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'
 
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join person_address pa
  on pa.personid = pe.personid
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 and pa.addresstype = 'Res'

left join person_address pam
  on pam.personid = pe.personid
 and current_date between pam.effectivedate and pam.enddate
 and current_timestamp between pam.createts and pam.endts 
 and pam.addresstype = 'Mail' 

left join person_net_contacts pncw
  on pncw.personid = pe.personid
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts
 and pncw.netcontacttype = 'WRK'::bpchar    
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 