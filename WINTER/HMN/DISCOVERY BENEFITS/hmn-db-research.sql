select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2020-02-14 18:40:46' where feedid = 'HMN_DiscoveryBenefits_FSAHSAContrib_Export';
update edi.edi_last_update set lastupdatets = '2020-02-16 18:40:46' where feedid = 'HMN_TransAmerica401k_Contribution_Export';
update edi.edi_last_update set lastupdatets = '2020-02-14 18:40:46' where feedid = 'HMN_GL_Export';


select 
 'H' ::char(1) as hdr_id
,'PYRL' ::char(10) as file_type
,to_char(psp.periodpaydate,'YYYYMMDD')::char(8) as post_date
,'Horace Mann-GENESYS' ::char(50) as source_name
,'09878' ::char(5) as client_id
,'000000000' ::char(15) as contrib_code

from pay_schedule_period psp

where psp.payrolltypeid = 1
  and psp.processfinaldate is not null
  and psp.periodpaydate = ?::date
  ;
select * from pspay_group_deductions where etv_id in ('VS1','VL1');
select * from person_identity where identity = '002686117';
select * from cognos_pspay_etv_names where etv_id like 'T%';

select * from pspay_payment_detail where etv_id in ('VS1','VL1') and personid = '66578';
select * from pspay_payment_header where paymentheaderid = '112123';  
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid = '101';
select * from pspay_payroll where pspaypayrollid = '92';

select * from pspay_payment_detail where etv_id in  ('VB1','VBU','VB2','V65','VBT','VB5','VB3','VB4') and personid = '66443' and check_date = '2020-02-28';

select * from pspay_payment_detail where etv_id in  ('VB1','VBU','VB2','V65','VBT','VB5','VB3','VB4') and personid = '67881' and check_date = '2020-02-28';

select * from pspay_payment_detail where etv_id in  ('VB1','VBU','VB2','V65','VBT','VB5','VB3','VB4') and personid = '68421' and check_date = '2020-02-28';

select * from pspay_payment_detail where etv_id in  ('VB1','VBU','VB2','V65','VBT','VB5','VB3','VB4') and personid = '68121' and check_date = '2020-02-28';
select * from pspay_payment_detail where etv_id in  ('VB1','VBU','VB2','V65','VBT','VB5','VB3','VB4') and personid = '68598' and check_date = '2020-02-28';


















  
(select 
 x.personid
,x.check_date
,x.etv_id
,x.etv_code
,sum(x.vba_amount) as vba_amount
,sum(x.vbb_amount) as vbb_amount
,sum(x.vej_amount) as vej_amount
,sum(x.vek_amount) as vek_amount
,sum(x.veh_amount) as veh_amount
,sum(x.vl1_amount) as vl1_amount
,sum(x.vs1_amount) as vs1_amount
from
(select distinct
 ppd.personid
,ppd.check_date
,ppd.etv_id
,ppd.etv_code
,case when ppd.etv_id = 'VBA' then etv_amount  else 0 end as vba_amount
,case when ppd.etv_id = 'VBB' then etv_amount  else 0 end as vbb_amount
,case when ppd.etv_id = 'VEJ' then etv_amount  else 0 end as vej_amount
,case when ppd.etv_id = 'VEK' then etv_amount  else 0 end as vek_amount
,case when ppd.etv_id = 'VEH' then etv_amount  else 0 end as veh_amount
,case when ppd.etv_id = 'VL1' then etv_amount  else 0 end as vl1_amount
,case when ppd.etv_id = 'VS1' then etv_amount  else 0 end as vs1_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'HMN_DiscoveryBenefits_FSAHSAContrib_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
   and ppd.etv_id  in  ('VBA','VBB','VEJ','VEK','VEH','VS1','VL1')) x
  group by 1,2,3,4 having sum(x.vba_amount + x.vbb_amount + x.vej_amount + x.vek_amount + x.veh_amount + x.vs1_amount + x.vl1_amount) <> 0) 
  ;