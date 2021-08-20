select distinct personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus = 'A';

select * from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus = 'A';

select * from pers_pos where current_date between effectivedate and enddate and current_timestamp between createts and endts and personid in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus = 'A');

select * from edi.edi_last_update where feedid = 'HMN_Equifax_PayrollDetails_Export';

insert into edi.edi_last_update (feedid,lastupdatets) values ('HMN_Equifax_PayrollDetails_Export','2021-03-09 20:12:20');
update edi.edi_last_update set lastupdatets = '2020-01-01 20:12:20' where feedid = 'HMN_Equifax_PayrollDetails_Export';

select * from pay_unit;