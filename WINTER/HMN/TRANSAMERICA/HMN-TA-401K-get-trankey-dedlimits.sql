select	
 pi.personid
,trim(pi.identity) ::varchar(20) as trankey
,trim(pie.identity)::varchar(20) as EmpNo
,trim(pip.identity)::varchar(20) as PSPID
,to_char(current_date,'mm-dd-yyyy')::char(10) as cr_current_date
,cast (coalesce(v65.initial_balance,0.00) as dec(18,2)) as v65_initial_balance --- for winter need to pull loan totals by etv_id per person
,cast (coalesce(vbt.initial_balance,0.00) as dec(18,2)) as vbt_initial_balance --- the initial_balance will be added to dedlimit amount from input file
from person_identity pi
left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
left join  
(select personid, etv_id, sum(etv_amount) as initial_balance      
   from pspay_payment_detail ppd 
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  
     and ppd.etv_id  in  ('V65') group by personid, etv_id order by personid) v65
  on v65.personid = pi.personid
left join  
(select personid, etv_id, sum(etv_amount) as initial_balance      
   from pspay_payment_detail ppd 
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  
     and ppd.etv_id  in  ('VBT') group by personid, etv_id order by personid) vbt
  on vbt.personid = pi.personid  
where pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts
  and pie.personid = '66027'
order by pip.identity;