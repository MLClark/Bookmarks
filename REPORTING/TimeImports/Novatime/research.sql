select * from batch_detail where personid = '69';
select * from person_identity where identity = '000001238';
select * from pay_schedule_period;

select	min(periodenddate) as EFFECTIVEDATE,
		1 as lookup_constant
from	pay_schedule_period
where	periodpaydate > ?::DATE and payrolltypeid = 1 

select * from batch_header where payscheduleperiodid < '636';
select * from pay_schedule_period where payscheduleperiodid = '634';

select * from pay_schedule_period where processfinaldate is null;


select * from batch_detail where batchheaderid in (select batchheaderid from batch_header where createts::date = current_date);
