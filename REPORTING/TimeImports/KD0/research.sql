select * from person_identity where identity = '149';
select * from person_names where personid = '69';
select * from person_pto_activity_request where personid = '69';
select batchname from batch_header group by 1;

select * from batch_header where batchname like '%KD0_DatamaticsImport%' ;
select * from batch_detail where batchheaderid in ('168') and personid = '69';



select 100 as divisor,l.key1 as import_code,l.value1 as etv_id from edi.lookup l
left join edi.lookup_schema els on els.lookupid = l.lookupid
where els.lookupname = 'KD0_Time_Import'

select * from edi.lookup lu join edi.lookup_schema ls on lu.lookupid = ls.lookupid and ls.lookupname = 'KD0_Time_Import';


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
select lookupid, 'EDH', 'EDH'
from edi.lookup_schema where lookupname = 'KD0_Time_Import';