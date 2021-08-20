/* 
This query is a collection of columns I've found by going through existing feeds.
I've been collecting various ways demographics are used along with benefit data
The query is currently using ADB data from PROD since this provides good bit of 
employee data.
*/
SELECT distinct
 pi.personid
,pi.trankey

--- company information 
,pbe.benefitplanid 				as "Plans"
,eb.benefitpolicyid				as "Group #"
,'???' as "Classification"


 --- Personal Information
,pi.locationdescription   					AS "Location"
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4)as "SSN with Dashes"
,replace(pi.identity,'-','')         			AS "SSN without Dashes"

--- the concat is more efficient method to use when combining strings 
,concat(pn.lname,', ',pn.fname,' ',pn.mname) ::varchar(100) as f5_emp_name 
,pn.lname||', '||pn.fname||' '||pn.mname ::char(60) as f5_emp_name 

-- personal information also found on ee tables
,pi.lastname              					AS "PI Last Name"
,pi.firstname             					AS "PI First Name"
,pi.middlename            					AS "PI Middle Name"
,pi.firstname||' '||pi.lastname||COALESCE(pi.middlename,'')  	AS "First Last Name"
,pi.lastname||', '||pi.firstname||COALESCE(pi.middlename,'')  	AS "Last,First Name"
,TRIM(UPPER(pn.lname||', '||fname||' '|| coalesce(LEFT(mname,1),' ')))::char(43) 
								as "Last,First Name Uppercase"
,cast((case	when pi.middlename is null then TRIM(both ' ' from pi.firstname)
		else pi.firstname || ' ' || LEFT(TRIM(both ' ' from pi.middlename), 1)
		end) as varchar(100)) 				as "Cast Firstname "

,to_char(pi.birthdate,'mm/dd/yyyy') 				AS "DOB"
,age(current_date, pi.birthdate) 				as "Employee Age"
,pi.gendercode            					as "Gender" 
,pi.maritalstatus						as "Marital Status"
,ms.maritalstatusdesc 						as "Marital Status Desc"


,pi.streetaddress1        					AS "ADD1"
,pi.streetaddress2        					AS "ADD2"
,pi.city                  					AS "City"
,pi.statecode             					AS "State"
,pi.zipcode               					AS "ZIP"
,pi.countrycode           					as "Country"

,pi.city|| ' ' || pi.statecode || ' ' || pi.zipcode 		as "City State Zip"
,pi.emailaddress          					AS "Email Address"
,ee.emailaddress						as "Email Address"
,pi.homephone							as "Home Phone"
,ee.homephone							as "Home Phone"
,pi.workphone							as "Work Phone"

, pv.smoker                                          as tobacco
, to_char(pv.smokerquitdate + INTERVAL '1 YEAR', 'MM/dd/YYYY')::char(10) as tobaccochgdt

,CASE pi.locationdescription
   WHEN 'Bangor' 	THEN 'BNGR'
   WHEN 'Biddeford' 	THEN 'BDFD'
   when 'Rockport'	then 'ROCK' 
   when 'Sanford'	then 'SNFD'
   when 'Scarborough'	then 'SCAR'
   when 'Topsham'	then 'TPSM'
   when 'Paratransit'	then 'PARA'
   else 'UNKN'  ---- Brunswick is showing up as UNKN and NEMS does have a service location in Brunswick
 END 								as "Benefit Group Code"
--- Employee Information
-- need to locate work address information
-- need to locate pay period start and end dates
-- need to locate hourly rate
-- need to locate hours worked
-- need to locate gross pay
-- need to locate termination reason
-- need to locate EEOC code

,'||' as "||"
,case when pp.schedulefrequency = 'H' then to_char(pp.scheduledhours,'0000V99')
      when pp.schedulefrequency = 'S' then to_char((pp.scheduledhours * 24) / 52,'0000V99')
      end as normal_sched_hours

,ee.employeeid							as "Employee Number"
,jd.jobcode::varchar(20) 					as "Job Code"
,jf.jobfamilycode 						as "Job Family Code"

,coalesce(ed.positiontitle, ' ')::CHAR(60) 			AS "Jobtitle"
,to_char(ed.emplhiredate,'mm/dd/yyyy') 				AS "Date of Hire"
,to_char(ed.empllasthiredate, 'YYYYMMDD')  			as "Last Hire Date" 
,to_char(ed.emplhiredate, 'YYYYMMDD')  				as "Original Hire Date" 

,pep.adjusted_hire_date						as "PEP Adjusted Hire Date"

,age(current_date, ed.emplhiredate) 				as "Years of Service years months and days"
,pep.years_of_service						as "Years of Service"
,pep.termination_date						as "PEP Termination Date"

,ed.schedulefrequency						as "Salary Type"
,ed.companyid as "employer ID"
,ci.companyidentity AS employerid


,CASE ed.emplstatus 
   WHEN 'A' THEN 'Active'
   WHEN 'T' THEN 'Terminated'
   ELSE '?' 
 END								AS "Employee Status"

