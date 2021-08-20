--[Logical].[Deductions by Check Date].[etv_id] in ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31')

select * from person_employment
select * from edi.lookup_schema;

select * from edi.edi_last_update;
insert into edi.edi_last_update (feedid,lastupdatets) values ( 'Empower 401k Plan Number Lookup' ,'2020-10-01 06:04:24') 
update edi.edi_last_update set lastupdatets = '2020-09-01 06:04:24' where feedid = 'Empower 401k Plan Number Lookup';
select * from pspay_payment_header where personid = '2461'

select * from pspay_group_deductions where etv_id in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31') and group_key = 'UEU00';
        
select * from payroll.pay_code_relationship_type;     
select * from payroll.pay_code_relationships where paycoderelationshiptype in ('401kHrs','401kWg');

select * from payroll.payment_header;

select * from payroll.payment_detail where paycode  in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31');
select * from payroll.payment_header where paymentheaderid in (select paymentheaderid from payroll.payment_detail where paycode  in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31'));
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid in (select payscheduleperiodid from payroll.payment_header where paymentheaderid in (select paymentheaderid from payroll.payment_detail where paycode  in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31')));
select * from pspay_payroll where pspaypayrollid in (select pspaypayrollid from pspay_payroll_pay_sch_periods where payscheduleperiodid in (select payscheduleperiodid from payroll.payment_header where paymentheaderid in (select paymentheaderid from payroll.payment_detail where paycode  in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31'))));

select * from pspay_payroll ppay
  join edi.edi_last_update elu  on elu.feedid =  'Empower 401k Plan Number Lookup' and elu.lastupdatets <= ppay.statusdate
 where pspaypayrollid in (select pspaypayrollid from pspay_payroll_pay_sch_periods where payscheduleperiodid in (select payscheduleperiodid from payroll.payment_header where paymentheaderid in (select paymentheaderid from payroll.payment_detail where paycode  in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31'))));
        
select * from payroll.earnings_imputed;      
--- ipe

left JOIN (SELECT individual_key
                 ,coalesce(sum(etv_amount),0) as imputed_partner_earnings
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
            WHERE etv_id in  ('E46')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date <= ?::DATE
         GROUP BY individual_key
          ) ipe
  ON ipe.individual_key = piP.identity
 
 select * from payroll.payment_detail where paycode = 'E46';
 
 select ppd.personid,coalesce(sum(amount),0) as imputed_partner_earnings
    from payroll.payment_detail ppd where ppd.paycode = 'E46' and date_part('year',ppd.check_date)<=date_part('year',current_date) 

             group by personid
--dedamt

(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) * -1 as vb1_amount
,sum(x.vb2_amount) * -1 as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.v65_amount) as v65_amount
,sum(x.v73_amount) as v73_amount
,sum(x.v31_amount) as v31_amount

,x.payscheduleperiodid
,x.paycode
,sum(x.vb1_amount+x.vb2_amount+x.vb3_amount+x.vb4_amount+x.vb5_amount+x.v65_amount+x.v73_amount+x.v31_amount) as total_401k
from
(select distinct
ppd.personid
,ppd.check_date
,case when ppd.paycode = 'VB1' then amount  else 0 end as vb1_amount
,case when ppd.paycode = 'VB2' then amount  else 0 end as vb2_amount
,case when ppd.paycode = 'VB3' then amount  else 0 end as vb3_amount
,case when ppd.paycode = 'VB4' then amount  else 0 end as vb4_amount
,case when ppd.paycode = 'VB5' then amount  else 0 end as vb5_amount
,case when ppd.paycode = 'V65' then amount  else 0 end as v65_amount
,case when ppd.paycode = 'V73' then amount  else 0 end as v73_amount
,case when ppd.paycode = 'V31' then amount  else 0 end as v31_amount
,ppd.paymentheaderid
,pph.payscheduleperiodid
,ppd.paycode
from PAYROLL.payment_detail ppd
join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid

where pph.paymentheaderid in 
        (select paymentheaderid from PAYROLL.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu  on elu.feedid =  'Empower 401k Plan Number Lookup' and elu.lastupdatets<= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.paycode  in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31')) x
  group by 1,2,payscheduleperiodid,paycode  having sum(x.vb1_amount + x.vb2_amount + vb3_amount + vb4_amount + vb5_amount + v65_amount + x.v73_amount + x.v31_amount) <> 0)
  
  ;
  
  
  (SELECT distinct x.personid, x.check_date, sum(x.subject_wages) as subject_wages
   from    
       (Select distinct
              ppd.personid
             ,ppd.subject_wages 
             ,ppd.check_date
             ,ppd.paycode
             ,ppd.paymentheaderid
             from PAYROLL.payment_detail ppd
             where ppd.paymentheaderid in (select paymentheaderid from PAYROLL.payment_header 
             where payscheduleperiodid in (select payscheduleperiodid from pspay_payroll_pay_sch_periods 
             where pspaypayrollid in (select pspaypayrollid from pspay_payroll ppay where ppay.pspaypayrollstatusid = 4 ))) 
               and ppd.paycode in ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31') and ppd.personid = '2472'
               and date_part('year',current_date) >= date_part('year',ppd.check_date)
               and ppd.subject_wages <> 0
       ) x group by personid, check_date, paycode
) ;


(SELECT wh.personid, wh.check_date, sum(wh.units_ytd) as hours, sum(wh.amount_ytd) as amount
   from    
       (Select distinct
              ppd.personid
             ,ppd.amount_ytd 
             ,ppd.check_date
             ,ppd.paymentheaderid
             ,ppd.units_ytd
             from PAYROLL.payment_detail ppd
             where ppd.paymentheaderid in (select paymentheaderid from PAYROLL.payment_header 
             where payscheduleperiodid in (select payscheduleperiodid from pspay_payroll_pay_sch_periods 
             where pspaypayrollid in (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid =  'Empower 401k Plan Number Lookup' and date_part('year',elu.lastupdatets) >= date_part('year',ppay.statusdate) where ppay.pspaypayrollstatusid = 4 ))) 
               and ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode) and ppd.personid = '2472'
       ) wh group by 1,2
)