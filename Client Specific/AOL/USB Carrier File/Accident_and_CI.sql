select distinct
  pi.personid 
, pdr.dependentid 
, 'WIJ4FD6L' ::char(8)              as EDI_ACCOUNT_ID
--•	CORRELATION_GUID – this value must be both employee and product distinct. Currently, 
--we are seeing the same value for the employee regardless of the product code.
----, 'WIJ4FD6L'||pi.personid||pdr.dependentid ::char(20)    as CORRELATION_GUID
/*, case when pdr.dependentid is null then 'WIJ4FD6L'||pi.personid||piE.identity||pbe.benefitsubclass 
       when pdr.dependentid is not null then 'WIJ4FD6L'||pi.personid||pdr.dependentid||pbe.benefitsubclass 
       end
*/
--,pbe.benefitsubclass 
,case when pbe.benefitsubclass = '1AC' then 'G000035653_'|| pi.identity ||'_AC'
      when pbe.benefitsubclass = 'CIV' then 'G000035653_'|| pi.identity ||'_CE'
      end ::varchar(25) as CORRELATION_GUID

, replace(pi.identity,'-','') ::char(11)          as EMPLOYEE_SSN
, replace(piDep.identity,'-','') ::char(11)       as dep_PERSON_SSN
, piE.identity ::char(11)                          as EMPLOYEE_OR_MEMBER_ID
, 'EMPLOYEE' ::varchar(20)                         as emp_RELATIONSHIP_TO_EMPLOYEE
, case when pdr.dependentrelationship in ('E', null)              then 'EMPLOYEE'
       when pdr.dependentrelationship in ('SP','NA','DP')         then 'SPOUSE'
       when pdr.dependentrelationship in ('D','S','C','FC','GC')  then 'DEPENDENT'
       when pdr.dependentrelationship in ('FA','M')               then 'PARENT'
       when pdr.dependentrelationship in ('$T')                   then 'ESTATE'
       when pdr.dependentrelationship in ('$F')                   then 'TRUST'
       when pdr.dependentrelationship in ('SB','SI','B')          then 'SIBLING'
       when pdr.dependentrelationship in ('GF','GM','GP')         then 'GRANDPARENT'
       when pdr.dependentrelationship in ('X','XN')               then 'EXSPOUSE'
                                                                  else 'OTHER'
       end ::varchar(20)                           as dep_RELATIONSHIP_TO_EMPLOYEE
, 'PRIMARYINSURED'  ::varchar(20)                  as emp_PERSON_POLICY_ROLE      
, pdr.dependentrelationship
, case when pdr.dependentrelationship in ('E', null)              then 'PRIMARYINSURED'
       when pdr.dependentrelationship in ('SP','NA','DP')         then 'SPOUSE'
       when pdr.dependentrelationship in ('D','S','C','FC','GC')  then 'DEPENDENT'
       when b.beneficiaryclass in ('P')                           then 'PRIMARYBENEFICIARY'
        end ::varchar(20)                                   as dep_PERSON_POLICY_ROLE     
  
, upper(pnE.lname) ::varchar(50)                            as emp_PERSON_LAST_NAME_OR_TRUST_NAME
, upper(pnD.lname) ::varchar(50)                            as dep_PERSON_LAST_NAME_OR_TRUST_NAME
, upper(pnE.fname) ::varchar(50)                            as emp_PERSON_FIRST_NAME
, upper(pnD.fname) ::varchar(50)                            as dep_PERSON_FIRST_NAME
, upper(pnE.mname) ::char(1)                                as emp_PERSON_MI
, upper(pnD.mname) ::char(1)                                as dep_PERSON_MI
, upper(pnE.title) ::varchar(10)                            as emp_PERSON_SUFFIX
, upper(pnD.title) ::varchar(10)                            as dep_PERSON_SUFFIX
, upper(pvE.gendercode) ::char(1)                           as emp_PERSON_GENDER
, upper(pvD.gendercode) ::char(1)                           as dep_PERSON_GENDER

, to_char(pvE.birthdate,'YYYYMMDD') ::char(8)      as emp_PERSON_DOB
, to_char(pvD.birthdate,'YYYYMMDD') ::char(8)      as dep_PERSON_DOB

, pmE.maritalstatus ::char(1)                      as emp_PERSON_MARITAL_STATUS
, ' ' ::char(1)                                    as emp_PERSON_HEIGHT_INCHES
, ' ' ::char(1)                                    as emp_PERSON_WEIGHT_POUNDS

