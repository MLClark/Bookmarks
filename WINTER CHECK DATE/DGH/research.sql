select * from edi.edi_last_update;

update edi.edi_last_update set lastupdatets = '2019-03-06 09:18:17' where feedid = 'DGH_JH_401K_Export'; --2019-03-19 16:01:50

select * from person_employment where personid = '17791';

select * from batch_detail where personid = '17286' 
select * from pspay_payment_detail where paymentheaderid in (select pph.paymentheaderid
 from pspay_payment_header pph
left join pay_schedule_period psp on pph.payscheduleperiodid = psp.payscheduleperiodid
where psp.periodpaydate > '2019-01-01'
and psp.periodpaydate <> pph.check_date)
and etv_id in ('V65','VB1','VB2','VB3','VB4','VB5');

left join 
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
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','VB3','VB4','VB5','VB6')) x
  group by 1,2 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.vb6_amount) <> 0) dedamt on dedamt.personid = pi.personid 
  
left join 
(select 
 x.personid
,x.check_date
,sum(x.v65_amount) as v65_amount -- loan 1
,sum(x.v73_amount) as v73_amount -- loan 2
,sum(x.vci_amount) as vci_amount -- loan 3
,sum(x.vcj_amount) as vcj_amount -- loan 4
,sum(x.v65_amount+x.v73_amount+x.vci_amount+x.vcj_amount) as total_loan_amount

from
(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'V65' then etv_amount  else 0 end as v65_amount
,case when ppd.etv_id = 'V73' then etv_amount  else 0 end as v73_amount
,case when ppd.etv_id = 'VCI' then etv_amount  else 0 end as vci_amount
,case when ppd.etv_id = 'VCJ' then etv_amount  else 0 end as vcj_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) -- pspaypayrollstatusid = 4 means payroll completed
  and ppd.etv_id  in ('V65','V73','VCI','VCJ')) x  
group by 1,2 having sum(x.v65_amount + x.v73_amount + x.vci_amount + x.vcj_amount) <> 0) loans on loans.personid = pe.personid 