-- voided Michele Rohrbaugh voided 401k contributions on 3/22

select * from person_names where personid = '18960';
select * from batch_header a, batch_detail b where a.batchheaderid=b.batchheaderid and batchname ilike '%void%' and etv_id in ('V65','VB1','VB2','VB3','VB4','VB5') ;
select * from batch_header where batchheaderid = '673'  and etv_id in ('V65','VB1','VB2','VB3','VB4','VB5') ;
select * from batch_detail where batchheaderid = '673' and etv_id in ('V65','VB1','VB2','VB3','VB4','VB5');

select * from pay_schedule_period where payscheduleperiodid = '764';  --- payscheduleperiodid = '764' is batch with voided checks
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid = '764';  ---- pspaypayrollid = '16' is batch with voided checks


select * from pspay_payroll where pspaypayrollid in ('16', '14','15');  ----- pspaypayrollid = '14' is for 3/22 pay roll pspaypayrollid = '15' is for 3/27 payroll pspaypayrollid = '16' is for 4/2 payroll 



select * from pspay_payroll_pay_sch_periods where pspaypayrollid in ('16', '14','15'); 
select * from pspay_payment_header where payscheduleperiodid in ( '1024','619','590','648','735','677','764','706') and personid = '18960';  ---- payscheduleperiodid in ( '1024','619','590','648','735','677','764','706') are all the psp id's for voided and processed batches
select * from pspay_payment_detail where paymentheaderid in ('8281','9450','9448','9447','8282') and etv_id in ('V65','VB1','VB2','VB3','VB4','VB5'); ---- paymentheaderid in ('8281','9450','9448','9447','8282') are all the paymentheader id's for voided and processed batches

 (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ) ) );

(select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ) ); 
                             
(select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 );                                                         
                             
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.vb6_amount) as vb6_amount
from
 

(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'VB6' then etv_amount  else 0 end as vb6_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ) ) )
  and ppd.etv_id  in  ('VB1','VB2','VB3','VB4','VB5','VB6')
  and ppd.personid = '18960') x
  group by 1,2 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.vb6_amount) <> 0)
  ;