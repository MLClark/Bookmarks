select distinct
 a.personid
,pto.takehours  
,sum(a.total_hours) as total_hours
,cast(sum(a.total_hours) - pto.takehours as dec(18,2)) as total_hours
from 
(
select distinct  
 pe.personid


,case when pe.emplstatus in ('P','L') then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as leave_days  
,case when pe.emplstatus = 'A' then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else 0 end as active_days  


,case when pe.enddate > current_date then extract(days from current_date::date - greatest(pe.effectivedate,current_date::date - interval '1 year'))+1
      when pe.effectivedate > (current_date::date - interval '1 year') and pe.enddate < current_date::date then  pe.enddate - pe.effectivedate+1
      else extract(days from least(pe.enddate,current_date::date) - (current_date::date - interval '1 year')) end as numdays
      
,cast(fc.annualfactor * pp.scheduledhours * 
     ((case when pe.enddate > current_date then extract(days from current_date::date - greatest(pe.effectivedate ,current_date::date - interval '1 year'))+1 
            when pe.effectivedate > (current_date::date - interval '1 year') and pe.enddate < current_date::date then  pe.enddate - pe.effectivedate + 1
            else extract(days from least(pe.enddate,current_date::date) - (current_date::date - interval '1 year')) end ) /365::numeric) as dec(18,2)) as total_hours
      

from person_employment pe

left join pers_pos pp 
  on pe.personid = pp.personid 
 and current_timestamp between pp.createts and pp.endts 
 and pp.effectivedate < pp.enddate 
 and (pp.effectivedate, pp.enddate) overlaps (pe.effectivedate, pe.enddate)

left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts
 
left join pay_unit pu on pu.payunitid = ppl.payunitid
left join frequency_codes fc on fc.frequencycode = pu.frequencycode  


where current_timestamp between pe.createts and pe.endts
  and (pe.effectivedate, pe.enddate) overlaps (current_date::date, current_date::date - interval '1 year' )
  and pe.effectivedate < pe.enddate
  and pe.personid = '67805'
 ) a
left join (select distinct personid, sum(takehours) as takehours from person_pto_activity_request 
            where ((effectivedate, enddate) overlaps (current_date::date , current_date::date - interval '1 year' )) and reasoncode = 'REQ'
              and effectivedate >= current_date - interval '1 year' and current_timestamp between createts and endts and effectivedate < enddate and personid = '67805' group by 1) pto on pto.personid = a.personid

group by 1,2;

--select * from person_employment where personid = '67805';    
--select * from person_employment where personid = '67805' and effectivedate < enddate and current_timestamp between createts and endts and (effectivedate, enddate) overlaps (current_date::date , current_date::date - interval '1 year' );
--select * from pers_pos where personid = '67805' and effectivedate < enddate and current_timestamp between createts and endts and (effectivedate, enddate) overlaps (current_date::date , current_date::date - interval '1 year' );
--select * from position_desc where positionid = '405627';
select * from person_payroll where personid = '67805';
select * from pay_unit ;
select * from frequency_codes where frequencycode = 'S';