
insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Eligibility_Election','2020-01-01 00:00:00');
insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Demographic_Election','2020-01-01 00:00:00');
insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Payroll_Deduction','2020-01-10 00:00:00');

--populate lookup_schema (original insert modified to use nextval ) 
INSERT INTO edi.lookup_schema (lookupid, valcoldesc1, valcoldesc2, valcoldesc3, valcoldesc4, lookupname, lookupdesc )
select nextval('edi.lookup_schema_id_seq'),'Group Code','Plan ID','PlanYearStartDate','PlanYearEndDate','Ameriflex_FLEX_Eligibility_Election','Group Code/PlanID';

insert into edi.lookup (lookupid,value1,value2,value3,value4) select lkups.lookupid,'AMFEDCHEN','EDCHEN','2021-01-01','2021-12-31' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Eligibility_Election');
/*

Please configure Ameriflex feed. Client is in production. 

IBAMF001AMFEDCHEN

ICAMF001AMFEDCHENEDCHEN

IHAMF001AMFEDCHEN

New File Naming Convention:
Open Enrollment:
ib_OE_AMFEDCHEN_YYYYMMDD.pgp
ic_OE_AMFEDCHEN_YYYYMMDD.pgp

Production:
ib_AMFEDCHEN_YYYYMMDD.pgp
ic_AMFEDCHEN_YYYYMMDD.pgp
ih_AMFEDCHEN_YYYYMMDD.pgp
 
*/




--- Changed the plan year start and end dates to use value column instead of using the effectived date and end date. 
--update edi.lookup_schema set valcoldesc3 = 'PlanYearStartDate' where lookupname = 'Ameriflex_FLEX_Eligibility_Election'; 
--update edi.lookup_schema set valcoldesc4 = 'PlanYearEndDate' where lookupname = 'Ameriflex_FLEX_Eligibility_Election'; 
--update edi.lookup set value3 = '2021-01-22'  where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election'); 
--update edi.lookup set value4 = '2199-12-31'  where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election'); 

----



select * from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');
select * from edi.edi_last_update;

update edi.edi_last_update set lastupdatets = '2021-06-01 14:20:51' where feedid = 'Ameriflex_FLEX_Demographic_Election';
update edi.edi_last_update set lastupdatets = '2021-06-01 14:20:51' where feedid = 'Ameriflex_FLEX_Eligibility_Election';