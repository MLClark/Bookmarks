SELECT distinct 
 pi.personid
,'PROMOTIONS' ::varchar(30) as qsource 
--,pp.positionid
--,pc.compevent 
--,por.organizationid
--,org_rel.memberoforgid
,RTrim(Coalesce(pn.lname || ' ','') || Coalesce(pn.fname || ' ', '')|| Coalesce(pn.mname || ' ', ''))::char(60) as emp_name
,coalesce(pv.ethniccode,' ') ::char(1) as emp_ethnicity_code
,coalesce(pv.gendercode,' ') ::char(1) as emp_gender_code
,case when pp.persposevent in ('Trans','Promo' ) then to_char(pp.effectivedate,'MM/DD/YYYY') end :: char(10) as promo_eff_date
,case when lc.locationdescription = 'Home Office' then 'HO' 
      when lc.locationdescription = 'Agent' then 'FA'
      else 'FN' end :: char(4) as location_distinction_code

--,coalesce(pd.positionxid, ' '):: char(12) as job_code
,jd.jobcode :: char(12) as job_code
,coalesce(pd.positiontitle, ' '):: char(50) as position_title
,sg.salarygradedesc :: char(6) as salary_grade_code
,oc_div.orgcode :: char(10) as division_code
,oc.orgcode :: char(10) as department_code
,case when pe.emplclass = 'F' then 'F'
      when pe.emplclass = 'P' then 'P'
      else null end :: char(2)  as employee_class_value
   

,'1' ::char(1) as sort_seq

from person_identity pi
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts

join pers_pos pp 
  on  pp.personid = pi.personid 
 and pp.effectivedate < pp.enddate
 AND current_timestamp BETWEEN pp.createts AND pp.endts  

left join person_compensation pc
  on pc.personid = pp.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.compevent = 'Promo'  
 
JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left JOIN position_desc pd 
  on pd.positionid  = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 AND current_timestamp BETWEEN pd.createts AND pd.endts 

join position_job pj 
  on pj.positionid = pp.positionid
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts

join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts 

left join salary_grade sg 
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts

left join pos_org_rel por 
  on por.positionid = pp.positionid 
 and por.posorgreltype = 'Member'
 and por.enddate > elu.lastupdatets
 and current_timestamp between por.createts and por.endts
 and por.effectivedate <= elu.lastupdatets
                   
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

where (pp.persposevent = 'Promo' or pc.compevent = 'Promo')
  and pp.effectivedate >= elu.lastupdatets and pp.effectivedate < elu.lastupdatets + interval '1 month'
  --and current_date between pp.effectivedate and pp.enddate
  --and current_timestamp between pp.createts and pp.endts
  and date_part('month',pp.effectivedate) = date_part('month',elu.lastupdatets)
  and date_part('year',pp.effectivedate) = date_part('year',elu.lastupdatets)
  and pp.effectivedate is not null   
 
union 

SELECT distinct 
 pi.personid
,'GRADE CHANGES' ::varchar(30) as qsource 
--,pp.positionid
--,pc.compevent 
,RTrim(Coalesce(pn.lname || ' ','') || Coalesce(pn.fname || ' ', '')|| Coalesce(pn.mname || ' ', ''))::char(60) as emp_name
,coalesce(pv.ethniccode,' ') ::char(1) as emp_ethnicity_code
,coalesce(pv.gendercode,' ') ::char(1) as emp_gender_code
,case when pp.persposevent in ('Trans','Promo' ) then to_char(pp.effectivedate,'MM/DD/YYYY') end :: char(10) as promo_eff_date
,case when lc.locationdescription = 'Home Office' then 'HO' 
      when lc.locationdescription = 'Agent' then 'FA'
      else 'FN' end :: char(4) as location_distinction_code

--,coalesce(pd.positionxid, ' '):: char(12) as job_code
,jd.jobcode :: char(12) as job_code
,coalesce(pd.positiontitle, ' '):: char(50) as position_title
,sg.salarygradedesc :: char(6) as salary_grade_code

,oc_div.orgcode :: char(10) as division_code
,oc.orgcode :: char(10) as department_code
,case when pe.emplclass = 'F' then 'F'
      when pe.emplclass = 'P' then 'P'
      else null end :: char(2)  as employee_class_value
   

,'1' ::char(1) as sort_seq

from person_identity pi
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts

join pers_pos pp 
  on  pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate
 AND current_timestamp BETWEEN pp.createts AND pp.endts  

left join person_compensation pc
  on pc.personid = pp.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.compevent <> 'Promo'  
 
JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left JOIN position_desc pd 
  on pd.positionid  = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 AND current_timestamp BETWEEN pd.createts AND pd.endts 

join position_job pj 
  on pj.positionid = pp.positionid
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts

join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts 

left join salary_grade sg 
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts

left join pos_org_rel por 
  on por.positionid = pp.positionid 
 and por.posorgreltype = 'Member'
 and por.enddate > elu.lastupdatets
 and current_timestamp between por.createts and por.endts
 and por.effectivedate <= elu.lastupdatets
                   
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

where pp.personid in 

(
select distinct
 grade.personid as grade_personid 

from  

(
select distinct
 pp.personid
,pn.lname
,pn.fname
,pp.positionid as curpos
,pp.effectivedate as cur_effdt
,ppp.positionid as prevpos
,ppp.effectivedate as prev_effdt
,ppp.positionid as prevpos
,pc.compevent as pc_compevent
,pc.effectivedate as pc_effdt
,sg.salarygradedesc as cur_grade
,sgp.salarygradedesc as prev_grade


from pers_pos pp
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
left join person_compensation pc
  on pc.personid = pp.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 
left join pers_pos ppp
  on ppp.personid = pp.personid
 and date_part('year',ppp.enddate) = date_part('year',elu.lastupdatets)
 and date_part('month',ppp.enddate)= date_part('month',elu.lastupdatets)
 and ppp.effectivedate - interval '1 day' <> ppp.enddate
 
left join position_desc pd 
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts
 
left join position_desc pdp
  on pdp.positionid = ppp.positionid
 and current_timestamp between pdp.createts and pdp.endts
 
left join salary_grade sg 
  on sg.grade = pd.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts
 
left join salary_grade sgp
  on sgp.grade = pdp.grade
 and current_timestamp between sgp.createts and sgp.endts 

join person_names pn
  on pn.personid = pp.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
join position_job pj 
  on pj.positionid = pp.positionid
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts

join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts
  
where current_date between pp.effectivedate and pp.enddate
  and current_timestamp between pp.createts and pp.endts
  and date_part('year',pp.effectivedate) = date_part('year',elu.lastupdatets)
  and date_part('month',pp.effectivedate) = date_part('month',elu.lastupdatets)
  and pp.effectivedate >= elu.lastupdatets and pp.effectivedate < elu.lastupdatets + interval '1 month'
  and sgp.salarygradedesc > '00'
  and sgp.salarygradedesc < sg.salarygradedesc
  and (pp.persposevent in ('Trans') or (pc.compevent not in ('Adjust','Promo','PROMO') 
  and pc.effectivedate < elu.lastupdatets )) 
  --and pp.personid = '63103'
  
) as grade where grade.cur_grade <> grade.prev_grade ) 
 

 order by 1