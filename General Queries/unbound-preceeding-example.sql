(
select 
 x.personid
,sum(x.cum_gross_pay) as gross_pay
,max(x.check_date) as max_check_date

from 

(select pph.personid, elu.lastupdatets lastupdate,pph.check_date check_date, 
        sum(pph.gross_pay) over (order by personid, check_date asc rows between unbounded preceding and current row) as cum_gross_pay
from pspay_payment_header pph
join edi.edi_last_update elu on elu.feedid = 'BAC_JH_401K_Export' 
where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date) 
                            ) x  where x.check_date <= x.lastupdate and x.personid = '2834' group by personid

union
select 
 x.personid
,sum(x.cum_gross_pay) as gross_pay
,x.check_date as max_check_date

from 

(select pph.personid, elu.lastupdatets lastupdate,pph.check_date check_date, 
        sum(pph.gross_pay) over (order by personid, check_date asc rows between unbounded preceding and current row) as cum_gross_pay
from pspay_payment_header pph
join edi.edi_last_update elu on elu.feedid = 'BAC_JH_401K_Export' 
where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date) 
                            ) x  where x.check_date > x.lastupdate and x.personid = '2834' group by personid,max_check_date
)