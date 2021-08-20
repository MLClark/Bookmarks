select * from person_names where lname like 'Kelly%';
select * from person_employment where personid = '1986';
select * from person_employment where personid = '2708';

select * from person_employment where personid = '2685';
select * from person_employment where personid = '2712';

select * from edi.edi_last_update;
select * from person_bene_election where personid = '2712' and benefitsubclass in ('60','61') and selectedoption = 'Y' 
--and benefitelection = 'E'
--and current_date between effectivedate and enddate
and current_timestamp between createts and endts
;