select * from person_user_field_vals where personid = '62958' and createts::date = current_date-interval '1 day';

select * from person_user_field_vals where ufid = '9'  and personid = '62958';
select * from person_names where personid = '62958';

select * from person_identity where personid = '64567';
delete from person_user_field_vals where createts::date  = current_date::date;

select distinct 
 pi.personid
,coalesce((select max(persufpid) from person_user_field_vals  where pv.personid = personid), 0)::integer as maxpersufpid
from person_identity pi
left join person_user_field_vals as pv on pv.personid = pi.personid
where pi.identitytype = 'EmpNo' and current_timestamp between pi.createts and pi.endts and pi.personid = '62958'
order by personid ;

select * from person_user_field_vals where personid = '62958';