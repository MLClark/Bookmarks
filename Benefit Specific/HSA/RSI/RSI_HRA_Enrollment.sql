--==================================================================================
/* 
   PARTICIPANTS
*/
--==================================================================================

SELECT distinct
 pi.personid
,replace(pu.employertaxid,'-','')       AS "Client Federal Id"
,'0'                      		AS "Plan Year Id"
,pi.employeessn           		AS "Participant Id"
,'1'                      		AS "Participant Id Identifier Type"
,''                       		AS "Dependent Id"
,pi.firstname             		AS "First Name"
,coalesce(left(pi.middlename,1),'') 	AS "Middle Initial"
,pi.lastname              		AS "Last Name"
,to_char(pi.birthdate,'mm/dd/yyyy') 	AS "Date of Birth"
,coalesce(pi.homephone,'')          	AS "Phone"
,replace(pi.streetaddress1,',','')  	AS "Address 1"
,coalesce(replace(pi.streetaddress2,',',''),'')  AS "Address 2"
,pi.city                  		AS "City"
,pi.statecode             		AS "State"
,pi.zipcode               		AS "Zip Code"
,coalesce(pi.emailaddress,'')          	AS "Email Address"
,bpd.benefitplancode      		AS "Enroll Plan Type Id"
,case bcd.benefitcoveragedescshort when 'Empl Only' then 'Single' when 'Family' then 'Family' else 'EE+1' end AS "Enroll Coverage Type Id"
,CASE WHEN pbe.benefitelection = 'T'::bpchar THEN to_char(pbe3.effectivedate,'mm/dd/yyyy') ELSE to_char(pbe.effectivedate,'mm/dd/yyyy') END as "Effective Date"
,CASE WHEN pbe.benefitelection = 'T'::bpchar THEN to_char(pbe.effectivedate,'mm/dd/yyyy') ELSE '' END AS "Termination or Retirement Date"
,''                       		AS "Cobra or Retirement Effective Date"
,''                       		AS "Cobra or Retirement Termination Date"
,''                       		AS "OtherID"
,replace(ro.org2desc,',','') 		AS "Location"
,''                       		AS "AddPostingCode"
,''                       		AS "AddPostingDescription"
,''                       		AS "AddPostingAmount"
,''                       		AS "AddPostingEffectiveDate"
,'0'                      		AS "DebitCardEnrollment"
,'0'                      		AS "AutoReimbursement"
,'0'                      		AS "Medicare Eligible"
,''                       		AS "ESRD"
,pi.gendercode            		AS "Gender"
,'0'                      		AS "Relationship"
,''                       		AS "HIC Number"
,'0'                      		AS "Coordination of Benefits"
,CASE pe.emplevent WHEN 'Retire'  THEN '2' WHEN 'VolTerm' THEN '1' WHEN 'InvTerm' THEN '1' ELSE ''  END AS "Termination Reason"
,'RSI_DBS_HRA_Enrollment'     AS feedid
,CURRENT_TIMESTAMP        		AS updatets

FROM person_bene_election pbe

--- This second pbe join ensures we are reporting on med participant
join 
    ( SELECT pbe2.personid,max(pbe2.personbeneelectionpid) as personbeneelectionpid

      FROM person_bene_election pbe2
           where pbe2.benefitsubclass in ('10', '1Y') 
             AND pbe2.benefitactioncode = 'E'
             and pbe2.benefitelection in ('E', 'T')
             AND pbe2.effectivedate < pbe2.enddate
             AND current_timestamp between pbe2.effectivedate and pbe2.enddate
       group by 1
       ) max_pid 

  on max_pid.personid = pbe.personid
 and max_pid.personbeneelectionpid = pbe.personbeneelectionpid


JOIN benefit_plan_desc bpd
  ON bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts

JOIN benefit_coverage_desc bcd ----- if this is turned into a join all rows w/o enroll cov typ id are dropped
  ON bcd.benefitcoverageid = pbe.benefitcoverageid 
 AND current_date between bcd.effectivedate and bcd.enddate  
 AND current_timestamp between bcd.createts AND bcd.endts 

