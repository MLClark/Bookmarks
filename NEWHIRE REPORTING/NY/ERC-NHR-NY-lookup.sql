
select * from edi.lookup_schema where lookupname like 'NY%';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname like 'NY%');
select * from edi.edi_last_update where feedid = 'NewHireReporting_NY';
select * from pay_unit;
select * from person_employment where emplstatus = 'A' and date_part('year',effectivedate) >= '2021';


insert into edi.edi_last_update (feedid,lastupdatets) values ('NewHireReporting_NY','2021-05-01 06:17:00');


insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, valcoldesc1,effectivedate,enddate)
select nextval('edi.lookup_schema_id_seq'), 'NY FEIN', 'NY FEIN included in new hire report','NY FEIN','1900-01-01','2199-12-31';
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, keycoldesc1, effectivedate,enddate
,valcoldesc1,valcoldesc2,valcoldesc3,valcoldesc4,valcoldesc5,valcoldesc6)
select nextval('edi.lookup_schema_id_seq'), 'NY FEIN Address', 'NY FEIN Address','FEIN','1900-01-01','2199-12-31',
'Street Address1','Street Address2','City','State','PostalCode','CompName';


insert into edi.lookup (lookupid,value1) select lkups.lookupid,'47-5420822' from edi.lookup_schema lkups where lookupname = 'NY FEIN';
insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6) select lkups.lookupid,'47-5420822'
,'2555 Route 130 Suite 2','Cranbury','NY','08512','US','IoTecha Corp' from edi.lookup_schema lkups where lookupname = 'NY FEIN Address';

