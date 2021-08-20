delete from edi.lookup where lookupid = 4;
--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, key1, value1)
select lookupid, '97', 'MA2K'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1)
select lookupid, '98', 'MA3750A'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1)
select lookupid, '9', 'DDPPO'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1)
select lookupid, '12', 'DDPPO'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1)
select lookupid, '104', 'DDPPO'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1)
select lookupid, '142', 'DDPPO'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1)
select lookupid, '37', 'VSP'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1)
select lookupid, '40', 'VSP'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1)
select lookupid, '109', 'VSP'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1)
select lookupid, '67', 'FSA'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';


update edi.edi_last_update set lastupdatets = '2021-06-01 00:00:00' where feedid = 'TASC_COBRA_Export';