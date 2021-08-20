select 
 pi.personid

,'BASIC MEMBER INFO - RTYPE 180' ::varchar(40) as qsource
--,ppd.etv_id
,'180' ::char(3) as recordtype
,' '   ::char(1) as filler_4
,'805911' ::char(6) as contract_number
,' ' ::char(1) as filler_11
,pi.identity ::char(9) as employee_id_number
,' ' ::char(1) as filler_21
,pn.lname||', '||pn.fname||' '||coalesce(substring(pn.mname,1,1),' ')  ::char(24) as emp_name
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,' ' ::char(1) as filler_56 
,to_char(pe.empllasthiredate,'mm/dd/yyyy')::char(10) as doh
,' ' ::char(1) as filler_67
,pv.gendercode ::char(1) as gender
,' ' ::char(8) as filler_69
,pi.identity ::char(9) as ssn
,' ' ::char(1) as filler_133_bytes
,case when pe.emplstatus in ('T','R') then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as benefit_event_date
,' ' ::char(1) as filler_229
,case when pe.emplstatus in ('T','R') then to_char(ytd.hours,'FM0000') else ' ' end ::char(4) as vesting_hours
,case when pe.emplstatus = 'T' and pe.emplevent in ('VolTerm','InvTerm') then '0001'
      when pe.emplstatus = 'R' then '0003'
      when pe.emplstatus = 'T' and pe.emplevent = 'Death' then '0005'
      else ' ' end ::char(4) as benefit_event_rsn
,' ' ::char(3) as filler_238     


 
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
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate 
 and current_timestamp between pv.createts and pv.endts

join (select personid, max(effectivedate) as effectivedate, rank() over(partition by personid order by max(effectivedate) desc) as rank
        from person_deduction_setup where etvid in  ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ') 
         and current_date between effectivedate and enddate
         and current_timestamp between createts and endts group by personid) pds on pds.personid = pi.personid
         
--- WS23 records are not populated for this client also had to revert back to using person_deduction_setup to pull only those ee's with contrib need to discuss w debbie how to handle better
left join (select ppd.personid, sum(ppd.etv_amount) AS taxable_amount, sum(etype_hours) AS hours 
             from pspay_payment_detail ppd
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDE_Principal_Financial_Group_401k_Export' 
                            and date_part('year',ppay.statusdate) = date_part('year',elu.lastupdatets)
                             where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A' group by 1)   
                        
group by 1) ytd on ytd.personid = pds.personid           

 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus in ('A','L') or (pe.emplstatus in ('T','R') and current_date - interval '60 days' <= pe.effectivedate))
  
  order by employee_id_number