JOIN edi.etl_personal_info pi
  ON pi.personid = pbe.personid
  
JOIN edi.etl_employment_data ed
  ON ed.personid = pbe.personid

LEFT JOIN person_payroll pp
  ON pp.personid = pi.personid
 AND now() between pp.effectivedate AND pp.enddate
 AND now() between pp.createts      AND pp.endts
LEFT JOIN pay_unit pu 
  ON pu.payunitid = pp.payunitid     

LEFT JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts
LEFT JOIN pos_org_rel por
  on por.positionid = ed.positionid
 AND now() between por.effectivedate AND por.enddate
 AND now() between por.createts AND por.endts
 AND por.posorgreltype = 'Member'

LEFT JOIN edi.orgstructure ro
  ON ro.org1id = por.organizationid   

---- Added this join to be able to determine effective date of the enrollment vs effective date of termination.

     LEFT JOIN LATERAL ( SELECT pbe2.personid,pbe2.benefitcoverageid,max(pbe2.effectivedate) AS effectivedate
           FROM person_bene_election pbe2
          WHERE pbe2.personid = pbe.personid 
            AND pbe2.benefitplanid = pbe.benefitplanid 
            AND pbe2.benefitelection = 'E'::bpchar 
            AND pbe2.selectedoption = 'Y'::bpchar 
            AND pbe2.enddate < '2199-12-31'::date 
            AND pbe2.effectivedate < pbe2.enddate
            AND now() >= pbe2.createts 
            AND now() <= pbe2.endts
          GROUP BY pbe2.personid, pbe2.benefitcoverageid) pbe3 ON true  

where pbe.benefitsubclass in ('10', '1Y') AND pbe.effectivedate < pbe.enddate AND pbe.benefitactioncode = 'E' and pbe.benefitelection in ('E', 'T') AND current_timestamp between pbe.effectivedate and pbe.enddate 
and date_part('year',pbe.effectivedate) >= '2015'



union


--==================================================================================
/* 
  DEPENDENTS 
*/
--==================================================================================
SELECT DISTINCT
 pi.personid
,replace(pu.employertaxid,'-','')       AS "Client Federal Id"
,'0' AS "Plan Year Id"
,pi.employeessn  AS "Participant Id"
,'1' AS "Participant Id Identifier Type"
,coalesce(edd.dependentssn,'')      	AS "Dependent Id"
,edd.dependentfirstname             	AS "First Name"
,coalesce(left(edd.dependentmiddlename,1),'') AS "Middle Initial"
,edd.dependentlastname              	AS "Last Name"
,to_char(edd.birthdate,'mm/dd/yyyy') 	AS "Date of Birth"
,coalesce(edd.homephone,'')          	AS "Phone"
,replace(edd.streetaddress1,',','')   AS "Address 1"
,coalesce(replace(edd.streetaddress2,',',''),'')          AS "Address 2"
,edd.city AS "City"
,edd.statecode AS "State"
,edd.zipcode AS "Zip Code"
,coalesce(edd.emailaddress,'') AS "Email Address"
,bpd.benefitplancode AS "Enroll Plan Type Id"
,case bcd.benefitcoveragedescshort when 'Empl Only' then 'Single' when 'Family'    then 'Family' else 'EE+1' end AS "Enroll Coverage Type Id"
---- 9/26/2016 modified effective and termination logic - using logic from edi.ediemployeebenefit to determine which date should be used.
,CASE WHEN pbe.benefitelection = 'T'::bpchar THEN to_char(pbe3.effectivedate,'mm/dd/yyyy') ELSE to_char(pbe.effectivedate,'mm/dd/yyyy') END as "Effective Date"
,CASE WHEN pbe.benefitelection = 'T'::bpchar THEN to_char(pbe.effectivedate,'mm/dd/yyyy') ELSE '' END AS "Termination or Retirement Date"
,'' AS "Cobra or Retirement Effective Date"
,'' AS "Cobra or Retirement Termination Date"
,'' AS "OtherID"
,'' AS "Location"
,'' AS "AddPostingCode"
,'' AS "AddPostingDescription"
,'' AS "AddPostingAmount"
,'' AS "AddPostingEffectiveDate"
,'0' AS "DebitCardEnrollment"
,'0' AS "AutoReimbursement"
,'0' AS "Medicare Eligible"
,''  AS "ESRD"
,edd.gendercode AS "Gender"
--
,CASE when edd.dependentrelationshipid = 'SP' THEN '1' 
      when edd.dependentrelationshipid in ('C','D','S') THEN '2' 
      when edd.dependentrelationshipid = 'DP' THEN '3'  ELSE '4' END AS "Relationship"
