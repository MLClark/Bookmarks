SELECT
 pi.personid
,pd.enddate
,pn.lname
,pn.fname
,coalesce(pd.positionxid, ' '):: char(12)  as current_position_code
,pp.positionid as current_position_id
,prev_pp.positionid as prior_position_id
,prev_pd.positionxid as prior_position_code
,coalesce(pd.positiontitle, ' '):: char(50) as current_position_title
,prev_pd.positiontitle as prev_position_title
,pd.grade:: char(6) as current_salary_grade_code
,prev_pd.grade as prev_salary_grade_code







from person_identity pi

LEFT JOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.effectivedate - interval '1 day' <> pn.enddate
 
left join public.person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join public.person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts

LEFT JOIN primarylocation pl
  ON pl.personid = pi.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_codes lc
  ON lc.locationid = pl.locationid
 AND current_date BETWEEN lc.effectivedate AND lc.enddate
 AND current_timestamp BETWEEN lc.createts AND lc.endts

left join pers_pos pp 
  on pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate
 AND current_timestamp BETWEEN pp.createts AND pp.endts

left JOIN position_desc pd 
  on pd.positionid  = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 AND current_timestamp BETWEEN pd.createts AND pd.endts

left join pers_pos prev_pp
  ON pp.personid = prev_PP.personid 
 and current_timestamp between prev_PP.createts and prev_PP.endts
 and prev_PP.effectivedate < prev_PP.enddate
 and prev_PP.enddate = pp.effectivedate - interval '1 day'
 
left join position_desc prev_PD 
  on prev_PD.positionid = prev_PP.positionid 
 and current_timestamp between prev_PD.createts and prev_PD.endts
 and current_date between prev_PD.effectivedate and prev_PD.enddate
 and prev_PD.effectivedate < prev_PD.enddate
 
 


left JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts

left join pos_org_rel por 
  on pp.positionid = por.positionid
 and por.posorgreltype = 'Member'
 and CURRENT_DATE between por.effectivedate and por.enddate
 and current_timestamp between por.createts and por.endts


left join organization_code oct 
  on oct.organizationid = por.organizationid 
 and oct.organizationtype =  'Div'
 and CURRENT_DATE BETWEEN oct.effectivedate AND oct.enddate 
 and CURRENT_TIMESTAMP BETWEEN oct.createts AND oct.endts


left join organization_code oc 
  on oc.organizationid = por.organizationid 
 and oc.organizationtype = 'Dept'
 and CURRENT_DATE BETWEEN oc.effectivedate AND oc.enddate 
 and CURRENT_TIMESTAMP BETWEEN oc.createts AND oc.endts    






where pi.identitytype = 'EmpNo' ::bpchar
and pc.compevent in ('Promo','Merit')
--and pi.personid =  '63526'  
order by personid

