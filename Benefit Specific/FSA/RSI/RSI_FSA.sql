SELECT distinct
 pi.personid
,replace(pu.employertaxid,'-','')         AS "Client Federal Id"
,pi.employeessn           AS "Participant Id"
,'1'                      AS "Participant Id Identifier Type"
,pi.firstname             AS "First Name"
,left(pi.middlename,1)    AS "Middle Initial"
,pi.lastname              AS "Last Name"
,replace(pi.streetaddress1,',','') 	 AS "Address 1"
,replace(pi.streetaddress2, ',','')  AS "Address 2"
,pi.city                  AS "City"
,pi.statecode             AS "State"
,pi.zipcode               AS "Zip Code"
,pi.emailaddress          AS "Email Address"
,to_char(pi.birthdate,'mm/dd/yyyy') AS "Date of Birth"
,pi.homephone             AS "Phone"

,CASE pu.frequencycode 
   WHEN 'BM' THEN 'B'
   WHEN 'S' THEN 'B'
   ELSE pu.frequencycode 
 END                      AS "Payroll Mode"
,to_char(coalesce(pbefsa.createts,pbedfsa.createts),'mm/dd/yyyy') AS "Enrollment Date"

,replace(ro.org2desc,',','')              AS "Location"
,CASE coalesce(pbefsa.benefitsubclass,pbedfsa.benefitsubclass)
   WHEN '61' THEN '1'
   WHEN '60' THEN '2'
 END                      AS "Plan Type Id"

,CASE WHEN coalesce(pbefsa.benefitelection,pbedfsa.benefitelection) = 'T' 
        THEN to_char(pbe1.effectivedate,'mm/dd/yyyy') 
      ELSE 
        to_char(coalesce(pbefsa.effectivedate,pbedfsa.effectivedate),'mm/dd/yyyy') 
      END 				AS "Enrollment Effective Date"
,to_char(coalesce(pbefsa.effectivedate,pbedfsa.effectivedate),'mm/dd/yyyy') AS "Effective Posting Date"
,to_char(poc.employeerate,'9999.99')     AS "Pay Period Amount"
,CASE WHEN coalesce(pbefsa.benefitelection,pbedfsa.benefitelection) = 'T'
        THEN 
            pbe1.coverageamount       
        ELSE 
            coalesce(pbefsa.coverageamount,pbedfsa.coverageamount)      
        END 			   AS "Annual Election"
,'1'                      AS "Funding Type"
,''                       AS "Employer Coverage Type Id"
,CASE
   WHEN coalesce(pbefsa.benefitelection,pbedfsa.benefitelection) = 'T' 
     THEN to_char(coalesce(pbefsa.deductionenddate,pbedfsa.deductionenddate),'mm/dd/yyyy')   
   ELSE NULL
 END                      AS "Benefit Termination Date"
,''                       AS "Cobra Effective Date"
,''                       AS "Cobra Termination Date"
,''                       AS "Participant Other Id"
,'0'                      AS "DebitCardEnrollment"
,'0'                      AS "AutoReimbursement"
,''                       AS "DD-Routing Number"
,''                       AS "DD-Account Number"
,''                       AS "DD-Account Type"
,'0'                      AS "Enrolled in HSA"
,'0'                      AS "Post Deductible Coverage"

,elu.feedid               AS feedid
,CURRENT_TIMESTAMP        AS updatets

FROM asof

JOIN edi.edi_last_update elu
  ON elu.feedid = 'RSI_DBS_FSA_Enrollment'

JOIN person_bene_election pbe
  ON pbe.benefitsubclass in ('60','61')
 AND pbe.effectivedate < pbe.enddate
 AND CURRENT_TIMESTAMP BETWEEN pbe.createts and pbe.endts
 
 
left join person_bene_election pbefsa
  on pbefsa.personid = pbe.personid 
 and pbefsa.benefitelection <> 'W'
 and pbefsa.selectedoption = 'Y'
 and pbefsa.benefitsubclass in ('60')
 and current_date between pbefsa.effectivedate and pbefsa.enddate
 and current_timestamp between pbefsa.createts and pbefsa.endts  
 and pbefsa.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  

left join person_bene_election pbedfsa
  on pbedfsa.personid = pbe.personid 
 and pbedfsa.benefitelection <> 'W'
 and pbedfsa.selectedoption = 'Y'
 and pbedfsa.benefitsubclass in ('61')
 and current_date between pbedfsa.effectivedate and pbedfsa.enddate
 and current_timestamp between pbedfsa.createts and pbedfsa.endts 
 and pbedfsa.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  
 
LEFT JOIN person_bene_election pbe1
  ON pbe1.personid = pbe.personid
 AND pbe1.personbeneelectionpid =
   (SELECT MAX(pbe2.personbeneelectionpid)
      FROM person_bene_election pbe2
     WHERE pbe2.personid = pbe1.personid
       AND pbe2.benefitsubclass in ('60','61')
       AND pbe2.benefitelection = 'E') 

JOIN edi.etl_personal_info pi
  ON pi.personid = pbe.personid
  
JOIN edi.etl_employment_data ed
  ON ed.personid = pbe.personid

LEFT JOIN edi.etl_employment_term_data etd
   ON etd.personid = pbe.personid

LEFT JOIN personbenoptioncostl poc 
  ON poc.personid              = pbe.personid
 AND ((poc.personbeneelectionpid = pbefsa.personbeneelectionpid) or (poc.personbeneelectionpid = pbedfsa.personbeneelectionpid))
 AND poc.costsby = 'P'   
 AND poc.employeerate > 0

LEFT JOIN person_payroll pp
  ON pp.personid = pi.personid
 AND now() between pp.effectivedate AND pp.enddate
 AND now() between pp.createts      AND pp.endts
LEFT JOIN pay_unit pu 
  ON pu.payunitid = pp.payunitid       

LEFT JOIN pos_org_rel por
  ON por.positionid = COALESCE(ed.positionid, etd.positionid)
 AND now() between por.effectivedate AND por.enddate
 AND now() between por.createts AND por.endts
 AND por.posorgreltype = 'Member'

LEFT JOIN edi.orgstructure ro
  ON ro.org1id = por.organizationid  

WHERE date_part('year',pbe.effectivedate) = '2018'
  and poc.employeerate is not null


order by 1,3,4
--WHERE asof.asofdate = CURRENT_DATE;