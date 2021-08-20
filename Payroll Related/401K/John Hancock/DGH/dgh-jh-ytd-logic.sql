--left join 
(select ppd.personid,pn.name, sum(etype_hours) AS hours,sum(etv_amount) AS taxable_amount
             from pay_schedule_period psp 

             join pspay_payment_header pph
               on pph.check_date = psp.periodpaydate
              and pph.payscheduleperiodid = psp.payscheduleperiodid   
             join pspay_payroll_pay_sch_periods  pppsp
               on pppsp.payscheduleperiodid = pph.payscheduleperiodid      
             join pspay_payment_detail ppd 
               on ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)
              and ppd.personid = pph.personid
              and ppd.check_date = psp.periodpaydate
              and pph.paymentheaderid = ppd.paymentheaderid 
             join pspay_payroll ppay 
               on ppay.pspaypayrollid = psp.payrolltypeid
             join edi.edi_last_update elu 
               on elu.feedid = 'DGH_JH_401K_Export' 
             join person_names pn 
               on pn.personid = ppd.personid 
              and pn.nametype = 'Legal'
              and current_date between pn.effectivedate and pn.enddate
              and current_timestamp between pn.createts and pn.endts             
            where psp.payrolltypeid in (1,2)
              and psp.processfinaldate is not null
              and psp.periodpaydate >= elu.lastupdatets
            group by 1,2)  --cur 
            ;


(select ppd.personid, pn.name ,sum(ppd.etype_hours) AS hours, sum(ppd.etv_amount) AS taxable_amount
   from pspay_payment_detail ppd
   join person_names pn on pn.personid = ppd.personid and pn.nametype = 'Legal' and current_date between pn.effectivedate and pn.enddate and current_timestamp between pn.createts and pn.endts 
  where ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)                             
group by 1,2)         ;                     
    
    
    

   
   
   
   
             from pay_schedule_period psp 
             join pspay_payment_header pph
               on pph.check_date = psp.periodpaydate
              and pph.payscheduleperiodid = psp.payscheduleperiodid              
             join pspay_payment_detail ppd 
               on ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)
              and ppd.personid = pph.personid
              and ppd.check_date = psp.periodpaydate
              and pph.paymentheaderid = ppd.paymentheaderid               
            where psp.payrolltypeid in (1,2)
              and psp.processfinaldate is not null
              and psp.periodpaydate <= ?::date
              and date_part('year',psp.periodpaydate) = date_part('year',?::DATE)
             --  and ppd.personid = '17286'
            group by 1) ytd
            
            
                
    
select * from batch_detail where personid = '17286' ;
   select * from pspay_payment_detail where etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)
   and personid = '17279' and check_date >= '2019-03-06';
   
select * from pay_schedule_period where payrolltypeid in(1,2) and date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)<='03';
(select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1);
(select ppd.personid,pn.name, sum(etype_hours) AS hours,sum(etv_amount) AS taxable_amount
             from pay_schedule_period psp 

             join pspay_payment_header pph
               on pph.check_date = psp.periodpaydate
              and pph.payscheduleperiodid = psp.payscheduleperiodid   
             join pspay_payroll_pay_sch_periods  pppsp
               on pppsp.payscheduleperiodid = pph.payscheduleperiodid      
             join pspay_payment_detail ppd 
               on ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)
              and ppd.personid = pph.personid
              and ppd.check_date = psp.periodpaydate
              and pph.paymentheaderid = ppd.paymentheaderid 
             join pspay_payroll ppay 
               on ppay.pspaypayrollid = psp.payrolltypeid
             join edi.edi_last_update elu 
               on elu.feedid = 'DGH_JH_401K_Export' 
             join person_names pn 
               on pn.personid = ppd.personid 
              and pn.nametype = 'Legal'
              and current_date between pn.effectivedate and pn.enddate
              and current_timestamp between pn.createts and pn.endts             
            where psp.payrolltypeid in (1,2)
              and psp.processfinaldate is not null
              and psp.periodpaydate >= elu.lastupdatets
             -- and elu.lastupdatets >= ppay.statusdate
             --  and ppd.personid = '17286'
            group by 1,2) -- cur
   ;       


 (select ppd.personid,sum(etv_amount) AS taxable_amount
             from pay_schedule_period psp 
             join pspay_payment_header pph
               on pph.check_date = psp.periodpaydate
              and pph.payscheduleperiodid = psp.payscheduleperiodid              
             join pspay_payment_detail ppd 
               on ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)
              and ppd.personid = pph.personid
              and ppd.check_date = psp.periodpaydate
              and pph.paymentheaderid = ppd.paymentheaderid               
            where psp.payrolltypeid = 1
              and psp.processfinaldate is not null
              and psp.periodpaydate <= current_date
              and date_part('year',psp.periodpaydate) = date_part('year',current_date::DATE)
             --  and ppd.personid = '17286'
            group by 1) -- ytd





(select ppd.person

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
  and ppd.etv_id  in  ('VB1','VB2','VB3','VB4','VB5','VB6'))
  ;
            
        select * from pay_schedule_period;    
left join (SELECT distinct personid
               ,sum(etype_hours) AS hours
               ,sum(etv_amount) AS taxable_amount
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                            where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$'
                            group by 1)
               AND check_date = ?::DATE 
         GROUP BY personid
          ) cur
  ON cur.personid = pe.personid