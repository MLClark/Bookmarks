
select distinct
 pi.personid
,pdr.dependentid as dependentid
,'2' ::char(1) as sortseq
,'ACTIVE EE DEP SPOUSE W CI' ::varchar(30) as qsource
,'WIJ4FD6L' ::char(8) as EDI_ACCOUNT_ID 
,pi.identity ::char(9) as EMPLOYEE_SSN 
,case when pbe.benefitsubclass = 'CIV' then 'G000035653_'|| pi.identity ||'_CE' end ::varchar(25) as CORRELATION_GUID
,replace(pidep.identity,'-','') ::char(9) as PERSON_SSN
,pie.identity ::char(9) as EMPLOYEE_OR_MEMBER_ID
,case when pdr.dependentrelationship in ('SP','NA','DP')         then 'SPOUSE'
      when pdr.dependentrelationship in ('D','S','C','FC','GC')  then 'DEPENDENT'
       end ::varchar(20) as RELATIONSHIP_TO_EMPLOYEE
       
,case when pdr.dependentrelationship in ('SP','NA','DP')         then 'SPOUSE'
      when pdr.dependentrelationship in ('D','S','C','FC','GC')  then 'DEPENDENT'
       end ::varchar(30) as PERSON_POLICY_ROLE
       
,upper(pnd.lname) ::varchar(40) as PERSON_LAST_NAME_OR_TRUST_NAME
,upper(pnd.fname) ::varchar(40) as PERSON_FIRST_NAME
,upper(pnd.mname) ::char(1) as PERSON_MI
,' ' ::char(1) as PERSON_SUFFIX
,pvd.gendercode ::char(1) as PERSON_GENDER
,to_char(pvd.birthdate,'yyyymmdd')::char(8) as PERSON_DOB
,' ' ::char(1) as PERSON_MARITAL_STATUS
,' ' ::char(1) as PERSON_HEIGHT_INCHES
,' ' ::char(1) as PERSON_WEIGHT_POUNDS

,pvd.smoker ::char(1) as TOBACCO_RESPONSE
,' ' ::char(1) as BENEFICIARY_PERCENTAGE
,' ' ::char(1) as filler1
,regexp_replace(coalesce(ppcw.phoneno,ppcb.phoneno,ppcm.phoneno,ppch.phoneno), '[^0-9]', '', 'g') ::varchar(20) AS PRIMARY_PHONE
,replace(pa.streetaddress,',',' ') ::varchar(30) as STREET_ADDRESS
,replace(pa.streetaddress2,',',' ') ::varchar(30) as STREET_ADDRESS2
,pa.city ::varchar(30) as CITY
,pa.stateprovincecode ::char(2) as STATE
,pa.postalcode ::char(5) as ZIP
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(50)  AS EMPLOYEE_EMAIL
,'N' ::char(1)  as ELECTRONIC_DELIVERY  
,case when pc.frequencycode = 'A' then pc.compamount
      when pc.frequencycode = 'H' then (pc.compamount * 2080 )
       end as ANNUAL_SALARY     
,concat('"',dxc.companyname,'"')::varchar(100) as EMPLOYER_ASSOCIATION_NAME   
,replace(lc.locationdescription,',', ' ') ::varchar(30) as LOCATION_DIVISION_NAME  
,to_char(pe.effectivedate,'yyyymmdd')::char(8) as DATE_OF_HIRE
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'yyyymmdd') else ' ' end ::char(8) as TERMINATION_DATE
,pe.emplstatus ::char(1) as EMPLOYMENT_STATUS 
,cast(pp.scheduledhours/2 as int) as HOURS_WORKED  
,' ' ::char(2) as PAY_MODE 
,' ' ::char(1) as filler02
,' ' ::char(1) as filler03
,'G000035653' ::char(10)as GROUP_NUMBER --found in application no idea where this is stored policy# AV00056468/CE0005646
,'D000000001' ::char(10) as DIVISON_NUMBER
,'CA' ::char(2)   as DOMICILE_STATE
,' ' ::char(1) as AGENT_TAX_ID
,'LV9754' ::char(10) as AGENT_NUMBER
,' ' ::char(1) as AGENT_NAME
,' ' ::char(1) as filler04
,'AV'::char(10) as PRODUCT_CODE
,' ' ::char(1) as PRODUCT_MASTER_NO
,'ALLEMPLOYEES' ::char(15) as CLASS_TYPE    
-- select * from benefit_plan_desc where benefitsubclass = '1AC'

