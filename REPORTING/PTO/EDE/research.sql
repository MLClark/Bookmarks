select * from timeoffusagehistory  ;
select * from personptoactivityplanyrbal ;
select * from pspay_employee_profile;
select * from person_names where lname like 'Bart%';
select * from person_names where personid = '433';

select * from person_pto_activity_request  where personid = '106' and date_part('year',effectivedate) = '2021';
select * from timeoffusagehistory where personid = '106' ;
select * from personptorequests where personid = '106';
select * from person_pto_request_group   where personid = '106' and date_part('year',effectivedate) = '2021';
select * from person_pto_activity_request where personid = '433';
select * from payroll.payment_detail where personid = '433' and paycode = 'E20';