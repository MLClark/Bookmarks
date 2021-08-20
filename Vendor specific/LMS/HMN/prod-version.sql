SELECT 
DISTINCT 
pi.employeessn,
ed.emplstatus, ed.personid,
      coalesce(left(pi.lastname,30),pn.lname)::char(30) as lastname,
		coalesce(left(pi.firstname,30),pn.fname)::char(30) as firstname,
		coalesce(left(pi.middlename,30), ' ')::char(30) as middlename,
		coalesce(left(pi.streetaddress1,30),pa.streetaddress,' ')::char(30) as streetaddress1,
		coalesce(left(pi.streetaddress2,30), ' ')::char(30) as streetaddress2,
		coalesce(left(pi.city,20),pa.city,' ')::char(20) as city,

		coalesce(left(pi.statecode,20),pa.stateprovincecode,' ')::char(20) as state,

--		left(sp.stateprovincename,20)::char(20) as state,
		coalesce(left(pi.zipcode, 10),pa.postalcode,' ')::char(10) as zipcode,
		trim(coalesce(left(ocDiv.organizationdesc, 30), ' '))::char(30) as Division,
		' '::char(90) as DivMgrName,
		left(ocDept.organizationdesc, 30)::varchar(30) as Department,
		left(ocDept.orgcode, 4)::varchar(4) as DeptOrgCode,
		' '::char(210) as DeptMgrName,
		coalesce(pi.emailaddress,pncw.url,' ')::char(30) as emailaddress,

		
		--pie.identity myempid,
		
		coalesce(left(pi.employeeid,10), pie.identity)::char(10) as employeeid,
		coalesce(left(id.identity,5), ' ')::char(5) as agentnum,
		coalesce(left(ocBudget.orgcode, 5), ' ')::char(5) as BudgetNum,
		--pe.effectivedate,
		--ed.emplhiredate,
		------ 11/28/2017 --- coalesce(to_char(ed.emplhiredate, 'YYYYMMdd'), ' ')::char(8) as hiredate,  ---- position 611-618
		------ spec change - set hire date to current hire date
--  -----------------------------------------------------------------------------------------------
--  11/26/2018 - as people have come back from LOA their last hire date is reflecting their return date.
		coalesce(to_char(pe.empllasthiredate, 'YYYYMMdd'), ' ')::char(8) as hiredate,  ---- position 611-618
--  -----------------------------------------------------------------------------------------------		
--		ed.emplstatus,
		case
			when ed.emplstatus = 'T' then to_char(ed.empleffectivedate, 'YYYYMMdd')
			else ' '
		end::char(8) as TermDate,
		coalesce(left(jd.jobexperience, 2), ' ')::char(2) as JobExperience,
		coalesce(left(jd.jobcode,5), ' ')::char(5) as jobcode, -- length issues
		coalesce(to_char(pos.effectivedate, 'YYYYMMdd'), ' ')::char(8) as position_date,

--  -----------------------------------------------------------------------------------------------	
--  4/25/2017
		coalesce(left(ed.positiontitle,23), ' ')::char(23) as position_title,
		coalesce(left(ed.grade,2), ' ')::char(2) as salary_grade,
		' '::char(5) as Salary_Grade_Blanks,
		
--  -----------------------------------------------------------------------------------------------		
		case ed.emplstatus
			when 'T' then 'T'
			when 'A' then ' '
			else 'N'
		end::char(1) as EmploymentStatus,
--		puf.ufvalue,
		case
			when lc.locationcode = 'HO' then 'HO'
			when puf.ufvalue <> '' and puf.ufvalue <> 'None' then 'FA'
			else 'FN'
		end::char(4) as Location,
		coalesce(left(fjc.federaljobcode,3), ' ')::char(3) as fedjobcode,
		coalesce(left(ed.eeocode,2), ' ')::char(2) as eeocode,
		case
			when ed.emplpermanency = 'T' then '4'
			when ed.emplclass = 'P' then '3'
			else '1'
		end::char(1) as FTPTIndicator,
		coalesce(left(pl.floormailstop,4), ' ')::char(4) as mailstop,
