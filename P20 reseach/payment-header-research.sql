--- This helps to establish the correct date to set lastupdatets to 

(select paymentheaderid from payroll.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'Ameriflex_FLEX_Payroll_Deduction' 
                              and elu.lastupdatets <= ppay.statusdate
                            where ppay.pspaypayrollstatusid = 4 
                             )))
;
select * from payroll.payment_detail where check_date = '2021-02-26' and paycode in  ('VGA');                           


select elu.lastupdatets, statusdate from pspay_payroll 
join edi.edi_last_update elu  on elu.feedid = 'Ameriflex_FLEX_Payroll_Deduction' 
where pspaypayrollstatusid = 4 and pspaypayrollid in 
(select pspaypayrollid from pspay_payroll_pay_sch_periods where payscheduleperiodid in 
(select payscheduleperiodid from payroll.payment_header where paymentheaderid in 
(select paymentheaderid from payroll.payment_detail where check_date = '2021-02-26' and paycode in  ('VGA'))))
;
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2021-01-01 13:28:02'  where feedid = 'Ameriflex_FLEX_Payroll_Deduction'