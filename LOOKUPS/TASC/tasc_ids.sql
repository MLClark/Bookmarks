insert into edi.edi_last_update (feedid,lastupdatets) values ('TASC_FSA_Census_File_Export','2021-01-01 00:00:00') ;
insert into edi.edi_last_update (feedid,lastupdatets) values ('TASC_FSA_Enrollment_File_Export','2021-01-01 00:00:00') ;
insert into edi.edi_last_update (feedid,lastupdatets) values ('TASC_FSA_Posting_Verification_File_Export','2021-01-01 00:00:00') ;



--- sww

insert into edi.lookup_schema (lookupid, lookupname, lookupdesc, keycoldesc1)
select nextval('edi.lookup_schema_id_seq'), 'TASC_FSA_Exports', 'TASC Client Specific Values','Lookup Data For TASC FSA';


insert into edi.lookup (lookupid,key1, value1) select lkups.lookupid, 'ClientTASCID', '4220-4681-2231' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Healthcare FSA','FLEX','60'::char(2),'1000136334' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Dependent Care FSA','FLEX','61'::char(2),'1000136335' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';

--- Note adding vendor plan id to paycodes - didn't want to add pbe join to payroll file.

insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'HCRA P/T','PAYCODE','VBA','1000136334' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'DCRA P/T','PAYCODE','VBB','1000136335' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'ERHCRA P/T','PAYCODE','VBA-ER','1000136334' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'ERDCRA P/T','PAYCODE','VBB-ER','1000136335' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';



insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'ERHSA C/U','PAYCODE','VEJ-ER','??????????'  from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'ERHSA Fam','PAYCODE','VEI-ER','??????????'  from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'ERPark-P/T','PAYCODE','VL1-ER','??????????'  from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'ERTrns-P/T','PAYCODE','VS1-ER','??????????'  from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'HSA C/U','PAYCODE','VEJ','??????????'  from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'HSA Co','PAYCODE','VEK','??????????'  from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'HSA Fam','PAYCODE','VEI','??????????'  from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'HSA Ind','PAYCODE','VEH','??????????'  from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'Park-P/T','PAYCODE','VL1','??????????'  from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid, key1,key2, value1, value2) select lkups.lookupid,'Trns-P/T','PAYCODE','VS1','??????????'  from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';



---- fOLLOWING LOOKUP VALUES complete list of inserts for TASC feeds convert ? to planid supplied by vendor
insert into edi.lookup (lookupid,key1, value1) select lkups.lookupid, 'ClientTASCID', '????-????-????' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Healthcare FSA','FLEX','60','??????????' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Dependent Care FSA','FLEX','61','??????????' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Transit','Parking','6A','??????????' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Parking','Parking','6B','??????????' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Transit Post-Tax','Parking','6AP','??????????' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Parking Post-Tax','Parking','6BP','??????????' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Health Savings Account A','FLEX','67','??????????' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Health Savings Catch Up','FLEX','6Y','??????????' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Health Reimbursment Account','FLEX','1Y','??????????' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';
insert into edi.lookup (lookupid,key1,key2, value1,value2) select lkups.lookupid, 'Health Savings Account','FLEX','6Z','??????????' from edi.lookup_schema lkups where lookupname = 'TASC_FSA_Exports';

          


select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'TASC_FSA_Exports');
select * from edi.lookup_schema where lookupname = 'TASC_FSA_Exports';
select * from edi.edi_last_update where feedid = 'TASC_FSA_Census_File_Export';
select * from edi.edi_last_update where feedid = 'TASC_FSA_Enrollment_File_Export';
select * from edi.edi_last_update where feedid = 'TASC_FSA_Posting_Verification_File_Export';


delete from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'TASC_FSA_Exports');
delete from edi.lookup_schema where lookupname = 'TASC_FSA_Exports';
delete from edi.edi_last_update where feedid = 'TASC_FSA_Census_File_Export';
delete from edi.edi_last_update where feedid = 'TASC_FSA_Enrollment_File_Export';
delete from edi.edi_last_update where feedid = 'TASC_FSA_Posting_Verification_File_Export';


update edi.edi_last_update set lastupdatets = '2021-01-01 00:00:00'  where feedid = 'TASC_FSA_Enrollment_File_Export';
