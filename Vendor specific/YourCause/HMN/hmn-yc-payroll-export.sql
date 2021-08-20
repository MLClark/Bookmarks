select distinct
 pi.personid
,pid.identity as EmployeeID
,pne.fname as FirstName
,pne.lname AS LastName

,case when dedamt.vci_amount > 0 then 'O'
      when dedamt.v67_amount > 0 then 'R'
      else ''
 end as Frequency

,to_char(payroll.periodpaydate::date,'mm/dd/yyyy')  as DeductionDate
,case when dedamt.etv_id = 'VCI' then dedamt.vci_amount else dedamt.v67_amount end as cr_dedamt

,case when dedamt.etv_id = 'VCI' then to_char(dedamt.vci_amount,'99999d99')
      when dedamt.etv_id = 'V67' then to_char(dedamt.v67_amount,'99999d99')
      else '0.00'
 end as DeductionAmount

,'USD' as DeductionCurrency

,dedamt.etv_id as etv_id

,elu.lastupdatets


from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'HMN_YourCause_Payroll_Export'

left join person_identity pid
  on pid.personid = pi.personid
and pid.identitytype = 'EmpNo'
and current_timestamp between pid.createts and pid.endts

join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts


LEFT JOIN (SELECT x.personid
		,x.periodpaydate
		,x.check_date
	  from
	  (SELECT ppd.personid
		,psp.periodpaydate
		,ppd.check_date

           FROM pspay_payment_detail ppd
	   join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
	   join pay_schedule_period psp on psp.payscheduleperiodid = pph.payscheduleperiodid
		where ppd.paymentheaderid in 
			(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
				(select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
					(select pspaypayrollid from pspay_payroll ppay 
							join edi.edi_last_update elu on elu.feedid = 'HMN_YourCause_Payroll_Export' 
								and elu.lastupdatets <= ppay.statusdate	
                             where ppay.pspaypayrollstatusid = 4 )))) x
group by 1,2,3) payroll ON payroll.personid = pi.personid  


left join 
(select 
 x.personid
,x.check_date
,x.etv_id
,sum(x.VCI_amount) as VCI_amount
,sum(x.V67_amount) as V67_amount

from

(select distinct
 ppd.personid
,ppd.check_date
,ppd.etv_id
,case when ppd.etv_id = 'VCI' then etv_amount  else 0 end as VCI_amount
,case when ppd.etv_id = 'V67' then etv_amount  else 0 end as V67_amount

,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'HMN_YourCause_Payroll_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in ('VCI','V67')-- ('VCI','V67')
  ) x
  group by 1,2,3
  having sum(x.VCI_amount + x.V67_amount) <> 0
  ) dedamt on dedamt.personid = pi.personid 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
--and payroll.periodpaydate is not null
and (dedamt.vci_amount > 0 
or dedamt.v67_amount > 0)
order by pi.personid