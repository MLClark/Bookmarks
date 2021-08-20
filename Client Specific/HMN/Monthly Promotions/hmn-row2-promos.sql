SELECT distinct
 pi.personid
,'PROMOTIONS' ::varchar(30) as qsource  

,pd.enddate
,pn.lname
,pn.fname

,jd.jobcode :: char(12) as prior_position_code
,jd.jobdesc :: char(25) as prior_position_title
,sg.salarygradedesc as prior_salary_grade_code


,'2' ::char(1) as sort_seq

from person_identity pi
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'

jOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.effectivedate - interval '1 day' <> pn.enddate

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
LEFT JOIN person_locations pl
  ON pl.personid = pi.personid
 AND current_date BETWEEN pl.effectivedate AND pl.enddate
 AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_codes lc
  ON lc.locationid = pl.locationid
 AND current_date BETWEEN lc.effectivedate AND lc.enddate
 AND current_timestamp BETWEEN lc.createts AND lc.endts

left join (select personid, positionid, persposevent, max(effectivedate) as effectivedate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
             from pers_pos
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
            where current_timestamp between createts and endts and effectivedate < enddate
              and date_part('year',effectivedate) = date_part('year',elu.lastupdatets)
              and date_part('month',effectivedate) = date_part('month',elu.lastupdatets)
            group by personid, positionid, persposevent) pp on pp.personid = pi.personid and pp.rank = 1

left join person_compensation pc
  on pc.personid = pp.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.compevent = 'Promo'   

left JOIN position_desc pd 
  on pd.positionid  = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 AND current_timestamp BETWEEN pd.createts AND pd.endts

left join (select personid, positionid, max(effectivedate) as effectivedate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
            from pers_pos 
            LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'
           where current_timestamp between createts and endts and effectivedate < enddate
             and effectivedate < elu.lastupdatets
           group by personid, positionid) prev_pp on prev_pp.personid = pp.personid and prev_pp.rank = 1

left join (select positionid, positiontitle, grade, max(effectivedate) as effectivedate, rank() over(partition by positionid order by max(effectivedate) desc) as rank
             from position_desc where current_timestamp between createts and endts and effectivedate < enddate
            group by positionid, positiontitle, grade) prev_pd on prev_pd.positionid = prev_pp.positionid and prev_pd.rank = 1 

left join position_job pj 
  on pj.positionid = prev_pp.positionid 
 --and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts
 
left join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts 

left join salary_grade sg 
  on sg.grade = prev_PD.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts 

left JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts

left join pos_org_rel por 
  on por.positionid = pp.positionid 
 and por.posorgreltype = 'Member'
 and por.enddate > elu.lastupdatets
 and current_timestamp between por.createts and por.endts
 and por.effectivedate <= elu.lastupdatets

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

where (pp.persposevent = 'Promo' or pc.compevent = 'Promo')
  and pp.effectivedate is not null   
  AND jd.jobcode IS NOT NULL 
   
  
  UNION 

SELECT distinct
 pi.personid
,'GRADE CHANGES' ::varchar(30) as qsource  
,pd.enddate
,pn.lname
,pn.fname
--,prev_pp.positionid as prior_position_id
,jd.jobcode :: char(12) as prior_position_code
---,prev_pd.positionxid as prior_position_code
,prev_pd.positiontitle :: char(25) as prior_position_title
,sg.salarygradedesc as prior_salary_grade_code


,'2' ::char(1) as sort_seq



from person_identity pi
LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'HMN_Monthly_Promotion_Report'

jOIN person_names pn 
  ON pn.personid = pi.personid 
 AND pn.nametype = 'Legal'::bpchar 
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.effectivedate - interval '1 day' <> pn.enddate

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
LEFT JOIN person_locations pl
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

left join person_compensation pc
  on pc.personid = pp.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.compevent = 'Promo'   

left JOIN position_desc pd 
  on pd.positionid  = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 AND current_timestamp BETWEEN pd.createts AND pd.endts

left join pers_pos prev_pp
  ON prev_PP.personid = pp.personid
 and current_timestamp between prev_PP.createts and prev_PP.endts
 and prev_PP.effectivedate < prev_PP.enddate
 and prev_PP.enddate = pp.effectivedate - interval '1 day'

left join position_desc prev_PD 
  on prev_PD.positionid = prev_PP.positionid 
 and prev_pd.positiondescpid = (select max(positiondescpid) 
                                  from position_desc 
                                 where positionid = prev_PP.positionid)

left join position_job pj 
  on pj.positionid = prev_pp.positionid 
 and elu.lastupdatets between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts

left join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts 

left join salary_grade sg 
  on sg.grade = prev_PD.grade
 and current_date between sg.effectivedate and sg.enddate
 and current_timestamp between sg.createts and sg.endts 

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
  and (pp.persposevent in ('Trans') or (pc.compevent not in ('Adjust','Promo','PROMO') and pc.effectivedate < elu.lastupdatets )) 

  --and pp.personid in ('66246','65735')
) as grade where grade.cur_grade <> grade.prev_grade ) 
 
 order by 1