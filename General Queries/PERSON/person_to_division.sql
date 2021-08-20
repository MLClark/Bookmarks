SELECT distinct 
 pi.personid
,pp.positionid 
,por.organizationid
,org_rel.memberoforgid
,pj.jobid
,jd.jobdesc
,pd.positiontitle as position_title
,jd.flsacode
,jd.eeocode
------ use this for division code
,oc_div.orgcode
,oc_div.organizationdesc
,oc.organizationtype as org_type
,oc.orgcode :: char(10) as department_code
,pd.grade :: char(6) as salary_grade_code

,RTrim(Coalesce(pn.lname || ' ','') || Coalesce(pn.fname || ' ', '')|| Coalesce(pn.mname || ' ', ''))::char(60) as emp_name

,case when pp.persposevent = 'Promo' then to_char(pp.effectivedate,'YYYY-MM-DD') end :: char(10) as promo_eff_date
,case when lc.locationdescription = 'Home Office' then 'HO' 
      when lc.locationdescription = 'Agent' then 'FA'
      else 'FN' end :: char(4) as location_distinction_code

,coalesce(pd.positionxid, ' '):: char(12) as position_code


,case when pe.emplclass = 'F' then 'F'
     when pe.emplclass = 'P' then 'P'
     else null end :: char(2)  as employee_class_value



from person_identity pi

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join public.person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts
 
left join pers_pos pp 
  on  pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate
 AND current_timestamp BETWEEN pp.createts AND pp.endts 
 
left JOIN position_desc pd 
  on pd.positionid  = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 AND current_timestamp BETWEEN pd.createts AND pd.endts 

left join pos_org_rel por 
  on por.positionid = pp.positionid 
 and por.posorgreltype = 'Member'
 and CURRENT_DATE between por.effectivedate and por.enddate
 and current_timestamp between por.createts and por.endts
                   
leFT JOIN edi.edi_last_update ed
  ON ed.feedid = 'HMN_Monthly_Promotion_Report'

left join organization_code oc
  on oc.organizationid = por.organizationid 
 and oc.organizationtype in ('Div', 'Dept')
 and CURRENT_DATE BETWEEN oc.effectivedate AND oc.enddate 
 and CURRENT_TIMESTAMP BETWEEN oc.createts AND oc.endts   
  
left join organization_code oc_dept
  on oc_dept.organizationid = por.organizationid 
 and oc_dept.organizationtype = 'Dept'
 and CURRENT_DATE BETWEEN oc_dept.effectivedate AND oc_dept.enddate 
 and CURRENT_TIMESTAMP BETWEEN oc_dept.createts AND oc_dept.endts 

left join organization_code oco 
  on oco.organizationid = por.organizationid 
 and CURRENT_DATE BETWEEN oco.effectivedate AND oco.enddate 
 and CURRENT_TIMESTAMP BETWEEN oco.createts AND oco.endts
 
LEFT JOIN primarylocation pl
  ON pl.personid = pi.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts 

LEFT JOIN location_codes lc
  ON lc.locationid = pl.locationid
 AND current_date BETWEEN lc.effectivedate AND lc.enddate
 AND current_timestamp BETWEEN lc.createts AND lc.endts 

LEFT JOIN org_rel org_rel 
  ON org_rel.organizationid = oc.organizationid 
 and org_rel.orgreltype = 'Management'::bpchar   
 AND current_date between org_rel.effectivedate AND org_rel.enddate 
 AND current_timestamp between org_rel.createts AND org_rel.endts

left join organization_code oc_div 
  on oc_div.organizationid = org_rel.memberoforgid
 and oc_div.organizationtype =  'Div'
 and CURRENT_DATE BETWEEN oc_div.effectivedate AND oc_div.enddate 
 and CURRENT_TIMESTAMP BETWEEN oc_div.createts AND oc_div.endts     

left join position_job pj
  on pj.positionid = pp.positionid 
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts

left join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts 

where pi.identitytype = 'EmpNo' ::bpchar
--and pp.persposevent = 'Promo'
AND current_timestamp BETWEEN pi.createts AND pi.endts
and pi.personid = '65915'