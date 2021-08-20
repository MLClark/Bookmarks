select distinct
 pi.personid
,pe.emplstatus
,'ACTIVE 401K CONTRIBUTIONS' ::varchar(50) as qsource
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(15) as ssn
,pn.fname ||' '||coalesce(pn.mname,'')||' '||pn.lname ::varchar(100) as ee_name

     
,case when dedamt.etv_id = 'VB1' then cast(dedamt.vb1_amount as dec(18,2)) else null end as emp_cont
,case when dedamt.etv_id = 'VB5' then cast(dedamt.vb5_amount as dec(18,2)) else null end as comp_cont
,case when dedamt.etv_id = 'VBU' then cast(dedamt.vbu_amount as dec(18,2)) else null end as mtch3_cont
,case when dedamt.etv_id = 'V65' then cast(dedamt.v65_amount as dec(18,2)) else null end as loan_prim
,case when dedamt.etv_id = 'VBT' then cast(dedamt.vbt_amount as dec(18,2)) else null end as loan_secn
,case when dedamt.etv_id = 'VB2' then cast(dedamt.vb2_amount as dec(18,2)) else null end as catch_up
,case when dedamt.etv_id = 'VB3' then cast(dedamt.vb3_amount as dec(18,2)) else null end as roth_cont
,case when dedamt.etv_id = 'VB4' then cast(dedamt.vb4_amount as dec(18,2)) else null end as roth_catch_up
            
,case when dedamt.etv_id = 'VB1' then '1'-- Pre Taxed 401(k)
      when dedamt.etv_id = 'VBU' then '6'-- 401 (k) 3MTCH3
      when dedamt.etv_id = 'VB2' then '5'-- Pre Taxed 401(k) Catch Up
      when dedamt.etv_id = 'V65' then '3'-- 401(k) Loan
      when dedamt.etv_id = 'VBT' then '4'-- 401(k) Loan 2
      when dedamt.etv_id = 'VB5' then '2'-- 401(k) Company
      when dedamt.etv_id = 'VB3' then '7'-- Roth
      when dedamt.etv_id = 'VB4' then '8'-- Roth Catch Up 
      end ::char(6) as key_rank --- for row denormaliser step
                      
      
from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 
join pay_schedule_period psp on 1=1

join 
(select 
 x.personid
,x.check_date
,x.etv_id
,x.vb1_amount as vb1_amount
,x.vbu_amount as vbu_amount
,x.vb2_amount as vb2_amount
,x.v65_amount as v65_amount
,x.vbt_amount as vbt_amount
,x.vb5_amount as vb5_amount
,x.vb3_amount as vb3_amount
,x.vb4_amount as vb4_amount


,x.svb1_amount as svb1_amount
,x.svbu_amount as svbu_amount
,x.svb2_amount as svb2_amount
,x.sv65_amount as sv65_amount
,x.svbt_amount as svbt_amount
,x.svb5_amount as svb5_amount
,x.svb3_amount as svb3_amount
,x.svb4_amount as svb4_amount

from

(select distinct
 ppd.personid
,ppd.check_date
,ppd.etv_id
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VBU' then etv_amount  else 0 end as vbu_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'V65' then etv_amount  else 0 end as v65_amount
,case when ppd.etv_id = 'VBT' then etv_amount  else 0 end as vbt_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount

,case when ppd.etv_id = 'VB1' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB1' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb1_amount
,case when ppd.etv_id = 'VBU' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VBU' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svbu_amount
,case when ppd.etv_id = 'VB2' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB2' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb2_amount
,case when ppd.etv_id = 'V65' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'V65' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as sv65_amount
,case when ppd.etv_id = 'VBT' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VBT' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svbt_amount
,case when ppd.etv_id = 'VB5' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB5' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb5_amount
,case when ppd.etv_id = 'VB3' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB3' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb3_amount
,case when ppd.etv_id = 'VB4' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB4' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb4_amount



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
  AND current_timestamp between pi.createts and pi.endts and ppd.etv_id  in  ('VB1','VBU','VB2','V65','VBT','VB5','VB3','VB4')) x
  group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
  having sum(x.vb1_amount + x.vbu_amount + x.vb2_amount + x.v65_amount + x.vbt_amount + x.vb5_amount + x.vb3_amount + x.vb4_amount) <> 0) dedamt on dedamt.personid = pi.personid and dedamt.check_date = psp.periodpaydate

where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and psp.periodpaydate = ?::date
  --and pi.personid in ('65781')--,'66137','66578'
  
  order by ssn