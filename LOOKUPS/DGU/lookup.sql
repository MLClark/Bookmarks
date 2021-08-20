[10:15 AM] Ryan Ferdon
    delete from edi.lookup where lookupid = '3' and key1 = 'E37'

    select * from edi.lookup;
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
(3,'VB5',3),
(3,'E37',4);


insert into edi.lookup (lookupid,key1,value1,value2)
values (3,'V65',5,'1'),
(3,'V73',5,'2'),
(3,'V31',5,'3');


-- Company Info Lookup Inserts
insert into edi.lookup_schema (lookupid,valcoldesc1,valcoldesc2,valcoldesc3,lookupname,lookupdesc)
values(4,'Company Code','Employer Number','Plan Type','Plan Info','401k Employer Information for DGU');


insert into edi.lookup (lookupid,value1,value2,value3)
values(4,'DGU','061393','401k');


-- Last Update Insert
insert into edi.edi_last_update (feedid,lastupdatets) values('Mutual_Of_America','2020-01-16 00:00:00');







