select * from edi.edi_last_update;  --- should have 3 entries for Ameriflex

select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');

---- For 2021 OE need to insert a new row for upcomping plan year.
insert into edi.lookup (lookupid,value1,value2,value3,value4) select lkups.lookupid,'AMFJEFCHS','JEFCHS','2021-03-01','2022-02-28' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Eligibility_Election');

---- For P20 upgrade - convert paycodes to lookup values 
---- DJB list of EE etv_ids ('VBA','VBB','VL1','VC1','VS1','VC0','VEH','VEK')
---- DJB list or ER etv_ids ('VBA','VBB','VL1','VS1','VC0','VC1','VEH','VEK') - these need to be converted to *_ER
/*

,case when dedamt_EE.etv_id = 'VBA' then 'FSA' --fsa
      when dedamt_EE.etv_id = 'VBB' then 'DCA' --dca
      when dedamt_EE.etv_id in ('VS1','VC0') then 'TRN' --trn
      when dedamt_EE.etv_id in ('VL1','VC1') then 'PKG' --pkg
      when dedamt_EE.etv_id = 'VEH' then 'UMB' --umb
      when dedamt_EE.etv_id = 'VEK' then 'HRA' --HRA
end :: char(3) as Account_Type

*/

select * from payroll.pay_codes where current_date between effectivedate and enddate and current_timestamp between createts and endts
and paycode like ('VGA%');

select * from payroll.pay_codes where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and paycodeshortdesc like ('%CRA%');
select * from payroll.pay_codes where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and paycodeshortdesc like ('%P/T%');


INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, lookupname, lookupdesc)
select nextval('edi.lookup_schema_id_seq'),'Paycode_AccountType_ContribType','Ameriflex_FLEX_Payroll_Deduction','key=Pay Code and Contrib Type';

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VBA','FSA','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VBA_ER','FSA','ER' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VBB','DCA','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VBB_ER','DCA','ER' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VL1','PKG','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VL1_ER','PKG','ER' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VC1','PKG','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
--VC1_ER is not used for DJB

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VS1','TRN','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VS1_ER','TRN','ER' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VC0','TRN','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');

-- VC0_ER is not used for DJB
-- VGA    is not used for DJB
-- VGA_ER is not used for DJB

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VEH','UMB','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
-- VEH_ER is not used for DJB

insert into edi.lookup (lookupid,value1,value2,value3) select lkups.lookupid,'VEK','HRA','EE' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Payroll_Deduction');
-- VEK_ER is not used for DJB

select * from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Payroll_Deduction';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Payroll_Deduction');

