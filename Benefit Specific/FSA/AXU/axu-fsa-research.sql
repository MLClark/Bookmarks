left join 
(select 
 x.personid
,x.check_date
,x.etv_code
,sum(x.vba_amount) as vba_amount -- med fsa
,sum(x.vbb_amount) as vbb_amount -- dcare fsa
,sum(x.vba_amount+x.vbb_amount) as total_fsa_amount

from
 

(select distinct
 ppd.personid
,ppd.check_date
,ppd.etv_code
,case when ppd.etv_id = 'VBA' then etv_amount  else 0 end as vba_amount
,case when ppd.etv_id = 'VBB' then etv_amount  else 0 end as vbb_amount
,psp.periodpaydate
,ppd.paymentheaderid

from person_identity pi

join pay_schedule_period psp 
  on psp.payrolltypeid = 1
 and psp.processfinaldate is not null
 and psp.periodpaydate = ?::date

join pspay_payment_header pph
  on pph.check_date = psp.periodpaydate
 and pph.payscheduleperiodid = psp.payscheduleperiodid 
 
join pspay_payment_detail ppd 
  on ppd.personid = pi.personid
 and ppd.check_date = psp.periodpaydate
 and pph.paymentheaderid = ppd.paymentheaderid

where pi.identitytype = 'SSN'::bpchar 
  AND current_timestamp between pi.createts and pi.endts and ppd.etv_id  in  ('VBA','VBB')) x
group by 1,2,3 having sum(x.vba_amount + x.vbb_amount) <> 0) ppd on ppd.personid = pi.personid 
                       


















select * from pay_schedule_period where payrolltypeid = 1;
select * from pspay_payment_detail where check_date = '2019-01-04' and etv_id in ('VBA','VBB');
SELECT * from pspay_payment_detail where individual_key = 'AXU00000002420' and etv_id in ('VBA','VBB');


select * from person_identity where personid = '857';
select * from person_names where lname like 'Cle%';
select * from person_employment where personid = '804';