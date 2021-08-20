select * from edi.edi_last_update;
select * from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');


--- Changed the plan year start and end dates to value column instead of using the effectived date and end date. The following will need to be ran for DJB

update edi.lookup_schema set valcoldesc3 = 'PlanYearStartDate' where lookupname = 'Ameriflex_FLEX_Eligibility_Election'; 
update edi.lookup_schema set valcoldesc4 = 'PlanYearEndDate' where lookupname = 'Ameriflex_FLEX_Eligibility_Election'; 
update edi.lookup set value3 = '2020-03-01'  where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election'); 
update edi.lookup set value4 = '2021-02-28'  where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election'); 

