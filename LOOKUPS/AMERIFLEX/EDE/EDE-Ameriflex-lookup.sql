select * from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');
select * from edi.edi_last_update;

insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Eligibility_Election','2020-06-01 00:00:00');
insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Demographic_Election','2020-06-01 00:00:00');
insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Payroll_Deduction','2021-06-10 00:00:00');


INSERT INTO edi.lookup_schema (lookupid, valcoldesc1, valcoldesc2, valcoldesc3, valcoldesc4, lookupname, lookupdesc )
select nextval('edi.lookup_schema_id_seq'),'Group Code','Plan ID','PlanYearStartDate','PlanYearEndDate','Ameriflex_FLEX_Eligibility_Election','Group Code/PlanID';

insert into edi.lookup (lookupid,value1,value2,value3,value4,effectivedate,enddate) select lkups.lookupid,'AMFSCOHOL','SCOHOL','2021-06-01','2021-12-31','2021-06-01','2021-12-31' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Eligibility_Election');




INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, lookupname, lookupdesc)
select nextval('edi.lookup_schema_id_seq'),'Paycode_AccountType_ContribType','Ameriflex_FLEX_Payroll_Deduction','key=Pay Code and Contrib Type';

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VBA','FSA','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VBA-ER','FSA','ER' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VGA','FSA','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VGA-ER','FSA','ER' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VBB','DCA','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VBB-ER','DCA','ER' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VS1','TRN','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VS1-ER','TRN','ER' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VC0','TRN','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VL1','PKG','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VL1-ER','PKG','ER' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VC1','PKG','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VEH','UMB','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');



select  distinct etvid from person_deduction_setup group by 1;
select * from edi.edi_last_update where feedid = 'Ameriflex_FLEX_Payroll_Deduction'; 
update edi.edi_last_update set lastupdatets = '2021-05-18 19:16:40' where feedid = 'Ameriflex_FLEX_Payroll_Deduction'; 
--'2021-06-09 14:29:27'


select * from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Payroll_Deduction';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Payroll_Deduction');



