----- division

select * from person_employment where personid = '67574';
select * from edi.edi_last_update;

---- budgetnum

left join pos_org_rel porB on porB.positionid = ed.positionid
     and current_date between porB.effectivedate and porB.enddate
     and current_timestamp between porB.createts and porB.endts
     and porB.posorgreltype = 'Budget'
left join organization_code ocBudget on porB.organizationid = ocBudget.organizationid
     and current_date between ocBudget.effectivedate and ocBudget.enddate
     and current_timestamp between ocBudget.createts and ocBudget.endts

insert into edi.edi_last_update (feedid,lastupdatets) values ('HMN_PS_LMSGet','1900-01-01 00:00:00');
update  edi.edi_last_update set lastupdatets = '1900-01-01 00:00:00' where feedid = 'HMN_PS_LMSGet';

select * from pers_pos where personid = '68850';

select * from pos_org_rel where posorgreltype = 'Budget' and current_date between effectivedate and enddate and current_timestamp between createts and endts and positionid = '400657';


select * from organization_code where organizationid  in ('1450')  and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from pos_org_rel where posorgreltype = 'Budget' and effectivedate < enddate and current_timestamp between createts and endts and positionid = '405903';


select * from pos_org_rel where posorgreltype = 'Budget' and positionid = '400657';
(select positionid, organizationid, rank() over (partition by positionid order by max(effectivedate) desc) as rank
             from pos_org_rel where posorgreltype = 'Budget' and effectivedate < enddate and current_timestamp between createts and endts and current_date >= effectivedate and positionid = '400657'
            group by positionid, organizationid)
     
     
     
     [Yesterday 9:19 AM] Debbie Flynn
    
paycodeaffiliationid_seq
?[Yesterday 9:20 AM] Debbie Flynn
    
select nextval('paycodeaffiliationid_seq') from dual
