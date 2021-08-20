select 
 pi.personid
--,'CONTRIBUTIONS RTYPE 407' ::varchar(40) as qsource
--,ppd.etv_id
,'407' ::char(3) as recordtype
,' '   ::char(1) as filler_4
,'805911' ::char(6) as contract_number
,' ' ::char(1) as filler_11
,pi.identity ::char(9) as employee_id_number
,' ' ::char(9) as filler_21
,'00' ::char(2) as investmenttype
,'0001' ::char(4) as transactiontype
,to_char(dedamt.check_date,'MM/DD/YYYY')::char(10) as paydate
,' ' ::char(1) as filler_27_bytes
,'C' ::char(1) as contribution_qualifier_type
--- create a numeric and string contrib amount for the for java conversion script
,'001' ::char(3) as elective_deferral
,to_char(dedamt.vb1_amount * 100,'FM0000000000')::char(10) as vb1_contrib_amt_s
,dedamt.vb1_amount as vb1_contrib_amt_n
,'C' ::char(1) as vb1_contrib_qual_type
,'002' ::char(3) as deferral_catch_up
,to_char(dedamt.vb2_amount * 100,'FM0000000000')::char(10) as vb2_contrib_amt_s
,dedamt.vb2_amount as vb2_contrib_amt_n
,'C' ::char(1) as vb2_contrib_qual_type
,'031' ::char(3) as er_match_in_k
,to_char(dedamt.vb5_amount * 100,'FM0000000000')::char(10) as vb5_contrib_amt_s
,dedamt.vb5_amount as vb5_contrib_amt_n
,'C' ::char(1) as vb5_contrib_qual_type
,'003' ::char(3) as roth_deferral
,to_char(dedamt.vb3_amount * 100,'FM0000000000')::char(10) as vb3_contrib_amt_s
,dedamt.vb3_amount as vb3_contrib_amt_n
,'C' ::char(1) as vb3_contrib_qual_type
,'004' ::char(3) as roth_deferral_catch_up
,to_char(dedamt.vb4_amount * 100,'FM0000000000')::char(10) as vb4_contrib_amt_s
,dedamt.vb4_amount as vb4_contrib_amt_n
,'C' ::char(1) as vb4_contrib_qual_type

,' ' ::char(3)  as mim_catch_up
,' ' ::char(10) as mim_contrib_amt
,' ' ::char(1)  as mim_contrib_qual_type
,' ' ::char(3)  as qne_catch_up
,' ' ::char(10) as qne_contrib_amt
,' ' ::char(1)  as qne_contrib_qual_type
,' ' ::char(3)  as erd_catch_up
,' ' ::char(10) as erd_contrib_amt
,' ' ::char(1)  as filler_56_bytes

 
from person_identity pi

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate 
 and current_timestamp between pa.createts and pa.endts
 
join 
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
from
 

(select 
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
--,psp.periodpaydate
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDE_Principal_Financial_Group_401k_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','VB3','VB4','VB5')) x
group by 1,2 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount ) <> 0) dedamt on dedamt.personid = pi.personid 
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus in ('A','L') or (pe.emplstatus in ('T','R') and current_date - interval '60 days' <= pe.effectivedate))