,case when pbe.benefitplanid = '85' then 'PLAN1'
      when pbe.benefitplanid = '88' then 'PLAN2'
      else ' ' END  ::char(10) as PLAN_CODE 

,case when pbe.benefitsubclass = 'CIV' and pbe.benefitplanid in ('136','112') then 'EO'
      when pbe.benefitsubclass = 'CIV' and pbe.benefitplanid in ('139','142') then 'EC'
      when pbe.benefitsubclass = 'CIV' and pbe.benefitplanid in ('145','148') then 'FA'           
      else 'EO' end ::char(2) as COVERAGE_TIER       

, pbe.coverageamount as BENEFIT_FACE_AMOUNT
, ' ' ::char(10) as filler05
, ' ' ::char(1) as filler06
, ' ' ::char(1) as filler07
, ' ' ::char(1) as INPATIENT_BENEFIT_LEVEL
, ' ' ::char(1) as UNDERLYING_DEDUCTIBLE
, ' ' ::char(1) as filler08
, ' ' ::char(1) as filler09
, ' ' ::char(1) as filler10
, ' ' ::char(1) as filler11
, ' ' ::char(1) as filler12
, ' ' ::char(1) as EMP_OPTION1_CODE
, ' ' ::char(1) as EMP_OPTION1_DETAIL
, ' ' ::char(1) as EMP_OPTION2_CODE
, ' ' ::char(1) as EMP_OPTION2_DETAIL
, ' ' ::char(1) as EMP_OPTION3_CODE
, ' ' ::char(1) as EMP_OPTION3_DETAIL
, ' ' ::char(1) as EMP_OPTION4_CODE
, ' ' ::char(1) as EMP_OPTION4_DETAIL
, ' ' ::char(1) as EMP_OPTION5_CODE
, ' ' ::char(1) as EMP_OPTION5_DETAIL
, ' ' ::char(1) as EMP_OPTION6_CODE
, ' ' ::char(1) as EMP_OPTION6_DETAIL
, ' ' ::char(1) as filler13
 
-- 85 Accident 1, 88 - Accident 2, 148 - Crit Ill EE2 NonTob    
,pbe.monthlyamount ::char(5) as TOTAL_PREMIUM

,pbe.monthlyamount ::char(5) as EE_PAID_PREMIUM

,cast(poc.employercost as decimal(18,2)) as ER_PAID_PREMIUM
,'12' ::char(2) as PREMIUM_MODE
,to_char(pbe.effectivedate,'YYYYMMDD') ::char(8) as COVERAGE_EFFECTIVE_DATE
,to_char(pbe.effectivedate,'YYYYMMDD') ::char(8) as DATE_OF_ELECTION
,pa.city ::varchar(40) ENROLLMENT_CITY
,'CA'::char(2) as ENROLLMENT_STATE
,' ' ::char(1) as ENROLLMENT_TYPE
,' ' ::char(1) as filler14
,case when pbe.effectivedate = pbe.createts then 'N'
      when pbe.benefitelection = 'T' then 'T'
      when pbe.benefitelection = 'W' then 'D' else 'C' end ::char(1) as ACTION_TYPE_CODE
