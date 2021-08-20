select distinct
 pi.personid
,pi.identity as empnbr
,pe.emplstatus
,pe.emplclass
,pn.fname ::varchar(64) as fname
,'"'||pn.lname||'"' ::varchar(64) as lname
,pn.mname ::char(1) as mname
,pd.positiondescpid
,'"'||pd.positiontitle||'"' ::varchar(64) as job_title
--,pp.positionid 
--,pord.organizationid as pord
--,porb.organizationid as porb
--,orel.memberoforgid as orel
--,ocd.organizationdesc as ocd
--,ocdiv.organizationdesc as ocdiv
--,ocdbu.organizationdesc as ocdbu
,coalesce(ocd.organizationdesc,ocdiv.organizationdesc,ocdbu.organizationdesc,'N/A') as department
,'"'||lc.locationdescription||'"' as work_location
,to_char(pp.effectivedate,'mm/dd/yyyy')::char(10) as position_start_date 
,to_char(pd.effectivedate,'mm/dd/yyyy')::char(10) as title_start_date 
,case when pe.employmenttype = 'P' then 'YES' else 'NO' end ::char(3) as is_primary 
,pis.identity as ssn
,pp.persposevent as event_name
,cpd.compplandesc as comp_plan_code

from person_identity pi

left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_identity pis
  on pis.personid = pi.personid 
 and pis.identitytype = 'SSN'
 and current_timestamp between pis.createts and pis.endts

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join pers_pos pp
  on pp.personid = pi.personid
 and pp.effectivedate < pp.enddate

left join position_desc pd
  on pd.positionid = pp.positionid
 and pd.effectivedate < pd.enddate   
 
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
 
left JOIN organization_code ocdiv
  ON ocdiv.organizationid = orel.memberoforgid
 AND ocdiv.organizationtype = 'Div'
 and current_date between ocdiv.effectivedate and ocdiv.enddate 
 and current_timestamp between ocdiv.createts and ocdiv.endts

LEFT JOIN organization_code ocd 
  ON ocd.organizationid = pord.organizationid 
 AND ocd.organizationtype = 'Dept'
 and current_date between ocd.effectivedate and ocd.enddate 
 and current_timestamp between ocd.createts and ocd.endts 

LEFT JOIN organization_code ocdbu
  ON ocdbu.organizationid = pord.organizationid 
 AND ocdbu.organizationtype = 'BU'
 and current_date between ocdbu.effectivedate and ocdbu.enddate 
 and current_timestamp between ocdbu.createts and ocdbu.endts
 
left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts
 
left join location_codes lc
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts  
 
left join position_comp_plan pcp 
  on pcp.positionid = pp.positionid
 and current_date between pcp.effectivedate and pcp.enddate
 and current_timestamp between pcp.createts and pcp.endts
	
left join comp_plan_desc cpd 
  on cpd.compplanid = pcp.compplanid
 and current_date between cpd.effectivedate and cpd.enddate
 and current_timestamp between cpd.createts and cpd.endts   

where pi.identitytype = 'EmpNo'
  and current_timestamp between pi.createts and pi.endts 

  order by personid 
