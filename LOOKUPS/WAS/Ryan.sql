-- NOVATIME Import Inserts -- 

 

--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, valcoldesc2, valcoldesc3, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Client', 'ETVID', 'Hours Type', 'Salary Flag', 'Novatime Import Lookup', 'key=lookupname'
from edi.lookup_schema;

 

--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E01', 'REG', 'Y'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E01', 'SAL', 'Y'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E02', 'OT', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E08', 'RETRO', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E15', 'VAC', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E16', 'SICK', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E17', 'HOL', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E18', 'BRVMT', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E19', 'JURY', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E20', 'PERS', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E32', '3POTH', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E32', '3RD', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E32', 'STAND', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E32', 'THIRD', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E37', 'CAR', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E61', 'BONUS', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E62', 'COM', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E71', 'MISCE', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','E71', 'OTHER', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','EBK', '3PTNT', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','ECC', 'COCAR', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','ECN', 'CARNT', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','ECP', 'COMP', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','ECV', 'COVI', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','EDH', 'FFCRA', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','EEJ', 'FHOL', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','EG0', 'SF', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','EHR', 'OTHHR', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','EML', 'MILES', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','EPC', 'CARUS', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'WAS','EXN', 'EXPNT', 'N'
from edi.lookup_schema;