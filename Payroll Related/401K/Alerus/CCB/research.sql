select * from pers_pos where personid in ('1079','1166')










--insert into edi.edi_last_update (feedid,lastupdatets) values ('CCB_Alerus_401K_Export','2020-11-06 06:00:17');

--select * from edi.edi_last_update;

--update edi.edi_last_update set lastupdatets = '2020-12-31 00:00:00'  where feedid = 'CCB_Alerus_401K_Export';
select * from PAYROLL.payment_detail where personid = '1164' and check_date = '2020-11-13' and paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode);
     
select * from person_names where personid = '1210';       
select * from PAYROLL.payment_detail where paycode  in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31') and check_date >= '2020-09-01' order by personid;

select distinct personid, check_date from PAYROLL.payment_detail where paycode  in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31') and check_date >= '2020-09-01';

select * from payroll.payment_header where personid = '1019' and check_date = '2020-11-13';
select * from pspay_payroll where pspaypayrollstatusid = 4;

(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.v65_amount) as v65_amount
,sum(x.v73_amount) as v73_amount
,sum(x.v31_amount) as v31_amount
,x.payscheduleperiodid
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


from PAYROLL.payment_detail ppd
join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
where pph.paymentheaderid in 
        (select paymentheaderid from PAYROLL.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu  on elu.feedid = 'CCB_Alerus_401K_Export' and elu.lastupdatets < ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.paycode  in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31')) x
group by personid, check_date, payscheduleperiodid  having sum(x.vb1_amount + x.vb2_amount + vb3_amount + vb4_amount + vb5_amount + v65_amount + x.v73_amount + x.v31_amount) <> 0) order by personid ;

(select wh.personid, wh.check_date, sum(wh.units) as hours, sum(wh.amount) as gross
   from    
       (select distinct
              ppd.personid
             ,ppd.amount
             ,ppd.check_date
             ,ppd.paymentheaderid
             ,ppd.units
             from PAYROLL.payment_detail ppd
             where ppd.personid = '1210' and ppd.paymentheaderid in (select paymentheaderid from PAYROLL.payment_header 
             where payscheduleperiodid in (select payscheduleperiodid from pspay_payroll_pay_sch_periods 
             where pspaypayrollid in (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'CCB_Alerus_401K_Export' and elu.lastupdatets < ppay.statusdate where ppay.pspaypayrollstatusid = 4 ))) 
               and ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode)
       ) wh group by personid, check_date order by personid
);
select personid, check_date, gross_pay from payroll.payment_header where check_date = '2020-11-13' and personid = '1210';
select * from payroll.payment_detail where check_date = '2020-11-13' and personid = '1210';
select * from payroll.payment_detail where check_date = '2020-11-13' and personid = '1019' and paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kHrs') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode);
select * from payroll.payment_detail where check_date = '2020-11-13' and personid = '1019' and paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode);

select * from payroll.pay_code_relationships where paycoderelationshiptype ilike ('401k%');