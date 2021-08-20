select pd.check_date, pd.paymentheaderid, sum(pd.etv_amount) as T01 -- 29585519.40

from pspay_payment_detail pd

where pd.etv_id = 'T01' and  paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay where ppay.pspaypayrollstatusid = 4 )))
                        group by check_date, paymentheaderid;
                        
select * from pspay_payment_detail where etv_id = 'T01' and paymentheaderid = '6120';                        