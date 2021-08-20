select * from batch_header where batchname like '7C8 Hourly 09-06-19.csv%';--1641
select * from batch_detail where batchheaderid = '1693';

select * from batch_header where batchname like '7C7 Hourly 09-06-19.csv%';
select * from batch_detail where batchheaderid = '1694';

select * from batch_header where batchname like 'E39  Hourly 09-06-19.csv%';
select * from batch_detail where batchheaderid = '1690';

select * from batch_header where batchname like 'AXE Hourly 09-16-19.csv%';
select * from batch_detail where batchheaderid = '1691';
select * from person_employment where personid = '20078';

select * from batch_header where batchname like '7YZ Hourly 09-06-19.csv%';
select * from batch_detail where batchheaderid = '1692';
select * from batch_detail where batchheaderid = '1692' and personid = '18857';
select * from person_names where personid = '18857';

select * from batch_header where batchname like '7XK Hourly 09-06-19.csv%';
select * from batch_detail where batchheaderid = '1688';
select * from batch_detail where batchheaderid = '1688' and personid in ('18217','18032','17806','17480'); --- missing ECP
select * from person_names where personid in ('18217','18032','17806','17480'); --- missing ECP


select * from batch_header where batchname like '7VK Hourly 09-06-19.csv%';
select * from batch_header where batchname like '7E6 Hourly 09-06-19.csv%';
select * from batch_header where batchname like '7DE Hourly 9-1-19.csv%';
select * from batch_header where batchname like '7C9 Hourly 09-06-19.csv%';
select * from batch_header where batchname like '7BC Hourly 09-06-19.csv%';
select * from batch_header where batchname like '7B9 Hourly 09-06-19.csv%';
select * from batch_header where batchname like '7B8 Hourly 09-06-19.csv%';
select * from batch_header where batchname like '7B4 Hourly 09-06-19.csv%';
select * from batch_header where batchname like 'E39 Salaried Vac 09-06-19.csv%';
select * from batch_header where batchname like 'AXE Salaried Vac 09-06-19.csv%';
select * from batch_header where batchname like '7YZ Salaried Vac 09-06-19.csv%';
select * from batch_header where batchname like '7XK Salaried Vac 09-06-19.csv%';
select * from batch_header where batchname like '7VK Salaried Vac 09-06-19.csv%';
select * from batch_header where batchname like '7E6 Salaried Vac 09-06-19.csv%';
select * from batch_header where batchname like '7DD Salaried Vac 09-06-19.csv%';
select * from batch_header where batchname like '7C9 Salaried Vac 09-06-19.csv%';
select * from batch_header where batchname like '7C8 Salaried 09-06-19.csv%';
select * from batch_header where batchname like '7C7 Salaried 09-06-19.csv%';
select * from batch_header where batchname like '7BC Salaried Vac 09-06-19.csv%';
select * from batch_header where batchname like '7B8 Salaried Vac 09-06-19.csv%';
select * from batch_header where batchname like '7B4 Salaried Vac 09-06-19.csv%';


