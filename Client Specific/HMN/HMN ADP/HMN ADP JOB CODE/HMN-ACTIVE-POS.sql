select distinct

 pd.positionid ::char(8) as positioncode
,porb.organizationid  
,pd.positiontitle ::varchar(64) as positiondesc
,fjc.federaljobcode ::varchar(255) as federaljobcode
,jd.eeocode ::char(2) as eeo1code
,case When jd.flsacode = 'E' Then 'Exempt'
		Else 'Non-Exempt' End ::varchar(15) as flsa
,sg.salarygradedesc ::char(2) as salarygradelevel
,jd.jobcode
,coalesce(ocdi.orgcode,ocd.orgcode) ::char(2) as divisioncode
,ocd.orgcode as departmentcode
,coalesce(pmd.current_manager) || '-' || coalesce(pmd.mgrpersonid) as DirectManager
,coalesce(pmd.occupiedby) || '-' || coalesce(HCE.personid) as CurrentIncumbent
,lc.locationCode || ': ' || lc.locationdescription as PlannedLocation
,lc.salarygraderegion
,ocb.orgcode as BudgetOrg
,coalesce(sg3.salaryminimum)::integer as Minimum
,coalesce(sg3.salarymaximum)::integer as Maximum
,'0' ::char(1) as ShiftDifferential
,sgrf.salarygraderegiondesc as AreaSalaryDifferential
,Case When HCE.hce_ind is Null Then 'N' Else 'Y' End ::char(1) as HCEIndicator
,coalesce(pmd.current_manager) as ManagerFullName
,case pd.enddate when '2199-12-31' then '0' else '1' end ::char(1) as Disabled

from position_desc pd

join position_job pj 
  on pj.positionid = pd.positionid
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts

left join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts 

left join federal_job_code fjc
  on fjc.federaljobcodeid = jd.federaljobcodeid 

left join salary_grade sg
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts  
 
left join pos_org_rel porb 
  ON porb.positionid = pd.positionid 
 AND porb.posorgreltype = 'Budget' 
 and current_date between porb.effectivedate and porb.enddate 
 and current_timestamp between porb.createts and porb.endts
 and porb.enddate = '2199-12-31'
 
left join pos_org_rel pord
  on pord.positionid = pd.positionid 
 and pord.posorgreltype = 'Member'
 and current_date between pord.effectivedate and pord.enddate 
 and current_timestamp between pord.createts and pord.endts
 
left JOIN org_rel orel 
  ON orel.organizationid = pord.organizationid
 and current_date between orel.effectivedate and orel.enddate 
 and current_timestamp between orel.createts and orel.endts

left join organization_code ocb 
  ON ocb.organizationid = porb.organizationid 
 AND ocb.organizationtype = 'CC'
 and current_date between ocb.effectivedate and ocb.enddate 
 and current_timestamp between ocb.createts and ocb.endts
 
left JOIN organization_code ocdi
  ON ocdi.organizationid = orel.memberoforgid
 AND ocdi.organizationtype = 'Div'
 and current_date between ocdi.effectivedate and ocdi.enddate 
 and current_timestamp between ocdi.createts and ocdi.endts

LEFT JOIN organization_code ocd 
  ON ocd.organizationid = pord.organizationid 
 AND ocd.organizationtype = 'Dept'
 and current_date between ocd.effectivedate and ocd.enddate 
 and current_timestamp between ocd.createts and ocd.endts 
 
left join ( Select distinct pp.personid as mgrpersonid, ppm.*
              From posposmanagerdetail ppm
		        LEFT JOIN pers_pos pp 
		          ON ppm.mgrpositionid = pp.positionid
					AND current_date between pp.effectivedate and pp.enddate 
					AND current_timestamp between pp.createts and pp.endts
             Where current_date between ppm.effectivedate and ppm.enddate
               AND current_timestamp between ppm.createts and ppm.endts
           ) pmd on pmd.positionid = pd.positionid                          

left join ( Select distinct pp.positionid, pp.personid, pc.hce_Ind
              From pers_pos pp
		        JOIN person_compensation pc 
		          ON pp.personid = pc.personid
		         and current_date between pc.effectivedate and pc.enddate
		         and current_timestamp between pc.createts and pc.endts
		       where current_date between pp.effectivedate and pp.enddate
		         and current_timestamp between pp.createts and pp.endts
		        group by 1,2,3
		     ) hce on hce.positionid = pd.positionid


left join position_location pl 
  ON pl.positionid = pd.positionid
 and current_date between pl.effectivedate and pl.enddate 
 and current_timestamp between pl.createts and pl.endts
 
LEFT JOIN location_codes lc
  ON pl.locationid = lc.locationid
 and current_date between lc.effectivedate and lc.enddate 
 and current_timestamp between lc.createts and lc.endts

left JOIN salarygraderegionsform sgrf 
  ON sgrf.salarygraderegion = lc.salarygraderegion
 and current_date between sgrf.effectivedate and sgrf.enddate 
 and current_timestamp between sgrf.createts and sgrf.endts


left join (  select distinct pd.positionid,sgr.salarygraderegion,sgr.grade,sgr.salaryminimum,sgr.salarymaximum, max(salarygraderangepid) as salarygraderangepid
               from salary_grade_ranges sgr
               join position_desc pd 
                 on pd.grade = sgr.grade
               where sgr.frequencycode = 'A' 
                 and sgr.edtcode = 'Regular' 
                 and current_date between sgr.effectivedate and sgr.enddate 
                 and current_timestamp between sgr.createts and sgr.endts	
              --   and pd.positionid in ('389557','389496','389427','389432','389511','389541','402571')
                 group by 1,2,3,4,5
         ) sg3 on sg3.positionid = pd.positionid 
              and sg3.salarygraderegion = lc.salarygraderegion             
           

where current_timestamp between pd.createts and pd.endts
--AND PD.POSITIONID = '405111'
and pd.enddate = '2199-12-31'

  
--  and pd.positionid in ('389557','389496','389427','389432','389511','389541','402571')


