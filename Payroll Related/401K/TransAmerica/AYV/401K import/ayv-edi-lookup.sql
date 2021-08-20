
CREATE SEQUENCE serial START 1;

INSERT INTO edi.lookup_schema (lookupid, 
keycoldesc1, 
valcoldesc1, valcoldesc2, valcoldesc3, valcoldesc4, valcoldesc5, 
lookupname, lookupdesc)
VALUES (nextval('serial'),
'TA 401K Conversion Columns',
'ContributionCode', 'ETV_ID', 'BenefitSubClass', 'BenefitPlanID', 'BenefitCalcType',
'SLC TA 401K Import','key columns required to import TA 401k data into pfpe table');
delete from edi.lookup where lookupid = 11;

select * from edi.lookup_schema;

INSERT INTO edi.lookup 
(lookupid,key1,value1,value2,value3,value4,value5) 
VALUES
(nextval('serial'),
'401K','VB1',40,89,' ',' ');

INSERT INTO edi.lookup 
(lookupid,key1,value1,value2,value3,value4,value5) 
VALUES
(10,
'401KC','VB2',40,89,' ',' ');

INSERT INTO edi.lookup 
(lookupid,key1,value1,value2,value3,value4,value5) 
VALUES
(10,
'4ROTH','VB3',47,215,' ',' ');

INSERT INTO edi.lookup 
(lookupid,key1,value1,value2,value3,value4,value5) 
VALUES
(10,
'4ROTC','VB4',47,215,' ',' ');


INSERT INTO edi.lookup 
(lookupid,key1,value1,value2,value3,value4,value5) 
VALUES
(10,
'401L','V65',' ',' ','DN65','DA65');

update edi.lookup_schema set valcoldesc5='DeductionCodeDN' where id = '11';

update edi.lookup_schema set valcoldesc6='DeductionCodeDA' where id = '11';
update edi.lookup set lookupid = '11' where lookupid = '10';

delete from edi.lookup where id = 101;
update edi.lookup set lookupid = 11 where id = 102 and key1 = '401L';
select * from edi.lookup_schema WHERE ID = 11;
select * from edi.lookup where key1 = '401K';


select 
 key1
,value1 as etv_id
,value2::int as benefitsubclass
,value3::int as benefitplanid
,value4 as dncode
,value5 as dacode

from edi.lookup lu
join edi.lookup_schema ls on ls.id = lu.lookupid and ls.keycoldesc1 = 'TA 401K Conversion Columns'
and key1 <> '401L'

union

select 
 key1
,value1 as etv_id
,null as benefitsubclass
,null as benefitplanid
,value4 as dncode
,value5 as dacode

from edi.lookup lu
join edi.lookup_schema ls on ls.id = lu.lookupid and ls.keycoldesc1 = 'TA 401K Conversion Columns'
and key1 = '401L'
