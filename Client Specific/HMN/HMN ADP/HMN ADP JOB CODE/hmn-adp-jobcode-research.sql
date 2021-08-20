-- a position can be active on position_jobs and inactive on position_desc
select * from position_desc where current_timestamp between createts and endts --and current_date between effectivedate and enddate
  and positionid in ('389504','389427')
  ;
select * from position_desc where current_timestamp between createts and endts --and current_date between effectivedate and enddate
  and positionid in ('389504','389427')
  ;  
select * from position_job where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and positionid in ('389504','389427')
  ;
-- a job desc can be active on job_desc if position is inactive
select * from job_desc where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and jobid in (select jobid from position_job where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and positionid in ('389504','389427'))
  ;
-- the salary grade is active but not accessible if using current date logic on position_desc  
select * from salary_grade where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and grade in (select grade from position_desc where current_timestamp between createts and endts --and current_date between effectivedate and enddate
  and positionid in ('389504','389427'))
  ;
-- the budget org relation is active but not accessible if using current date logic on position_desc  
select * from pos_org_rel where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and posorgreltype = 'Budget' 
  and positionid in (select positionid from position_desc where current_timestamp between createts and endts --and current_date between effectivedate and enddate
  and positionid in ('389504','389427'))
  ;
-- the member relation is active but not accessible if using current date logic on position_desc  
select * from pos_org_rel where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and posorgreltype = 'Member' 
  and positionid in (select positionid from position_desc where current_timestamp between createts and endts --and current_date between effectivedate and enddate
  and positionid in ('389504','389427'))
  ;
-- budget rel types don't map to org_rel  
select * from org_rel where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and organizationid in (select organizationid from pos_org_rel where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and posorgreltype = 'Budget' 
  and positionid in (select positionid from position_desc where current_timestamp between createts and endts --and current_date between effectivedate and enddate
  and positionid in ('389504','389427')))
  ;
-- map to org_rel using Member org rel type  
select * from org_rel where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and organizationid in (select organizationid from pos_org_rel where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and posorgreltype = 'Member' 
  and positionid in (select positionid from position_desc where current_timestamp between createts and endts --and current_date between effectivedate and enddate
  and positionid in ('389504','389427')))
  ;  
-- map to organization code by budget type  organizationtype = CC (cost centers)
select * from organization_code where current_timestamp between createts and endts and current_date between effectivedate and enddate
  --and organizationtype = 'CC'
  and organizationid in (select organizationid from pos_org_rel where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and posorgreltype = 'Budget' 
  and positionid in (select positionid from position_desc where current_timestamp between createts and endts --and current_date between effectivedate and enddate
  and positionid in ('389504','389427')))
  ;  
-- map to organization code by member type    organizationtype = Dept
select * from organization_code where current_timestamp between createts and endts and current_date between effectivedate and enddate
  --and organizationtype = 'Dept'
  and organizationid in (select organizationid from pos_org_rel where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and posorgreltype = 'Member' 
  and positionid in (select positionid from position_desc where current_timestamp between createts and endts --and current_date between effectivedate and enddate
  and positionid in ('389504','389427')))
  ;    
-- map to organization code by member type    organizationtype = Div using memberoforgid from org_rel
select * from organization_code where current_timestamp between createts and endts and current_date between effectivedate and enddate
  --and organizationtype = 'Div'
  and organizationid in (select memberoforgid from org_rel where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and organizationid in (select organizationid from pos_org_rel where current_timestamp between createts and endts and current_date between effectivedate and enddate
  and posorgreltype = 'Member' 
  and positionid in (select positionid from position_desc where current_timestamp between createts and endts --and current_date between effectivedate and enddate
  and positionid in ('389504','389427'))))
  ;    
  


  