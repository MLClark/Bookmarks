select distinct

 pe.personid
,'CLASS = FULL TIME' ::varchar(50) as qsource

,pe.emplclass
,pe.emplstatus
,pe.effectivedate, pe.enddate
,to_char(current_date::date - interval '1 year','yyyy-mm-dd') as earliest_startdate

,case when pe.emplstatus = 'L' then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as leave_days  
,case when pe.emplstatus = 'A' then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as active_days  
,fc.annualfactor

,pp.positionid
,pp.schedulefrequency
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
  and ((pe.effectivedate, pe.enddate) overlaps (current_date::date , current_date::date - interval '1 year' )
   or  (pe.enddate, '2199-12-31'::date) overlaps (current_date::date - interval '1 year','2199-12-31'::date))
  and pe.effectivedate - interval '1 day' < pe.enddate
  and pe.emplstatus in ('L','A')
  and pe.emplclass = 'F'
  --- uncomment this when testing for Exempt - 66438 is non-exempt but has multiple scenarios for testing 
  -- and pd.flsacode = 'E'
  and pe.personid = '66438'

  ;

select distinct

 pe.personid
,'CLASS = FULL TIME' ::varchar(50) as qsource

,pe.emplclass
,pe.emplstatus
,pe.effectivedate, pe.enddate


,to_char(current_date::date - interval '1 year','yyyy-mm-dd') as earliest_startdate

,case when pe.emplstatus = 'L' then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as leave_days  
,case when pe.emplstatus = 'A' then extract (days from (least(pe.enddate,current_date)) - (greatest(pe.effectivedate - interval '1 day' ,current_date - interval '1 year'))) else null end as active_days  
,fc.annualfactor

,pp.positionid
,pp.schedulefrequency
,ppl.payunitid

,pd.flsacode    

from person_employment pe

left join pers_pos pp
  on pp.personid = pe.personid
 and current_timestamp between pp.createts and pp.endts
 and current_date between pp.effectivedate and pp.enddate
 
left join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts

left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts
 
left join pay_unit pu on pu.payunitid = ppl.payunitid
left join frequency_codes fc on fc.frequencycode = pu.frequencycode  

where current_timestamp between pe.createts and pe.endts
  and current_date between pe.effectivedate and pe.enddate
  and pe.emplstatus in ('L','A')
  --and pe.emplclass = 'F'

  and pe.personid = '66438'

  ;
    
select * from person_employment where personid = '66438';    

  
select * from person_employment where personid = '66438' and effectivedate < enddate and current_timestamp between createts and endts and (effectivedate, enddate) overlaps (current_date::date , current_date::date - interval '1 year' );
select * from pers_pos where personid = '66438' and effectivedate < enddate and current_timestamp between createts and endts and (effectivedate, enddate) overlaps (current_date::date , current_date::date - interval '1 year' );
--select * from position_desc where positionid = '402334';
--select * from person_payroll where personid = '66438';
--select * from pay_unit ;
--select * from frequency_codes where frequencycode = 'S';