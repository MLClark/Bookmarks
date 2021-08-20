select * from posposmanagerdetail where positionid = '3271';
select * from person_names where lname like 'Adams%';
select * from pers_pos where personid = '4687';
select * from pers_pos where positionid = '3587';
select * from pos_pos where topositionid = '3271' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from pers_pos where positionid  = '3587';
select * from person_names where personid = '4663';
select * from position_desc where positionid = '3271';


select * from person_names where lname like 'Mark%';
select * from pers_pos where personid = '6343';
select * from posposmanagerdetail where positionid = '3551';
select * from posposmanagerdetail where positionid = '3624';
select * from position_desc where positionid in ('3624');


select * from pay_unit;

select * from pos_org_rel where organizationid in (select organizationid from organization_code where organizationtype = 'CC' and current_date between effectivedate and enddate and current_timestamp between createts and endts);
select * from organization_code where organizationtype = 'CC' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from organization_code where organizationtype = 'Div' and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from pos_org_rel where posorgreltype='Member';


select * from person_net_contacts where personid = '4675';


(select personid, url, enddate, max(effectivedate) as effectivedate, max(createts) as createts,  RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
             from person_net_contacts where netcontacttype = 'WRK' and effectivedate < enddate and current_timestamp between createts and endts
             and personid = '6224'
            group by personid, url, enddate)
            
            
            
select * from pos_org_rel where positionid ='3417';
select * from organization_code where organizationid = '62';
select * from organization_code where organizationid in (select organizationid from pos_org_rel where posorgreltype='Member'  and current_date between effectivedate and enddate and current_timestamp between createts and endts) and organizationtype = 'Div';

select * from person_locations where personid = '4510';

select * from location_address where locationid = '13';
select * from location_address where timezoneid is not null;

select * from time_zones tz ;
select * from location_codes where locationid = '1';

select * from salary_grade;


select * from person_compensation where personid = '4510';



select * from person_names where personid = '4510';

select * from position_desc where positionid = '3417'; 
select * from job_desc;