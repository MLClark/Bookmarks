INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'EDH', 'EDH'
from edi.lookup_schema where lookupname = 'KD0_Time_Import';

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'EDI', 'EDI'
from edi.lookup_schema where lookupname = 'KD0_Time_Import';

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'EEL', 'EEL'
from edi.lookup_schema where lookupname = 'KD0_Time_Import';

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'E22', 'E22'
from edi.lookup_schema where lookupname = 'KD0_Time_Import';

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'E12', 'E12'
from edi.lookup_schema where lookupname = 'KD0_Time_Import';


select * from edi.lookup lu join edi.lookup_schema ls on lu.lookupid = ls.lookupid and ls.lookupname = 'KD0_Time_Import';