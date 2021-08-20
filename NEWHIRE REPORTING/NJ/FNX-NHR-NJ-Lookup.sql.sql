 select * from edi.lookup_schema where lookupname like 'NJ%';
 select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname like 'NJ%');
 select * from edi.edi_last_update where feedid = 'NewHireReporting_NJ';
 select * from pay_unit;
 select * from person_employment where emplstatus = 'A' and date_part('year',effectivedate) = '2020';
 
delete from edi.lookup 
-- fein 22-2526472      
-- 100 Passaic Avenue
-- Financial Northeastern Corporation
-- Fairfield New Jersey 07004
-- Patricia Schreck
-- pshreck@financialnortheastern.com
    

 
insert into edi.edi_last_update (feedid,lastupdatets) values ('NewHireReporting_NJ','2021-05-01 06:17:00');
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, valcoldesc1,effectivedate,enddate)
select nextval('edi.lookup_schema_id_seq'), 'NJ FEIN', 'NJ FEIN included in new hire report','NJ FEIN','1900-01-01','2199-12-31';
insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, keycoldesc1, effectivedate,enddate
,valcoldesc1,valcoldesc2,valcoldesc3,valcoldesc4,valcoldesc5,valcoldesc6)
select nextval('edi.lookup_schema_id_seq'), 'NJ FEIN Address', 'NJ FEIN Address','FEIN','1900-01-01','2199-12-31',
'Street Address1','Street Address2','City','State','PostalCode','CountryCode';


insert into edi.lookup (lookupid,value1) select lkups.lookupid,'22-2526472' from edi.lookup_schema lkups where lookupname = 'NJ FEIN';
insert into edi.lookup (lookupid,key1,value1,value2,value3,value4,value5,value6) select lkups.lookupid,'22-2526472'
,'100 Passaic Avenue',' ','Fairfield','NJ','07004','Financial Northeastern Corp' from edi.lookup_schema lkups where lookupname = 'NJ FEIN Address';

/*
 
Lori McCann on July 13,2021 8:32 AM 
 
	Marsha Clark
Test file looks good. You can shorten Corporation to Corp and then go ahead and set this up in production. 
Set Look back date to 8/1/2021, schedule New Hire job to run the 1st & 15th of every month and put job on hold. 
i will release when the client goes live. Please make sure to request report to be pushed to the FTP site

*/

update edi.lookup set value6 = 'Financial Northeastern Corp' where lookupid = 5 and id = 4;
update edi.edi_last_update set lastupdatets = '2021-08-01 06:17:00' where feedid = 'NewHireReporting_NJ';
(select lp.lookupid,lp.key1 as lfein, value1 as faddress1, value2 as faddress2, value3 as fcity, value4 as fstate, value5 as fzip, value6 as fcompname
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'NJ FEIN Address' 
 )
