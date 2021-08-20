select 
 days.personid
,days.qsource
,days.pp_effectivedate
,days.pp_enddate
,days.emplclass
,days.emplstatus
,days.leave_days
,days.active_days
,days.annualfactor
,days.scheduledhours
,cast(sum(ppar.takehours) as dec(18,2)) as pto_hours
from 
(
select distinct

 pe.personid
,'CURRENT ACITVE LEAVE DAYS' ::varchar(50) as qsource

,pe.emplclass
,pe.emplstatus
,pe.effectivedate as pe_effectivedate
,pe.enddate as pe_enddate
,to_char(current_date::date - interval '1 year','yyyy-mm-dd') as earliest_startdate

,case when pe.emplstatus in ('P','L') then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as leave_days  
,case when pe.emplstatus = 'A' then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as active_days  
,fc.annualfactor
,pp.scheduledhours
,pp.effectivedate as pp_effectivedate
,pp.enddate as pp_enddate

,pp.positionid

,ppl.payunitid

,pd.flsacode

from person_employment pe

left join pers_pos pp
  on pp.personid = pe.personid
 and pp.persposrel = 'Occupies'
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
left join position_desc pd
  on pd.positionid = pp.positionid
 and pd.effectivedate < pd.enddate
 and current_timestamp between pd.createts and pd.endts

left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts

left join pay_unit pu on pu.payunitid = ppl.payunitid
left join frequency_codes fc on fc.frequencycode = pu.frequencycode  

where pe.enddate = '2199-12-31'
  and current_date between pe.effectivedate and pe.enddate
  and current_timestamp between pe.createts and pe.endts
  --- uncomment this when testing for Exempt - 66438 is non-exempt but has multiple scenarios for testing 
  -- and pd.flsacode = 'E'
  and pe.personid = '66438'
  
  UNION
  
select distinct

 pe.personid
,'PRIOR ACTIVE AND LEAVE DAYS' ::varchar(50) as qsource

,pe.emplclass
,pe.emplstatus
,pe.effectivedate as pe_effectivedate
,pe.enddate as pe_enddate
,to_char(current_date::date - interval '1 year','yyyy-mm-dd') as earliest_startdate

,case when pe.emplstatus in ('P','L') then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as leave_days  
,case when pe.emplstatus = 'A' then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as active_days  
,fc.annualfactor
,pp.scheduledhours
,pp.effectivedate as pp_effectivedate
,pp.enddate as pp_enddate

,pp.positionid

,ppl.payunitid

,pd.flsacode


from person_employment pe

left join pers_pos pp
  on pp.personid = pe.personid
 and pp.effectivedate < pp.enddate
 and pp.enddate < '2199-12-31' --- don't want current scheduled hours 
 and current_timestamp between pp.createts and pp.endts
 and (pp.effectivedate, pp.enddate) overlaps (current_date::date , current_date::date - interval '1 year' )
 
left join position_desc pd
  on pd.positionid = pp.positionid
 and pd.effectivedate < pd.enddate
 and current_timestamp between pd.createts and pd.endts

left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts
 
left join pay_unit pu on pu.payunitid = ppl.payunitid
left join frequency_codes fc on fc.frequencycode = pu.frequencycode  

where current_timestamp between pe.createts and pe.endts
  and ((pe.effectivedate, pe.enddate) overlaps (current_date::date , current_date::date - interval '1 year' ))
  and pe.effectivedate < pe.enddate
  and pe.emplstatus in ('L','A','P')
  and pe.emplclass = 'F'
  --- uncomment this when testing for Exempt - 66438 is non-exempt but has multiple scenarios for testing 
  -- and pd.flsacode = 'E'
  and pe.personid = '66438'  
  order by 4
) DAYS

join person_pto_activity_request ppar
  on ppar.personid = days.personid 
 and ((ppar.effectivedate, ppar.enddate) overlaps (current_date::date , current_date::date - interval '1 year' )) and ppar.reasoncode = 'REQ'
 and ppar.effectivedate >= current_date - interval '1 year'
 and current_timestamp between ppar.createts and ppar.endts and ppar.effectivedate < ppar.enddate
 
 group by 1,2,3,4,5,6,7,8,9,10