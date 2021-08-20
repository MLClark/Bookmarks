select distinct

 rtrim(ltrim(piE.identity,'0'),' ') as EmployeeID
,pe.personid
--,jd.eeocode ::char(20) as FederalJobCode
--,jd.jobcode
--,jd.job_xid
--,piN.personid
--,eed.emplstatus
--,piP.identity
--,pep.individual_key
,' ' as AssociateID
,rtrim(left(piS.identity,3)||'-'||substring(piS.identity,4,2)||'-'||right(piS.identity,4),' ') as SSN
,rtrim(pn.fname,' ') as FirstName
,rtrim(pn.lname,' ') as LastName
,rtrim(pn.mname,' ') as MiddleInitial
,rtrim(pn.title,' ') as NameSuffix
,to_char(pv.birthdate,'YYYY/MM/DD')::char(10) as Birthdate
,to_char(pe.emplhiredate,'YYYY/MM/DD')::char(10) as HireDate
,rtrim(pncW.url,' ') AS Email
,rtrim(pa.streetaddress,' ')  as Address1
,rtrim(pa.streetaddress2,' ') as Address2
,rtrim(pa.city,' ') as city
,pa.stateprovincecode ::char(2) as state
,case pa.countrycode when 'US' then 'USA' else ' ' end ::char(3) as country
,rtrim(pa.postalcode,' ') as Zip

,rtrim(ppcH.phoneno,' ') as PrimaryPhone
,rtrim(ppcW.phoneno,' ') as WorkPhone
,pv.gendercode ::char(1) as Gender
,case pv.ethniccode 
   when 'H' then '1'
   when 'W' then '2'
   when 'B' then '3'
   when 'A' then '4'
   when 'P' then '5'
   when 'I' then '6'
   when 'T' then '7'
   else '9' end ::char(1) as Race


,case when pe.emplstatus = 'A' then 'Hiring Manager' else ' ' end as RoleCode1
,case when pe.emplstatus = 'A' then 'Requisition Approver' else ' ' end as RoleCode2
,' ' as RoleCode3
,' ' as RoleCode4  

--,
--,rtrim(pcr4.personcompanyreltype,' ') as RoleCode5 
,case when pcr4.personcompanyreltype = 'WF4' and pe.emplstatus = 'A' then 'HR Business Partner' else ' ' end as RoleCode5
--,rtrim(pcr5.personcompanyreltype,' ') as RoleCode6
,case when pcr5.personcompanyreltype = 'WF5' and pe.emplstatus = 'A' then 'Division Head' else ' ' end as RoleCode6
,pp.positionid
,rtrim(jd.jobcode,' ') as CurrentJobCode
,rtrim(jd.jobdesc,' ') as CurrentJobDesc
,rtrim(lc.locationcode,' ') as CurrentLocationCode
,'Internal Employee' as SourceID
,'Internal Employee' as SourceCategory
,rtrim(piN.identity,' ') as EmployeeNumber  
,case pe.rehireindicator when 'Y' then 'Yes' else 'No' end as Action_Reason

-- 11/17/2018 28065 term date should be paythru date
--,case when pe.emplstatus = 'T' then pe.effectivedate - interval '1 day' else null end as interval_date
-- can't use interval doesn't match application - also need to coalesce since older terms don't have pay through dates
,case when pe.emplstatus = 'T' then to_char(coalesce(pe.paythroughdate,pe.effectivedate),'YYYY/MM/DD') else null end ::char(10) as Termination_Date
/*,case jd.jobcode 
   when 'A6414' then 'Associate'
   when 'A6319' then 'Assistant Vice President'
   when 'BBPeiser' then 'Manager'
   when 'B1418' then 'Manager'
   when 'BPeiser' then 'Manager'
   else ' ' end as FederalJobCode */
,jobdesc
,case when pe.emplstatus = 'A' then jd.jobcode else ' ' end as FederalJobCode
,case when pe.emplstatus = 'A' then '1' else '0' end ::char(1) as Active
,rtrim(pd.flsacode,' ') as hrisStatus 
,por.organizationid
,orl.memberoforgid
,ocdp.organizationid
,rtrim(ocdp.organizationdesc,' ') as department
,rtrim(ocdv.organizationdesc,' ') as division

from person_employment pe

left join (SELECT personid, emplstatus, emplevent,  empleventdetcode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_employment pe1
            WHERE enddate > effectivedate 
                   AND current_timestamp BETWEEN createts AND endts
                   and emplstatus <>  'A'
                   and enddate <= current_date
            GROUP BY personid, emplstatus, emplevent, empleventdetcode ) leavest on leavest.rank = 1 and leavest.personid = pe.personid

