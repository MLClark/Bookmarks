(select  ppd.personid, count(ppd.etv_id) as counter 
from pspay_payment_detail ppd where ppd.etv_id  in ('VEJ','VEK','VEH','VBA''VBB')  and check_date = ?::date and personid = '68671' group by 1);

(select  * from pspay_payment_detail ppd where ppd.etv_id  in ('VEJ','VEK','VEH','VBA''VBB')  and date_part('year',check_date) = date_part('year', ?::date) and personid = '68671' );



---- Combination FSA is for when the employee also has the HSA deduction.  If they only have FSA then the plan is Health FSA
select * from pspay_etv_list where etv_id in ('VBA','VBB','VEJ','VEK','VEH','VS1','VL1') ;

select * from pspay_input_transaction where 
select * from PERSON_DEDUCTION_SETUP where personid =


select * from person_identity where identity = '205689001';

insert into edi.edi_last_update(feedid,lastupdatets)
values('HMN_DiscoveryBenefits_FSAHSAContrib_Export','2019-06-28 00:00:00'); 
 select * from edi.edi_last_update where feedid = 'HMN_DiscoveryBenefits_FSAHSAContrib_Export';
 update edi.edi_last_update set lastupdatets = '2019-06-28 00:00:00' where feedid = 'HMN_DiscoveryBenefits_FSAHSAContrib_Export';


select * from edi.edi_last_update where feedid = 'HMN_DiscoveryBenefits_FSAHSAContrib_Export';


select * from PERSON_FINANCIAL_PLAN_ELECTION;


select * from pspay_payment_detail where etv_id  in  ('VS1','VL1') and check_date = '2020-01-15';
select * from pspay_payment_detail where etv_id  in  ('VBA','VBB','VEJ','VEK','VEH','VL1','VS1') and check_date = '2020-01-31';
select * from pspay_payment_detail where etv_code = 'ER' and check_date = '2020-01-15' and etv_id like 'V%';
select * from pspay_etv_list where etv_id  in ('VBA','VBB','VEJ','VEK','VEH') ;


select * from benefit_plan_desc;
select * from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'Y' and benefitelection = 'E';
select * from pspay_payment_detail where check_date = '2019-07-15' and etv_id in ('VBA','VBB');


select * from person_names where lname like 'Ford%';
  select * from pay_schedule_period where periodpaydate = '2019-07-15' and processfinaldate is not null and payrolltypeid in (1,2);
  select * from pspay_payment_header where check_date = '2019-07-15' and payscheduleperiodid = '78';
  select * from pspay_payment_header where check_date = '2019-07-15' and payscheduleperiodid = '87365';
  select * from pspay_payment_detail where check_date = '2019-07-15' and etv_id in ('VBA','VBB');
  
  select * from pspay_payment_detail where personid = '68432' and check_date = '2020-01-15' and etv_id  in  ('VBA','VBB','VEJ','VEK','VEH');
  
  select * from person_identity where identity = '205689001';
  select * from person_names where personid in (select personid from person_identity where identity = '239599584');
  select * from person_employment where personid = '67370';
  
  (select distinct ppd.personid, etv_id, count(ppd.etv_id) as counter 
from pspay_payment_detail ppd where ppd.etv_id  in ('VBA','VBB','VEJ','VEK','VEH') and check_date = ?::date and personid = '68478'
     
  group by 1,2)
  
  (select distinct
 ppd.personid
,ppd.check_date
,ppd.etv_id
,ppd.etv_code
,case when ppd.etv_id = 'VBA' then etv_amount  else 0 end as vba_amount
,case when ppd.etv_id = 'VBB' then etv_amount  else 0 end as vbb_amount
,case when ppd.etv_id = 'VEH' then etv_amount  else 0 end as veh_amount
,case when ppd.etv_id = 'VEJ' then etv_amount  else 0 end as vej_amount
,case when ppd.etv_id = 'VEK' then etv_amount  else 0 end as vek_amount
,psp.periodpaydate
,ppd.paymentheaderid

from pay_schedule_period psp 

join pspay_payment_header pph
  on pph.check_date = psp.periodpaydate
 and pph.payscheduleperiodid = psp.payscheduleperiodid 
 
join pspay_payment_detail ppd 
  on ppd.personid = pph.personid
 and ppd.check_date = psp.periodpaydate
 and pph.paymentheaderid = ppd.paymentheaderid

where psp.payrolltypeid in (1,2)
  and psp.processfinaldate is not null
  and psp.periodpaydate = ?::date
  and ppd.etv_id  in  ('VBA','VBB','VEJ','VEK','VEH')
  and ppd.personid = '68432'
  ) 