,pe.emplevent as "Event Type" 
 
, case	when ed.emplhiredate +  28 > current_date then 'Y'::char(1)
	else ''::char(1) 
 end 								as "Calculated Activation"
,CASE ed.emplclass 
      WHEN 'F' THEN 'Full-time'
      WHEN 'P' THEN 'Part-time'
      ELSE '?' 
 END                            				AS "Employee Part Time Full Time Status" 
,pep.actual_status						as "PEP Actual Status"
,pep.work_status_indicator					as "PEP Work Status Indicator"
,CASE
      WHEN ed.benefitstatus = 'T'::bpchar THEN to_char(ed.empleffectivedate, 'YYYYMMDD')
      ELSE NULL
 END 								AS "Termination Date"
,pe.emplevent							as "Termination Reason"
,case pe.emplevent
      when 'InvTerm   ' then '2'
      when 'VolTerm   ' then '1'
      else ' '	end						as "Termination Reason" 
,CASE
      WHEN ed.benefitstatus = 'T'::bpchar THEN to_char((ed.empleffectivedate - interval '1 day'), 'YYYYMMDD')
      ELSE NULL
 END 								AS "Last Day Worked"

--- dependent data
,'||' as "||"
,coalesce(edd.dependentssn,'')      				AS "Dependent Id"
,edd.dependentfirstname             				AS "Dependent First Name"
,coalesce(left(edd.dependentmiddlename,1),'') 			AS "Dependent Middle Initial"
,edd.dependentlastname              				AS "Dependent Last Name"
,to_char(edd.birthdate,'mm/dd/yyyy') 				AS "Dependent Date of Birth"
,coalesce(edd.homephone,'')          				AS "Dependent Phone"
,replace(edd.streetaddress1,',','')     			AS "Dependent Address 1"
,coalesce(replace(edd.streetaddress2,',',''),'')          	AS "Dependent Address 2"
,edd.city                  					AS "Dependent City"
,edd.statecode             					AS "Dependent State"
,edd.zipcode               					AS "Dependent Zip Code"
,coalesce(edd.emailaddress,'')          			AS "Dependent Email Address"
,CASE edd.dependentrelationshipid
   WHEN 'SP' THEN '1'
   WHEN 'C'  THEN '2'
   WHEN 'DP' THEN '3'
   ELSE '4'
 END                      					AS "Dependent Relationship"
 ,edd.student							as "Full Time Student"
 ,edd.disabledyn             					as "Disabled Child"


--- benefit data
,'||' as "||"
,to_char(poc.employeerate,'9999.99')     			AS "Pay Period Amount"
,to_char(poc.employercost,'9999.99')     			as "Employer Cost"
---,bct.benefitcoveragetypedesc					as "Cobra Indicator"


-- another source of employee and employer amt not bringing this in because it turns query into cartprod
--,pd.etv_amount as employeramt
--,pd.etv_amount as employeeamt
,bpd.benefitplandesc      					AS "Benefit Plan Description"
,bpd.benefitplanid 						as "Benefit Plan ID"
		,pbe.coverageamount   				as "Annual Coverage Amount"
		,to_char(poc.employeerate,'9999.99')    	AS "Per Pay Period Amount"

,CASE
   WHEN pbe.benefitelection = 'T' THEN
     to_char(pbe.effectivedate,'mm/dd/yyyy')
   WHEN pbe.benefitelection <> 'T' THEN
     to_char(pbe.effectivedate,'mm/dd/yyyy')
 END                      					AS "Original Effective Date"
,to_char(pbe.effectivedate,'mm/dd/yyyy') 			AS "Change Date"
,CASE
   WHEN pbe.benefitactioncode = 'T' 
     THEN to_char(pbe.deductionenddate,'mm/dd/yyyy')   
   ELSE NULL
 END                     					AS "Benefit Termination Date"
,CASE
   WHEN pbe.benefitcoverageid in ('1')
     THEN 'Ind'
   WHEN pbe.benefitcoverageid in ('2')
     THEN 'IndSpouse'
   WHEN pbe.benefitcoverageid in ('3')
     THEN 'IndChild'        
   WHEN pbe.benefitcoverageid in ('5')
     THEN 'Family'  
   ELSE 'Termed'
 END                      					AS "Coverage Level"
,''                       					AS "Reason"

,elu.feedid               AS feedid
,CURRENT_TIMESTAMP        AS updatets

FROM asof

JOIN edi.edi_last_update elu
  ON elu.feedid = 'ABD_GD_HRA_AddChange'

--- This first pbe join ensures we are locating both med and hra participants
JOIN person_bene_election pbe
  --ON pbe.benefitplanid = '33' --- is HRA - rest are MED
  ON pbe.benefitplanid in ('33','2', '3', '4')
 AND pbe.effectivedate < pbe.enddate
 AND pbe.benefitactioncode = 'E'
 and pbe.benefitelection in ('E', 'T')
 AND pbe.createts  BETWEEN elu.lastupdatets and asof.asofdate
 AND current_timestamp between pbe.effectivedate and pbe.enddate 
 

