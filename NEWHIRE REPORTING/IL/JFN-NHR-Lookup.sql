 
select * from edi.lookup_schema where lookupname like 'IL%';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname like 'IL%');


select * from edi.edi_last_update where feedid = 'NewHireReporting_IL';
select * from pay_unit;
select * from person_employment where emplstatus = 'A' and date_part('year',effectivedate) >= '2021';
         

insert into edi.edi_last_update (feedid,lastupdatets) values ('NewHireReporting_IL','2021-04-01 06:17:00');
update edi.edi_last_update set lastupdatets = '2021-04-01 06:17:00' where feedid = 'NewHireReporting_IL';


insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, valcoldesc1,effectivedate,enddate)
select nextval('edi.lookup_schema_id_seq'), 'IL FEIN', 'IL FEIN included in new hire report','IL FEIN','1900-01-01','2199-12-31';
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, keycoldesc1, effectivedate,enddate
,valcoldesc1,valcoldesc2,valcoldesc3,valcoldesc4,valcoldesc5,valcoldesc6)
select nextval('edi.lookup_schema_id_seq'), 'IL FEIN Address', 'IL FEIN Address','FEIN','1900-01-01','2199-12-31',
'Street Address1','Street Address2','City','State','PostalCode','CompName';


insert into edi.lookup (lookupid,value1) select lkups.lookupid,'23-2742482' from edi.lookup_schema lkups where lookupname = 'IL FEIN';
insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6) select lkups.lookupid,'23-2742482'
,'150 W 30th St','Suite 900','New York','NY','10001','Jewish Funders Network' from edi.lookup_schema lkups where lookupname = 'IL FEIN Address';


LEFT JOIN  (select lp.lookupid,lp.key1 as lfein, value1 as faddress1, value2 as faddress2, value3 as fcity, value4 as fstate, value5 as fzip, value6 as fcompname
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'IL FEIN Address' 
 )finaddress on finaddress.lookupid is not null