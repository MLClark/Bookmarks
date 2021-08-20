update edi.edi_last_update set lastupdatets = '2020-02-01 00:00:00' where feedid = 'WageWorks_COBRA_Export';



--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1,valcoldesc1,lookupname,lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Benefit Type', 'Benefit Subclass', 'WageWorks_COBRA_BenefitSubclasses', 'Configurable Benefit Subclasses'
from edi.lookup_schema;

 

--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'Medical', '10'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'Dental', '11'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'Vision', '14'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'FSA', '60'
from edi.lookup_schema;





update edi.edi_last_update set lastupdatets = '2020-01-01 00:00:00' where feedid = 'WageWorks_COBRA_Export'


--Update lastupdatets
update edi.edi_last_update
set lastupdatets = '2020-01-01 00:00:00'
where feedid = 'WageWorks_Cobra_Export';

 

--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Benefit Plan ID','Benefit Plan Name', 'CDS_WageWorks_Cobra_Export', 'Benefit Plan Names'
from edi.lookup_schema;

 

--Add etvid lookup values first 3 inserts need to be ran 1 at a time.

 

INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '3', 'Geisinger PPO Employee-MEDE'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '6', 'Geisinger PPO Manager-MEDM'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '9', 'Aetna Dental'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '97', 'VSP'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '114', 'EEHMO'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '115', 'MGHMO'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '119', 'Aetna Dental Employee-DENE'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '122', 'Aetna Dental Management-DENM'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '125', 'EEVIS'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '126', 'MGVIS'
from edi.lookup_schema;