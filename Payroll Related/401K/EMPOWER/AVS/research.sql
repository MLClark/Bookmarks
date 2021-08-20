select check_date::date from pspay_payment_detail where date_part('year',check_date) >= '2017'  group by 1 order by 1;
select * from pay_schedule_period where payunitid = '1';
SELECT * from pspay_payment_detail where etv_id in ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ') and check_date = ?;
select * from pspay_payment_header where check_date = ?::date and individual_key in (SELECT individual_key from pspay_payment_detail where etv_id in ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ'));
select distinct personid,frequencycode,max(compamount) compamount
   from person_compensation 
  where earningscode = 'BenBase'
    and personid = '5157'
 group by 1,2;
 select * from person_compensation where earningscode = 'BenBase' and personid = '5157' and current_date between effectivedate and enddate and current_timestamp between createts and endts;