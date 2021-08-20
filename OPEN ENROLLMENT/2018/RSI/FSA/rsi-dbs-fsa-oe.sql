SELECT distinct
 pi.personid
,replace(pu.employertaxid,'-','')               AS "Client Federal Id"
,pi.identity                                    AS "Participant Id"
,'1'                                            AS "Participant Id Identifier Type"
,pn.fname                                       AS "First Name"
,left(pn.mname,1)                               AS "Middle Initial"
,pn.lname                                       AS "Last Name"
,replace(pa.streetaddress,',','')               AS "Address 1"
,replace(pa.streetaddress2, ',','')             AS "Address 2"
,pa.city                                        AS "City"
,pa.stateprovincecode                           AS "State"
,pa.postalcode                                  AS "Zip Code"
,pncw.url                                       AS "Email Address"
,to_char(pv.birthdate,'mm/dd/yyyy')             AS "Date of Birth"
,ppch.phoneno                                   AS "Phone"

,case when pu.frequencycode = 'BM' then 'B'
      when pu.frequencycode = 'S' then 'B' else pu.frequencycode end AS "Payroll Mode"

,case when pbe.benefitsubclass = '60' then to_char(pbefsa.effectivedate,'mm/dd/yyyy')
      when pbe.benefitsubclass = '61' then to_char(pbedfsa.effectivedate,'mm/dd/yyyy') end ::char(10) as "Enrollment Date"

,replace(ro.org2desc,',','') AS "Location"
,CASE when pbe.benefitsubclass = '61'THEN '1'
      when pbe.benefitsubclass = '60'THEN '2' end ::char(1)  AS "Plan Type Id"

,case when pbe.benefitsubclass = '60' then to_char(pbefsa.effectivedate,'mm/dd/yyyy')
      when pbe.benefitsubclass = '61' then to_char(pbedfsa.effectivedate,'mm/dd/yyyy') end ::char(10) AS "Enrollment Effective Date"

,case when pbe.benefitsubclass = '60' then to_char(pbefsa.effectivedate,'mm/dd/yyyy')
      when pbe.benefitsubclass = '61' then to_char(pbedfsa.effectivedate,'mm/dd/yyyy') end ::char(10) AS "Effective Posting Date"
      
,to_char(poc.employeerate,'9999.99') AS "Pay Period Amount"
,to_char(poca.employeerate,'9999.99') AS "Annual Election"

,'1'                      AS "Funding Type"
,''                       AS "Employer Coverage Type Id"
,NULL                     AS "Benefit Termination Date"
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


from person_identity pi 

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts 

left join person_bene_election pbefsa
  on pbefsa.personid = pbe.personid 
 and pbefsa.benefitelection = 'E'
 and pbefsa.selectedoption = 'Y'
 and pbefsa.benefitsubclass in ('60')
 and pbefsa.effectivedate >= date_trunc('year', current_date + interval '1 year') 
 and current_timestamp between pbefsa.createts and pbefsa.endts  

left join person_bene_election pbedfsa
  on pbedfsa.personid = pbe.personid 
 and pbedfsa.benefitelection = 'E'
 and pbedfsa.selectedoption = 'Y'
 and pbedfsa.benefitsubclass in ('61')
 and pbedfsa.effectivedate >= date_trunc('year', current_date + interval '1 year') 
 and current_timestamp between pbedfsa.createts and pbedfsa.endts  
 
left join person_names pn
  on pn.personid = pbe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join person_address pa
  on pa.personid = pbe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
left join person_vitals pv
  on pv.personid = pbe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join ( select personid, url, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_net_contacts where netcontacttype = 'HomeEmail' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, url) pnch on pnch.personid = pe.personid and pnch.rank = 1 

left join ( select personid, url, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_net_contacts where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, url) pncw on pncw.personid = pe.personid and pncw.rank = 1              
 
left join ( select personid, phoneno, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Home' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppch on ppch.personid = pe.personid and ppch.rank = 1

left join ( select personid, phoneno, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Mobile' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppcm on ppcm.personid = pe.personid and ppcm.rank = 1 
 
left join ( select personid, phoneno, max(effectivedate) as effectivedate,  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              from person_phone_contacts where phonecontacttype = 'Work' and current_date between effectivedate and enddate and current_timestamp between createts and endts
             group by personid, phoneno) ppcw on ppcw.personid = pe.personid and ppcw.rank = 1 

left join personbenoptioncostl poc 
  on poc.personid              = pbe.personid
 and poc.personbeneelectionpid = pbe.personbeneelectionpid
 and poc.costsby = 'P'

left join personbenoptioncostl poca
  on poca.personid              = pbe.personid
 and poca.personbeneelectionpid = pbe.personbeneelectionpid
 and poca.costsby = 'A' 

left join person_payroll pp
  on pp.personid = pbe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

left join pay_unit pu 
  on pu.payunitid = pp.payunitid    
  
left join pers_pos ppos
  on ppos.personid = pe.personid 
 and current_date between ppos.effectivedate and ppos.enddate
 and current_timestamp between ppos.createts and ppos.endts    

left join pos_org_rel porb 
  on porb.positionid = ppos.positionid
 and current_date between porb.effectivedate and porb.enddate
 and current_timestamp between porb.createts and porb.endts   

left join pos_org_rel por
  on por.positionid = porb.positionid
 and current_date between por.effectivedate and por.enddate
 and current_timestamp between por.createts and por.endts
 and por.posorgreltype = 'Member'

left join edi.orgstructure ro
  on ro.org1id = por.organizationid  
              
 
where pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and pbe.effectivedate >= date_trunc('year', current_date + interval '1 year') 
  and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  
  and pbe.benefitsubclass in ('60','61')  




