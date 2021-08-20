SELECT distinct
--- fixed enrollment date 2-3-2017
pi.personid,
'Capps, Inc./Rausch, Sturm, Israel, Enerson & Hornik, LLC' ::char(100)                             AS clientname,
case pu.payunitdesc when 'Capps' then 'CAPPS, Inc.' 
                    when 'RSIEH' then 'RSIEH, LLC'
                    when 'GW Financial' then 'GW Financial, LLC'
                    when 'Enerson' then 'Enerson Law, LLC' end ::char(50)                          AS clientDivisionName,


pi.identity ::char(9)                                                                              AS SSN,
' ' ::char(35)                                                                                     AS Salutation,   
 
rtrim(ltrim(pn.fname))::char(50)                                                                   AS FirstName,
coalesce(rtrim(ltrim(upper(substring(pn.mname from 1 for 1)))),'') ::char(1)                       AS MiddleInitial,
rtrim(ltrim(pn.lname)) ::char(50)                                                                  AS LastName,
' ' ::char(20)                                                                                     AS IndividualIdentifier,

cast((case when pa.streetaddress2 is null then trim(both ' ' from pa.streetaddress)
           else pa.streetaddress || ' ' || pa.streetaddress2 end ) as varchar(50))  AS Address1,
' ' ::char(50) AS Address2,            

rtrim(ltrim(pa.city)) ::char(50)                                                                   AS City,
rtrim(ltrim(pa.stateprovincecode)) ::char(50)                                                      AS StateOrProvince,
rtrim(ltrim(pa.postalcode)) ::char(35)                                                             AS PostalCode,
case pa.countrycode when 'US' then ' ' else pa.countrycode end ::char(50)                          AS Country,

rtrim(ltrim(ppcm.phoneno::character varying(10))) ::char(10)                 AS Phone1,
rtrim(ltrim(ppch.phoneno::character varying(10))) ::char(10)                 AS Phone2,

coalesce(rtrim(ltrim(pnc.url)),'')::char(100)                                                      AS Email,
rtrim(ltrim(pv.gendercode))::char(1)                                                               AS Sex,
to_char(pv.birthdate, 'MM/dd/YYYY')::char(10)                                                      AS DOB,

'UNKNOWN' ::char(35)                                                                               AS TobaccoUse,
'UNKNOWN' ::char(35)                                                                               AS EmployeeType,
'UNKNOWN' ::char(35)                                                                               AS EmployeePayrollType,

pep.years_of_service                                                                               AS YearsOfService, 
'COUPONBOOK' ::char(35)                                                                            AS PremiumCouponType, 
' ' ::char(5)                                                                                      AS UsesHCTC, 
' ' ::CHAR(50)                                                                                     AS BenefitGroup,
' ' ::char(50)                                                                                     AS AccountStructure,
' ' ::char(50)                                                                                     AS ClientCustomData,
case pe.emplevent 
    when 'InvTerm' then 'INVOLUNTARYTERMINATION' 
    when 'VolTerm' then 'TERMINATION'
    when 'Divorce' then 'DIVORCELEGALSEPARATION'
    when 'Retire' then 'RETIREEBANKRUPTCY'
   --- Note eHCM values for the following conditions are unknown - so defaulting the following to drop-downs values in cobrapoint spreadsheet    
    when 'REDUCTIONINFORCE'  then 'REDUCTIONINFORCE'
    when 'BANKRUPTCY' then 'BANKRUPTCY'
    when 'STATECONTINUATION' then 'STATECONTINUATION'
    when 'LOSSOFELIGIBILITY' then 'LOSSOFELIGIBILITY' 
    when 'REDUCTIONINHOURS-ENDOFLEAVE' then 'REDUCTIONINHOURS-ENDOFLEAVE'
    when 'WORKSTOPPAGE' then 'WORKSTOPPAGE'
    when 'USERRA-TERMINATION' then 'USERRA-TERMINATION'
    when 'USERRA-REDUCTIONINHOURS' then 'USERRA-REDUCTIONINHOURS'
    when 'TERMINATIONWITHSEVERANCE' then 'TERMINATIONWITHSEVERANCE'
    else 'UNKNOWN' end ::char(35)                                                                  AS eType,