,' ' ::char(1) as CHANGE_EVENT_TYPE
,' ' as CHANGE_EVENT_DATE
,' ' as EXISTING_POLICY_NUMBER
,' ' ::char(1) as filler15
,' ' ::char(1) as REMARKS
,' ' ::char(1) as QUESTION_DETAILS
,' ' ::char(1) as WORKERS_COMP_RESPONSE
,' ' ::char(1) as DRIVERS_LICENSE_RESPONSE
,' ' ::char(1) as OUTLINE_OF_COVERAGE_RESPONSE
,' ' ::char(1) as ILLUSTRATION_CERT_RESPONSE
,' ' ::char(1) as EXIST_REPLACE_INSURACE_RESPONSE
,' ' ::char(1) as EXIST_REPLACE_INSURACE_DETAILS
,' ' ::char(1) as PRODUCER_STATEMENT_EXIST_REPLACE
,' ' ::char(1) as DECLINED_HEALTH_COVERAGE
,' ' ::char(1) as EXISTING_LTC
,' ' ::char(1) as UNINTENDED_LAPSE_DESIGNATION
,' ' ::char(1) as DISCLOSURE1_CODE
,' ' ::char(1) as DISCLOSURE1_RESPONSE
,' ' ::char(1) as DISCLOSURE2_CODE
,' ' ::char(1) as DISCLOSURE2_RESPONSE
,' ' ::char(1) as DISCLOSURE3_CODE 
,' ' ::char(1) as DISCLOSURE3_RESPONSE
,' ' ::char(1) as DISCLOSURE4_CODE
,' ' ::char(1) as DISCLOSURE4_RESPONSE
,' ' ::char(1) as AIDS_RESPONSE
,' ' ::char(1) as HOSPTIALIZE_RESPONSE
,' ' ::char(1) as DIAGNOSIS_DISEASE_RESPONSE
,' ' ::char(1) as HBP_MED_RESPONSE
,' ' ::char(1) as MED_TREATMENT_RESPONSE
,' ' ::char(1) as CANCER_RESPONSE
,' ' ::char(1) as TRANSPLANT_BIOPSY_RESPONSE
,' ' ::char(1) as filler16
,' ' ::char(1) as filler17
,' ' ::char(1) as filler18
,' ' ::char(1) as filler19
,' ' ::char(1) as filler20
,' ' ::char(1) as filler21
,' ' ::char(1) as filler22
,' ' ::char(1) as filler23
,' ' ::char(1) as filler24
,' ' ::char(1) as filler25       
 
from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 
left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.selectedoption = 'Y'
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('CIV') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 

left join personbenoptioncostl poc 
  on costsby = 'P'
 and poc.personbeneelectionpid = pbe.personbeneelectionpid

left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
left join person_phone_contacts ppcw 
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 
 and ppcw.phonecontacttype = 'Work'   
left join person_phone_contacts ppcb 
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'      
left join person_phone_contacts ppcm 
  on ppcm.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile' 
 
left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate 
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate      
left join person_net_contacts pnco 
  on pnco.personid = pi.personid 
 and pnco.netcontacttype = 'OtherEmail'::bpchar 
 and current_date between pnco.effectivedate and pnco.enddate
 and current_timestamp between pnco.createts and pnco.enddate   

left join dxcompanyname dxc on 1=1
 and current_date between dxc.effectivedate and dxc.enddate
 and current_timestamp between dxc.createts and dxc.endts

left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate 
 and current_timestamp between pl.createts and pl.endts
 
left join location_codes lc
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts  
  
 
----- DEPENDENT DATA

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 ---and pdr.dependentrelationship in ('SP','C','S','DP','D')
 
left join person_identity piDep
  on piDep.personid = pdr.dependentid
 and piDep.identitytype = 'SSN'
 and current_timestamp between piDep.createts and piDep.endts 
 
left join person_names pnd
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts
 and pnd.nametype = 'Dep'

left join person_vitals pvd
  on pvd.personid = piDep.personid
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts    

left join 
(select distinct
 pbe.personid
,c.d_ind
,s.d_ind
,case when c.d_ind is not null and s.d_ind is not null then 'FA'  
      when c.d_ind is null and s.d_ind is not null then 'ES'  
      when c.d_ind is not null and s.d_ind is null then 'EC' end ::char(2) as cvg
 from person_bene_election pbe 
left join (select distinct pdr.personid, pdr.dependentrelationship, pdr.dependentid, 'child' as d_ind                 
  from person_dependent_relationship pdr
 where pdr.dependentrelationship in ('S','D','C')) c on c.personid = pbe.personid
left join (select distinct pdr.personid, pdr.dependentrelationship, pdr.dependentid,'spouse' as d_ind         
  from person_dependent_relationship pdr
 where pdr.dependentrelationship in ('SP','DP')) s on s.personid = pbe.personid 
 where pbe.benefitsubclass in ('CIV') and pbe.selectedoption = 'Y' and pbe.benefitelection in ('E')) fcvgtier  on fcvgtier.personid = pbe.personid         
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
  and pbe.benefitelection = 'E' 
  and pbe.benefitsubclass in ('CIV') 
  --and pbe.benefitplanid in ('145','148')   
  and pdr.dependentrelationship in ('SP','DP')
  --and pe.personid = '2185'