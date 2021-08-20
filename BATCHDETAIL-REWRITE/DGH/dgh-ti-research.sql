--select * from batch_header limit 10;
select * from batch_header where batchname = 'E39Hourly10-18-19.csv.bak';
select * from batch_detail where batchheaderid in (select distinct batchheaderid from batch_header where batchname = 'E39Hourly10-18-19.csv.bak');

delete from batch_detail where batchheaderid in (select distinct batchheaderid from batch_header where batchname = 'E39Hourly10-18-19.csv.bak');
delete from batch_header where batchname = 'E39Hourly10-18-19.csv.bak';

select * from pay_schedule_period where 