--- This helps to establish the correct date to set lastupdatets to 

(select paymentheaderid, check_date from payroll.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'KD0_LincolnFinancial_403B_Contributions' 
                              and elu.lastupdatets <= ppay.statusdate
                            where ppay.pspaypayrollstatusid = 4 
                             )))
;
select * from payroll.payment_detail where check_date = '2021-02-05' and paycode in  ('VD0','VDP','VB6','VAT','VAU') and paymentheaderid in 
  (select paymentheaderid from payroll.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'KD0_LincolnFinancial_403B_Contributions' 
                              and elu.lastupdatets <= ppay.statusdate
                            where ppay.pspaypayrollstatusid = 4 
                             )));                         


select elu.lastupdatets, statusdate from pspay_payroll 
join edi.edi_last_update elu  on elu.feedid = 'KD0_LincolnFinancial_403B_Contributions' 
where pspaypayrollstatusid = 4 and pspaypayrollid in 
(select pspaypayrollid from pspay_payroll_pay_sch_periods where payscheduleperiodid in 
(select payscheduleperiodid from payroll.payment_header where paymentheaderid in 
(select paymentheaderid from payroll.payment_detail where check_date = '2021-01-28' and paycode in  ('VBB'))))





(select
 x.personid
,x.periodpaydate
,sum(x.vdo_amount) as vdo_amount -- Pre Taxed 403(b)  
,sum(x.vdp_amount) as vdp_amount -- 403b EE Catchup
,sum(x.vb6_amount) as vb6_amount -- ER Base Contribution
,sum(x.loan1_amount) as loan1_amount -- loan 1 amount
,sum(x.loan2_amount) as loan2_amount -- loan 2 amount
,sum(x.vdo_amount + x.vdp_amount + x.vb6_amount + x.loan1_amount + x.loan2_amount) as total_payroll_amount

from

(select
ppd.personid
,psp.periodpaydate
,case when ppd.paycode = 'VDO' then amount else 0 end as vdo_amount  -- 403b EE deductions
,case when ppd.paycode = 'VDP' then amount else 0 end as vdp_amount  -- 403b EE Catchup
,case when ppd.paycode = 'VB6' then amount else 0 end as vb6_amount  -- Employer Match
,case when ppd.paycode = 'VAT' then amount else 0 end as loan1_amount  -- Loan 1
,case when ppd.paycode = 'VAU' then amount else 0 end as loan2_amount  -- Loan 2
,ppd.paymentheaderid

from PAYROLL.payment_detail ppd 
join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
join pay_schedule_period psp on psp.payscheduleperiodid = pph.payscheduleperiodid
where ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'KD0_LincolnFinancial_403B_Contributions' 
                              and elu.lastupdatets <= ppay.statusdate 
					       and ppay.pspaypayrollstatusid = 4 )))) x 			       
 group by 1,2 having sum(x.vdo_amount + x.vdp_amount + x.vb6_amount + x.loan1_amount + x.loan2_amount) <> 0)
 ;