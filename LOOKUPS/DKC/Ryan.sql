
------------------------------------- CUSTOM FIELDS -------------------------------
-- HOLIDAY SCHEMA --
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, keycoldesc2, valcoldesc1, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'UFID','UFNAME','Description', 'Novatime_Custom_Holiday', 'Custom User Field for Novatime'
from edi.lookup_schema;

-- HOLIDAY VALUES --
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '1','NOVAHOLIDAY', 'STANDARD'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_Holiday';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '2','NOVAHOLIDAY', 'EXEMPT HOLIDAY'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_Holiday';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '3','NOVAHOLIDAY', 'PT HR'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_Holiday';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '4','NOVAHOLIDAY', 'No Holiday'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_Holiday';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '5','NOVAHOLIDAY', 'PT HR - 6 hours'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_Holiday';

------------------------------------------------------------------------------------------------------------
-- PAY CATEGORY SCHEMA --
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, keycoldesc2, valcoldesc1, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'UFID','UFNAME','Description', 'Novatime_Custom_PayCategory', 'Custom User Field for Novatime'
from edi.lookup_schema;

-- PAY CATEGORY VALUES--
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '100','NOVAPAYCATEGORY', 'OFFICERS AND OWNERS'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayCategory';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '101','NOVAPAYCATEGORY', 'EXEMPT'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayCategory';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '102','NOVAPAYCATEGORY', 'NON EXEMPT'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayCategory';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '103','NOVAPAYCATEGORY', '3 WK AGREEMENT EXEMPT'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayCategory';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '104','NOVAPAYCATEGORY', '3 WK AGREEMENT NON EXEMPT'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayCategory';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '105','NOVAPAYCATEGORY', '4 WK AGREEMENT EXEMPT'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayCategory';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '106','NOVAPAYCATEGORY', '4 WK AGREEMENT NON EXEMPT'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayCategory';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '107','NOVAPAYCATEGORY', '5 WK AGREEMENT EXEMPT'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayCategory';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '108','NOVAPAYCATEGORY', '4 wk Non-exempt PT 32 hrs wk'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayCategory';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '200','NOVAPAYCATEGORY', 'PT NOT ELIGIBLE'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayCategory';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '201','NOVAPAYCATEGORY', 'TEMP NOT ELIGIBLE'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayCategory';

------------------------------------------------------------------------------------------------------------
-- PAY POLICY SCHEMA --
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, keycoldesc2, valcoldesc1, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'UFID','UFNAME','Description', 'Novatime_Custom_PayPolicy', 'Custom User Field for Novatime'
from edi.lookup_schema;

-- PAY POLICY VALUES--
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '1','NOVAPAYPOLICY', 'SALARIED PAY POLICY'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayPolicy';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '10','NOVAPAYPOLICY', 'Temporary Hourly One Punch PAY POLICY'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayPolicy';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '2','NOVAPAYPOLICY', 'OFFICE PAY POLICY'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayPolicy';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '3','NOVAPAYPOLICY', 'HOURLY PAY POLICY'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayPolicy';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '4','NOVAPAYPOLICY', 'EXEMPT AUTO PAY'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayPolicy';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '5','NOVAPAYPOLICY', 'TEMP WORKERS PAY POLICY'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayPolicy';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '6','NOVAPAYPOLICY', 'PART TIME 25+ HOURS PER WEEK'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayPolicy';
INSERT INTO edi.lookup (lookupid, key1,key2,value1) 
select coalesce(max(lookupid), 1), '7','NOVAPAYPOLICY', 'PART TIME 20 HOURS PER WEEK'
from edi.lookup_schema
where lookupname = 'Novatime_Custom_PayPolicy';











select * from edi.lookup_schema where createts::date = current_date;
select * from edi.lookup where createts::date = current_date;


































-- NOVATIME Export Inserts -- 

 

--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, valcoldesc2, valcoldesc3, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Group', 'Company', 'Organization', 'Position', 'Novatime Group', 'key=lookupname'
from edi.lookup_schema;


 

--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'Group','company_code', 'organization_code', 'position_desc'
from edi.lookup_schema
where lookupname = 'Novatime Group';



select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Novatime Group') and createts::date = current_date::date;


delete from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Novatime Group') and createts::date = current_date::date;


select * from edi.lookup_schema where lookupname =  'Novatime Group' and createts::date = current_date::date;
delete from edi.lookup_schema where lookupname =  'Novatime Group' and createts::date = current_date::date;


















-- NOVATIME Import Inserts -- 

 

--remove current values
delete from edi.lookup_schema where lookupid = '4';
delete from edi.lookup where lookupid = '4';

 

--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, valcoldesc2, valcoldesc3, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Client', 'ETVID', 'Hours Type', 'Salary Flag', 'Novatime Import Lookup', 'key=lookupname'
from edi.lookup_schema;

 

--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E01', 'REG', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E01', 'SAL', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E01', 'WKHM', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E02', 'OT', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E08', 'RETRO', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E15', 'PTO', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E15', 'PTO2', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E15', 'PTO3', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E15', 'PTO4', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E15', 'PTO5', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E15', 'PTO6', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E15', 'PTO7', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E15', 'PTO8', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E15', 'VAC', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E16', 'SICK', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E17', 'HOL', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E18', 'BRVMT', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E19', 'JURY', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E20', 'PERS', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E30', 'SEV', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E32', 'THIRD', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E33', 'WC', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E34', 'LTD3', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E37', 'CAR', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E61', 'BONUS', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','E62', 'COM', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','EBK', '3PTNT', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','EDB', 'OFFS', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','EDB', 'OFFSI', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','EDH', 'EPTO', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','EDI', 'CPTO', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','EEL', 'FPTO', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','EG0', 'CARNT', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','EG1', 'CPT', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','EG3', 'DENRE', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','EG4', 'EMCL', 'N'
from edi.lookup_schema;

 

INSERT INTO edi.lookup (lookupid, key1, value1, value2, value3) 
select coalesce(max(lookupid), 1), 'DKC','EG8', 'OUTB', 'N'
from edi.lookup_schema;