, pvE.smoker ::char(1)                             as emp_TOBACCO_RESPONSE
, pvD.smoker ::char(1)                             as dep_TOBACCO_RESPONSE

, pbe.benefitsubclass
, pbe.benefitplanid
, b.beneficiarypercent                             as emp_BENEFICIARY_PERCENTAGE
, ' ' ::char(10)                                   as filler01
, regexp_replace(coalesce(ppcw.phoneno,ppcb.phoneno,ppcm.phoneno,ppch.phoneno), '[^0-9]', '', 'g') ::varchar(20) AS emp_PRIMARY_PHONE
, replace(paE.streetaddress,',', ' ') ::varchar(40)  as emp_STREET_ADDRESS
, replace(paE.streetaddress2,',',' ') ::varchar(40)  as emp_STREET_ADDRESS2
, paE.city ::varchar(40)                           as emp_CITY
, paE.stateprovincecode ::char(2)                  as emp_STATE
, paE.postalcode ::char(10)                        as emp_ZIP
, coalesce(pncw.url,pnch.url,pnco.url) ::varchar(50)  AS EMPLOYEE_EMAIL
, 'N' ::char(1)                                    as ELECTRONIC_DELIVERY  
, pc.frequencycode  
, case 
      when pc.frequencycode = 'A' then pc.compamount
      --when pc.frequencycode = 'H' then (pc.compamount * 2080 * pe.emplfulltimepercent)
      when pc.frequencycode = 'H' then (pc.compamount * 2080 )
      end                           as ANNUAL_SALARY                
, replace(dxc.companyname,',', ' ')   ::varchar(100)    as EMPLOYER_ASSOCIATION_NAME  

, concat('"',dxc.companyname,'"')::varchar(100)    as EMPLOYER_ASSOCIATION_NAME  
, replace(lc.locationdescription,',', ' ') ::varchar(30) as LOCATION_DIVISION_NAME
, to_char(eed.emplhiredate,'YYYYMMDD') ::char(8) as DATE_OF_HIRE
, case when pbe.benefitelection = 'W' then to_char(pbe.effectivedate,'YYYYMMDD')
       when etd.benefitstatus = 'T' then to_char(etd.termdate,'YYYYMMDD')::char(8) end as TERMINATION_DATE
, eed.emplstatus ::char(1) as EMPLOYMENT_STATUS
, cast(eed.scheduledhours/2 as int) as HOURS_WORKED
--, eed.schedulefrequency as PAY_MODE 
, ' ' ::char(2) as PAY_MODE 
, ' ' ::char(1) as filler02
, ' ' ::char(1) as filler03
, 'G000035653' ::char(10)as GROUP_NUMBER --found in application no idea where this is stored policy# AV00056468/CE0005646
, 'D000000001' ::char(10) as DIVISON_NUMBER
, 'CA' ::char(2)   as DOMICILE_STATE
, ' ' ::char(1) as AGENT_TAX_ID
, 'LV9754' ::char(10) as AGENT_NUMBER
, ' ' ::char(1) as AGENT_NAME
, ' ' ::char(1) as filler04
, case when pbe.benefitsubclass = '1AC' then 'AV'
       when pbe.benefitsubclass = 'CIV' then 'CE' end ::char(10) as PRODUCT_CODE
, ' ' ::char(1) as PRODUCT_MASTER_NO
,'ALLEMPLOYEES' ::char(15) as CLASS_TYPE
, case when pbe.benefitplanid = '85' then 'PLAN1'
       when pbe.benefitplanid = '88' then 'PLAN2'
       else 'PLAN1' END  ::char(10) as PLAN_CODE
