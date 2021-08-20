    insert into edi.edi_last_update(feedid,lastupdatets) values('Mutual_Of_America_Quarterly','2020-09-30 18:21:21.563-04');





insert into edi.edi_last_update(feedid,lastupdatets)
values('Ameriflex_FLEX_Eligibility_Election', '2020-01-01 00:00:00'),
('Ameriflex_FLEX_Demographic_Election','2020-01-01 00:00:00');




--Add last update
insert into edi.edi_last_update (feedid,lastupdatets)
values('Ameriflex_FLEX_Payroll_Deduction','2020-03-01 00:00:00');

 

--Add etvid lookup schema
INSERT INTO edi.lookup_schema (lookupid, valcoldesc1, valcoldesc2, lookupname, lookupdesc)
select coalesce(max(lookupid) + 1, 1), 'Group Code','Plan ID', 'Ameriflex_FLEX_Eligibility_Election', 'Group Code/PlanID'
from edi.lookup_schema;

 

--Add etvid lookup values
INSERT INTO edi.lookup (lookupid, value1, value2) 
select coalesce(max(lookupid), 1), 'AMFJEFCHS', 'JEFCHS'
from edi.lookup_schema;

[3:35 PM] Ryan Ferdon
    Could you plz run the following on DJB prod?
?[3:35 PM] Ryan Ferdon
    delete from edi.lookup_schema where lookupid = 7;
delete from edi.lookup where lookupid = 7;
delete from edi.lookup where lookupid = 5;
update edi.lookup set effectivedate = '2020-03-01', enddate = '2021-02-28' where lookupid =6;
[3:36 PM] Ryan Ferdon
    

delete from edi.lookup_schema where lookupid = 5;

