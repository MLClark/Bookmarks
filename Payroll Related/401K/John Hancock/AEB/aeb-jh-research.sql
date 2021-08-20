INSERT into edi.edi_last_update (feedid,lastupdatets) values ('AEB_JH_401k_Export','2019-04-05 00:00:00');
update edi.edi_last_update set lastupdatets = '2019-04-08 07:00:31' where feedid = 'AEB_JH_401k_Export'; --2019-04-08 07:00:31

select * from pspay_payroll where statusdate 

select * from edi.edi_last_update;

select 


(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.vbt_amount) as vbt_amount
,sum(x.vbu_amount) as vbu_amount
from
 

(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'VBT' then etv_amount  else 0 end as vbt_amount
,case when ppd.etv_id = 'VBU' then etv_amount  else 0 end as vbu_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'AEB_JH_401k_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','VB3','VB5','VBT','VBU')) x
  group by 1,2 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb5_amount + x.vbt_amount + x.vbu_amount) <> 0)
  ;
  
select * from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'AEB_JH_401k_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ;
                             
  (select * from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'AEB_JH_401k_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))                             
                             ;

        (select * from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'AEB_JH_401k_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))   
                             ;                          
select * from pspay_payment_detail where personid = '4509' and etv_id = 'VB1' and check_date >= '2019-03-08';                             
select * from edi.edi_last_update where feedid = 'AEB_JH_401k_Export' ;