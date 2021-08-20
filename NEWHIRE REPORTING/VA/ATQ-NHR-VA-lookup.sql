
 select * from edi.lookup_schema where lookupname like 'VA%';
 select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname like 'VA%');
 select * from edi.edi_last_update where feedid = 'NewHireReporting_VA';
 select * from pay_unit;
 select * from person_employment where emplstatus = 'A' and date_part('year',effectivedate) >= '2020';
 
insert into edi.edi_last_update (feedid,lastupdatets) values ('NewHireReporting_VA','2021-05-01 06:17:00');
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, valcoldesc1,effectivedate,enddate)
select nextval('edi.lookup_schema_id_seq'), 'VA FEIN', 'VA FEIN included in new hire report','VA FEIN','1900-01-01','2199-12-31';
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, keycoldesc1, effectivedate,enddate,valcoldesc1,valcoldesc2,valcoldesc3,valcoldesc4,valcoldesc5,valcoldesc6)
select nextval('edi.lookup_schema_id_seq'), 'VA FEIN Address', 'VA FEIN Address','FEIN','1900-01-01','2199-12-31','Street Address1','Street Address2','City','State','PostalCode','CountryCode';


insert into edi.lookup (lookupid,value1) select lkups.lookupid,'54-0682048' from edi.lookup_schema lkups where lookupname = 'VA FEIN';
insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6) select lkups.lookupid,'54-0682048'
,'16720 Brookneal Hwy',' ','Brookneal','VA','24528','Foster Fuels Inc' from edi.lookup_schema lkups where lookupname = 'VA FEIN Address';

insert into edi.lookup (lookupid,value1) select lkups.lookupid,'20-2495876' from edi.lookup_schema lkups where lookupname = 'VA FEIN';
insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6) select lkups.lookupid,'20-2495876'
,'16720 Brookneal Hwy',' ','Brookneal','VA','24528','PHELPS CREEK ANGUS FARM INC' from edi.lookup_schema lkups where lookupname = 'VA FEIN Address';