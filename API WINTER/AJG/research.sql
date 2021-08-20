select * from person_deduction_setup where createts::date = current_date --- - interval '1 day' 

select * from person_deduction_setup where personid in ('9642', '9628') and etvid in ('VBB');

select * from person_deduction_setup where etvid = 'STD';
select * from pspay_input_transaction where transaction_originate like 'AJG%';


select * from person_deduction_setup where personid  in ('9642', '9628') and etvid = 'VBB';

select * from person_deduction_setup where personid = '13565' and etvid = 'VBC';

select * from person_deduction_setup where personid = '9760' and etvid in ('VBC','VBD','VBE');


--- Back out / reset transactions
update person_deduction_setup set enddate = '2199-12-31' where personid in ('9642', '9628') and etvid = 'VBB';
update person_deduction_setup set enddate = '2199-12-31' where personid = '13565' and etvid = 'VBC';
update person_deduction_setup set enddate = '2199-12-31' where personid = '9760' and etvid in ('VBC','VBD','VBE');
delete from  person_deduction_setup where createts::date = current_date and personid = '9760' and etvid in ('VBC','VBD','VBE');


select l.value1 as etv_id, l.value2 as goal_flag, 1 as valid_etv from edi.lookup_schema ls join edi.lookup l on ls.lookupid = l.lookupid where lookupname = 'AJG_Selerex_Deduction_Import';

select * from person_deduction_setup where personid = '9760' and etvid in ('VBC','VBD','VBE');


select * from log_entries where processName = 'PersDeductionsSetup' and viewName = 'PERSON_DEDUCTION_SETUP' and pageName = 'MetaUpdateRow';
select * from person_identity where identity in ('480','559','546','17335') and identitytype = 'EmpNo';
select * from person_identity where identitytype = 'EmpNo';