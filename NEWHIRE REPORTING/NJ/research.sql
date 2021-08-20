(select lp.lookupid,lp.key1 as lfein, value1 as faddress1, value2 as faddress2, value3 as fcity, value4 as fstate, value5 as fzip, value6 as fcompname
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'NJ FEIN Address' 
 );
 
 select * from edi.lookup_schema;
 select * from edi.lookup;
 select * from edi.edi_last_update;
 
 DEPTNJOTHR - NJ Other
 
 Pay Unit: EMC04 Semi-Mthly Edison
 Pay Unit: EMC02 Semi-Mthly Edison
select * from person_locations where personid in ('168','186'); 
select * from companyname;
select * from pay_unit;

insert into edi.edi_last_update (feedid,lastupdatets) values ('NewHireReporting_NJ','2021-05-01 06:17:00');
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, valcoldesc1,effectivedate,enddate)
select nextval('edi.lookup_schema_id_seq'), 'NJ FEIN', 'NJ FEIN included in new hire report','NJ FEIN','1900-01-01','2199-12-31';
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, keycoldesc1, effectivedate,enddate
,valcoldesc1,valcoldesc2,valcoldesc3,valcoldesc4,valcoldesc5,valcoldesc6)
select nextval('edi.lookup_schema_id_seq'), 'NJ FEIN Address', 'NJ FEIN Address','FEIN','1900-01-01','2199-12-31',
'Street Address1','Street Address2','City','State','PostalCode','CountryCode';


insert into edi.lookup (lookupid,value1) select lkups.lookupid,'80-0902384' from edi.lookup_schema lkups where lookupname = 'NJ FEIN';
insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6) select lkups.lookupid,'80-0902384'
,'281 Witherspoon Street',' ','Princeton','NJ','08540',' ' from edi.lookup_schema lkups where lookupname = 'NJ FEIN Address';


update edi.edi_last_update set lastupdatets = '2021-03-01 06:17:00' where feedid = 'NewHireReporting_NJ'
select * from person_names where lname like 'Kra%' and nametype = 'Legal' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from person_identity where personid in ('168','186') and identitytype = 'SSN' and current_timestamp between createts and endts;