case pe.emplevent when 'Divorce' then pn.fname||' '||pn.lname 
                  when 'Ineligible Dependent' then pn.fname||' '||pn.lname 
                  when 'Death' then pn.fname||' '||pn.lname 
                  when 'Medicare' then pn.fname||' '||pn.lname else ' ' end ::char(100)           AS etypeEmpName,
                   
case pe.emplevent when 'Divorce' then pi.identity 
                  when 'Ineligible Dependent' then pi.identity 
                  when 'Death' then pi.identity 
                  when 'Medicare' then pi.identity 
                  else ' ' end ::char(9)                                                          AS etypeEmpSSN,                    

                   
to_char(pe.paythroughdate,'MM/DD/YYYY') ::char(10)                                                 AS QEventDate,
to_char(pe.emplhiredate,'MM/DD/YYYY') ::char(10)                                                   AS EnrollmentDate,

                      
' ' ::char(5)                                                                                      AS IsLegacy,
' ' ::CHAR(10)                                                                                     AS RightsDate,
' ' ::CHAR(10)                                                                                     AS PostmarkDate,
' ' ::CHAR(10)                                                                                     AS NextPremiumDate,
' ' ::char(4)                                                                                      AS NextPremiumYear,
' ' ::char(5)                                                                                      AS SendTakeOverLetter,
' ' ::char(5)                                                                                      AS IsConversionLetterSent,
' ' ::char(5)                                                                                      AS IsSecondEvent,
' ' ::CHAR(10)                                                                                     AS SecondEventOrigFDOC,
' ' ::char(5)                                                                                      AS IsDisabilityApproved,
' ' ::CHAR(10)                                                                                     AS DisabilityExtPMDate,
' ' ::CHAR(10)                                                                                     AS DisabilityExtDisableDate,
' ' ::char(5)                                                                                     AS AllowMemberSSO

FROM person_identity pi
     
JOIN edi.edi_last_update elu on elu.feedID = 'RSI_DBS_COBRA_QB_Feed'  --- elu.lastupdatets

JOIN person_employment pe 
  ON pe.personid = pi.personid 
 AND current_date between pe.effectivedate AND pe.enddate 
 AND current_timestamp between pe.createts AND pe.endts

JOIN person_bene_election pbe 
  on pbe.personid = pe.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitsubclass in ('10','11','14','1Y')
 AND current_date between pbe.effectivedate AND pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts

   -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','1Y') and benefitelection = 'E' and selectedoption = 'Y'
                         and date_part('year',planyearenddate) = date_part('year',current_date))
 

 
LEFT JOIN comp_plan_benefit_plan cpbp 
  on cpbp.benefitsubclass = pbe.benefitsubclass
 AND current_date between cpbp.effectivedate AND cpbp.enddate 
 AND current_timestamp between cpbp.createts AND cpbp.endts 
         
LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts

LEFT JOIN person_address pa 
  ON pa.personid = pi.personid 
 AND pa.addresstype = 'Res'::bpchar 
 AND current_date between pa.effectivedate AND pa.enddate 
 AND current_timestamp between pa.createts AND pa.endts

LEFT JOIN person_vitals pv 
  ON pv.personid = pi.personid 
 AND current_date between pv.effectivedate AND pv.enddate 
 AND current_timestamp between pv.createts AND pv.endts     

LEFT JOIN person_phone_contacts ppch 
 ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'
LEFT JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'   
LEFT JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'      
LEFT JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'  
 
LEFT JOIN person_net_contacts pnc 
  ON pnc.personid = pi.personid 
 AND pnc.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnc.effectivedate AND pnc.enddate 
 AND current_timestamp between pnc.createts AND pnc.endts
  
LEFT JOIN person_payroll ppay 
  ON ppay.personid = pi.personid 
 AND current_date between ppay.effectivedate AND ppay.enddate 
 AND current_timestamp between ppay.createts AND ppay.endts 
 
LEFT JOIN pay_unit pu 
  ON pu.payunitid = ppay.payunitid
  
LEFT JOIN pspay_employee_profile pep 
  ON pep.individual_key = pi.identity

where pi.identitytype = 'SSN' 
  AND current_timestamp between pi.createts AND pi.endts  
  and cpbp.cobraplan = 'Y' 
  and pe.emplstatus = 'T'
  
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
   --and pi.personid = '497'

order by 1,2   
                
     