--  -----------------------------------------------------------------------------------------------	
--  4/25/2017
--		' '::char(1) as space1,
		coalesce(left(trim(ed.flsacode),1), ' ')::char(1) as flsacode,
--  -----------------------------------------------------------------------------------------------	
      --ppc.phoneno workext,
----- 8/21/2017 - fix extension w lowercase x no spaces - note doing this royally screwed up the alignment 
----- had to add ltrim to pull it back together.
		ltrim(case
			when position('x' in lower(ppc.phoneno)) > 1 then
			    --position('x' in lower(ppc.phoneno))
				substring(ppc.phoneno from (position('x' in lower(ppc.phoneno)) + 1) for 5)		
			when position('X. ' in upper(ppc.phoneno)) > 1 then
				substring(ppc.phoneno from (position('X. ' in upper(ppc.phoneno)) + 3) for 5)
			when position('X' in upper(ppc.phoneno)) > 1 then
				ltrim(substring(ppc.phoneno from (position('X' in upper(ppc.phoneno)) + 1) for 5))
			else '    '
		end)
		::char(4) as Extension,


		case
			when position('X' in upper(ppc.phoneno)) > 1 then
				substring(ppc.phoneno from 1 for position('X' in upper(ppc.phoneno)) -1)
			else
				ppc.phoneno
		end::varchar(20) as WorkPhone,
--******
		coalesce(left(piDept.lastname,30), ' ')::char(30) as MgrLastname,
		coalesce(left(piDept.middlename,30), ' ')::char(30) as MgrMiddlename,
		coalesce(left(piDept.firstname,25), ' ')::char(25) as MgrFirstname,
--		' '::char(55) as MgrFirstBlanks,
		coalesce(right(piDept.employeeid, 5), ' ')::char(5) as mgr_EmployeeNum,
		case
			when jobcode = 'R10E4' then 'Y'
			else 'N'
		end::char(1) as RegionalTrainer,
--		' '::char(9) as Reg_Tra_Blanks,
		
		
		--pi.emailaddress as myemail,
		coalesce(left(pi.emailaddress, (position('@' in pi.emailaddress)) - 1), pncw.url,' ')::char(8) as UserId,
		
		--7.2.2018 position 810-818 replace ssn with spaces
		--coalesce(pi.employeessn, ' ')::char(9) as employeessn,
		' '::char(9) as employeessn_1,


----  8/15/2017 9704 
----  pe.emplservicedate,
		------ 11/28/2017 --- coalesce(to_char(ed.emplhiredate, 'YYYYMMdd'), ' ')::char(8) as emplservicedate,  ------ position 819 - 826
		------ spec change - set service date to original hire date
		eemp.originalhiredate,
		eemp.employmentbegindate,
		coalesce(to_char(eemp.employmentbegindate, 'YYYYMMdd'), ' ')::char(8) as emplservicedate,  ------ position 819 - 826		
		' '::char(8) as endingblank,
---- 4/11/2019  Added Gender/Ethnicity
		coalesce(pi.gendercode, ' ')::char(1) as gender,
		coalesce(pi.ethniccode, 'N')::char(3) as ethniccode,
		coalesce(pvs.veteranstatus, '  ')::char(2) as veteranstatus,
		' '::char(3) as Reg_Tra_Blanks

FROM	edi.etl_employment_data ed
--- had to change to left join - Beth missing people - changing this pulled emp's with no names 
left join	edi.etl_personal_info pi on ed.personid = pi.personid

left join edi.ediemployee eemp
  on eemp.personid = ed.personid
  

left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 and pe.effectivedate - interval '1 day' <> pe.enddate
 
left join pos_org_rel por on por.positionid = ed.positionid
     and current_date between por.effectivedate and por.enddate
     and current_timestamp between por.createts and por.endts
     and por.posorgreltype = 'Member'
left join organization_code ocDept on por.organizationid = ocDept.organizationid
     and current_date between ocDept.effectivedate and ocDept.enddate
     and current_timestamp between ocDept.createts and ocDept.endts
