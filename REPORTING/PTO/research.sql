select * from person_pto_activity_request where personid = '13739'
and current_date between effectivedate and enddate and current_timestamp between createts and endts;
--select * from person_pto_activity_request;
select * from pto_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts
and ptoplanid in (2,5);
--select * from person_names where lname like 'Abra%';
select * from personptomaxbalance where personid = '13739' and asofdate = current_date and ptoplanid in (2,5);