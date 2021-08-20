select * from pspay_etv_list;
select * from person_financial_plan_election;
SELECT * FROM pspay_etv_operators;
select * from benefit_plan_desc;
select * from pspay_deduction_accumulators; --- loans
select * from pspay_etv_accumulator_codes;
select * from pspay_financial_plan_accumulators;
select * from pspay_input_transaction;
select * from person_identity where personid = '5978';

select * from person_financial_plan_election where personid = '5978' and createts::date = current_date::date;
delete from person_financial_plan_election where personid = '5978' and createts::date = current_date::date;
select * from person_deduction_setup where personid = '5978';
delete from person_deduction_setup where personid = '5978';


INSERT INTO person_deduction_setup (personid, etvid, persondedsetuppid, dedamount, dedpercentage, dedlimit, initialbalance, arrearsbalance, paybackfactor, effectivedate, enddate, createts, endts, updatets, dederamount) VALUES ( '5978        ',  'V65',  0.24363,  101,  NULL,  NULL,  NULL,  NULL,  NULL,  '2018-01-10 00:01:00-05',  '2199-12-31 00:00:00-05',  '2018-06-25 17:33:06.092042-04',  '2199-12-31 00:00:00-05',  '2018-06-25 17:33:06.092042-04',  NULL) ;
