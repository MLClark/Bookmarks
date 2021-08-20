[3:03 PM] Ryan Ferdon
    update edi.edi_last_update set lastupdatets = '2020-03-21 00:00:00' where feedid = 'DAB_NBSBenefits_401k_Export';
 




--lookup schema for division
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Payunit XID','Division Name', 'DAB_NBSBenefits_401k_Export', 'Divisions'
from edi.lookup_schema;

 

--Add division lookup values
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '00', 'SAR1'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '05', 'SHC1'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '10', 'SHT1'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '15', 'SHC1'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '20', 'SHC1'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '25', 'SHC1'
from edi.lookup_schema;
insert into edi.edi_last_update (feedid,lastupdatets)
values('DAB_NBSBenefits_401k_Export','2020-03-15 00:00:00');