
select * from  edi.lookup where id in (select id from edi.lookup where (value1 = '45-3670186' or key1 = '45-3670186'));
delete from  edi.lookup where id in (select id from edi.lookup where (value1 = '45-3670186' or key1 = '45-3670186'));
/*
 
insert into edi.edi_last_update (feedid,lastupdatets) values ('NewHireReporting_NJ','2021-05-01 06:17:00');


insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, valcoldesc1,effectivedate,enddate)
select nextval('edi.lookup_schema_id_seq'), 'NY FEIN', 'NY FEIN included in new hire report','NY FEIN','1900-01-01','2199-12-31';
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, keycoldesc1, effectivedate,enddate
,valcoldesc1,valcoldesc2,valcoldesc3,valcoldesc4,valcoldesc5,valcoldesc6)
select nextval('edi.lookup_schema_id_seq'), 'NY FEIN Address', 'NY FEIN Address','FEIN','1900-01-01','2199-12-31',
'Street Address1','Street Address2','City','State','PostalCode','CompName';


insert into edi.lookup (lookupid,value1) select lkups.lookupid,'45-3670186' from edi.lookup_schema lkups where lookupname = 'NY FEIN';
insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6) select lkups.lookupid,'45-3670186'
,'1095 Avenue of the Americas','New York','NY','10036','US','CCB International Overseas USA Inc' from edi.lookup_schema lkups where lookupname = 'NY FEIN Address';

insert into edi.lookup (lookupid,value1) select lkups.lookupid,'32-0273004' from edi.lookup_schema lkups where lookupname = 'NY FEIN';
insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6) select lkups.lookupid,'32-0273004'
,'1095 Avenue of the Americas','New York','NY','10036','US','China Construction Bank' from edi.lookup_schema lkups where lookupname = 'NY FEIN Address';
*/