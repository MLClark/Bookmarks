select * from user_field_desc where ufname in ('LTIP','LTIPP','Section16') ;




SELECT * FROM person_user_field_vals where ufid in (
select ufid from user_field_desc where ufname in ('Section16','LTIPP')
)
and current_date between effectivedate and enddate
and current_timestamp between createts and endts
--and personid not in (select personid from person_user_field_vals where ufid = 7 and ufvalue = 'Y')
order by personid, ufid
;

SELECT distinct personid FROM person_user_field_vals where ufid in (
select ufid from user_field_desc where ufname in ('Section16','LTIPP')
)
and current_date between effectivedate and enddate
and current_timestamp between createts and endts
--and personid not in (select personid from person_user_field_vals where ufid = 7 and ufvalue = 'Y')
group by 1
;



6 - section 16
7 - ltip
30 - ltipp





select ufname from user_field_desc group by 1;

 --puf
 (	select distinct
			personid, ufid
		from person_user_field_vals
		where ufid in (select ufid from user_field_desc where ufname in ('Section16', 'LTIP'))
			and current_date between effectivedate and enddate
			and current_timestamp between createts and endts
			and ufvalue = 'Y' order by 1);
 --S16
 (	select distinct
			personid, ufid
		from person_user_field_vals
		where ufid in (select ufid from user_field_desc where ufname = 'Section16')
			and current_date between effectivedate and enddate
			and current_timestamp between createts and endts
			and ufvalue = 'Y' order by 1) ;
 
 --ltip
 (	select distinct
			personid, ufid
		from person_user_field_vals
		where ufid in (select ufid from user_field_desc where ufname ='LTIP')
			and current_date between effectivedate and enddate
			and current_timestamp between createts and endts
			and ufvalue = 'Y' order by 1);