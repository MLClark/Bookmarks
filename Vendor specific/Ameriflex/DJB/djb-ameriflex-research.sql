

select * from edi.edi_last_update;
select * from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');
update edi.edi_last_update set lastupdatets = '2021-02-01 13:28:02'  where feedid = 'Ameriflex_FLEX_Payroll_Deduction'