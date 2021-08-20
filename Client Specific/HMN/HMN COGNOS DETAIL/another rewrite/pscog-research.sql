SELECT * from person_employment where current_date between effectivedate and enddate 
and current_timestamp between createts and endts and emplstatus = 'T'
and emplevent <> 'Retire'
and date_part('year',effectivedate) >= date_part('year',current_date - interval '1 year')
;
select * from person_employment where personid = '63682'
 and current_date between effectivedate and enddate and current_timestamp between createts and endts
 and emplstatus = 'A';
select * from pers_pos where personid = '66247';
select * from position_desc where positionid = '404963';

select * from position_job where positionid = '404963';
select * from job_desc where jobid = '69317';

select * from pers_pos where personid = '63631';

select * from personcomppercentinrangeasof where personid = '65260';
select * from personcomppercentinrange  where personid = '65260';

select distinct positionid, max(posorgrelpid) as posorgrelpid
  from pos_org_rel where positionid = '401959' group by 1;

select * from pos_org_rel where positionid = '392354';
select * from organization_code where organizationid = '1406';
select * from organization_code where organizationid = '123';

select positionid, max(organizationid) as organizationid, max(posorgrelpid) as posorgrelpid
             from pos_org_rel where posorgreltype = 'Budget' and positionid = '401959'
             group by 1
             ;
select * from edi.edi_last_update 
select * from organization_code where organizationid = '1406';


SELECT distinct pe.personid from person_employment pe 

left join (select personid, max(perspospid) as perspospid 
             from pers_pos where current_timestamp between createts and endts
            group by 1) as maxpos on maxpos.personid = pe.personid

left join pers_pos pp 
  on pp.personid = maxpos.personid
 and pp.perspospid = maxpos.perspospid
 --and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 

left join (select positionid, max(positiondescpid) as positiondescpid
             from position_desc 
            --where current_timestamp between createts and endts
            group by 1) maxpd on maxpd.positionid = pp.positionid

left join position_job pj
  on pj.positionid = maxpd.positionid
 and current_date between pj.effectivedate and pj.enddate
 and current_timestamp between pj.createts and pj.endts
 
left join job_desc jd
  on jd.jobid = pj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts 



left join position_desc pd
  on pd.positionid = maxpd.positionid
 and pd.positiondescpid = maxpd.positiondescpid
 --and current_date between pd.effectivedate and pd.enddate
 --and current_timestamp between pd.createts and pd.endts  


where current_date between pe.effectivedate and pe.enddate 
and current_timestamp between pe.createts and pe.endts 
  and pe.emplstatus = 'T' 
  and pe.emplevent <> 'Retire'
  and pd.positiontitle <> ('Agent') 
  and jd.jobcode not in ('A1012')  
and date_part('year',pe.effectivedate) >= date_part('year',current_date - interval '1 year')
;






select * from pspay_etv_operators where etvindicator = 'E';

select * from person_user_field_vals 
where current_date between effectivedate and enddate 
and current_timestamp between createts and endts
---and char_length(ufvalue) > 10 
---and persufpid = 2
and personid = '67479'
;
select * from person_compensation where personid = '65469';
select * from personcomppercentinrange WHERE PERSONID = '64567' ;
SELECT * FROM personcomppercentinrangeasof WHERE PERSONID = '64567' and asofdate = current_date;

select personid, max(asofdate) as asofdate, max(percomppid) percomppid from personcomppercentinrangeasof 
WHERE earningscode = 'Regular' and PERSONID = '64567' group by 1;

select * from person_employment where personid = '63735';


select cast(date_part('year',age('2017-09-01','1999-10-11')) + (date_part('month',age('2017-09-01','1999-10-11')) * .1) as dec (18,4))
select age(timestamp '2017-09-01', timestamp '1999-10-11');
select date_part('year',age('2017-09-01','1999-10-11'));
select date_part('month',age('2017-09-01','1999-10-11'))* .10;

select cast(date_part('year',age('2017-09-01','1999-10-11')) ||'.'|| (date_part('month',age('2017-09-01','1999-10-11')) * .1) as dec (18,2))

select age(timestamp '2001-04-10', timestamp '1957-06-13')



select * from dxpersonpositiondet where personid = '63675';
select * from person_employment where emplstatus = 'T' and emplevent = 'Retire'
and current_date between effectivedate and enddate 
and current_timestamp between createts and endts
and date_part('year',effectivedate) >= date_part('year',current_date - interval '1 year');

select * from pers_pos where personid = '62994'
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;

select * from person_employment where personid = '63006';
select * from person_employment where personid = '63682';

select * from pos_org_rel where positionid = '389511'
and current_date between effectivedate and enddate 
and current_timestamp between createts and endts
and posorgreltype = 'Budget';

select * from organization_code where organizationid = '1430' -- porb.organizationid
and current_date between effectivedate and enddate 
and current_timestamp between createts and endts
and posorgreltype = 'Budget';

select * from pers_pos where personid = '63675'
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;

select * from position_desc where positionid = '392561'
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;

select personid, max(perspospid) as perspospid 
from pers_pos where personid = '63675'
and current_timestamp between createts and endts
group by 1;

select positionid, max(positiondescpid) as positiondescpid
from position_desc 
where current_timestamp between createts and endts
and  positionid = '389562'
group by 1;

select * from person_compensation
where personid = '63675'
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;

select personid, max(percomppid) as percomppid
from person_compensation 
where personid =  '63675'
group by 1