---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select * from person_names where lname like 'Ward%';
--- HMN ticket 38530
select * from person_names where personid = '69038';
select * from cognos_gl_detail_results_pending where personid = '66218' and periodpaydate = '2020-12-15';
select * from pspaygroupearningdeductiondets_mv limit 10;
select * from gl_amt_acct_map;
select * from cognos_gl_detail_results_released where categorydesc ilike 'ER TAX' and periodpaydate = '2020-12-15' and personid IN ('69038','66218') ;
select * from cognos_gl_detail_results_released where categorydesc ilike 'SUTA' and periodpaydate = '2020-12-15' and personid IN ('69038','66218') ;
select * from gl_execute_job limit 10;

select * from pspay_payment_detail where personid in ('69038','66218') and check_date = '2020-12-15' and etv_id like 'T%';

select * from gl_period_detail_results where personid IN ('69038','66218') and payscheduleperiodid = 120 and acctnum = '245013-999999-000'

---------------------------------------------------------------------------------------------------------------------------------------------------------------------