join 
    (
     SELECT 
        pbe2.personid,
	max(pbe2.personbeneelectionpid) as personbeneelectionpid

      FROM asof
      JOIN edi.edi_last_update elu
	ON elu.feedid = 'ABD_GD_HRA_AddChange'
      JOIN person_bene_election pbe2
        --on pbe2.benefitplanid = '33'
        on pbe2.benefitplanid in ('33','2', '3', '4')
       AND pbe2.benefitactioncode = 'E'
       and pbe2.benefitelection in ('E', 'T')
       AND pbe2.effectivedate < pbe2.enddate
       AND pbe2.createts  BETWEEN elu.lastupdatets and asof.asofdate
       AND current_timestamp between pbe2.effectivedate and pbe2.enddate
       group by 1    
       ) max_pid 

  on max_pid.personid = pbe.personid
 and max_pid.personbeneelectionpid = pbe.personbeneelectionpid    
/* This join isn't working yet but it's another method to get employee employer amts

JOIN 
(
 	SELECT pd.individual_key
             , pd.check_date
             , SUM(coalesce(pd1.etv_amount,0)) as employeramt
             , SUM(coalesce(pd2.etv_amount,0)) as employeeamt
          FROM pspay_payment_detail pd
        LEFT JOIN pspay_payment_detail pd1
          ON pd1.individual_key = pd.individual_key
         AND pd1.check_date     = pd.check_date 
         AND pd1.etv_id             = 'VEK'  
        LEFT JOIN pspay_payment_detail pd2
          ON pd2.individual_key = pd.individual_key
         AND pd2.check_date     = pd.check_date 
         AND pd2.etv_id             = 'VEH'          
       WHERE pd.check_date = (select max(check_date) from pspay_payment_detail)
       --WHERE pd.check_date = '2015-12-18 00:00:00'
           AND pd.etv_id IN ('VEH','VEK')
        GROUP BY pd.individual_key, pd.check_date
  ) pd 

  */

JOIN benefit_plan_desc bpd
  ON bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts

/* I've found cobra indicator on this table not sure what to join this table on 
join benefit_coverage_type bct
  on bct.benefitcoveragetype
*/   
JOIN edi.etl_personal_info pi
  ON pi.personid = pbe.personid

  LEFT JOIN person_names pn 
    ON pn.personid = pi.personid
--   AND pd.check_date between pn.effectivedate and pn.enddate
--   AND pd.check_date between pn.createts      and pn.endts  

join edi.ediemployee ee
  ON ee.personid = pbe.personid

JOIN edi.etl_employment_data ed
  ON ed.personid = pbe.personid

left join position_job pj on ed.positionid = pj.positionid and now() >= pj.effectivedate AND now() <= pj.enddate AND now() >= pj.createts AND now() <= pj.endts  
left join job_desc jd on jd.jobid = pj.jobid  and now() >= jd.effectivedate AND now() <= jd.enddate AND now() >= jd.createts AND now() <= jd.endts
left join job_family_desc jf on jf.jobfamilyid = jd.jobfamilyid

join pspay_payment_detail pd
  on pi.trankey = pd.individual_key
  
LEFT JOIN personbenoptioncostl poc 
  ON poc.personid              = pbe.personid
 AND poc.personbeneelectionpid = pbe.personbeneelectionpid
 AND poc.costsby = 'P' 

 join pspay_employee_profile pep
  on pi.trankey = pep.individual_key

join person_employment pe 
  on pe.personid = pbe.personid
 join edi.ediemployeebenefit eb
   ON eb.personid = pbe.personid

JOIN edi.edidependent edd
  ON edd.employeepersonid = pbe.personid

JOIN dependent_enrollment de    ------>...... I changed this to use the table not the view
  ON de.dependentid = edd.dependentid
 and de.selectedoption = 'Y'  
 and de.benefitsubclass = pbe.benefitsubclass ------->............... the table has the subclass   

join person_vitals pv on pi.personid = pv.personid
     and current_date      between pv.effectivedate and pv.enddate
     and current_timestamp between pv.createts and pv.enddate

join marital_status ms 
  on ms.maritalstatus = pi.maritalstatus

left join person_address pa on pi.personid = pa.personid
     and pa.addresstype = 'Res'
     and current_date between pa.effectivedate and pa.enddate
     and current_timestamp between pa.createts and pa.endts
       
LEFT JOIN person_employment pemp ON pemp.personid = pi.personid
 AND current_date      between pemp.effectivedate and pemp.enddate
 AND current_timestamp between pemp.createts and pemp.enddate
 
LEFT JOIN company_identity ci ON ci.companyid = pe.companyid 
 AND ci.companyidentitytype = 'FEIN'::bpchar AND ci.endts > now()  
  
WHERE asof.asofdate = CURRENT_DATE 

;