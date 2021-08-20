
select * from person_names where lname like 'Autry' and current_date between effectivedate and enddate and current_timestamp between createts and endts and nametype = 'Legal';
select * from person_names where lname like 'Bias' and current_date between effectivedate and enddate and current_timestamp between createts and endts and nametype = 'Legal';
select * from person_names where lname like 'Howard' and current_date between effectivedate and enddate and current_timestamp between createts and endts and nametype = 'Legal';
select * from person_names where lname like 'Maw' and current_date between effectivedate and enddate and current_timestamp between createts and endts and nametype = 'Legal';
select * from person_names where lname like 'Wright' and current_date between effectivedate and enddate and current_timestamp between createts and endts and nametype = 'Legal';


select * from cognos_pspaypayrollregistertaxes_winter_mv where personid in ('13609', '13638', '10309', '10662', '10660') 
   and etv_id = 'T02' and check_date = '2021-08-05';