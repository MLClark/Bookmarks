select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-09-01 00:00:00' where feedid = 'HMN_MetLife_DisabilityEligibility';
select * from person_address where personid = '65633' and addresstype = 'Res';




select * from pers_pos where personid = '67805';
(select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts
            and personid = '66578'
            group by personid, positionid, scheduledhours, schedulefrequency) 
;     
       
       (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
             and positionid = '402543'
            group by positionid, grade, positiontitle, flsacode)
            ;
select * from position_desc where positionid = '402543';

select * from person_names where lname like 'Harris%';
select * from person_vitals where personid in ('66379','68288');
select * from pay_schedule_period where date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)='07';

select * from pos_pos where topositionid = '405735';
select * from pers_pos where positionid = '405735';
select * from person_identity where personid = '63003' and identitytype = 'SSN';

select * from person_identity where personid = '65937' and identitytype = 'SSN';;
(select personid, positionid, scheduledhours, schedulefrequency, max(enddate) as enddate, max(createts) as createts, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(createts) DESC) AS RANK
             from pers_pos where current_date between effectivedate and enddate and current_timestamp between createts and endts 
              and positionid = '405735'
            group by personid, positionid, scheduledhours, schedulefrequency);

select * from pers_pos where positionid = '405735'
and current_date between effectivedate and enddate
and current_timestamp between createts and endts

;
select * from person_employment where personid = '67805';

