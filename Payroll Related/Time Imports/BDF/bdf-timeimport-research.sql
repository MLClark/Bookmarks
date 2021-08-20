select * from pay_schedule_period where date_part('year',periodpaydate)='2018' and date_part('month',periodpaydate)='04';


select	min(periodenddate) as EFFECTIVEDATE,
		1 as lookup_constant
from	pay_schedule_period
where	periodpaydate > ? and payrolltypeid = 1 
 
;


select * from batch_header where date_part('year',createts::date)='2018' and date_part('month',createts::date)='05';
select * from batch_header where batchname = 'MICROS' and batchnotes = 'BDF_Micros_TimeImport';
select * from batch_detail;
delete from batch_detail where batchheaderid in ('113','114');
delete from batch_header where batchheaderid in ('113','114');

select * from batch_header where batchheaderid in ('113','114');
select *  from batch_detail where batchheaderid in ('113','114');
