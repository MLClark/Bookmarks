insert into edi.edi_last_update (feedid,lastupdatets) values ('NewHireReporting_PA','2019-09-01 06:46:23');

insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, valcoldesc1,effectivedate,enddate)
select nextval('edi.lookup_schema_id_seq'), 'PA FEIN', 'PA FEIN included in new hire report','PA FEIN','1900-01-01','2199-12-31';

insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, effectivedate,enddate,valcoldesc1,valcoldesc2,valcoldesc3)
select nextval('edi.lookup_schema_id_seq'), 'FEIN contact', 'PA contact','1900-01-01','2199-12-31','First Name','Last Name','Phone Number';

insert into edi.lookup (lookupid,value1) select lkups.lookupid,'25-6001173' from edi.lookup_schema lkups where lookupname = 'PA FEIN';
insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'Scott','Bemiss','8148755437' from edi.lookup_schema lkups where lookupname = 'FEIN contact';


select * from pay_unit;
select * from companyname;
select * from location_address;
select * from edi.edi_last_update;
select * from edi.lookup_schema;
select * from edi.lookup;

update edi.edi_last_update set lastupdatets = '2021-07-26 06:46:23'  where feedid = 'NewHireReporting_PA';
update edi.lookup_schema set valcoldesc4 = 'CompName' where lookupdesc = 'PA contact' and lookupname = 'FEIN contact';
update edi.lookup set value4 = 'East Erie Commercial Railroad' where lookupid in (select lookupid from edi.lookup_schema where lookupdesc = 'PA contact' and lookupname = 'FEIN contact');