left join person_identity piN on piN.personid = pe.personid
 and current_timestamp between piN.createts and piN.endts
 and piN.identitytype = 'NetId' 

left join person_identity piP on piP.personid = pe.personid
 and current_timestamp between piP.createts and piP.endts
 and piP.identitytype = 'PSPID' 

left join person_identity piE on piE.personid = pe.personid
 and current_timestamp between piE.createts and piE.endts
 and piE.identitytype = 'EmpNo' 

left join person_identity piS on piS.personid = pe.personid
 and current_timestamp between piS.createts and piS.endts
 and piS.identitytype = 'SSN'

left join person_names pn on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
left join person_vitals pv on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join pers_pos pp on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 and pp.persposrel = 'Occupies'
 

left join 
(select positionid, count(topositionid) as subpositions 
   from pos_pos pop 
  where current_date between pop.effectivedate and pop.enddate
    and current_timestamp between pop.createts and pop.endts
    and pop.posposrel = 'Manages' group by positionid) mgr on mgr.positionid = pp.positionid
    
left join pos_org_rel por on por.positionid = pp.positionid
 and current_date between por.effectivedate and por.enddate
 and current_timestamp between por.createts and por.endts
 and por.posorgreltype = 'Member'

left join organization_code ocdp on ocdp.organizationid = por.organizationid
 and current_date between ocdp.effectivedate and ocdp.enddate
 and current_timestamp between ocdp.createts and ocdp.endts
 and ocdp.organizationtype = 'Dept' 
left join org_rel orl on orl.organizationid = ocdp.organizationid
 and current_date between orl.effectivedate and orl.enddate
 and current_timestamp between orl.createts and orl.endts
left join organization_code ocdv on ocdv.organizationid = orl.memberoforgid
 and current_date between ocdv.effectivedate and ocdv.enddate
 and current_timestamp between ocdv.createts and ocdv.endts
 and ocdv.organizationtype = 'Div' 
 
left join pos_pos mymgr on mymgr.topositionid = pp.positionid
 and current_date between mymgr.effectivedate and mymgr.enddate
 and current_timestamp between mymgr.createts and mymgr.endts	
 	
left join position_desc pd on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between  pd.createts and pd.endts	 
 
left join person_company_rel pcr on pcr.personid = pe.personid
 and current_date between pcr.effectivedate and pcr.enddate
 and current_timestamp between pcr.createts and pcr.endts 
left join person_company_rel pcr4 on pcr4.personid = pe.personid
 and pcr4.personcompanyreltype = 'WF4'
 and current_date between pcr4.effectivedate and pcr4.enddate
 and current_timestamp between pcr4.createts and pcr4.endts
left join person_company_rel pcr5 on pcr5.personid = pe.personid
 and pcr5.personcompanyreltype = 'WF5'
 and current_date between pcr5.effectivedate and pcr5.enddate
 and current_timestamp between pcr5.createts and pcr5.endts
    
    
left join person_address pa on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
left join ( select personid, url, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
  from person_net_contacts
  where netcontacttype = 'WRK'
   and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   group by personid, url) pncW on pncW.personid = pe.personid and pncW.rank = 1

left join ( select personid, phoneno, enddate, max(effectivedate) as effectivedate, max(endts) as endts,
  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
  from person_phone_contacts
  where phonecontacttype = 'Home' 
   and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   group by personid, phoneno, enddate) ppch on ppch.personid = pe.personid and ppch.rank = 1
  
left join ( select personid, phoneno, max(effectivedate) as effectivedate, max(endts) as endts,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(endts) DESC) AS RANK
  from person_phone_contacts
  where phonecontacttype = 'Work'
   and current_date between effectivedate and enddate 
   and current_timestamp between createts and endts
   group by personid, phoneno) ppcW on ppcW.personid = pe.personid and ppcW.rank = 1   

left join person_locations pl on pl.personid = pe.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts

LEFT JOIN location_codes lc ON lc.locationid = pl.locationid
 AND current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts
 
left join position_job pj ON pj.positionid = pp.positionid 
 AND current_date between pj.effectivedate AND pj.enddate 
 AND current_timestamp between pj.createts AND pj.endts 

left join job_desc jd ON jd.jobid = pj.jobid 
 AND current_date between jd.effectivedate AND jd.enddate 
 AND current_timestamp between jd.createts AND jd.endts 

where pe.emplpermanency in ('T', 'P')
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 --and pe.personid = '66162'
order by ssn
;
