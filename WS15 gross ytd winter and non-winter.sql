left join     
(select ppd.personid, sum(ppd.etype_hours) as hours
   from pspay_payment_detail ppd
   join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key 
  where peo.operand = 'WS23' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A'  
    and ppd.paymentheaderid in (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                                       (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                                               (select pspaypayrollid 
                                                  from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'DGH_JH_401K_Export' 
                                                   and date_part('year',ppay.statusdate) = date_part('year',elu.lastupdatets)
                                                 where ppay.pspaypayrollstatusid = 4 ))) group by 1)  ytdhrs ON ytdhrs.personid = pe.personid        
                                                 
left join     
(select ppd.personid, sum(etv_amount) AS taxable_amount
   from pspay_payment_detail ppd
   join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key 
  where peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A'  
    and ppd.paymentheaderid in (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                                       (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                                               (select pspaypayrollid 
                                                  from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'DGH_JH_401K_Export' 
                                                   and date_part('year',ppay.statusdate) = date_part('year',elu.lastupdatets)
                                                 where ppay.pspaypayrollstatusid = 4 ))) group by 1)  ytdw ON ytdw.personid = pe.personid  

left join     
(select ppd.personid, sum(etv_amount) AS taxable_amount
   from pspay_payment_detail ppd
   join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key 
  where peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A'  
    and ppd.paymentheaderid in (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                                       (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                                               (select pspaypayrollid 
                                                  from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'DGH_JH_401K_Export' 
                                                   and ppay.statusdate::date >= elu.lastupdatets::date
                                                 where ppay.pspaypayrollstatusid = 4 ))) group by 1)  curw ON curw.personid = pe.personid                                                   


----- 5/8/2019 - changed gross ytd and ptd to use payment header --- note vendor does not use this value
----- 5/8/2019 - gross or net wages not stored in bucket - can't be pulled from pspay_etv_operators table.

left join 
(select
 pph.personid
,sum(pph.gross_pay) as gross_pay
from pspay_payment_header pph

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) group by 1
                             ) wages on wages.personid = pi.personid
left join
(select 
 pph.personid
,sum(pph.gross_pay) as ytd_gross_pay

from pspay_payment_header pph

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date)
                            group by 1) ytdwages on ytdwages.personid = pi.personid                           

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



---winter
LEFT JOIN (SELECT distinct personid
               ,sum(etype_hours) AS hours
               ,sum(etv_amount) as taxable_wage
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                            where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$'
                            group by 1)
              AND date_part('year', check_date) = date_part('year',?::DATE)
              AND check_date <= ?::DATE 
         GROUP BY personid
          ) grossytd
  ON grossytd.personid = pi.personid  
  
-- non winter

LEFT JOIN (SELECT distinct personid
               ,sum(etype_hours) AS hours
               ,sum(etv_amount) as taxable_wage
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                             join pspay_etv_list b 
                               on a.etv_id = b.etv_id
                              and a.group_key = b.group_key
                            where a.operand = 'WS15' and a.etvindicator = 'E' group by 1)
              AND date_part('year', check_date) = date_part('year',?::DATE)
              AND check_date <= ?::DATE
         GROUP BY personid
          ) grossytd
  ON grossytd.personid = piP.personid     
  