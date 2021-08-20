/*
SELECT ea_month, id, amount, ea_year, circle_id
     , sum(amount) OVER (PARTITION BY circle_id ORDER BY mon) AS cum_amt
FROM   (SELECT *, to_date(ea_year || ea_month, 'YYYYMonth') AS mon FROM tbl)
ORDER  BY circle_id, mon;

*/
--cur401k
select 
 x.personid
,x.check_date
,sum(x.hours) as hours
,sum(x.taxable_amount) as taxable_amount

from

(select distinct ppd.personid, ppd.check_date, sum(ppd.etype_hours) over (partition by check_date) as hours, 
        sum(etv_amount) over (partition by check_date) AS taxable_amount
             from pspay_payment_detail ppd
             join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key 
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'BAC_JH_401K_Export' 
                            and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
     and peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A' AND PPD.PERSONID = '2834'
)x group by 1,2
;


--wages
(select
 pph.personid
,pph.check_date 
,sum(pph.gross_pay) as gross_pay
from pspay_payment_header pph
where PPh.PERSONID = '2834' and paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'BAC_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) group by 1,2
                             )
                             
                             
;                             

select ppdata.personid, ppdata.check_date, sum(ppdata.hours) over (order by check_date asc rows between unbounded preceding and current row) as cum_etype_hours
from 
(select ppd.personid, ppd.check_date check_date,  elu.lastupdatets lastupdate,  sum(ppd.etype_hours) as hours, sum(etv_amount) as taxable_amount
             from pspay_payment_detail ppd
             join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key
             join edi.edi_last_update elu on elu.feedid = 'BAC_JH_401K_Export' 
                            and date_part('year',ppd.check_date) = date_part('year',elu.lastupdatets) 
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))               
     and peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A' and ppd.personid = '2834' 
group by 1,2,3 order by 1,2 ) ppdata order by personid, check_date
;


with ppdata as (select 
 pph.personid
, pph.check_date
,sum(pph.gross_pay) as gross_pay
from pspay_payment_header pph
where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date)
                   
and                   pph.personid = '2834' 
                            group by 1, 2 ) 
select personid, check_date, gross_pay, sum(gross_pay) over (order by check_date asc rows between unbounded preceding and current row)

from ppdata   
;


with ppdata as (select 
 x.personid
,sum(x.hours) as prior_hours 
,sum(x.taxable_amount) as taxable_amount
,x.check_date as max_check_date

from

(select ppd.personid, ppd.check_date check_date,  elu.lastupdatets lastupdate,  sum(ppd.etype_hours) as hours, sum(etv_amount) as taxable_amount
             from pspay_payment_detail ppd
             join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key
             join edi.edi_last_update elu on elu.feedid = 'BAC_JH_401K_Export' 
                            and date_part('year',ppd.check_date) = date_part('year',elu.lastupdatets) 
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))               
     and peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A' and ppd.personid = '2834' 
group by 1,2,3 order by 1,2) x
where x.check_date > x.lastupdate
group by personid, max_check_date
)
select personid, prior_hours, max_check_date, taxable_amount, sum(taxable_amount) over (order by max_check_date asc rows between unbounded preceding and current row)
from ppdata
