select distinct
 pi.personid
,pn.lname
,pn.fname
,pj.positionid as position_code

,pd.positiontitle as position_title
,jcd.eeocode as EEO1Code
,Case When jd.flsacode = 'E' Then 'Exempt'	Else 'Non-Exempt' End as flsa
,dpd.salarygradedesc as SalaryGradeLevel
,jcd.jobcode as PositionExternalID  -------- change this to job code is A560001 should be A5600 FROM jobcodedetail
,oc_div.orgcode as division_code
,oc_cc.orgcode as BudgetOrg 
,oc_cc.organizationxid 
,ot.organizationtypedesc
,oc.organizationdesc
,ocd.orgcode as DepartmentCode
,pmd.current_manager || '-' || pmd.mgrpersonid as DirectManager
,pmd.occupiedby || '-' || HCE.personid as CurrentIncumbent
,lc.locationCode || ': ' || lc.locationdescription as PlannedLocation
,oc_cc.effectivedate as ocb_effdate

--,sg.salaryminimum::integer as Minimum
--,sg.salarymaximum::integer as Maximum
,'0' as ShiftDifferential
,sgrf.salarygraderegiondesc as AreaSalaryDifferential
,Case When HCE.hce_ind is Null Then 'N' Else 'Y' End as HCEIndicator
,pmd.current_manager as ManagerFullName
,case dpd.enddate when '2199-12-31' then '0' else '1' end ::char(1) as Disabled



from person_identity pi 

join person_names pn
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'
 
left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 and pp.effectivedate - interval '1 day' <> pp.enddate 
 
left join 
     (
     Select distinct pp.personid, pp.positionid, pc.hce_Ind
       From pers_pos pp
		 JOIN person_compensation pc 
		   ON pc.personid = pp.personid
		group by 1,2,3
	  ) as HCE
  on hce.personid = pi.personid			
 
left join 
     (
      Select distinct pp.personid as mgrpersonid, ppm.*
        From posposmanagerdetail ppm
		  LEFT OUTER JOIN pers_pos pp 
		    ON pp.positionid = ppm.mgrpositionid
		   AND current_date between pp.effectivedate and pp.enddate 
		   AND current_timestamp between pp.createts and pp.endts
		   and pp.effectivedate - interval '1 day' <> pp.enddate
       Where current_date between ppm.effectivedate and ppm.enddate 
         AND current_timestamp between ppm.createts and ppm.endts
         and ppm.effectivedate - interval '1 day' <> ppm.enddate
      )	as pmd
  on pmd.mgrpersonid = pi.personid 

left join 
      (
         Select distinct pd.positionid, sgr.*
           From positiondetails pd
	        JOIN salary_grade_ranges sgr 
	          ON sgr.grade pd.grade
	         AND sgr.edtcode = 'Regular' 
	         AND frequencycode = 'A'
			   and current_date between sgr.effectivedate and sgr.enddate AND current_timestamp between sgr.createts and sgr.endts
							
Where current_date between pd.effectivedate and pd.enddate)
  on 
left join position_job pj
  on pj.positionid = hce.positionid
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts
 
left join position_desc pd
  on pd.positionid = pj.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts

left join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts 
  
--left join dcpositiondesc dpd
 -- on dpd.positionid = hce.positionid
  
left join jobcodedetail jcd
  on jcd.jobid = pj.jobid
 and current_date between jcd.effectivedate and jcd.enddate
 and current_timestamp between jcd.createts and jcd.endts
 and jcd.effectivedate - interval '1 day' <> jcd.enddate							
							
left join pos_org_rel porm
  on porm.positionid = pp.positionid
 and porm.posorgreltype = 'Member'
 and current_date between porm.effectivedate and porm.enddate
 and current_timestamp between porm.createts and porm.endts
 and porm.effectivedate - interval '1 day' <> porm.enddate 

left join organization_code ocd
  on ocd.organizationid = porm.organizationid
 and current_date between ocd.effectivedate and ocd.enddate 
 and current_timestamp between ocd.createts and ocd.endts
 and ocd.effectivedate - interval '1 day' <> ocd.enddate
 
left join org_rel orel
  on orel.organizationid = porm.organizationid
 and current_date between orel.effectivedate and orel.enddate
 and current_timestamp between orel.createts and orel.endts
 and orel.effectivedate - interval '1 day' <> orel.enddate	
 
left join organization_code oc_div 
  on oc_div.organizationid = orel.memberoforgid
 and oc_div.organizationtype = 'Div'
 and current_date between oc_div.effectivedate and oc_div.enddate
 and current_timestamp between oc_div.createts and oc_div.endts
 and oc_div.effectivedate - interval '1 day' <> oc_div.enddate  

left join pos_org_rel porb
  on porb.positionid = pp.positionid
 and porb.posorgreltype = 'Budget'
 and current_date between porb.effectivedate and porb.enddate
 and current_timestamp between porb.createts and porb.endts
 and porb.effectivedate - interval '1 day' <> porb.enddate 
        

left join organization_code oc_dept
  ON oc_dept.organizationid = porm.organizationid
 AND oc_dept.organizationtype = 'Dept'
 and current_date between oc_dept.effectivedate and oc_dept.enddate 
 and current_timestamp between oc_dept.createts and oc_dept.endts 
 and oc_dept.effectivedate - interval '1 day' <> oc_dept.enddate  
 
left join organization_code oc_cc
  ON oc_cc.organizationid = porb.organizationid
 AND oc_cc.organizationtype = 'CC'
 and current_date between oc_cc.effectivedate and oc_cc.enddate 
 and current_timestamp between oc_cc.createts and oc_cc.endts 
 and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate

left join organization_code oc
  on current_date between oc.effectivedate and oc.enddate 
 and current_timestamp between oc.createts AND oc.endts 
 and oc.organizationxid = oc_cc.organizationxid
 
LEFT JOIN organization_type ot 
  ON ot.organizationtype = oc.organizationtype
 
left join position_location pl 
  ON pl.positionid = hce.positionid
 and current_date between pl.effectivedate and pl.enddate 
 and current_timestamp between pl.createts and pl.endts 
 and pl.effectivedate - interval '1 day' <> pl.enddate

left join location_codes lc 
  ON lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate 
 and current_timestamp between lc.createts and lc.endts 
 and lc.effectivedate - interval '1 day' <> lc.enddate

left join salarygraderegionsform sgrf 
  ON sgrf.salarygraderegion = lc.salarygraderegion
 
left join rpt_orgstructure rorg
  on rorg.org1id = oc_dept.organizationid
 and current_date between rorg.org1effdt and rorg.org1enddt
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and dpd.positionid is not null
