
delete from batch_detail where batchheaderid in (select batchheaderid from batch_header where createts::date = current_date);
delete from batch_header where createts::date = current_date;

SELECT * from person_identity where identity = 'AXE024440';


select * from person_pto_activity_request where createts::date = current_date::date-- and activityrequestcomment = 'DGHTiimeImport';

select eventname from person_benefit_action group by 1;


select * from pay_schedule_period where payrolltypeid = 1 and date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)<='09';

select * from pspay_group_deductions where group_key <> '$$$$$' and etv_id like 'V%';
select * from person_pto_activity_request where activityrequestcomment = 'DGHTiimeImport' and createts::date >= current_date;

delete from person_pto_activity_request where activityrequestcomment = 'DGHTiimeImport' and createts::date >= '2019-05-02';
select * from batch_header where batchname like '%.csv%' and createts::date >= '2019-05-02';


select * from person_names where personid = '19102';

select * from person_pto_activity_request where personid = '19102' and activityrequestcomment = 'DGHTiimeImport';

update edi.edi_last_update set lastupdatets = '2019/04/30 08:00:38' where feedid = 'DGH_PersonPTOPlans_Import'; 

 --delete from person_pto_activity_request where activityrequestcomment = 'DGHTiimeImport' and createts::date = '2019-04-22';
select * from batch_header where batchname like '%.csv%' and createts::date >= '2019-05-02';
select * from batch_detail where batchheaderid in ('209');



select * from batch_detail where createts::date= current_date;
select * from batch_header where createts::date= current_date;
delete from person_pto_activity_request where activityrequestcomment = 'DGHTiimeImport' and createts::date >= '2019-05-02';
delete from batch_detail where createts::date= current_date;
delete from batch_header where createts::date= current_date;

select * from batch_header where batchname like '2019 04 02 METH.csv%';

select * from batch_detail where batchheaderid in ('769'); --- using prod version batch detail
select * from batch_detail where batchheaderid in ('198'); --- using brians version

select * from edi.edi_last_update
select * from person_names where personid = '19458';

E39099328

select current_timestamp;
select * from pay_schedule_period where date_part('month',periodpaydate )>='11' and date_part('year',periodpaydate )= '2019' and processfinaldate is not null;

select * from batch_header where batchheaderid = '2164';

select * from batch_detail where personid = '19458' and date_part('year',effectivedate ) = '2019' and date_part('month',effectivedate)>='11';

select * from payscheduleperiodasof where payunitid = 4 and companyid = 1 and payrolltypeid = 1 and asofdate = '2019-12-13';

select * from batch_header where payscheduleperiodid = '608';

select * from person_identity where identity = 'AXE007086';
select * from person_identity where personid = '19458';


(select payscheduleperiodid, psp.payunitid, periodstartdate, periodenddate, periodpaydate
        from pay_schedule_period psp
        join (Select payunitid, min(periodpaydate) lastpaydate 
                from pay_schedule_period where periodpaydate > ?::DATE and payrolltypeid = 1 group by payunitid ) as ppd on ppd.payunitid = psp.payunitid and ppd.lastpaydate = psp.periodpaydate
               where payrolltypeid = 1 ) 
               
select * from batch_header where batchname like 'E39Hourly%';
select * from batch_detail where batchheaderid = '2341';


select * from batch_header where batchname like 'E39 Hourly 12-27-19_12232019_130155.csv';
select * from batch_header where batchname like '7C7 Salaried Vac 04-19-19.csv%';
select * from batch_header where batchname like '7E6 Hourly 04-19-19.csv%';
select * from batch_header where batchname like '7C8 Salaried Vac 04-19-19.csv%';
select * from batch_header where batchname like '7C8 Salaried Vac 04-19-19.csv%';
select * from batch_header where batchname like '7B4 Salaried Vac 10-18-19.csv%';
select * from batch_header where batchname like '7B8 Salaried Vac 10-18-19.csv%';
select 
select * from batch_header where batchname like '7E6_Hourly_01-25-19.csv%';
select * from batch_header where batchname like '7DE%';

select * from person_names where lname like 'Lien%';
select * from person_names where personid = '18007';
BOSKOVITCH
select * from batch_detail where batchheaderid in ('1922','1952');


select * from person_names where personid in (select personid from batch_detail where batchheaderid in ('272')) order by name;


delete from batch_detail where batchheaderid in ('196');
delete from batch_header where batchname = 'E39_Hourly03-08-19.csv' and batchheaderid in  ('196');


delete from batch_detail where batchheaderid in
(select distinct batchheaderid from batch_header where batchname = '7DE_Hourly_01-25-19.csv')
delete from batch_detail where batchheaderid in ('306');
delete from batch_header where batchname = '7DE_Hourly_01-25-19.csv' and batchheaderid in  ('306');

