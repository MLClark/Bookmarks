select distinct
 pald.personid
,pald.qsource
,pald.positionid
,pald.payunitid
,pald.flsacode
,sum(pald.leave_days) as leave_days
,sum(pald.active_days) as active_days

from 
(select distinct
 pe.personid
,'PRIOR ACTIVE LEAVE DAYS' ::varchar(50) as qsource
,pe.emplclass
,pe.emplstatus
,to_char(current_date::date - interval '1 year','yyyy-mm-dd') as earliest_startdate
,case when pe.emplstatus in ('P','L') then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as leave_days  
,case when pe.emplstatus = 'A' then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as active_days  
,pp.positionid
,ppl.payunitid
,pd.flsacode


from person_employment pe

left join pers_pos pp
  on pp.personid = pe.personid
 and pp.effectivedate < pp.enddate
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
) pald

group by 1,2,3,4,5