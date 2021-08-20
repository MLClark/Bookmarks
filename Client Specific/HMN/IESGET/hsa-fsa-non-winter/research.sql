select * from pay_schedule_period where date_part('year',periodpaydate)='2019'and date_part('month',periodpaydate)='12';
select * from pspay_payment_detail where etv_id in ('VBA','VBB','VEJ','VEK','VEH','VS1','VL1') and check_date = '2019-12-13';
select distinct etv_id from pspay_payment_detail group by 1;



select * from pspay_payment_detail where etv_id in ('VBA','VBB','VEJ','VEK','VEH','VS1','VL1') and check_date = '2019-11-27' AND personid = '63407';
update pspay_payment_detail set etv_id = 'VL1' where etv_id in ('VBA') and check_date = '2019-11-27' AND personid = '63407';
update pspay_payment_detail set etv_id = 'VS1' where etv_id in ('VEH') and check_date = '2019-11-27' AND personid = '63407';



(select 
 x.personid
,x.check_date
,x.etv_id
,x.etv_code
,sum(x.vba_amount) as vba_amount
,sum(x.vbb_amount) as vbb_amount
,sum(x.vej_amount) as vej_amount
,sum(x.vek_amount) as vek_amount
,sum(x.veh_amount) as veh_amount
,sum(x.vl1_amount) as vl1_amount
,sum(x.vs1_amount) as vs1_amount
from
(select distinct
 ppd.personid
,ppd.check_date
,ppd.etv_id
,ppd.etv_code
,case when ppd.etv_id = 'VBA' then etv_amount  else 0 end as vba_amount
,case when ppd.etv_id = 'VBB' then etv_amount  else 0 end as vbb_amount
,case when ppd.etv_id = 'VEJ' then etv_amount  else 0 end as vej_amount
,case when ppd.etv_id = 'VEK' then etv_amount  else 0 end as vek_amount
,case when ppd.etv_id = 'VEH' then etv_amount  else 0 end as veh_amount
,case when ppd.etv_id = 'VL1' then etv_amount  else 0 end as vl1_amount
,case when ppd.etv_id = 'VS1' then etv_amount  else 0 end as vs1_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd

where  ppd.personid = '63407' and ppd.etv_id  in ('VBA','VBB','VEJ','VEK','VEH','VS1','VL1') and check_date = ?::date ) x

  group by 1,2,3,4 having sum(x.vba_amount + x.vbb_amount + x.vej_amount + x.vek_amount + x.veh_amount) <> 0) 