,bcd.benefitcoveragedesc
,eeb.coverageleveldesc          
, case when bcd.benefitcoveragedesc = 'Employee Only' then 'EO'
       when eeb.coverageleveldesc   = 'Employee Only' then 'EO'
       
       when bcd.benefitcoveragedesc = 'Employee + Spouse' then 'ES'
       when eeb.coverageleveldesc   = 'Employee + Spouse' then 'ES'
       
       when bcd.benefitcoveragedesc = 'Employee + Children' then 'EC'
       when eeb.coverageleveldesc   = 'Employee + Children' then 'EC'
       
       when bcd.benefitcoveragedesc = 'Family'        then 'FA'
       when eeb.coverageleveldesc   = 'Family'        then 'FA'
       
       when pbe.benefitplanid in ('145', '148' ) then 'FA' -- Crit Ill EE2 NonTob corresponds to ci family rate on pdf from vendor w monthly premiumns
       when pdr.dependentrelationship in ('SP','NA','DP')  and pbe.benefitplanid in ('139', '142' ) then 'ES' -- Critical Ill EE1 Tob
       when pdr.dependentrelationship in ('D','S','C','FC','GC')  and pbe.benefitplanid in ('139', '142' ) then 'EC' -- Critical Ill EE1 Tob
       
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
,pbe.benefitplanid   
-- 85 Accident 1, 88 - Accident 2, 148 - Crit Ill EE2 NonTob    
, case when pbe.benefitplanid = '85' and bcd.benefitcoveragedesc = 'Employee Only' then '12.50'  
       when pbe.benefitplanid = '85' and bcd.benefitcoveragedesc = 'Employee + Spouse' then '19.32'  
       when pbe.benefitplanid = '85' and bcd.benefitcoveragedesc = 'Employee + Children' then '14.52'  
       when pbe.benefitplanid = '85' and bcd.benefitcoveragedesc = 'Family' then '21.36'        

       when pbe.benefitplanid = '85' and pdr.dependentrelationship in ('E', null) then '12.50'  
       when pbe.benefitplanid = '85' and pdr.dependentrelationship in ('SP','NA','DP')  then '19.32'  
       when pbe.benefitplanid = '85' and pdr.dependentrelationship in ('D','S','C','FC','GC')  then  '14.52'  
       when pbe.benefitplanid = '85' and bcd.benefitcoveragedesc   is null then '12.50'                 

       when pbe.benefitplanid = '88' and bcd.benefitcoveragedesc = 'Employee Only' then '18.75'  
       when pbe.benefitplanid = '88' and bcd.benefitcoveragedesc = 'Employee + Spouse' then '29.04'  
       when pbe.benefitplanid = '88' and bcd.benefitcoveragedesc = 'Employee + Children' then '23.73'  
       when pbe.benefitplanid = '88' and bcd.benefitcoveragedesc = 'Family' then '34.28'   

       when pbe.benefitplanid = '88' and pdr.dependentrelationship in ('E', null) then '18.75' 
       when pbe.benefitplanid = '88' and pdr.dependentrelationship in ('SP','NA','DP')  then '29.04'  
       when pbe.benefitplanid = '88' and pdr.dependentrelationship in ('D','S','C','FC','GC')  then '23.73'  
       when pbe.benefitplanid = '88' and bcd.benefitcoveragedesc   is null then '18.75'   
       
       when pbe.benefitplanid in ('112','136','139','142','145','148') then pbe.monthlyamount    
       end  ::char(5) as TOTAL_PREMIUM

, case when pbe.benefitplanid = '85' and bcd.benefitcoveragedesc = 'Employee Only' then '12.50'  
       when pbe.benefitplanid = '85' and bcd.benefitcoveragedesc = 'Employee + Spouse' then '19.32'  
       when pbe.benefitplanid = '85' and bcd.benefitcoveragedesc = 'Employee + Children' then '14.52'  
       when pbe.benefitplanid = '85' and bcd.benefitcoveragedesc = 'Family' then '21.36'        
       
       when pbe.benefitplanid = '85' and pdr.dependentrelationship in ('E', null) then '12.50'  
       when pbe.benefitplanid = '85' and pdr.dependentrelationship in ('SP','NA','DP')  then '19.32'  
       when pbe.benefitplanid = '85' and pdr.dependentrelationship in ('D','S','C','FC','GC')  then  '14.52'   
       when pbe.benefitplanid = '85' and bcd.benefitcoveragedesc   is null then '12.50'     

       when pbe.benefitplanid = '88' and bcd.benefitcoveragedesc = 'Employee Only' then '18.75'  
       when pbe.benefitplanid = '88' and bcd.benefitcoveragedesc = 'Employee + Spouse' then '29.04'  
       when pbe.benefitplanid = '88' and bcd.benefitcoveragedesc = 'Employee + Children' then '23.73'  
       when pbe.benefitplanid = '88' and bcd.benefitcoveragedesc = 'Family' then '34.28'   
       
       when pbe.benefitplanid = '88' and pdr.dependentrelationship in ('E', null) then '18.75' 
       when pbe.benefitplanid = '88' and pdr.dependentrelationship in ('SP','NA','DP')  then '29.04'  
       when pbe.benefitplanid = '88' and pdr.dependentrelationship in ('D','S','C','FC','GC')  then '23.73' 
       when pbe.benefitplanid = '88' and bcd.benefitcoveragedesc is null then '18.75'
       when pbe.benefitplanid in ('112','136','139','142','145','148') then pbe.monthlyamount   
       end  ::char(5) as EE_PAID_PREMIUM


              
          