(select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where (effectivedate < enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts
             and personid = '63031'
            group by personid, positionid, scheduledhours, schedulefrequency)
            ;

select * from pers_pos where personid = '65618' and persposrel = 'Occupies'  and current_timestamp between createts and endts and current_date between effectivedate and enddate;
select * from pos_pos where positionid = '399716' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from pos_pos where topositionid = '399716' and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from pos_pos where pospospid = '3269' and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from edi_snapshot limit 10;
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-09-01 00:00:00' where feedid = 'HMN_MetLife_DisabilityEligibility';

select * from person_identity where identity = '539668675';
select * from person_names where personid = '68055';

select * from pers_pos where positionid = '402073' and persposrel = 'Occupies' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from pers_pos where positionid = '405735' and persposrel = 'Occupies' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from person_names where personid in ('67998','68339');
select * from person_names where lname like 'Polite%';
select * from pers_pos where personid = '66298' and persposrel = 'Occupies' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from pos_pos where topositionid = '402073' and current_date between effectivedate and enddate and current_timestamp between createts and endts;


(select ppdx.personid, min(ppdx.check_date) check_date from pspay_payment_detail ppdx 
             left JOIN (select substring(individual_key,1,5) as paygroup, max(check_date) as last_check_date 
                          from pspay_payment_header group by 1) lastchk2 ON  lastchk2.paygroup = substring(ppdx.individual_key,1,5)
	                 where ppdx.etv_id IN ('E01','E02')
	          	   and ppdx.check_number <> 'INIT REC'
		           and ppdx.check_date between current_date - interval '12 months' and lastchk2.last_check_date
		           and ppdx.personid = '66018'
	       group by ppdx.personid order by 1)
	       
	       select * from pspay_payment_detail where personid = '66018';
	       
	       
select distinct
 basehours.personid
,basehours.hours as basehours
,sum(ppar.takehours)as ptohours
,lpad((round(basehours.hours - sum(ppar.takehours))::text),4,'0') as yearlyhrs

from 
(select distinct
 pe.personid
,pp.positionid 
,psp.periodpaydate::date - (psp.periodpaydate::date - interval '1 year') as datedays
,pp.effectivedate as pp_start_date
,pp.enddate as pp_end_date
,psp.periodpaydate::date as current_payroll_date
,to_char(psp.periodpaydate::date - interval '1 year','YYYY-MM-DD')::char(10) as last_year_payroll_date
,pp.partialpercent
,pp.scheduledhours
,fc.annualfactor 
,psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year') as numdaysend
,least(pp.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year') as days_worked_by_emplclass
,case when pp.enddate > current_date then extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year'))
      else extract(days from least(pp.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) end as numdays
,fc.annualfactor * pp.scheduledhours * extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year')) as greatestdays
,fc.annualfactor * pp.scheduledhours * extract(days from least(pp.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) as leastdays
,case when pp.enddate > current_date then 
           fc.annualfactor * pp.scheduledhours * (extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year')) /365::numeric) 
      else fc.annualfactor * pp.scheduledhours * (extract(days from least(pp.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year')) /365::numeric) end as hours

from person_employment pe 

join pay_schedule_period psp 
  on psp.payrolltypeid in (1,2)
 and psp.processfinaldate is not null
 and psp.periodpaydate = '2019-06-14' --?::date 
 
join pers_pos pp
  on pp.personid = pe.personid
 and current_timestamp between pp.createts and pp.endts
 and (pp.effectivedate, pp.enddate) overlaps (psp.periodpaydate::date, psp.periodpaydate::date - interval '1 year') ----('2019-06-14'::date , '2019-06-14'::date - interval '1 year' )
 and pp.effectivedate < pp.enddate

left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts
 
left join pay_unit pu on pu.payunitid = ppl.payunitid
left join frequency_codes fc on fc.frequencycode = pU.frequencycode 



where pe.effectivedate >= current_date - interval '1 year'
  and pe.effectivedate <= pe.enddate
  and current_timestamp between pe.createts and pe.endts
  and pe.personid = '66416'
) basehours 

left join person_pto_activity_request ppar 
  on ppar.personid = basehours.personid
 and ppar.effectivedate >= current_date - interval '1 year'  
 and current_timestamp between ppar.createts and ppar.endts
 --- select * from person_pto_activity_request where personid = '66416' and effectivedate >= current_date - interval '1 year' and current_timestamp between createts and endts
 --- select * from person_employment where personid = '66416' and emplstatus = 'L'; 
 group by 1,2
 ;   





select pe.personid, pe.effectivedate, pe.enddate
, psp.periodpaydate::date - greatest(pe.effectivedate, psp.periodpaydate::date - interval '1 year') as numdaysend
,case when pe.enddate > current_date then extract(days from psp.periodpaydate::date - greatest(pe.effectivedate, psp.periodpaydate::date - interval '1 year'))
      else extract(days from least(pe.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) end as numdays
from person_employment pe

join pay_schedule_period psp 
  on psp.payrolltypeid in (1,2)
 and psp.processfinaldate is not null
 and psp.periodpaydate = '2019-06-14' --?::date 
 
where pe.effectivedate >= current_date - interval '1 year'
  and pe.effectivedate <= pe.enddate
  and current_timestamp between pe.createts and pe.endts
  and (pe.effectivedate, pe.enddate) overlaps (psp.periodpaydate::date, psp.periodpaydate::date - interval '1 year') 
  and pe.emplstatus = 'L' 
  and pe.personid = '66416'

;

select basedays.scheduledhours, fc.annualfactor, basedays.numdays, basedays.*, fc.annualfactor * basedays.scheduledhours * (basedays.numdays/365::numeric) as hours

from (select '2019-06-14'::date as checkdate, '2019-06-14'::date - interval '1 year' as startdate, '2019-06-14'::date - ('2019-06-14'::date - interval '1 year') as datedays
, effectivedate, enddate, partialpercent, scheduledhours
, '2019-06-14'::date - greatest(effectivedate ,'2019-06-14'::date - interval '1 year') as numdaysend
,  least(enddate,'2019-06-14'::date )   - ('2019-06-14'::date - interval '1 year')
, case when enddate > current_date then extract(days from '2019-06-14'::date - greatest(effectivedate ,'2019-06-14'::date - interval '1 year'))
  else extract(days from least(enddate,'2019-06-14'::date )   - ('2019-06-14'::date - interval '1 year')) end as numdays
from pers_pos 
where personid = '66416' 
and current_timestamp between createts and endts
and (effectivedate, enddate) overlaps ('2019-06-14'::date , '2019-06-14'::date - interval '1 year' )
and effectivedate < enddate) basedays
join frequency_codes fc on fc.frequencycode = 'S'
;


select distinct
 pe.personid
--,pp.positionid 
--,psp.periodpaydate::date - (psp.periodpaydate::date - interval '1 year') as datedays
--,pp.effectivedate as pp_start_date
--,pp.enddate as pp_end_date
--,psp.periodpaydate::date as current_payroll_date
--,to_char(psp.periodpaydate::date - interval '1 year','YYYY-MM-DD')::char(10) as last_year_payroll_date
--,pp.partialpercent
--,pp.scheduledhours
--,fc.annualfactor 
--,psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year') as numdaysend
--,least(pp.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year') as days_worked_by_emplclass
--,case when pp.enddate > current_date then extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year'))
--      else extract(days from least(pp.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) end as numdays
--,fc.annualfactor * pp.scheduledhours * extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year')) as greatestdays
--,fc.annualfactor * pp.scheduledhours * extract(days from least(pp.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) as leastdays
,case when pp.enddate > current_date then 
           fc.annualfactor * pp.scheduledhours * (extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year')) /365::numeric) 
      else fc.annualfactor * pp.scheduledhours * (extract(days from least(pp.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year')) /365::numeric) end as hours

from person_employment pe 

join pay_schedule_period psp 
  on psp.payrolltypeid in (1,2)
 and psp.processfinaldate is not null
 and psp.periodpaydate = '2019-06-14' --?::date 
 
join pers_pos pp
  on pp.personid = pe.personid
 and current_timestamp between pp.createts and pp.endts
 and (pp.effectivedate, pp.enddate) overlaps (psp.periodpaydate::date, psp.periodpaydate::date - interval '1 year') ----('2019-06-14'::date , '2019-06-14'::date - interval '1 year' )
 and pp.effectivedate < pp.enddate

left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
 and current_timestamp between ppl.createts and ppl.endts
 
left join pay_unit pu on pu.payunitid = ppl.payunitid
left join frequency_codes fc on fc.frequencycode = pU.frequencycode 

left join person_pto_activity_request ppar 
  on ppar.personid = pe.personid
 and ppar.effectivedate >= current_date - interval '1 year'

where pe.effectivedate >= current_date - interval '1 year'
  and pe.effectivedate <= pe.enddate
  and current_timestamp between pe.createts and pe.endts
  and pe.personid = '66416'


;







select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-08-01 00:00:00' where feedid = 'HMN_MetLife_DisabilityEligibility';
















select distinct
basehours.personid
,basehours.hours as basehours
,sum(ppar.takehours)as ptohours
,lpad((round(basehours.hours - sum(ppar.takehours))::text),4,'0') as yearlyhrs
--lpad((round(yearlyhrs.reghours)::text),4,'0') 
from 
(select distinct
 pe.personid
,pe.emplstatus
,pp.positionid 
,psp.periodpaydate::date - (psp.periodpaydate::date - interval '1 year') as datedays
,pp.effectivedate as pp_start_date
,pp.enddate as pp_end_date
,psp.periodpaydate::date as current_payroll_date
,to_char(psp.periodpaydate::date - interval '1 year','YYYY-MM-DD')::char(10) as last_year_payroll_date
,pp.partialpercent
,pp.scheduledhours
,fc.annualfactor 
,psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year') as numdaysend
,least(pp.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year') as days_worked_by_emplclass
,case when pp.enddate > current_date then extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year'))
      else extract(days from least(pp.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) end as numdays
,fc.annualfactor * pp.scheduledhours * extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year')) as greatestdays
,fc.annualfactor * pp.scheduledhours * extract(days from least(pp.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) as leastdays
,case when pp.enddate > current_date then 
           fc.annualfactor * pp.scheduledhours * (extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year')) /365::numeric) 
      else fc.annualfactor * pp.scheduledhours * (extract(days from least(pp.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year')) /365::numeric) end as hours

, case when pe.enddate > current_date then extract(days from '2019-06-14'::date - greatest(pe.effectivedate ,'2019-06-14'::date - interval '1 year'))
       when pe.effectivedate > ('2019-06-14'::date - interval '1 year') and pe.enddate < '2019-06-14'::date then  pe.enddate - pe.effectivedate + 1
  else extract(days from least(pe.enddate,'2019-06-14'::date )   - ('2019-06-14'::date - interval '1 year')) + 1 end as numdays_active

, case when pe.enddate > current_date then extract(days from '2019-06-14'::date - greatest(pe.effectivedate ,'2019-06-14'::date - interval '1 year'))
       when pe.effectivedate > ('2019-06-14'::date - interval '1 year') and pe.enddate < '2019-06-14'::date then  pe.enddate - pe.effectivedate + 1
  else extract(days from least(pe.enddate,'2019-06-14'::date )   - ('2019-06-14'::date - interval '1 year')) + 1 end as numdays_active



from person_employment pe 

join pay_schedule_period psp 
  on psp.payrolltypeid in (1,2)
and psp.processfinaldate is not null
and psp.periodpaydate = '2019-06-14' --?::date 
 
join pers_pos pp
  on pp.personid = pe.personid
and current_timestamp between pp.createts and pp.endts
and (pp.effectivedate, pp.enddate) overlaps (psp.periodpaydate::date, psp.periodpaydate::date - interval '1 year') ----('2019-06-14'::date , '2019-06-14'::date - interval '1 year' )
and pp.effectivedate < pp.enddate

left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
and current_timestamp between ppl.createts and ppl.endts

left join pay_unit pu on pu.payunitid = ppl.payunitid
left join frequency_codes fc on fc.frequencycode = pU.frequencycode 



where pe.effectivedate >= current_date - interval '1 year'
  and pe.effectivedate <= pe.enddate
  and pe.emplstatus = 'L'
  and current_timestamp between pe.createts and pe.endts

  and pe.personid = '66416'
) basehours 

left join person_pto_activity_request ppar 
  on ppar.personid = basehours.personid
and ppar.effectivedate >= current_date - interval '1 year'  
 --- select * from person_pto_activity_request where personid = '66416' and effectivedate >= current_date - interval '1 year' and current_timestamp between createts and endts
 --- select * from person_employment where personid = '66416' and emplstatus = 'L'; 
  
 group by 1,2
;  
select 
 pe.personid
,pe.emplstatus
,pe.effectivedate 
,pe.enddate

from person_employment pe



















(select distinct
 pe.personid
,pe.emplstatus 
,case when pe.enddate > current_date then 
           fc.annualfactor * pp.scheduledhours * (extract(days from psp.periodpaydate::date - greatest(pe.effectivedate, psp.periodpaydate::date - interval '1 year')) /365::numeric) 
      else fc.annualfactor * pp.scheduledhours * (extract(days from least(pe.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year')) /365::numeric) end as pe_hours

,case when pp.enddate > current_date then 
           fc.annualfactor * pp.scheduledhours * (extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year')) /365::numeric) 
      else fc.annualfactor * pp.scheduledhours * (extract(days from least(pp.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year')) /365::numeric) end as pp_hours

,pp.positionid 
,psp.periodpaydate::date - (psp.periodpaydate::date - interval '1 year') as datedays
,pp.effectivedate as pp_start_date
,pp.enddate as pp_end_date
,psp.periodpaydate::date as current_payroll_date
,to_char(psp.periodpaydate::date - interval '1 year','YYYY-MM-DD')::char(10) as last_year_payroll_date
,pp.partialpercent
,pp.scheduledhours
,fc.annualfactor 
,psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year') as numdaysend
,least(pp.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year') as days_worked_by_emplclass
,case when pp.enddate > current_date then extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year'))
      else extract(days from least(pp.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) end as numdays
,fc.annualfactor * pp.scheduledhours * extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year')) as greatestdays
,fc.annualfactor * pp.scheduledhours * extract(days from least(pp.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) as leastdays

from person_employment pe 

join pay_schedule_period psp 
  on psp.payrolltypeid in (1,2)
and psp.processfinaldate is not null
and psp.periodpaydate = '2019-06-14' --?::date 
 
join pers_pos pp
  on pp.personid = pe.personid
and current_timestamp between pp.createts and pp.endts
and (pp.effectivedate, pp.enddate) overlaps (psp.periodpaydate::date, psp.periodpaydate::date - interval '1 year') ----('2019-06-14'::date , '2019-06-14'::date - interval '1 year' )
and pp.effectivedate < pp.enddate

left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
and current_timestamp between ppl.createts and ppl.endts


select distinct
basehours.personid
,basehours.hours as basehours
,sum(ppar.takehours)as ptohours
,lpad((round(basehours.hours - sum(ppar.takehours))::text),4,'0') as yearlyhrs
--lpad((round(yearlyhrs.reghours)::text),4,'0') 
from 
(select distinct
pe.personid
--,pp.positionid 
--,psp.periodpaydate::date - (psp.periodpaydate::date - interval '1 year') as datedays
--,pp.effectivedate as pp_start_date
--,pp.enddate as pp_end_date
--,psp.periodpaydate::date as current_payroll_date
--,to_char(psp.periodpaydate::date - interval '1 year','YYYY-MM-DD')::char(10) as last_year_payroll_date
--,pp.partialpercent
--,pp.scheduledhours
--,fc.annualfactor 
--,psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year') as numdaysend
--,least(pp.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year') as days_worked_by_emplclass
--,case when pp.enddate > current_date then extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year'))
--      else extract(days from least(pp.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) end as numdays
--,fc.annualfactor * pp.scheduledhours * extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year')) as greatestdays
--,fc.annualfactor * pp.scheduledhours * extract(days from least(pp.enddate,psp.periodpaydate::date)   - (psp.periodpaydate::date - interval '1 year')) as leastdays
,case when pp.enddate > current_date then 
           fc.annualfactor * pp.scheduledhours * (extract(days from psp.periodpaydate::date - greatest(pp.effectivedate, psp.periodpaydate::date - interval '1 year')) /365::numeric) 
      else fc.annualfactor * pp.scheduledhours * (extract(days from least(pp.enddate,psp.periodpaydate::date) - (psp.periodpaydate::date - interval '1 year')) /365::numeric) end as hours

from person_employment pe 

join pay_schedule_period psp 
  on psp.payrolltypeid in (1,2)
and psp.processfinaldate is not null
and psp.periodpaydate = '2019-06-14' --?::date 
 
join pers_pos pp
  on pp.personid = pe.personid
and current_timestamp between pp.createts and pp.endts
and (pp.effectivedate, pp.enddate) overlaps (psp.periodpaydate::date, psp.periodpaydate::date - interval '1 year') ----('2019-06-14'::date , '2019-06-14'::date - interval '1 year' )
and pp.effectivedate < pp.enddate

left join person_payroll ppl 
  on ppl.personid = pe.personid 
 and current_date between ppl.effectivedate and ppl.enddate
and current_timestamp between ppl.createts and ppl.endts

left join pay_unit pu on pu.payunitid = ppl.payunitid
left join frequency_codes fc on fc.frequencycode = pU.frequencycode 



where pe.effectivedate >= current_date - interval '1 year'
  and pe.effectivedate <= pe.enddate
  and current_timestamp between pe.createts and pe.endts
  and pe.personid = '66416' and pe.emplstatus <> 'L'
) basehours 

left join person_pto_activity_request ppar 
  on ppar.personid = basehours.personid
and ppar.effectivedate >= current_date - interval '1 year'  
 --- select * from person_pto_activity_request where personid = '66416' and effectivedate >= current_date - interval '1 year' 
  
 group by 1,2
;  



left join pay_unit pu on pu.payunitid = ppl.payunitid
left join frequency_codes fc on fc.frequencycode = pU.frequencycode 



where current_timestamp between pe.createts and pe.endts
  and (pe.effectivedate, pe.enddate) overlaps ('2019-06-14'::date , '2019-06-14'::date - interval '1 year' )
  and pe.effectivedate < pe.enddate
  and pe.personid = '66438'
  --and pe.personid = '64889'
   --and pe.emplstatus = 'L'
)
;

-- employment status hours
select  '2019-06-14'::date as checkdate, '2019-06-14'::date - interval '1 year' as startdate, 
 pe.effectivedate, pe.enddate, pe.emplstatus 
, case when pe.enddate > current_date then extract(days from '2019-06-14'::date - greatest(pe.effectivedate ,'2019-06-14'::date - interval '1 year'))
       when pe.effectivedate > ('2019-06-14'::date - interval '1 year') and pe.enddate < '2019-06-14'::date then  pe.enddate - pe.effectivedate + 1
  else extract(days from least(pe.enddate,'2019-06-14'::date )   - ('2019-06-14'::date - interval '1 year')) + 1 end as numdays
  
, fc.annualfactor * pp.scheduledhours * ((case when pe.enddate > current_date then extract(days from '2019-06-14'::date - greatest(pe.effectivedate ,'2019-06-14'::date - interval '1 year'))
       when pe.effectivedate > ('2019-06-14'::date - interval '1 year') and pe.enddate < '2019-06-14'::date then  pe.enddate - pe.effectivedate + 1
  else extract(days from least(pe.enddate,'2019-06-14'::date )   - ('2019-06-14'::date - interval '1 year')) + 1 end ) /365::numeric) as hours

 
, '2019-06-14'::date - greatest(pe.effectivedate ,'2019-06-14'::date - interval '1 year') as numdaysend
,  least(pe.enddate,'2019-06-14'::date )   - ('2019-06-14'::date - interval '1 year')

, pp.effectivedate, pp.enddate, pp.partialpercent, pp.scheduledhours

from person_employment pe
left join pers_pos pp on pe.personid = pp.personid and current_timestamp between pp.createts and pp.endts and pp.effectivedate < pp.enddate and (pp.effectivedate, pp.enddate) overlaps (pe.effectivedate, pe.enddate)
join frequency_codes fc on fc.frequencycode = 'S'
where
    pe.personid = '66438'
  -- pe.personid = '64889'
and current_timestamp between pe.createts and pe.endts
and (pe.effectivedate, pe.enddate) overlaps ('2019-06-14'::date , '2019-06-14'::date - interval '1 year' )
and pe.effectivedate < pe.enddate




select * from person_names where lname like 'Donelan%'; --- Malissa Donelan – Exempt employee who goes between full-time and part-time frequently
select * from person_names where lname like 'Johnson%'; --- Corey Johnson – Non-exempt to Exempt employee 
select * from person_names where lname like 'Stark%'; --- Kim Stark – Non-exempt employee with an unpaid leave and a lot of PTO/Uncomp time
select * from person_names where lname like 'Bunch%'; --- Marshall Bunch – intern to full-time exempt employee
select * from person_names where personid = '64889'; --- ZACHWIEJA,DANIEL 
select * from position_desc where positionid = '405304';

select 

select * from person_pto_activity_request ppar where personid = '65072' and effectivedate >= current_date - interval '1 year' and takehours <> 0;
select * from pers_pos where personid = '65072' and effectivedate >= current_date - interval '1 year';
select * from position_desc where positionid in (select positionid from pers_pos where personid = '65072' and effectivedate >= current_date - interval '1 year')
and ((enddate >= current_date - interval '1 year') or (effectivedate >= current_date - interval '1 year'));


 --select * from person_pto_plans where personid = '19703';
select * from pto_plan_desc;
 --select * from edi.edi_last_update;



(select ppdx.personid,ppdx.check_date, substring(ppdx.individual_key,6) as empno, ppdx.etv_id, sum(ppdx.etype_hours) as reghours
            from pspay_payment_detail ppdx 
            left JOIN (select substring(individual_key,1,5) as paygroup, max(check_date) as last_check_date 
                         from pspay_payment_header group by 1) lastchk2 ON  lastchk2.paygroup = substring(ppdx.individual_key,1,5)
	                where ppdx.etv_id IN (select a.etv_id from pspay_etv_operators a
                               join pspay_etv_list b on a.etv_id = b.etv_id and a.group_key = b.group_key
                              where a.operand = 'WS01' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> 'SSSSS' group by 1)
		          and ppdx.check_number <> 'INIT REC'
		          and ppdx.check_date between current_date - interval '12 months' and lastchk2.last_check_date
		          and ppdx.personid = '65072'
	                group by ppdx.personid, ppdx.check_date, ppdx.etv_id, substring(ppdx.individual_key,6) order by 1);



select pn.name, pp.scheduledhours from pers_pos pp
join person_names pn on pn.personid = pp.personid and pn.nametype = 'Legal' and current_date between pn.effectivedate and pn.enddate and current_timestamp between pn.createts and pn.endts
where positionid in (select positionid from position_desc where flsacode = 'E' and current_timestamp between createts and endts)



select 
 hours.name
,hours.scheduledhours
,hours.takehours
,hours.scheduledhours - takehours as ytdhours
from

( 
select pn.name, ppar.takehours, pp.scheduledhours from pers_pos pp
join person_names pn on pn.personid = pp.personid and pn.nametype = 'Legal' and current_date between pn.effectivedate and pn.enddate and current_timestamp between pn.createts and pn.endts
left join person_pto_activity_request ppar on ppar.personid = pp.personid and ppar.effectivedate >= current_date - interval '1 year' and ppar.takehours <> 0
where positionid in (select positionid from position_desc where flsacode = 'E' and current_timestamp between createts and endts)
) hours 
;


select * from pspay_payment_detail where personid = '65072' and check_date >= current_date - interval '1 year';
select * from person_pto_activity_request ppar where personid = '65072' and effectivedate >= current_date - interval '1 year' and takehours <> 0;


select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-05-15 00:00:00' where feedid = 'HMN_MetLife_DisabilityEligibility';
INSERT into edi.edi_last_update (feedid,lastupdatets) values ('HMN_MetLife_DisabilityEligibility','2019-05-15 00:00:00');

select * from pay_schedule_period where date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)>='05';

--------------------------------
----- MANAGERS INFORMATION -----
-------------------------------- 
left join pers_pos ppos 
  on ppos.personid = pe.personid
 and (current_date between ppos.effectivedate and ppos.enddate or (ppos.effectivedate > current_date and ppos.enddate > ppos.effectivedate)) and current_timestamp between ppos.createts and ppos.endts
 and persposrel = 'Occupies' 

left join pos_pos popos 
  on popos.topositionid = ppos.positionid
 and (current_date between popos.effectivedate and popos.enddate or (popos.effectivedate > current_date and popos.enddate > popos.effectivedate))
 and current_timestamp between popos.createts and popos.endts 

left join pers_pos perp
  on perp.positionid = popos.positionid
 and (current_date between perp.effectivedate and perp.enddate or (perp.effectivedate > current_date and perp.enddate > perp.effectivedate))
 and current_timestamp between perp.createts and perp.endts 




















left join person_identity pim
  on pim.personid = perp.personid 
 and pim.identitytype = 'SSN'
 
 select * from pers_pos ppos where persposrel = 'Occupies'  and personid = '68000'  
    and (current_date between ppos.effectivedate and ppos.enddate or (ppos.effectivedate > current_date and ppos.enddate > ppos.effectivedate)) and current_timestamp between ppos.createts and ppos.endts
;
(select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts
           and personid = '68000' 
            group by personid, positionid, scheduledhours, schedulefrequency
            )



select * from batch_payment_type;
select * from pspay_group_earnings;
select * from pspay_group_deductions;
select * from cognos_pspay_etv_names ;
select * from cognos_pspay_etv_names_mv;
select * from pspay_benefit_mapping;
select * from employerbenecontribution_2018;
select * from person_names where personid = '63202';
SELECT * from person_pto_activity_request where personid = '63202' and ptoplanid in ('75','76');

(select ppdx.personid,ppdx.check_date, substring(ppdx.individual_key,6) as empno, ppdx.etv_id, sum(ppdx.etype_hours) as reghours
            from pspay_payment_detail ppdx 
            left JOIN (select substring(individual_key,1,5) as paygroup, max(check_date) as last_check_date 
                         from pspay_payment_header group by 1) lastchk2 ON  lastchk2.paygroup = substring(ppdx.individual_key,1,5)
	                where ppdx.etv_id IN (select a.etv_id from pspay_etv_operators a
                               join pspay_etv_list b on a.etv_id = b.etv_id and a.group_key = b.group_key
                              where a.operand = 'WS01' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> 'SSSSS' group by 1)
		          and ppdx.check_number <> 'INIT REC'
		          and ppdx.check_date between current_date - interval '12 months' and lastchk2.last_check_date
		          and ppdx.personid = '63032'
	                group by ppdx.personid, ppdx.check_date, ppdx.etv_id, substring(ppdx.individual_key,6) order by 1);
	                
(select substring(individual_key,1,5) as paygroup, max(check_date) as last_check_date 
                         from pspay_payment_header group by 1) lastchk2 ON  lastchk2.paygroup = substring(ppdx.individual_key,1,5)
	                where ppdx.etv_id IN (select a.etv_id from pspay_etv_operators a
                               join pspay_etv_list b on a.etv_id = b.etv_id and a.group_key = b.group_key
                              where a.operand = 'WS01' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> 'SSSSS' group by 1)
		          and ppdx.check_number <> 'INIT REC'
		          and ppdx.check_date between current_date - interval '12 months' and lastchk2.last_check_date
	                group by ppdx.personid, substring(ppdx.individual_key,6) order by 1)
	                	                
	                	                
	                	                

select * from pspay_payment_detail where etv_id = 'E22' and check_date <= '2019-04-17';
select * from person_names where personid = '66121';
select * from pspay_etv_operators;
select * from pspay_etv_list where etv_id in ('E01', 'E02', 'E03','EAR','EA1','E15','E16','E17','E18','E20');
select * from person_employment
select personid, positionid

left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) ppos on ppos.personid = pe.personid and ppos.rank = 1







select * from cognos_person_tax_elections where personid = '68448';
select * from tax;
select * from tax_filing_status;


select * from pspay_payment_detail ppdx
left JOIN (select substring(individual_key,1,5) as paygroup, max(check_date) as last_check_date 
                          from pspay_payment_header group by 1) lastchk2 ON  lastchk2.paygroup = substring(ppdx.individual_key,1,5)
where personid = '65684' and check_number <> 'INIT REC'
 and etv_id in 
(select a.etv_id from pspay_etv_operators a
                               join pspay_etv_list b on a.etv_id = b.etv_id and a.group_key = b.group_key
                              where a.operand = 'WS01' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> 'SSSSS' group by 1)


left join person_compensation pc on pc.personid = pe.personid and pc.earningscode in ('Regular','RegHrly','ExcHrly')
 and current_timestamp between pc.createts and pc.endts and ((current_date between pc.effectivedate and pc.enddate or (pc.effectivedate > current_date and pc.enddate > pc.effectivedate))
  or (pe.benefitstatus = 'T' and (pe.effectivedate - interval '1 day') between pc.effectivedate and pc.enddate 
 and not exists (select pc2.personid from person_compensation pc2 where pc2.personid = pc.personid and current_date between pc2.effectivedate and pc2.enddate and current_timestamp between pc2.createts and pc2.endts)))


(select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where earningscode in ('Regular','RegHrly','ExcHrly') and personid = '68000'
              and current_timestamp between createts and endts and (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate))
            group by personid, compamount, increaseamount, compevent, frequencycode )
            
            
left join (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where earningscode in ('Regular','RegHrly','ExcHrly')
              and current_timestamp between createts and endts and (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate))
            group by personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1  
            
            
select * from person_identity where personid = '68089' and identitytype = 'SSN' and current_timestamp between createts and endts;        
            












select * from pspay_etv_operators;
select * from pspay_etv_accumulator_codes;

(select distinct personid, sum(etype_hours) as hours, sum(etv_amount) as taxable_wage, max(check_date)::date as check_date
             from pspay_payment_detail 
            where  (select distinct periodpaydate::date as check_date from pay_schedule_period where payrolltypeid in (1,2) and periodpaydate <= current_date  and periodpaydate >= current_date - interval '1 year') as check_date between current_date
            
            
            
            etv_id in (select a.etv_id from pspay_etv_operators a
                               join pspay_etv_list b on a.etv_id = b.etv_id and a.group_key = b.group_key
                              where a.operand = 'WS01' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> 'SSSSS' group by 1)
             and etv_id not in ('E15','E16','E17','E18','E19','E20')  ---- known etv's that must be excluded
             --and check_date::date between (select distinct periodpaydate::date as check_date from pay_schedule_period where payrolltypeid in (1,2) and periodpaydate <= current_date  and periodpaydate >= current_date - interval '1 year') and current_date


           group by personid) ;
             
select * from pspay_etv_list where etv_id in (select a.etv_id from pspay_etv_operators a
                             join pspay_etv_list b on a.etv_id = b.etv_id and a.group_key = b.group_key
                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' group by 1)             
and etv_id not in ('E15','E16','E17','E18','E19','E20')                            


select personid, etv_id, etype_hours, check_date from pspay_payment_detail where etv_id not in ('E15','E16','E17','E18','E19','E20') 
   and ((check_date,current_date) OVERLAPS (date check_date,interval '1 year', max(check_date))

    and ((pbe.effectivedate, pbe.enddate) OVERLAPS (cppy.planyearstart, cppy.planyearend) OR cppy.planyearstart IS NULL) 
   
 where pe.personid = '836' and pbe.benefitelection = 'E' and pbe.selectedoption = 'Y' and pe.emplstatus = 'T';
 
 SELECT (DATE '2016-01-10', INTERVAL '1 month') OVERLAPS (DATE '2016-01-20', INTERVAL '7 days');
 
 select (date check_date, interval - '1 year') overlaps (date check_date, interval - '1 month') from pspay_payment_detail;
 
SELECT (DATE '2011-01-28', DATE '2011-02-01') OVERLAPS
       (DATE '2011-02-01', DATE '2011-02-01');
SELECT (DATE '2011-01-28', DATE '2011-02-01' + 1) OVERLAPS
       (DATE '2011-02-01', DATE '2011-02-01');      

select current_date - interval '1 year';
select distinct periodpaydate from pay_schedule_period where payrolltypeid in (1,2) and periodpaydate <= current_date  and periodpaydate >= current_date - interval '1 year';
select personid, etype_hours, etv_id, check_date from pspay_payment_detail where check_date >= current_date - interval '1 month' and etv_id not in ('E15','E16','E17','E18','E19','E20')

select * from process_process_links where viewname like 'PERSON%';

(select pph2.individual_key, pph2.period_begin_date, pph2.period_end_date, state_code 
          from pspay_payment_header pph2
          join (select personid, max(check_date) as max_check_date 
         from cognos_payment_earnings_by_check_date 
          group by personid) as pmax2 on pmax2.personid = pph2.personid and pmax2.max_check_date = pph2.check_date
           group by pph2.individual_key, pph2.period_begin_date, pph2.period_end_date, state_code)
;
(select ppdx.personid,substring(ppdx.individual_key,6) as empno, sum(ppdx.etype_hours) as reghours
   from pspay_payment_detail ppdx 
   left JOIN (select substring(individual_key,1,5) as paygroup, max(check_date) as last_check_date 
                from pspay_payment_header group by 1) lastchk2 ON  lastchk2.paygroup = substring(ppdx.individual_key,1,5)
	       where ppdx.etv_id IN ('E01', 'E02', 'E03')
		 and ppdx.check_number <> 'INIT REC'
		 and ppdx.check_date between current_date - interval '12 months' and lastchk2.last_check_date
	       group by ppdx.personid, substring(ppdx.individual_key,6) order by 1)
;			           
(select ppdx.personid, min(ppdx.check_date) check_date   from pspay_payment_detail ppdx 
   left JOIN (select substring(individual_key,1,5) as paygroup, max(check_date) as last_check_date 
                from pspay_payment_header group by 1) lastchk2 ON  lastchk2.paygroup = substring(ppdx.individual_key,1,5)
	       where ppdx.etv_id IN (select a.etv_id from pspay_etv_operators a
                               join pspay_etv_list b on a.etv_id = b.etv_id and a.group_key = b.group_key
                              where a.operand = 'WS01' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> 'SSSSS' group by 1)
		 and ppdx.check_number <> 'INIT REC'
		 and ppdx.check_date between current_date - interval '12 months' and lastchk2.last_check_date
	       group by ppdx.personid order by 1)
;			           

select a.etv_id from pspay_etv_operators a
                               join pspay_etv_list b on a.etv_id = b.etv_id and a.group_key = b.group_key
                              where a.operand = 'WS01' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> 'SSSSS' group by 1
