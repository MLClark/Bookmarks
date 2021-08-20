select * from cognos_orgstructure co
left join pos_org_rel por on co.org1id = por.organizationid and por.posorgreltype = 'Member'
and current_date between por.effectivedate and por.enddate
and current_timestamp between por.createts and por.endts
where org1desc = 'Sysco'
and positionid = 3386;


select * from cognos_orgstructure ;
select * from org_rel where orgreltype = 'Management' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from organization_code where current_date between effectivedate and enddate and current_timestamp between createts and endts;


select * from company_organization_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts ;


