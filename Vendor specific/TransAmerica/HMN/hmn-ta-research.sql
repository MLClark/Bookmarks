select * from edi.edi_last_update;

update edi.edi_last_update set lastupdatets = '2020-05-19 23:59:44' where feedid = 'HMN_401k_Census_File_Export';
select * from person_names where lname like 'Hoener%';
select * from employment_event_detail ;


select * from person_employment where emplstatus in ('L', 'T')
and current_timestamp between createts and endts
and effectivedate < enddate
and empleventdetcode <> 'VT' 
--and personid = '65205'
order by effectivedate;

select * from person_employment where personid = '65205' and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from employment_event_detail where empleventdetcode in (
select distinct empleventdetcode
from person_employment
where emplstatus in ('L')
and current_timestamp between createts and endts
and effectivedate < enddate
and empleventdetcode <> 'VT'
) 
order by 2;

select empleventdetcode from employment_event_detail group by 1;


select * from person_address where personid = '67630' and 