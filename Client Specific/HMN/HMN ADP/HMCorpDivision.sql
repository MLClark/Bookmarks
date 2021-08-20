/*
Marsha - For the division file I was expecting about 23 entries and only got 15.... missing Division code HA, MA, NO, NW, as an example
*/

select DISTINCT
 oc.organizationid
,rtrim(oc.orgcode,' ') ::char(5) as DivisionCode
,rtrim(ltrim(oc.organizationdesc,' '),' ') ::char(30) as DivisionDescription
,case oc.enddate when '2199-12-31' then '0' else '1' end ::char(1) as Disabled

from  organization_code oc
left join org_rel orid on orid.memberoforgid = oc.organizationid
 and current_date between orid.effectivedate and orid.enddate
 and current_timestamp between orid.createts and orid.endts
where current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts
  and oc.organizationtype = 'Div'
  and oc.organizationid > 1
  ORDER BY 1
;  