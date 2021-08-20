select * from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');
select * from edi.edi_last_update;
/*
Please configure Ameriflex feed. Client is being implemented. 

IBAMF001AMFSCOHOL

ICAMF001AMFSCOHOLSCOHOL

IHAMF001AMFSCOHOL
*/
insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Eligibility_Election','2020-01-01 00:00:00');
insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Demographic_Election','2020-01-01 00:00:00');
insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Payroll_Deduction','2021-04-10 00:00:00');




INSERT INTO edi.lookup_schema (lookupid, valcoldesc1, valcoldesc2, valcoldesc3, valcoldesc4, lookupname, lookupdesc )
select nextval('edi.lookup_schema_id_seq'),'Group Code','Plan ID','PlanYearStartDate','PlanYearEndDate','Ameriflex_FLEX_Eligibility_Election','Group Code/PlanID';

insert into edi.lookup (lookupid,value1,value2,value3,value4,effectivedate,enddate) select lkups.lookupid,'AMFSCOHOL','SCOHOL','2021-01-01','2021-12-31','2021-01-01','2021-12-31' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Eligibility_Election');