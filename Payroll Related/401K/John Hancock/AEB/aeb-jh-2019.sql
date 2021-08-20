select 
  pi.personid
, pi.identity as trankey
, pi2.identity::char(9) as SSNO

, upper(pn.fname)::varchar(30) as firstname
, upper(pn.lname)::varchar(30) as lastname
, upper(pn.mname)::varchar(30) as middlename

, coalesce (dedamt.vb1_amount + dedamt.vb2_amount, 0) as ee401kamt 
, coalesce (dedamt.vb3_amount, 0) as eerothamt
, coalesce (dedamt.vb5_amount, 0) as ermatchamt
, coalesce (dedamt.vbt_amount, 0) as erpensionamt
, coalesce (dedamt.vbu_amount, 0) as ersafeharboramt
, to_char(dedamt.check_date,'mmddyyyy')::char(8) as check_date

FROM person_identity pi

LEFT JOIN person_identity pi2 ON pi.personid = pi2.personid 
 AND pi2.identitytype = 'SSN'::bpchar 
 AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts
 
LEFT Join person_names pn ON pn.personid = pi.personid
 AND pn.nametype = 'Legal'
 AND CURRENT_DATE between pn.effectivedate and pn.enddate
 AND CURRENT_TIMESTAMP between pn.createts and pn.endts

left join 
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.vbt_amount) as vbt_amount
,sum(x.vbu_amount) as vbu_amount
from
 

(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'VBT' then etv_amount  else 0 end as vbt_amount
,case when ppd.etv_id = 'VBU' then etv_amount  else 0 end as vbu_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'AEB_JH_401k_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','VB3','VB5','VBT','VBU')) x
  group by 1,2 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb5_amount + x.vbt_amount + x.vbu_amount) <> 0) dedamt on dedamt.personid = pi.personid 
  
where pi.identitytype = 'PSPID'
  AND CURRENT_TIMESTAMP between pi.createts AND pi.endts
  group by 1,2,3,4,5,6,7,8,9,10,11,12
   having sum(dedamt.vb1_amount + dedamt.vb2_amount + dedamt.vb3_amount + dedamt.vb5_amount + dedamt.vbt_amount + dedamt.vbu_amount) <> 0



order by SSNO