select * from person_pto_activity_request where createts::date = current_date;

insert into person_user_field_vals (personid, persufpid, ufid, ufvalue, effectivedate, enddate, createts, endts) 
select 85089, 47, '15','32.0', '2019/09/21', '2199-12-31 +0', current_timestamp, '2199-12-30 00:00:00-05'


select * from person_user_field_vals where createts::date = current_date;
delete from person_user_field_vals where personid = '85089' and persufpid = '47';
select activityrequestcomment from person_pto_activity_request group by 1;

--query to run on BA3 EDI before running your import
select * from person_names where personid = '85089';
select * from pspay_input_transaction where last_updt_dt::date = current_date;



delete from pspay_input_transaction where last_updt_dt::date = current_date;

select * from batch_detail where createts::date = current_date;

update pto_plan_desc
set enddate = '2199-12-31'
where ptoplanid = 26 and ptoplanpid = 659
;BA3WFO_Import


select    pi.trankey::varchar(20),
                pi.netid::varchar(20),
                ed.emplclass::varchar(2),
                ed.emplpermanency::varchar(2),
                pi.employeeid::varchar(5),
                ed.flsacode::char(5),
                round(ed.scheduledhours, 2) as "NORM",
                pu.payunitid,
                pu.payunitdesc
,   pi.personid
from                      edi.etl_employment_data ed
                join        edi.etl_personal_info pi on ed.personid = pi.personid
                left join person_payroll as pp on pp.personid = ed.personid AND now() >= pp.effectivedate AND now() <= pp.enddate AND now() >= pp.createts AND now() <= pp.endts
                left join pay_unit as pu on pp.payunitid = pu.payunitid
WHERE substring(pi.trankey,1,5) <> 'BA310'
--and ed.flsacode is not null

BATCH_NOTES = 'WFO TimeImport';