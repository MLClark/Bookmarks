select 
 oc.organizationid
,ocD.organizationid
,rtrim(ocD.orgcode,' ')as DepartmentCode
,rtrim(ocD.organizationdesc) as DepartmentDescription
,rtrim(oc.orgcode)as DivisionCode
,case ocD.enddate when '2199-12-31' then '0' else '1' end ::char(1) as disabled

from  organization_code oc
left join org_rel orid on orid.memberoforgid = oc.organizationid
 and current_date between orid.effectivedate and orid.enddate
 and current_timestamp between orid.createts and orid.endts
join organization_code ocD on ocD.organizationid = orid.organizationid
 and current_date between ocD.effectivedate and ocD.enddate
 and current_timestamp between ocD.createts and ocD.endts
 and ocD.organizationtype = 'Dept'


where current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts
  and oc.organizationtype = 'Div'
;  