left join pos_pos pp on pp.topositionid = por.positionid
     and current_date between pp.effectivedate and pp.enddate
     and current_timestamp between pp.createts and pp.endts
left join edi.etl_employment_data edDept on edDept.positionid = pp.positionid
left join edi.etl_personal_info piDept on piDept.personid = edDept.personid

-- added person names and address to coalesce missing employees

left join person_names pn on pn.personid = ed.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
left join person_address pa on pa.personid = ed.personid
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

---- added email not being populated
LEFT JOIN person_net_contacts pncw ON pncw.personid = ed.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.enddate 

--- added for empnbr not being populated
LEFT JOIN person_identity piE
  ON pIe.personid = ed.personid
 AND CURRENT_TIMESTAMP BETWEEN piE.createts AND piE.endts
 AND piE.identitytype = 'EmpNo'

--- added for ssn's not being populated
LEFT JOIN person_identity piS
  ON pIS.personid = ed.personid
 AND CURRENT_TIMESTAMP BETWEEN piS.createts AND piS.endts
 AND piS.identitytype = 'SSN'

left join org_rel orel on orel.organizationid = por.organizationid
     and current_date between orel.effectivedate and orel.enddate
     and current_timestamp between orel.createts and orel.endts
     and orel.orgreltype = 'Management'
left join organization_code ocDiv on orel.memberoforgid = ocDiv.organizationid
     and current_date between ocDiv.effectivedate and ocDiv.enddate
     and current_timestamp between ocDiv.createts and ocDiv.endts


left join pos_org_rel porB on porB.positionid = ed.positionid
     and current_date between porB.effectivedate and porB.enddate
     and current_timestamp between porB.createts and porB.endts
     and porB.posorgreltype = 'Budget'
left join organization_code ocBudget on porB.organizationid = ocBudget.organizationid
     and current_date between ocBudget.effectivedate and ocBudget.enddate
     and current_timestamp between ocBudget.createts and ocBudget.endts




left join position_job pj on pj.positionid = ed.positionid
     and current_date between pj.effectivedate and pj.enddate
     and current_timestamp between pj.createts and pj.endts
left join job_desc jd on jd.jobid = pj.jobid
     and current_date between jd.effectivedate and jd.enddate
     and current_timestamp between jd.createts and jd.endts

left join pers_pos pos on pos.personid = pi.personid
     and current_date between pos.effectivedate and pos.enddate
     and current_timestamp between pos.createts and pos.endts

left join person_user_field_vals puf on puf.personid = ed.personid
     and current_date between puf.effectivedate and puf.enddate
     and current_timestamp between puf.createts and puf.endts
     and puf.ufid = (select ufid from user_field_desc where ufname = 'AgentType'
			and current_date between effectivedate and enddate
			and current_timestamp between createts and endts)

left join person_locations pl on pl.personid = ed.personid
     and current_date between pl.effectivedate and pl.enddate
     and current_timestamp between pl.createts and pl.endts
left join location_codes lc on lc.locationid = pl.locationid
     and current_date between lc.effectivedate and lc.enddate
     and current_timestamp between lc.createts and lc.endts

left join federal_job_code fjc on fjc.federaljobcodeid = jd.federaljobcodeid

left join person_phone_contacts ppc on ppc.personid = pi.personid and ppc.phonecontacttype = 'Work'
     and current_date between ppc.effectivedate and ppc.enddate
     and current_timestamp between ppc.createts and ppc.endts

left join state_province sp on sp.stateprovincecode = pi.statecode and sp.countrycode = 'US'

left join person_identity id on id.personid = pi.personid and id.identitytype = 'AgtNo'
     --and current_timestamp between id.createts and id.endts
left join person_veteran_status_us pvs on pvs.personid = pi.personid
	and current_date between pvs.effectivedate and pvs.enddate
	and current_timestamp between pvs.createts and pvs.endts
where ed.emplstatus <> 'T' --and ed.personid = '63845'
  --and pi.personid in ('65894', '63560')
    --and pi.personid in ('65890', '63792')
order by pi.employeessn