--, cast(poc.employeerate + poc.employercost  as decimal(18,2)) as TOTAL_PREMIUM
--, cast(poc.employeerate as decimal(18,2)) as EE_PAID_PREMIUM
, cast(poc.employercost as decimal(18,2)) as ER_PAID_PREMIUM
, '12' ::char(2) as PREMIUM_MODE
, to_char(pbe.effectivedate,'YYYYMMDD') ::char(8) as COVERAGE_EFFECTIVE_DATE
, to_char(pbe.effectivedate,'YYYYMMDD') ::char(8) as DATE_OF_ELECTION
, paE.city ::varchar(40) ENROLLMENT_CITY
, 'CA' ::char(2) as ENROLLMENT_STATE
, ' ' ::char(1) as ENROLLMENT_TYPE
, ' ' ::char(1) as filler14
, case when pbe.effectivedate = pbe.createts then 'N'
       when pbe.benefitelection = 'T' then 'T'
       when pbe.benefitelection = 'W' then 'D' else 'C' end ::char(1) as ACTION_TYPE_CODE
, ' ' ::char(1) as CHANGE_EVENT_TYPE
, ' ' as CHANGE_EVENT_DATE
, ' ' as EXISTING_POLICY_NUMBER
, ' ' ::char(1) as filler15
, ' ' ::char(1) as REMARKS
, ' ' ::char(1) as QUESTION_DETAILS
, ' ' ::char(1) as WORKERS_COMP_RESPONSE
, ' ' ::char(1) as DRIVERS_LICENSE_RESPONSE
, ' ' ::char(1) as OUTLINE_OF_COVERAGE_RESPONSE
, ' ' ::char(1) as ILLUSTRATION_CERT_RESPONSE
, ' ' ::char(1) as EXIST_REPLACE_INSURACE_RESPONSE
, ' ' ::char(1) as EXIST_REPLACE_INSURACE_DETAILS
, ' ' ::char(1) as PRODUCER_STATEMENT_EXIST_REPLACE
, ' ' ::char(1) as DECLINED_HEALTH_COVERAGE
, ' ' ::char(1) as EXISTING_LTC
, ' ' ::char(1) as UNINTENDED_LAPSE_DESIGNATION
, ' ' ::char(1) as DISCLOSURE1_CODE
, ' ' ::char(1) as DISCLOSURE1_RESPONSE
, ' ' ::char(1) as DISCLOSURE2_CODE
, ' ' ::char(1) as DISCLOSURE2_RESPONSE
, ' ' ::char(1) as DISCLOSURE3_CODE 
, ' ' ::char(1) as DISCLOSURE3_RESPONSE
, ' ' ::char(1) as DISCLOSURE4_CODE
, ' ' ::char(1) as DISCLOSURE4_RESPONSE
, ' ' ::char(1) as AIDS_RESPONSE
, ' ' ::char(1) as HOSPTIALIZE_RESPONSE
, ' ' ::char(1) as DIAGNOSIS_DISEASE_RESPONSE
, ' ' ::char(1) as HBP_MED_RESPONSE
, ' ' ::char(1) as MED_TREATMENT_RESPONSE
, ' ' ::char(1) as CANCER_RESPONSE
, ' ' ::char(1) as TRANSPLANT_BIOPSY_RESPONSE
, ' ' ::char(1) as filler16
, ' ' ::char(1) as filler17
, ' ' ::char(1) as filler18
, ' ' ::char(1) as filler19
, ' ' ::char(1) as filler20
, ' ' ::char(1) as filler21
, ' ' ::char(1) as filler22
, ' ' ::char(1) as filler23
, ' ' ::char(1) as filler24
, ' ' ::char(1) as filler25
from person_identity pi

JOIN edi.etl_employment_data eed
  ON eed.personid = pi.personid

LEFT JOIN edi.etl_employment_term_data etd
   ON etd.personid = pi.personid
   
