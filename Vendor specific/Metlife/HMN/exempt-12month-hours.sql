select 
 basehours.personid
,cast(sum(basehours.hours - ppar.takehours) as int) as hrs_past_12m
,cast(sum(ppar.takehours) as int) as pto_hours
,sum(basehours.hours) as total_ytd_hours

from (

select 
 basedays.personid
,basedays.numdays
,cast ((fc.annualfactor * basedays.scheduledhours) * (basedays.numdays/365::numeric) as dec(18,2))as hours
 from
(
select distinct
 pe.personid
,pp.positionid 
,psp.periodpaydate::date - (psp.periodpaydate::date - interval '1 year') as datedays
,pp.effectivedate as pp_start_date
,pp.enddate as pp_end_date
,psp.periodpaydate::date as current_payroll_date
,to_char(psp.periodpaydate::date - interval '1 year','YYYY-MM-DD')::char(10) as last_year_payroll_date
,pp.partialpercent
,pp.scheduledhours
,psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year') as numdaysend
,least(pp.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year') as days_worked_by_emplclass
,case when pp.enddate > current_date then extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year'))
      else extract(days from least(pp.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) end as numdays
      

from person_employment pe 

join pay_schedule_period psp 
  on psp.payrolltypeid in (1,2)
 and psp.processfinaldate is not null
 and psp.periodpaydate = '2019-08-30' --?::date 
 
join pers_pos pp
  on pp.personid = pe.personid
 and current_timestamp between pp.createts and pp.endts
 and (pp.effectivedate, pp.enddate) overlaps (psp.periodpaydate::date, psp.periodpaydate::date - interval '1 year') ----('2019-06-14'::date , '2019-06-14'::date - interval '1 year' )
 and pp.effectivedate < pp.enddate


where pe.effectivedate >= current_date - interval '1 year'
  and pe.effectivedate <= pe.enddate
  and current_timestamp between pe.createts and pe.endts
  and pe.personid = '67805'
  
  ) basedays

join person_payroll ppl 
  on ppl.personid = basedays.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts
 
join pay_unit pu on pu.payunitid = ppl.payunitid
join frequency_codes fc on fc.frequencycode = pu.frequencycode
) basehours

left join person_pto_activity_request ppar 
  on ppar.personid = basehours.personid
 and ppar.effectivedate >= current_date - interval '1 year'
 --and ppar.takehours <> 0

group by 1
