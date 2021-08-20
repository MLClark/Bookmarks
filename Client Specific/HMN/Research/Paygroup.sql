select 
 oc.organizationid
,oc.orgcode ::char(5) as DivisionCode
,oc.organizationdesc ::char(30) as DivisionDescription
,case oc.enddate when '2199-12-31' then '0' else '1' end ::char(1) as Disabled
,orid.organizationid
,ocD.orgcode ::char(5) as DepartmentCode
,ocD.organizationdesc ::char(30) as DepartmentDescription
,case orid.enddate when '2199-12-31' then '0' else '1' end ::char(1) as Disabled
,oc.orgcode ::char(5) as DivisionParentCode


from  organization_code oc
join org_rel orid on orid.memberoforgid = oc.organizationid
 and current_date between orid.effectivedate and orid.enddate
 and current_timestamp between orid.createts and orid.endts
left join organization_code ocD on ocD.organizationid = orid.organizationid
 and current_date between ocD.effectivedate and ocD.enddate
 and current_timestamp between ocD.createts and ocD.endts
 and ocD.organizationtype = 'Dept'


where current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts
  and oc.organizationtype = 'Div'
;  