,'' AS "HIC Number"
,'0' AS "Coordination of Benefits"
,CASE pe.emplevent WHEN 'Retire'  THEN '2' WHEN 'VolTerm' THEN '1' WHEN 'InvTerm' THEN '1' ELSE '' END AS "Termination Reason"
,'RSI_DBS_HRA_Enrollment'     AS feedid
,CURRENT_TIMESTAMP        		AS updatets

FROM person_bene_election pbe 

join 
    ( SELECT pbe2.personid,max(pbe2.personbeneelectionpid) as personbeneelectionpid

      FROM person_bene_election pbe2
           where pbe2.benefitsubclass in ('10', '1Y') 
             AND pbe2.benefitactioncode = 'E'
             and pbe2.benefitelection in ('E', 'T')
             AND pbe2.effectivedate < pbe2.enddate
       --AND pbe2.createts  BETWEEN elu.lastupdatets and asof.asofdate
             AND current_timestamp between pbe2.effectivedate and pbe2.enddate
       group by 1
       ) max_pid 

  on max_pid.personid = pbe.personid
 and max_pid.personbeneelectionpid = pbe.personbeneelectionpid
 
JOIN benefit_plan_desc bpd
  ON bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts

JOIN benefit_coverage_desc bcd ----- if this is turned into a join all rows w/o enroll cov typ id are dropped
  ON bcd.benefitcoverageid = pbe.benefitcoverageid 
 AND current_date between bcd.effectivedate and bcd.enddate  
 AND current_timestamp between bcd.createts AND bcd.endts 

JOIN edi.etl_personal_info pi
  ON pi.personid = pbe.personid
  


JOIN edi.edidependent edd
  ON edd.employeepersonid = pbe.personid

JOIN dependent_enrollment de    ------>...... I changed this to use the table not the view
  ON de.dependentid = edd.dependentid
 and de.selectedoption = 'Y'  
 and de.benefitsubclass = pbe.benefitsubclass ------->............... the table has the subclass

LEFT JOIN person_payroll pp
  ON pp.personid = pi.personid
 AND now() between pp.effectivedate AND pp.enddate
 AND now() between pp.createts      AND pp.endts
LEFT JOIN pay_unit pu 
  ON pu.payunitid = pp.payunitid

LEFT JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts   

---- Added this join to be able to determine effective date of the enrollment vs effective date of termination.

     LEFT JOIN LATERAL ( SELECT pbe2.personid,pbe2.benefitcoverageid,max(pbe2.effectivedate) AS effectivedate
           FROM person_bene_election pbe2
          WHERE pbe2.personid = pbe.personid 
            AND pbe2.benefitplanid = pbe.benefitplanid 
            AND pbe2.benefitelection = 'E'::bpchar 
            AND pbe2.selectedoption = 'Y'::bpchar 
            AND pbe2.enddate < '2199-12-31'::date 
            --AND pbe2.effectivedate < pbe2.enddate
            AND now() >= pbe2.createts 
            AND now() <= pbe2.endts
          GROUP BY pbe2.personid, pbe2.benefitcoverageid) pbe3 ON true  

--WHERE asof.asofdate = CURRENT_DATE 
--and pi.personid = '716'
where pbe.benefitsubclass in ('10', '1Y') AND pbe.effectivedate < pbe.enddate AND pbe.benefitactioncode = 'E' and pbe.benefitelection in ('E', 'T') AND current_timestamp between pbe.effectivedate and pbe.enddate 
and date_part('year',pbe.effectivedate) >= '2015'

ORDER BY 1

;