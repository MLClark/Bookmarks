select * from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');
select * from edi.edi_last_update;

insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Eligibility_Election','2020-07-01 00:00:00');
insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Demographic_Election','2020-07-01 00:00:00');
insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Payroll_Deduction','2021-05-01 00:00:00');



INSERT INTO edi.lookup_schema (lookupid, valcoldesc1, valcoldesc2, valcoldesc3, valcoldesc4, lookupname, lookupdesc )
select nextval('edi.lookup_schema_id_seq'),'Group Code','Plan ID','PlanYearStartDate','PlanYearEndDate','Ameriflex_FLEX_Eligibility_Election','Group Code/PlanID';

insert into edi.lookup (lookupid,value1,value2,value3,value4,effectivedate,enddate) select lkups.lookupid,'AMFFRANKG','FRANKG','2020-07-01','2999-12-31','2020-07-01','2999-12-31' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Eligibility_Election');


IBAMF001AMFFRANKG
ICAMF001AMFFRANKGFRANKG
IHAMF001AMFFRANKG

update edi.lookup set value3 = '2021-01-01' where lookupid = 1;
update edi.lookup set value4 = '2021-12-31' where lookupid = 1;
update edi.lookup set effectivedate = '2020-07-01' where lookupid = 1;
update edi.lookup set enddate = '2021-12-31' where lookupid = 1;

update edi.edi_last_update set lastupdatets = '2020-07-03 00:00:00' where feedid = 'Ameriflex_FLEX_Eligibility_Election'; --2021-07-06 06:09:22

