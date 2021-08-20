
select * from pspay_payment_detail where paymentheaderid in (select pph.paymentheaderid
 from pspay_payment_header pph
left join pay_schedule_period psp on pph.payscheduleperiodid = psp.payscheduleperiodid
where psp.periodpaydate > '2019-01-01'
and psp.periodpaydate <> pph.check_date)
and etv_id like 'V%' 

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


select * from pay_schedule_period where payscheduleperiodid in (91,92);--- check for processfinaldate  is not null final date determines if final ran

select * from pspay_payroll -- drives when payroll is run

select * from pspay_payment_header where payscheduleperiodid in (91,92);

select * from pspay_payroll_pay_sch_periods where pspaypayrollid in (91,92);  -- id's pay units processed

select * from pspay_payment_detail

2018-07-27
select * from pspay_payment_header limit 10;
select * from pspay_payment_header where check_date = '2018-07-27' 
select * from pay_schedule_period where periodpaydate = '2018-07-27' and processfinaldate is null and payrolltypeid = 1;

select * from pspay_payment_header where check_date = '2018-06-29' ;
select * from pay_schedule_period where periodpaydate = '2018-06-29' and processfinaldate is not null and payrolltypeid = 1;
select * from pspay_payment_detail where check_date = '2018-07-28' and etv_id in  ('VEH','VEK','VEI','VEJ');

select * from pay_schedule_period where processfinaldate is not null and payrolltypeid = 1;

select * from pspay_payment_header where personid = '1179' and check_date = '2018-03-20';
select * from pspay_etv_list;

join pay_schedule_period psp 
  on psp.payrolltypeid = 1
 and psp.processfinaldate is not null
 and psp.periodpaydate = ?::date

join pspay_payment_header pph
  on pph.check_date = psp.periodpaydate
 and pph.payscheduleperiodid = psp.payscheduleperiodid  

join pspay_payment_detail ppd
  on ppd.etv_id IN ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')
 and ppd.personid = pi.personid
 and ppd.check_date = psp.periodpaydate
 and pph.paymentheaderid = ppd.paymentheaderid
 
 

(SELECT personid
                 ,sum(etype_hours) AS ytdhours
                 --,sum(etv_amount) as ytd_taxable_wage
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
             -- 6/16 feedback need holiday pay included in ytd totals adding ECZ, EC8, E17
            WHERE etv_id in  ('E01','E02','E03','E15','E19','E18','E08', 'E61','E05','ECZ','EC8','E17')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date <= ?::DATE
         GROUP BY personid
          )

select distinct 
 psp.processfinaldate
,ppd.personid
,sum(ppd.etype_hours) as ytdhours
from pay_schedule_period psp  


join pspay_payment_detail ppd
  on ppd.etv_id IN ('E01','E02','E03','E15','E19','E18','E08', 'E61','E05','ECZ','EC8','E17')  
 and ppd.check_date <= psp.periodpaydate
 AND date_part('year', ppd.check_date) = date_part('year',current_date)

where psp.payrolltypeid = 1
  and psp.processfinaldate is not null
  and psp.periodpaydate = ?::date        
  and ppd.personid = '2001'
  group by 1,2