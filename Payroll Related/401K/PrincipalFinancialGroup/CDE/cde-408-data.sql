select 
 pi.personid
--,'LOANS RTYPE 408' ::varchar(40) as qsource
--,ppd.etv_id
,'408' ::char(3) as recordtype
,' '   ::char(1) as filler_4
,'805911' ::char(6) as contract_number
,' ' ::char(1) as filler_11
,pi.identity ::char(9) as employee_id_number
,' ' ::char(9) as filler_9_bytes
,'00' ::char(2) as investmenttype
,'0031' ::char(4) as transactiontype
,to_char(dedamt.check_date,'MM/DD/YYYY')::char(10) as paydate
,' ' ::char(1) as filler_14_bytes
--- create a numeric and string contrib amount for the for java conversion script
,to_char(dedamt.v65_amount * 100,'FM0000000000S')::char(10) as v65_contrib_amt_s
,dedamt.v65_amount as v65_contrib_amt_n
,' ' ::char(1) as filler_171_bytes
,case when dedamt.v65_amount < 0 then 'Y' else 'N' end ::char(1) as neg_loan_flag
,case when dedamt.v65_amount < 0 then 'Negative Loan payment excluded. Contact vendor.' else ' ' end ::char(50) as neg_loan_ermsg
 
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
 

join 
(select 
 x.personid
,x.check_date
,sum(x.v65_amount) as v65_amount
from
 

(select 
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'V65' then etv_amount  else 0 end as v65_amount
--,psp.periodpaydate
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDE_Principal_Financial_Group_401k_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('V65')) x
group by 1,2 having sum(x.v65_amount ) <> 0) dedamt on dedamt.personid = pi.personid 

 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus in ('A','L') or (pe.emplstatus in ('T','R') and current_date - interval '60 days' <= pe.effectivedate))
  and pe.personid = '327'