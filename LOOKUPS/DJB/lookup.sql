    
--Add last update
insert into edi.edi_last_update (feedid,lastupdatets)
values('Ameriflex_FLEX_Payroll_Deduction','2020-03-01 00:00:00');


--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, valcoldesc1, valcoldesc2, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Group Code','Plan ID', 'Ameriflex_FLEX_Eligibility_Election', 'Group Code/PlanID'
from edi.lookup_schema;


--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, value1, value2) 
select coalesce(max(lookupid), 1), 'AMFJEFCHS', 'JEFCHS'
from edi.lookup_schema;







    update edi.lookup set value1 = '6' where key1 = 'VB6';



update edi.lookup_schema
set lookupdesc = '1=403b/401k & Catch-up, 2=Roth & Catch-up, 3=ER Contrib, 4=Excl. Earnings, 5=Loans, 6=ER Contrib'
where lookupid = 3;

 

insert into edi.lookup(lookupid,key1,value1)
values(3,'VB6',6);



-- ETVID Lookup Inserts
insert into edi.lookup_schema (lookupid,keycoldesc1,valcoldesc1,valcoldesc2,lookupname,lookupdesc)
values(3,'ETV Code','Identifier','Loan Number','ETV IDs','Identifiers: 1=403b/401k & Catch-up, 2=Roth & Catch-up, 3=ER Contrib, 4=Excluded Earnings, 5=Loans');


insert into edi.lookup (lookupid,key1,value1)
values(3,'VB1',1),
(3,'VB2',1),
(3,'V25',1),
(3,'VCG',1),
(3,'VCH',1),
(3,'VDO',1),
(3,'VDP',1),
(3,'VB3',2),
(3,'VB4',2),
(3,'V44',2),
(3,'V45',2),
(3,'VAJ',2),
(3,'VAK',2),
(3,'VB5',3),
(3,'E12',4);


insert into edi.lookup (lookupid,key1,value1,value2)
values (3,'V47',5,'1'),
(3,'V73',5,'2'),
(3,'V31',5,'3');


-- Company Info Lookup Inserts
insert into edi.lookup_schema (lookupid,valcoldesc1,valcoldesc2,valcoldesc3,lookupname,lookupdesc)
values(4,'Company Code','Employer Number','Plan Type','Plan Info','403b Employer Information for DJB');


insert into edi.lookup (lookupid,value1,value2,value3)
values(4,'DJB','053149','403b');


-- Last Update Insert
insert into edi.edi_last_update (feedid,lastupdatets) values('Mutual_Of_America','2020-01-08 11:25:14');

select * from edi.edi_last_update;







