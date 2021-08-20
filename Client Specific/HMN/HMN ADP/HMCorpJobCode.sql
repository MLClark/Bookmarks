
With sg as (Select distinct pd.positionid, sgr.*
From positiondetails pd
	JOIN salary_grade_ranges sgr ON pd.grade = sgr.grade AND sgr.edtcode = 'Regular' AND frequencycode = 'A'
							and current_date between sgr.effectivedate and sgr.enddate AND current_timestamp between sgr.createts and sgr.endts
							
Where current_date between pd.effectivedate and pd.enddate)
, HCE as (

Select distinct pp.positionid, pp.personid, pc.hce_Ind
From pers_pos pp
		JOIN person_compensation pc ON pp.personid = pc.personid
		group by 1,2,3


), pmd as(

Select distinct pp.personid as mgrpersonid, ppm.*
From posposmanagerdetail ppm
		LEFT OUTER JOIN pers_pos pp ON ppm.mgrpositionid = pp.positionid
						AND current_date between pp.effectivedate and pp.enddate AND current_timestamp between pp.createts and pp.endts
Where current_date between ppm.effectivedate and ppm.enddate AND current_timestamp between ppm.createts and ppm.endts

)

Select Distinct dpd.positionid as "PositionCode"
	, dpd.positiontitle as "Position"
	, fjcid.federaljobcode as "FederalJobCode"
	, jcd.eeocode as "EEO1Code"
	, Case When dpd.flsacode = 'E' Then 'Exempt'
		Else 'Non-Exempt'
		End as "FLSA"
	, dpd.salarygradedesc as "SalaryGradeLevel"

 ---, dpd.positionxid as "Position External ID"  -------- 11/14/2017 change this to job code is A560001 should be A5600 FROM jobcodedetail
	, jcd.jobcode as "Position External ID"  -------- change this to job code is A560001 should be A5600 FROM jobcodedetail

	, ocdi.orgcode as "DivisionCode"
	, ocd.orgcode as "DepartmentCode"
	, pmd.current_manager || '-' || pmd.mgrpersonid as "DirectManager"
	, pmd.occupiedby || '-' || HCE.personid as "CurrentIncumbent"
	, lc.locationCode || ': ' || lc.locationdescription as "PlannedLocation"
	, ocb.effectivedate as "ocb-eff-date"
	, ocb.orgcode as "BudgetOrg"
	, sg.salaryminimum::integer as "Minimum"
	, sg.salarymaximum::integer as "Maximum"
	, '0' as "ShiftDifferential"
	, sgrf.salarygraderegiondesc as "AreaSalaryDifferential"
	, Case When HCE.hce_ind is Null Then 'N' Else 'Y' End as "HCEIndicator"
	, pmd.current_manager as "ManagerFullName"
	, case dpd.enddate when '2199-12-31' then '0' else '1' end ::char(1) as "Disabled"
From dcpositiondesc dpd
	LEFT OUTER JOIN pmd ON dpd.positionid = pmd.positionid
	LEFT OUTER JOIN jobcodedetail jcd ON dpd.jobid = jcd.jobid
							and current_date between jcd.effectivedate and jcd.enddate and current_timestamp between jcd.createts and jcd.endts
	LEFT OUTER JOIN federaljobcodeid fjcid ON jcd.federaljobcodeid = fjcid.federaljobcodeid
	LEFT OUTER JOIN position_location pl ON dpd.positionid = pl.positionid
							and current_date between pl.effectivedate and pl.enddate and current_timestamp between pl.createts and pl.endts
	LEFT OUTER JOIN location_codes lc ON pl.locationid = lc.locationid
							and current_date between lc.effectivedate and lc.enddate and current_timestamp between lc.createts and lc.endts
	LEFT OUTER JOIN sg ON dpd.positionid = sg.positionid AND lc.salarygraderegion = sg.salarygraderegion
	LEFT OUTER JOIN salarygraderegionsform sgrf ON lc.salarygraderegion = sgrf.salarygraderegion
							and current_date between sgrf.effectivedate and sgrf.enddate and current_timestamp between sgrf.createts and sgrf.endts
	LEFT OUTER JOIN positionorgreldetail pord ON dpd.positionid = pord.positionid AND pord.posorgreltype = 'Member'
							and current_date between pord.effectivedate and pord.enddate and current_timestamp between pord.createts and pord.endts
	LEFT OUTER JOIN positionorgreldetail porb ON dpd.positionid = porb.positionid AND porb.posorgreltype = 'Budget'
							and current_date between porb.effectivedate and porb.enddate and current_timestamp between porb.createts and porb.endts
	LEFT OUTER JOIN organization_code ocd ON pord.organizationid = ocd.organizationid AND ocd.organizationtype = 'Dept'
							and current_date between ocd.effectivedate and ocd.enddate and current_timestamp between ocd.createts and ocd.endts
	LEFT OUTER JOIN org_rel orel ON pord.organizationid = orel.organizationid
							and current_date between orel.effectivedate and orel.enddate and current_timestamp between orel.createts and orel.endts
	LEFT OUTER JOIN organization_code ocdi ON orel.memberoforgid = ocdi.organizationid AND ocdi.organizationtype = 'Div'
							and current_date between ocdi.effectivedate and ocdi.enddate and current_timestamp between ocdi.createts and ocdi.endts
	LEFT OUTER JOIN organization_code ocb ON porb.organizationid = ocb.organizationid AND ocb.organizationtype = 'CC'
							and current_date between ocb.effectivedate and ocb.enddate and current_timestamp between ocb.createts and ocb.endts
	LEFT OUTER JOIN HCE ON dpd.positionid = HCE.positionid
	