select * from person_bene_election where personid = '18843';
select * from benefit_coverage_desc

select * from person_pto_plans where personid = '18843';
select * from person_pto_activity_request where activityrequestcomment = 'DGHTiimeImport';

update person_pto_activity_request set effectivedate = '2019-01-18' where activityrequestcomment = 'DGHTiimeImport';
delete from person_pto_activity_request where activityrequestcomment = 'DGHTiimeImport';

select * from person_pto_activity_request  where personid = '19495';
update person_pto_activity_request set activityrequestsource = 'IMPORT' where personid = '19495' and personactivityreqpid = '44874';

update person_pto_activity_request set effectivedate = '2019-01-18' where personid = '19495' and personactivityreqpid = '44874';

select * from person_user_field_vals;


select * from person_pto_activity_request where activityrequestcomment = 'DGHTiimeImport' and createts::date = '2019-02-09';

select * from person_pto_activity_request where activityrequestcomment = 'IMPORT' and effectivedate > '2018-12-31';
select * from personplayyearasof where personid = '18843';

select * from personptoplanyearend where personid = '18843';
select * from personptoplanyr   where personid = '18843';
select * from personptoplanyearstart   where personid = '18843';

select * from pto_plan_desc;
select * from batch_header where batchname like  'DGH_TimeImport%';


select * from person_names where personid = '19236';


select * from batch_header where batchheaderid = '129';

select * from batch_detail where batchheaderid = '129';

delete from batch_detail where batchheaderid = '182';
delete from batch_header where batchheaderid = '182';

select * from batch_detail where personid = '17908' and batchheaderid = '128';
select * from batch_detail where personid = '19512';


select * from person_names where lname like '%Lopez%';
select * from person_identity where personid = '19512';

SELECT * from person_names where personid = '17498';

select * from pay_schedule_period where payrolltypeid = 1 and payunitid = 4;

select * from person_identity where identity = '7BC022222';

select pi.personid
, trim(pi.identity)::char(9) as ssno
, l.logid
, substring(pit.identity from 1 for 5)::char(5) as groupno
, pit.identity::char(15) as trankey
, current_timestamp as rightnow
, pie.identity as empno
, npdate.periodenddate::date next_periodenddate
from person_identity pi 
join person_identity pit on pi.personid = pit.personid
       and current_timestamp between pit.createts and pit.endts
       and pit.identitytype = 'PSPID'
join person_identity pie on pi.personid = pie.personid
       and current_timestamp between pie.createts and pie.endts
       and pie.identitytype = 'EmpNo'
cross join ( select 1234::int  as logid )l
join person_payroll pp on pp.personid = pi.personid and current_date between pp.effectivedate and pp.enddate and current_timestamp between pp.createts and pp.endts
join (select payscheduleperiodid, psp.payunitid, periodstartdate, periodenddate, periodpaydate 
                     from pay_schedule_period psp
                     join (Select payunitid, min(periodpaydate) lastpaydate 
                           from pay_schedule_period where periodpaydate > ?::DATE and payrolltypeid = 1 group by payunitid ) as ppd on ppd.payunitid = psp.payunitid
                           and ppd.lastpaydate = psp.periodpaydate
                           where payrolltypeid = 1 ) npdate on npdate.payunitid = pp.payunitid
where current_timestamp between pi.createts and pi.endts
and pi.identitytype = 'SSN' and pi.personid = '19386'
order by pi.identity;
















select * from person_names where lname like 'Smith%';

select * from person_identity where personid = '18602' and identitytype = 'Badge';
SELECT * FROM person_identity where identity = '000001274';
select * from person_identity where identity = '7B4906009';
select * from person_names where personid = '19703';
select * from Batch_detail where personid = '19495' and effectivedate = '2018-11-11';
---- 2nd shift person 
select * from person_identity where identity = '7C7200026';
select * from person_names where personid = '19579';
select * from Batch_detail where personid = '19579' and effectivedate = '2018-11-11';


select * from batch_header where batchname = 'DGH_TimeImport';
select * from Batch_detail where batchheaderid = '82';

select * from edi.lookup;
select * from edi.lookup_schema;
select	min(periodenddate) as EFFECTIVEDATE,1 as lookup_constant
from	pay_schedule_period
where	periodpaydate > ?::DATE and payrolltypeid = 1 


select * from pay_schedule_period where payrolltypeid = 1 ;


select * from batch_header where batchname = 'DGH_TimeImport';
select * from Batch_detail where batchheaderid = '96';
select * from batch_detail where personid = '17400' and batchheaderid = '86';


delete from batch_detail where batchheaderid in ('163','164');
delete from batch_header where batchname = 'DGH_TimeImport' and batchheaderid in ('163','164');