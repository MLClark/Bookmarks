select * FROM person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and empleventdetcode in ('NHR','RH') ;


select * from  edi.edi_last_update;
insert into edi.edi_last_update (lastupdatets,feedid) values ('2021-04-15 00:00:00', 'NewHireReporting_MD');

update edi.edi_last_update set lastupdatets = '2019-01-01 00:00:00' where feedid = 'NewHireReporting_MD';