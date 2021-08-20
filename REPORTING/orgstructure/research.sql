select * from cognos_orgstructure ;
select * from company_organization_rel;

select * from organization_code where current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from org_rel where orgreltype = 'Management' and current_date between effectivedate and enddate and current_timestamp between createts and endts;




