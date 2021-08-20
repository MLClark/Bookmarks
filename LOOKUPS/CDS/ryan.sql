---------------------------
--TASC Lookups --
---------------------------

---------------------
--Client ID Lookup --
---------------------
--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1,valcoldesc2, lookupname)
select coalesce(max(lookupid) + 1, 1),'Client','MyTasc_Client_ID','CSA_ID', 'TASC_Cobra_Client_Info'
from edi.lookup_schema;

--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, key1, value1,value2) 
select coalesce(max(lookupid), 1), 'CDS','4520-2769-2539','44209'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Client_Info';

----------Last Updates-----------
--Add last update
insert into edi.edi_last_update (feedid,lastupdatets)
values('TASC_Cobra_QE_Export','2020-11-01 00:00:00');

--Add last update
insert into edi.edi_last_update (feedid,lastupdatets)
values('TASC_Cobra_GIN_Export','2020-11-01 00:00:00');

------------------------------------- Benefit PlanIDs -------------------------------

--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc, effectivedate)
select coalesce(max(lookupid) + 1, 1), 'Benefit Plan ID','Benefit Plan Code', 'TASC_Cobra_Benefitplans', 'Benefit Plan Names', '2020-10-01'
from edi.lookup_schema;

--Add etvid lookup values

INSERT INTO edi.lookup (lookupid, key1, value1, effectivedate) 
select coalesce(max(lookupid), 1), '3','MOHSA80', '2020-10-01'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1, effectivedate) 
select coalesce(max(lookupid), 1), '113','MOES', '2020-10-01'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1, effectivedate) 
select coalesce(max(lookupid), 1), '155','MOHSA50', '2020-10-01'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1, effectivedate) 
select coalesce(max(lookupid), 1), '125','DUHCP', '2020-10-01'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1, effectivedate) 
select coalesce(max(lookupid), 1), '9','DUDMO', '2020-10-01'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';
INSERT INTO edi.lookup (lookupid, key1, value1, effectivedate) 
select coalesce(max(lookupid), 1), '128','VUHC', '2020-10-01'
from edi.lookup_schema
where lookupname = 'TASC_Cobra_Benefitplans';


------------------------------------- Benefit Subclasses -------------------------------

--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1,valcoldesc1,lookupname,lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Benefit Type', 'Benefit Subclass', 'TASC_COBRA_BenefitSubclasses', 'Configurable Benefit Subclasses'
from edi.lookup_schema;

--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'Medical', '10'
from edi.lookup_schema
where lookupname = 'TASC_COBRA_BenefitSubclasses';
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'Dental', '11'
from edi.lookup_schema
where lookupname = 'TASC_COBRA_BenefitSubclasses';
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'Vision', '14'
from edi.lookup_schema
where lookupname = 'TASC_COBRA_BenefitSubclasses';




























insert into edi.edi_last_update(feedid,lastupdatets)
values('Ameriflex_FLEX_Eligibility_Election', '2020-01-01 00:00:00'),
('Ameriflex_FLEX_Demographic_Election','2020-01-01 00:00:00');



update edi.lookup set effectivedate = '2019-01-01', enddate = '2019-12-31' where lookupid = 4;
insert into edi.lookup(lookupid,value1,value2,effectivedate,enddate)
values(4,'AMFCOMDOC','COMDOC','2020-01-01','2020-12-31');




update edi.edi_last_update set lastupdatets = '2020-02-01 00:00:00' where feedid = 'WageWorks_COBRA_Export';



insert into edi.lookup (lookupid, key1, value1)
values (3,12,'Delta Dental'),
(3,158,'BlueChoice HMO HSA/HRA Gold 1500'),
(3,159,'BlueChoice HMO HSA/HRA Silver 1500'),
(3,160,'BlueChoice HMO HSA/HRA Silver 2000');

 

------------------------------------- Benefit Subclasses -------------------------------
--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1,valcoldesc1,lookupname,lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Benefit Type', 'Benefit Subclass', 'WageWorks_COBRA_BenefitSubclasses', 'Configurable Benefit Subclasses'
from edi.lookup_schema;

 

--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'Medical', '10'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'Medical', '1MD'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'Dental', '11'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'Dental', '11MD'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'Vision', '14'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), 'FSA', '60'
from edi.lookup_schema;






--Add last update
insert into edi.edi_last_update (feedid,lastupdatets)
values('Ameriflex_FLEX_Payroll_Deduction','2020-03-01 00:00:00');

 

--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, valcoldesc1, valcoldesc2, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Group Code','Plan ID', 'Ameriflex_FLEX_Eligibility_Election', 'Group Code/PlanID'
from edi.lookup_schema;

 

--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, value1, value2) 
select coalesce(max(lookupid), 1), 'AMFPEOSTR', 'PEOSTR'
from edi.lookup_schema;





update edi.edi_last_update
set lastupdatets = '2020-02-01 00:00:00'
where feedid = 'WageWorks_Cobra_Export';



--Add last update
insert into edi.edi_last_update (feedid,lastupdatets)
values('WageWorks_Cobra_Export','2020-01-01 00:00:00');

 

--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Benefit Plan ID','Benefit Plan Name', 'WageWorks_Cobra_Export', 'Benefit Plan Names'
from edi.lookup_schema;

 

--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '3', 'Liberty EPO HSA'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '6', 'Medical 2'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '9', 'Dental Network Only PPO 20PIN53'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '40', 'Vision 2'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '113', 'Liberty- Excl Select'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '125', 'Dental PPO'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '128', 'Vision'
from edi.lookup_schema;
INSERT INTO edi.lookup (lookupid, key1, value1) 
select coalesce(max(lookupid), 1), '155', 'Liberty EPO HSA  50'
from edi.lookup_schema;

 

 