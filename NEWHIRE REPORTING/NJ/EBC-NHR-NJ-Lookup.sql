 select * from edi.lookup_schema;
 select * from edi.lookup;
 select * from edi.edi_last_update;
 select * from pay_unit;
 select * from person_employment where date_part('year',effectivedate) = '2020';
 
insert into edi.edi_last_update (feedid,lastupdatets) values ('NewHireReporting_NJ','2021-05-01 06:17:00');
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, valcoldesc1,effectivedate,enddate)
select nextval('edi.lookup_schema_id_seq'), 'NJ FEIN', 'NJ FEIN included in new hire report','NJ FEIN','1900-01-01','2199-12-31';
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, keycoldesc1, effectivedate,enddate
,valcoldesc1,valcoldesc2,valcoldesc3,valcoldesc4,valcoldesc5,valcoldesc6)
select nextval('edi.lookup_schema_id_seq'), 'NJ FEIN Address', 'NJ FEIN Address','FEIN','1900-01-01','2199-12-31',
'Street Address1','Street Address2','City','State','PostalCode','CountryCode';

--- From EVM document note only populate prod table with EVM
insert into edi.lookup (lookupid,value1) select lkups.lookupid,'47-5420822' from edi.lookup_schema lkups where lookupname = 'NJ FEIN';
insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6) select lkups.lookupid,'47-5420822'
,'2555 Route 130','Suite 2','Cranbury','NJ','08512',' ' from edi.lookup_schema lkups where lookupname = 'NJ FEIN Address';
