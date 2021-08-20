select * from benefit_plan_desc
where current_date between effectivedate and enddate
and current_timestamp between createts and endts;

select * from pspay_deduction_accumulators;

select * from person_bene_election 
where benefitsubclass in ('60','61')
  and selectedoption = 'Y'
  and benefitelection = 'E' 
  and current_date between effectivedate and enddate
  and current_timestamp between createts and endts;
  
select * from pay_schedule_period where date_part('year',periodpaydate)='2018'and date_part('month',periodpaydate)='09';  
select * from pspay_payment_detail where personid = '322' and etv_id in ('VBA','VBB') and check_date <= '2018-10-17';

SELECT personid,check_date,paymentheaderid, sum(etv_amount) as etv_amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VBA') and personid = '322'    
              and check_date = '2018-10-17'
              and etv_amount <> 0
         GROUP BY personid,check_date,paymentheaderid
         ;

SELECT personid,check_date,paymentheaderid, sum(etv_amount) as etv_amount
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VBB') and personid = '322'    
              and check_date = '2018-10-17'
         GROUP BY personid,check_date,paymentheaderid
         ;         