select * from batch_header where batchname = 'Kudos Import' order by createts desc;
select * from batch_detail where batchheaderid in ('1702','1703','1704');


delete from batch_detail where batchheaderid in ('1702','1703','1704');
delete from batch_header where batchheaderid in ('1702','1703','1704');



select * from payscheduleperiodasof where asofdate >= '2019-08-30';

select * from batch_header where createts::date = current_date;
select * from batch_detail where batchheaderid in (select batchheaderid from batch_header where createts::date = current_date group by 1) order by personid, etv_id;





select * from pay_schedule_period where date_part('year',periodpaydate)='2019'and date_part('month',periodpaydate)='10';




select * from log_entries where userid = 'EDI';



select * from pspay_input_transaction where last_updt_dt::date = current_date::date;
delete from pspay_input_transaction where last_updt_dt::date = current_date::date;


select * from batch_header where batchname = 'WO Time Import' order by createts desc;
select * from batch_detail where batchheaderid = '1724'  and personid = '85080' ;
select * from person_identity where identity = '01217';
select batchname from batch_header group by 1;


select * from batch_detail where createts::date = current_date and personid = '85124' ;
select * from batch_header where createts::date = current_date;
select * from batch_detail where batchheaderid in (select batchheaderid from batch_header where createts::date = current_date group by 1);


delete from batch_detail where batchheaderid in (select batchheaderid from batch_header where createts::date = current_date group by 1);
delete from batch_header where createts::date = current_date;


select
 a.identity as empno
,b.identity::char(14) as pspid
,left(b.identity,5)::char(5) as payunit
,l.logid
, npdate.next_periodenddate::date next_periodenddate
  from person_identity a
join person_identity b
  on b.personid = a.personid
 and current_timestamp between b.createts and b.endts
 and b.identitytype = 'PSPID'
cross join ( select nextval('log_seq') as logid from dual )l
cross join (select distinct
psp.periodpaydate::date,
to_char(npay.next_periodenddate,'yyyy-mm-dd')::char(10) as next_periodenddate
from pay_schedule_period psp
join 
(select distinct periodpaydate::date,lag(periodenddate) over (order by periodpaydate desc)::date as next_periodenddate
 FROM pay_schedule_period where periodpaydate >= ?::date 
 order by 1) npay on npay.periodpaydate = psp.periodpaydate

where psp.periodpaydate = ?::date 
and npay.next_periodenddate > ?::date) npdate
where a.identitytype = 'EmpNo'
  and current_timestamp between a.createts and a.endts
order by 1
;
