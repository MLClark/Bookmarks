

select * from edi.edi_last_update where feedid = 'AXU_Infinisource_Cobra_QE_Export';
update edi.edi_last_update set lastupdatets = '2020-03-21 00:00:00' where feedid = 'AXU_Infinisource_Cobra_QE_Export';

update edi.edi_last_update set lastupdatets = '2020-03-21 00:00:00' where feedid = 'AXU_Infinisource_Cobra_QE_Export';


AXU_Infinisource_Cobra_QE_Export
AXU_Infinisource_Cobra_QE_Export

[1:44 PM] Ryan Ferdon
    update edi.edi_last_update set lastupdatets = '2019-09-24 00:00:00' where feedid = 'AXU_Infinisource_Cobra_QE_Export';


select * from edi.edi_last_update;


--Delete lookup
delete from edi.lookup where lookupid = 15;

 

--------------------------------------- Plan Year 2019 ----------------------------------------
--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5,effectivedate,enddate) 
select coalesce(max(lookupid), 1), '9', 'BCBS OF SC','MED A CORE','SGL','EE+CHILD(REN)','FAMILY','2019-01-01','2019-12-31'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5,effectivedate,enddate) 
select coalesce(max(lookupid), 1), '15', 'BCBS OF SC','MED B PLUS','SGL','EE+CHILD(REN)','FAMILY','2019-01-01','2019-12-31'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5,effectivedate,enddate) 
select coalesce(max(lookupid), 1), '143', 'BCBS OF SC','MED A CORE','SGL','EE+CHILD(REN)','FAMILY','2019-01-01','2019-12-31'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5,effectivedate,enddate) 
select coalesce(max(lookupid), 1), '146', 'BCBS OF SC','MED B PLUS','SGL','EE+CHILD(REN)','FAMILY','2019-01-01','2019-12-31'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5,effectivedate,enddate) 
select coalesce(max(lookupid), 1), '21', 'DELTA DENTAL', 'DENTAL','EE','EE+1','EE+2 OR MORE','2019-01-01','2019-12-31'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5, value6,effectivedate,enddate) 
select coalesce(max(lookupid), 1), '27', 'PHYS EYECARE', 'VISION','SGL','EE+SPOUSE','EE+CHILD(REN)','FAMILY','2019-01-01','2019-12-31'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3,effectivedate,enddate) 
select coalesce(max(lookupid), 1), '105', 'INFINISOURCE', 'FSA','MONTHLY PREMIUM','2019-01-01','2019-12-31'
from edi.lookup_schema;

 

--------------------------------------- Plan Year 2020 ----------------------------------------
--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5,effectivedate) 
select coalesce(max(lookupid), 1), '9', 'BCBS','BEACH PLAN','EE ONLY','EE+1','EE+FAMILY','2020-01-01'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5,effectivedate) 
select coalesce(max(lookupid), 1), '15', 'BCBS','BEACH PLUS','EE ONLY','EE+1','EE+FAMILY','2020-01-01'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5,effectivedate) 
select coalesce(max(lookupid), 1), '143', 'BCBS','BEACH PLAN','EE ONLY','EE+1','EE+FAMILY','2020-01-01'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5,effectivedate) 
select coalesce(max(lookupid), 1), '146', 'BCBS','BEACH PLUS','EE ONLY','EE+1','EE+FAMILY','2020-01-01'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5,effectivedate) 
select coalesce(max(lookupid), 1), '160', 'BCBS','HSA PLAN','EE ONLY','EE+1','EE+FAMILY','2020-01-01'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5,effectivedate) 
select coalesce(max(lookupid), 1), '21', 'DELTA DENTAL', 'DENTAL','EE','EE+1','EE+2 OR MORE','2020-01-01'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5, value6,effectivedate) 
select coalesce(max(lookupid), 1), '27', 'PHYS EYECARE', 'VISION','SGL','EE+SPOUSE','EE+CHILD(REN)','FAMILY','2020-01-01'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3,effectivedate) 
select coalesce(max(lookupid), 1), '105', 'INFINISOURCE', 'FSA','MONTHLY PREMIUM','2020-01-01'
from edi.lookup_schema;















update edi.edi_last_update

set lastupdatets = '2020-01-01 00:00:00'

where feedid = 'AXU_Infinisource_Cobra_QE_Export';



INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1,valcoldesc2,valcoldesc3,valcoldesc4,valcoldesc5,valcoldesc6, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Benefit Plan ID','Benefit Plan Name','Sub-Benefit Plan Name', 'Coverage Type 1','Coverage Type 2','Coverage Type 3','Coverage Type 4', 'AXU_Infinisource_Cobra_QE_Export', 'Benefit Plan Names'
from edi.lookup_schema;

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5) 
select coalesce(max(lookupid), 1), '9', 'BCBS','BEACH PLAN','EE ONLY','EE+1','EE+FAMILY'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5) 
select coalesce(max(lookupid), 1), '15', 'BCBS','BEACH PLUS','EE ONLY','EE+1','EE+FAMILY'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5) 
select coalesce(max(lookupid), 1), '143', 'BCBS','BEACH PLAN','EE ONLY','EE+1','EE+FAMILY'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5) 
select coalesce(max(lookupid), 1), '146', 'BCBS','BEACH PLUS','EE ONLY','EE+1','EE+FAMILY'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5) 
select coalesce(max(lookupid), 1), '160', 'BCBS','HSA PLAN','EE ONLY','EE+1','EE+FAMILY'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5) 
select coalesce(max(lookupid), 1), '21', 'DELTA DENTAL', 'DENTAL','EE','EE+1','EE+2 OR MORE'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3, value4, Value5, value6) 
select coalesce(max(lookupid), 1), '27', 'PHYS EYECARE', 'VISION','SGL','EE+SPOUSE','EE+CHILD(REN)','FAMILY'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3)
select coalesce(max(lookupid), 1), '105', 'INFINISOURCE', 'FSA','MONTHLY PREMIUM'
from edi.lookup_schema;