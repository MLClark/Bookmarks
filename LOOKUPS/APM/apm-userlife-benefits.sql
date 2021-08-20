select * from edi.lookup;
select * from edi.lookup_schema;

INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, keycoldesc2,  lookupname, lookupdesc)
VALUES                               (2,'Subclass','Dep Relationship' ,'Useable Life Benefit Lookup','key=lookupname');

delete from edi.lookup_schema where lookupid = 2;

delete from edi.lookup where lookupid = 2;

insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'20','EE','Basic Employee Life');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'20','EE','Basic Employee AD&D');

insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'21','EE','Voluntary Employee Life');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'21','EE','Voluntary Employee AD&D'); 

insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'2Z','SP','Voluntary Spouse Life');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'2Z','DP','Voluntary Spouse Life');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'2Z','NA','Voluntary Spouse Life');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'2Z','SP','Voluntary Spouse AD&D');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'2Z','DP','Voluntary Spouse AD&D');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'2Z','NA','Voluntary Spouse AD&D');

insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','D','Voluntary Child Life');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','S','Voluntary Child Life');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','C','Voluntary Child Life');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','ND','Voluntary Child Life');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','NS','Voluntary Child Life');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','NC','Voluntary Child Life');

insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','D','Voluntary Child AD&D');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','S','Voluntary Child AD&D');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','C','Voluntary Child AD&D');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','ND','Voluntary Child AD&D');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','NS','Voluntary Child AD&D');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'25','NC','Voluntary Child AD&D');



insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'30','EE','Basic STD');
insert into edi.lookup (lookupid,key1,key2,value1) VALUES (2,'31','EE','Basic LTD');

select * from edi.lookup_schema where lookupid = 2;
select * from edi.lookup where lookupid = 2;

--- and pdr.dependentrelationship in ('DP','SP','NA','D','S','C','ND','NS','NC')
select 
 lu.key1 ::char(2) as benefitsubclass
,lu.value1 ::varchar(30) as life_prod_desc
,lu.value2 ::varchar(30) as add_prod_desc
from edi.lookup lu
join edi.lookup_schema ls on ls.lookupid = lu.lookupid
where ls.keycoldesc1='Subclass' and lookupname='Useable Life Benefit Lookup' 