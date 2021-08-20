select distinct pp.personid
, pc.personid 
, pc.frequencycode 
, pdx.workedhours as pdxhours
, pp.scheduledhours as ppschedhrs
, fcpos.annualfactor as fcposannual
, fcpay.annualfactor as fcpayannual
, pdx.distinctpayperiods as payperiod
, pp.schedulefrequency as schedfreq


, pdx.payyear
, pdx.distinctpayperiods
, ((pp.scheduledhours * fcpos.annualfactor)/ fcpay.annualfactor) as hoursPerPay
, case when pc.personid is not null then cast(((pp.scheduledhours * fcpos.annualfactor)/ fcpay.annualfactor) * pdx.distinctpayperiods as dec (5,2))
                else pdx.workedhours end as hours_this_year
, fcpos.annualfactor
, pc.frequencycode
from pers_pos pp
left join person_compensation pc 
  on pp.personid = pc.personid
 and pc.earningscode in ('Regular','ExcHrly', 'RegHrly')
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.frequencycode <> 'H'       
join (select pd.personid
           , psp.payunitid
           , sum(case when peo.etvoperatorpid is null then pd.etype_hours else 0 end) as workedhours
           , extract(year from pd.check_date) as payyear
           , count(distinct psp.payscheduleperiodid) as distinctpayperiods
        from pspay_payment_header ph
        join pspay_payment_detail pd 
          on pd.paymentheaderid = ph.paymentheaderid
         and pd.personid = ph.personid
        join pay_schedule_period psp 
          on ph.payscheduleperiodid = psp.payscheduleperiodid
         and psp.payrolltypeid = 1 ----- NORMAL
   left join pspay_etv_operators peo 
          on peo.group_key = pd.group_key
         and peo.etv_id = pd.etv_id 
         and current_timestamp between peo.createts and peo.endts
         and peo.operand = 'WS102'
         and peo.opcode = 'A'
       where extract(year from pd.check_date) = extract(year from current_date)
       group by pd.personid, extract(year from pd.check_date), psp.payunitid)pdx 
  on pp.personid = pdx.personid
  
join frequency_codes fcpos 
  on pp.schedulefrequency = fcpos.frequencycode
join pay_unit pu on pdx.payunitid = pu.payunitid
join frequency_codes fcpay on pu.frequencycode = fcpay.frequencycode               
where current_date between pp.effectivedate and pp.enddate
 and current_Timestamp between pp.createts and pp.endts
 --and pp.personid = '10002'
;

select * from person_compensation 
where personid = '10002'
  and current_date between effectivedate and enddate
  and current_timestamp between createts and endts
 ;
 
 select pd.personid
           , psp.payunitid
           , peo.etvoperatorpid
           , sum(case when peo.etvoperatorpid is null then pd.etype_hours else 0 end) as workedhours
           , extract(year from pd.check_date) as payyear
           , count(distinct psp.payscheduleperiodid) as distinctpayperiods
        from pspay_payment_header ph
        join pspay_payment_detail pd 
          on pd.paymentheaderid = ph.paymentheaderid
         and pd.personid = ph.personid
        join pay_schedule_period psp 
          on ph.payscheduleperiodid = psp.payscheduleperiodid
         and psp.payrolltypeid = 1 ----- NORMAL
   left join pspay_etv_operators peo 
          on peo.group_key = pd.group_key
         and peo.etv_id = pd.etv_id 
         and current_timestamp between peo.createts and peo.endts
         and peo.operand = 'WS102'
         and peo.opcode = 'A'
       where extract(year from pd.check_date) = extract(year from current_date)
         and pd.personid = '10002'
       group by pd.personid, extract(year from pd.check_date), psp.payunitid, peo.etvoperatorpid
       ;
----select * from pspay_etv_operators;  

select * from pspay_payment_detail 
where personid = '10002'
  and extract(year from check_date) = extract(year from current_date);

 
select sum(etype_hours) from pspay_payment_detail 
where personid = '10002'
  and extract(year from check_date) = extract(year from current_date);
  
  
  
select distinct pp.personid

from pers_pos pp
left join person_compensation pc 
  on pp.personid = pc.personid
 and pc.earningscode in ('Regular','ExcHrly', 'RegHrly')
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.frequencycode <> 'H'       
join (select pd.personid
           , psp.payunitid
           , sum(case when peo.etvoperatorpid is null then pd.etype_hours else 0 end) as workedhours
           , extract(year from pd.check_date) as payyear
           , count(distinct psp.payscheduleperiodid) as distinctpayperiods
        from pspay_payment_header ph
        join pspay_payment_detail pd 
          on pd.paymentheaderid = ph.paymentheaderid
         and pd.personid = ph.personid
        join pay_schedule_period psp 
          on ph.payscheduleperiodid = psp.payscheduleperiodid
         and psp.payrolltypeid = 1 ----- NORMAL
   left join pspay_etv_operators peo 
          on peo.group_key = pd.group_key
         and peo.etv_id = pd.etv_id 
         and current_timestamp between peo.createts and peo.endts
         and peo.operand = 'WS102'
         and peo.opcode = 'A'
       where extract(year from pd.check_date) = extract(year from current_date)
       group by pd.personid, extract(year from pd.check_date), psp.payunitid)pdx 
  on pp.personid = pdx.personid
  
join frequency_codes fcpos 
  on pp.schedulefrequency = fcpos.frequencycode
join pay_unit pu on pdx.payunitid = pu.payunitid
join frequency_codes fcpay on pu.frequencycode = fcpay.frequencycode               
where current_date between pp.effectivedate and pp.enddate
 and current_Timestamp between pp.createts and pp.endts
 --and pp.personid = '10002'
 group by 1
;  
       