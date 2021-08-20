select * from edi.edi_last_update where feedid = 'NewHireReporting_PA';
select * from edi.lookup_schema where lookupdesc like '%PA%';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupdesc like '%PA%');


insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, valcoldesc1,effectivedate,enddate)
select nextval('edi.lookup_schema_id_seq'), 'PA FEIN', 'PA FEIN included in new hire report','PA FEIN','1900-01-01','2199-12-31';

insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, effectivedate,enddate,valcoldesc1,valcoldesc2,valcoldesc3)
select nextval('edi.lookup_schema_id_seq'), 'FEIN contact', 'PA contact','1900-01-01','2199-12-31','First Name','Last Name','Phone Number';

insert into edi.lookup (lookupid,value1) select lkups.lookupid,'23-2046977' from edi.lookup_schema lkups where lookupname = 'PA FEIN';
insert into edi.lookup (lookupid,value1) select lkups.lookupid,'20-4878371' from edi.lookup_schema lkups where lookupname = 'PA FEIN';

insert into edi.lookup (lookupid,value1,value2,value3) 
select lkups.lookupid,'Alan','Lewenthal','2156343100' from edi.lookup_schema lkups where lookupname = 'FEIN contact';

insert into edi.lookup (lookupid,value1,value2,value3) 
select lkups.lookupid,'Alan','Lewenthal','2156343100' from edi.lookup_schema lkups where lookupname = 'FEIN contact';