LEFT JOIN pos_org_rel por
  ON por.positionid = COALESCE(eed.positionid, etd.positionid)
 AND current_date between por.effectivedate AND por.enddate
 AND current_timestamp between por.createts AND por.endts
 AND por.posorgreltype = 'Member'

LEFT JOIN rpt_orgstructure ro
  ON ro.org1id = por.organizationid     

left join dxcompanyname dxc on 1=1
 and current_date between dxc.effectivedate and dxc.enddate
 and current_timestamp between dxc.createts and dxc.endts

left join organization_code oc
  on oc.organizationtype = 'Div'
 and current_date between oc.effectivedate and oc.enddate
 and current_timestamp between oc.createts and oc.endts
left join org_rel orid on orid.memberoforgid = oc.organizationid
 and current_date between orid.effectivedate and orid.enddate
 and current_timestamp between orid.createts and orid.endts
left join organization_code ocD on ocD.organizationid = orid.organizationid
 and current_date between ocD.effectivedate and ocD.enddate
 and current_timestamp between ocD.createts and ocD.endts
 and ocD.organizationtype = 'Dept'
left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate 
 and current_timestamp between pl.createts and pl.endts
left join location_codes lc
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts 

left join person_bene_election pbe
  on pbe.personid = pi.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('1AC', 'CIV')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T', 'E' ,'W')

left join edi.ediemployeebenefit eeb
  on eeb.personid = pi.personid
 and eeb.asofdate = current_date
 and eeb.benefitsubclass = pbe.benefitsubclass 

left join benefit_coverage_desc bcd 
  on pbe.benefitcoverageid = bcd.benefitcoverageid 
 and current_date between bcd.effectivedate and bcd.enddate
 and current_timestamp between bcd.createts and bcd.endts 

join person_identity piP 
  on piP.personid = pi.personid
 and current_timestamp between piP.createts and piP.endts
 and piP.identitytype = 'PSPID'
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
JOIN person_identity piE
  on piE.personid = pi.personid
 and current_timestamp between piE.createts and piE.endts
 and piE.identitytype = 'EmpNo' 

join person_names pnE
  on pnE.personid = pi.personid
 and current_date between pnE.effectivedate and pnE.enddate
 and current_timestamp between pnE.createts and pnE.endts
 and pnE.nametype = 'Legal'
 
join person_address paE
  on paE.personid = pi.personid
 and paE.addresstype = 'Res'
 and current_date between paE.effectivedate and paE.enddate
 and current_timestamp between paE.createts and paE.endts
      
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
 
LEFT JOIN person_net_contacts pnco ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'OtherEmail'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.enddate   

left join personbenoptioncostl poc 
  on costsby = 'P'
 and poc.personbeneelectionpid = pbe.personbeneelectionpid


join person_vitals pvE
  on pvE.personid = pi.personid
 and current_date between pvE.effectivedate and pvE.enddate
 and current_timestamp between pvE.createts and pvE.endts 

left join person_maritalstatus pmE
  on pmE.personid = pi.personid
 and current_date between pmE.effectivedate and pmE.enddate
 and current_timestamp between pmE.createts and pmE.endts
 
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
  
--=======================================================--

left join person_dependent_relationship pdr
  on pdr.personid = pi.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

left join person_identity piDep
  on piDep.personid = pdr.dependentid
 and piDep.identitytype = 'SSN'
 and current_timestamp between piDep.createts and piDep.endts 
 
left join person_names pnD
  on pnD.personid = pdr.dependentid
 and current_date between pnD.effectivedate and pnD.enddate
 and current_timestamp between pnE.createts and pnD.endts
 and pnD.nametype = 'Dep'

left join beneficiary b
  on b.personid = pi.personid
 and current_date between b.effectivedate and b.enddate
 and current_timestamp between b.createts and b.endts
 and b.benefitsubclass in 
    (select benefitsubclass from beneficiary 
      where current_date between effectivedate and enddate
        and current_timestamp between createts and endts
        and benefitsubclass in ('1AC', 'CIV')
      group by 1)
 
left join person_vitals pvD
  on pvD.personid = piDep.personid
 and current_date between pvD.effectivedate and pvD.enddate
 and current_timestamp between pvD.createts and pvD.endts  
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts  
  and pbe.benefitsubclass in ('1AC', 'CIV')
  and pi.personid in ('2001')
  
  order by 1