select distinct
----- this query pulls everyone that is not enrolled in life / ad&d 
 pi.personid
,pe.effectivedate
 ,TO_CHAR(date_trunc('MONTH',pe.effectivedate) + INTERVAL '1 MONTH','YYYYMMDD')::DATE AS CALC_DATE_30
 ,(date_trunc('MONTH',pe.effectivedate) + INTERVAL '3 MONTHS') ::DATE  AS CALC_DATE_90
,'B' ::char(1) as sort_seq
,'*' ::char(1) as count_seq
,pbe.benefitsubclass 
,pbe.benefitplanid
,pbe.effectivedate
,pe.emplstatus
,pe.effectivedate
,pi.identity ::char(9) as subscriber_id 
,'00' ::char(2) as member_indicator
,pne.lname ::char(35) as lname
,pne.fname ::char(15) as fname
,'EE' ::char(2) as mbr_rel
,pne.mname ::char(1) as mname
,pae.streetaddress ::char(40) as addr1
,pae.streetaddress2::char(40) as addr2
,pae.city ::char(19) as city
,pae.stateprovincecode ::char(2) as state
,replace(pae.postalcode,'-','') ::char(9) as zip_split_me
,coalesce(ppcM.phoneno,ppcH.phoneno) ::char(12) as homephone
,coalesce(ppcW.phoneno,ppcB.phoneno) ::char(12) as workphone
,pve.gendercode ::char(1) as gender
,to_char(pve.birthdate,'YYYYMMDD')::char(8) as dob
,'715621' ::char(30) as group_policy_nbr
,'2001' ::char(30) as subgrp_policy_nbr
--,to_char(pbe.effectivedate,'YYYYMMDD')::char(8) as emp_subgrp_eff_date
,case when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'A' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + INTERVAL '1 MONTH','YYYYMMDD')  
      when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'H' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + INTERVAL '3 MONTHS','YYYYMMDD') 
      when pe.effectivedate::date <= '2017-09-01' then '20170901' 
  END ::char(8) as emp_subgrp_eff_date

,pbe.benefitsubclass
,' ' ::char(10) as plan_code

--,to_char(pbe.effectivedate,'YYYYMMDD') ::char(8) as plan_code_eff_date
,case when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'A' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + INTERVAL '1 MONTH','YYYYMMDD')  
      when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'H' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + INTERVAL '3 MONTHS','YYYYMMDD') 
      when pe.effectivedate::date <= '2017-09-01' then '20170901' 
  END ::char(8) as plan_code_eff_date      


,' ' ::char(2) as tier_code
      
      
      
/*
The client’s current billing method is ‘self bill’ and the new target date to switched 
them to ‘EDI List Bill’ was  09/01/2017. 09/01/2017 was the date used to determine the
employee’s eligibility effective date along with the hire date and new hire waiting period 
(All Salaried Employees - First of the month following 30 days; 
All Hourly Employees - First of the month following 90 days).
If the calculated effective date is prior to 09/01/2017, then use 09/01/2017.
If the calculated effective date is after 09/01/2017, then use the calculated effective date.

*/    

--,to_char(pbe.effectivedate,'YYYYMMDD')::char(8) as eff_date
,case when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'A' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + INTERVAL '1 MONTH','YYYYMMDD')
      when pe.effectivedate::date > '2017-09-01' and pc.frequencycode = 'H' 
      then TO_CHAR(date_trunc('MONTH',pe.effectivedate) + INTERVAL '3 MONTHS','YYYYMMDD')
      when pe.effectivedate::date <= '2017-09-01' then '20170901' 
  end ::char(8) as eff_date
,case when pbe.benefitelection = 'T' then to_char(pbe.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as term_date
,' ' ::char(9) as alt_id
,' ' ::char(1) as student
,' ' ::char(1) as handicapped
,' ' ::char(3) as written_pref_lang
,' ' ::char(8) as written_pref_eff_date
,' ' ::char(3) as spoken_pref_lang
,' ' ::char(8) as spoken_pref_eff_date
,'N' ::char(1) as CALAP_elig_ind

,to_char(pe.effectivedate,'YYYYMMDD')::char(8) as doh
---- need to convert subscriber_class_id to either: 
---- 2001 benefitsubclass 26 - planid 285 All F/T and P/T EEs Enroll in Medical Plan
---- 2002 benefitsubclass 26 - planid 296 All F/T and P/T EEs Not Enroll in Medical Plan
---- 2001 for all other coverages
,'2002' ::char(4) as subscriber_class_id
--,to_char(pbe.effectivedate,'YYYYMMDD') ::char(8) as subscriber_eff_date
,' ' ::char(8) as subscriber_eff_date

,'A'::char(1) as salary_type
--,pc.compamount
,' ' ::char(10) as salary_amount
      
      
  
,' ' ::char(8) as salary_eff_date   
   
,' ' as suplife_cvgamt
,' ' ::char(10) as plan_coverage_amount          ---DT39
      
--,to_char(pbe.effectivedate,'YYYYMMDD')  ::char(8) as rating_prem_ovrd_eff_date
,' ' ::char(8) as rating_prem_ovrd_eff_date  

,' ' ::char(8) as student_status_eff_date
,' ' ::char(8) as student_status_term_date
,' ' ::char(8) as handicap_eff_date
,' ' ::char(8) as handicap_term_date

from person_identity pi

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts

left join person_maritalstatus pmse
  on pmse.personid = pi.personid
 and current_date between pmse.effectivedate and pmse.enddate
 and current_timestamp between pmse.createts and pmse.endts
 
LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_address pae 
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts

left JOIN person_phone_contacts ppch 
  ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'
left JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'   
left JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'      
left JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'   

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 


left join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass not in ('20','21','22')
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'

 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and pbe.benefitelection = 'E'
  and pbe.selectedoption = 'Y'  
  and pi.personid not in 
  (select personid
     from person_bene_election 
    where current_date between effectivedate and enddate
      and current_timestamp between createts and endts
      and benefitsubclass in ('20','21','22')
      and benefitelection = 'E'
      and selectedoption = 'Y')  

  order by 1
 