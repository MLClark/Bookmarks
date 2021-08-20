



select distinct
 list1.personid 
,list1.f5_emp_name 
,list1.positionid 
,min(list1.orgcode) as orgcode
,min(list1.organizationid) as organizationid
from 
(


select distinct
 pi.personid 
,pn.lname||', '||pn.fname||' '||COALESCE(pn.mname,'') ::varchar(60) as f5_emp_name 
,oc_cc.orgcode
,pp.positionid 
,porb.organizationid

 
from person_identity pi

join person_names pn
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

join pers_pos pp 
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
left join pos_org_rel porb
  ON porb.positionid = PP.positionid 
 AND porb.posorgreltype = 'Budget' 
 and porb.posorgrelevent = 'NewOrgRel' 
 and current_date > porb.effectivedate and porb.enddate <> '2199-12-31'
 and current_timestamp between porb.createts and porb.endts
 
left join organization_code oc_cc
  ON oc_cc.organizationid = porb.organizationid
 AND oc_cc.organizationtype = 'CC'
 and current_date between oc_cc.effectivedate and oc_cc.enddate 
 and current_timestamp between oc_cc.createts and oc_cc.endts 
 
    
where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and oc_cc.orgcode is not null

union

select distinct
 pi.personid 
,pn.lname||', '||pn.fname||' '||COALESCE(pn.mname,'') ::varchar(60) as f5_emp_name 
,oc_cc.orgcode
,pp.positionid 
,porb.organizationid

 
from person_identity pi

join person_names pn
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

join pers_pos pp 
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
left join pos_org_rel porb
  ON porb.positionid = PP.positionid 
 AND porb.posorgreltype = 'Budget' 
 and porb.posorgrelevent = 'NewPos'
 and current_date > porb.effectivedate and porb.enddate <> '2199-12-31'
 and current_timestamp between porb.createts and porb.endts
 
left join organization_code oc_cc
  ON oc_cc.organizationid = porb.organizationid
 AND oc_cc.organizationtype = 'CC'
 and current_date between oc_cc.effectivedate and oc_cc.enddate 
 and current_timestamp between oc_cc.createts and oc_cc.endts 
 
    
where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and oc_cc.orgcode is not null
  --and pi.personid = '63613' 
  order by f5_emp_name 
) list1
group by 1,2,3
order by f5_emp_name 