select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2021-01-17 10:45:59' where feedid = 'MG0_JH_401K_Export'; --2020/08/03 09:57:50.861000000
select * from company_parameters where companyparametername = 'PInt'; 
select paycoderelationshiptype from payroll.pay_code_relationships group by 1;
(select distinct
              ppd.personid
             ,ppd.amount
             ,ppd.check_date
             ,ppd.paymentheaderid
             ,ppd.units
             from PAYROLL.payment_detail ppd
             where ppd.paymentheaderid in (select paymentheaderid from PAYROLL.payment_header 
             where payscheduleperiodid in (select payscheduleperiodid from pspay_payroll_pay_sch_periods 
             where pspaypayrollid in (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'MG0_JH_401K_Export' and elu.lastupdatets < ppay.statusdate where ppay.pspaypayrollstatusid = 4 ))) 
               and ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode)
       );


(select distinct
              ppd.personid
             ,ppd.amount
             ,ppd.check_date
             ,ppd.paymentheaderid
             ,ppd.units
             from PAYROLL.payment_detail ppd
             where ppd.paymentheaderid in (select paymentheaderid from PAYROLL.payment_header 
             where payscheduleperiodid in (select payscheduleperiodid from pspay_payroll_pay_sch_periods 
             where pspaypayrollid in (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'MG0_JH_401K_Export' where ppay.pspaypayrollstatusid = 4 and date_part('year',ppay.statusdate)>=date_part('year',elu.lastupdatets) ))) 
               and ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode)
       );















(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount ---- 401K P/T    
,sum(x.vb2_amount) as vb2_amount ---- 401K C/U    
,sum(x.v25_amount) as v25_amount ---- 401k        
,sum(x.vdp_amount) as vdp_amount ---- 403b C/U    
,sum(x.vb3_amount) as vb3_amount ---- ROTH        
,sum(x.vb4_amount) as vb4_amount ---- ROTH C/U    
,sum(x.vb6_amount) as vb6_amount ---- SHNEC      
,sum(x.vb1_amount+x.vb2_amount+x.v25_amount+x.vdp_amount+x.vb3_amount+x.vb4_amount+x.vb6_amount) as total_401k 
,x.payscheduleperiodid
from


(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.paycode = 'VB1' then amount  else 0 end as vb1_amount
,case when ppd.paycode = 'VB2' then amount  else 0 end as vb2_amount
,case when ppd.paycode = 'V25' then amount  else 0 end as v25_amount
,case when ppd.paycode = 'VDP' then amount  else 0 end as vdp_amount
,case when ppd.paycode = 'VB3' then amount  else 0 end as vb3_amount
,case when ppd.paycode = 'VB4' then amount  else 0 end as vb4_amount
,case when ppd.paycode = 'VB6' then amount  else 0 end as vb6_amount
,ppd.paymentheaderid
,pph.payscheduleperiodid

from PAYROLL.payment_detail ppd
join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid

where pph.paymentheaderid in                                        
     (select paymentheaderid from PAYROLL.payment_header where payscheduleperiodid in 
            (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                   (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu  on elu.feedid =  'MG0_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                     where ppay.pspaypayrollstatusid = 4 )))
  and ppd.paycode  in  ('VB1','VB2','V25','VDP','VB3','VB4','VB6')) x
  group by 1,2,payscheduleperiodid  having sum(x.vb1_amount + x.vb2_amount + v25_amount + vdp_amount + x.vb3_amount + x.vb4_amount + x.vb6_amount) <> 0)




