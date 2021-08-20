select distinct
'150010460' ::char(9) as group_nbr
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4)::varchar(11) as ssn
,to_char(ppd.check_date, 'YYYYMMDD')::char(8) as check_date
,case when ppd.etv_id = 'VEK' then '1' else '0' end::char(1) as etv_code
,to_char(ppd.etv_amount, '99999999D99') ::char(12) as etv_amount


,date_part('year', CURRENT_DATE)::char(4) as check_year

from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'::bpchar
 and current_timestamp between pip.createts and pip.endts

join pay_schedule_period psp 
  on psp.payrolltypeid = 1
 and psp.processfinaldate is not null
 and psp.periodpaydate = ?::date

join pspay_payment_header pph
  on pph.check_date = psp.periodpaydate
 and pph.payscheduleperiodid = psp.payscheduleperiodid 
 
join pspay_payment_detail ppd 
  on ppd.etv_id in ('VEH','VEK','VEI','VEJ')
 and ppd.personid = pi.personid
 and ppd.check_date = psp.periodpaydate
 and pph.paymentheaderid = ppd.paymentheaderid

where pi.identitytype = 'SSN'::bpchar 
  AND current_timestamp between pi.createts and pi.endts

order by trankey

--- 2018-06-29