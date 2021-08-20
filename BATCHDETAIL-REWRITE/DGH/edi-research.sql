select * from batch_header where batchname like '7C8Hourly09-06-19.csv.bak%';--1641
select * from batch_detail where batchheaderid = '1641';
select * from batch_header where batchname like '7C7Hourly09-06-19.csv.bak%';--1642
select * from batch_detail where batchheaderid = '1642';
select * from batch_header where batchname like 'E39Hourly09-06-19.csv.bak%';
select * from batch_detail where batchheaderid = '1643';
select * from batch_header where batchname like 'AXEHourly09-16-19.csv.bak%';
select * from batch_detail where batchheaderid = '1644';
select * from person_employment where personid = '20078';
select * from batch_header where batchname like '7YZHourly09-06-19.csv.bak%';
select * from batch_detail where batchheaderid = '1645';
select * from person_names where personid = '18857';
select * from batch_detail where batchheaderid = '1645' and personid = '18857';
select * from batch_header where batchname like '7XKHourly09-06-19.csv.bak%';
select * from batch_detail where batchheaderid = '1646';
select * from batch_detail where batchheaderid = '1646' and personid in ('18217','18032','17806','17480'); --- missing ECP
select * from person_names where personid in ('18217','18032','17806','17480'); --- missing ECP due to link to step disabled.
delete from batch_detail where batchheaderid = '1646';
delete from batch_header where batchheaderid = '1646';
select * from batch_detail where batchheaderid = '1670';

select * from batch_header where batchname like '7VKHourly09-06-19.csv.bak%';
select * from batch_header where batchname like '7E6Hourly09-06-19.csv.bak%';
select * from batch_header where batchname like '7DEHourly9-1-19.csv.bak%';
select * from batch_header where batchname like '7C9Hourly09-06-19.csv.bak%';
select * from batch_header where batchname like '7BCHourly09-06-19.csv.bak%';
select * from batch_header where batchname like '7B9Hourly09-06-19.csv.bak%';
select * from batch_header where batchname like '7B8Hourly09-06-19.csv.bak%';
select * from batch_header where batchname like '7B4Hourly09-06-19.csv.bak%';
select * from batch_header where batchname like 'E39SalariedVac09-06-19.csv.bak%';
select * from batch_header where batchname like 'AXESalariedVac09-06-19.csv.bak%';
select * from batch_header where batchname like '7YZSalariedVac09-06-19.csv.bak%';
select * from batch_header where batchname like '7XKSalariedVac09-06-19.csv.bak%';
select * from batch_header where batchname like '7VKSalariedVac09-06-19.csv.bak%';
select * from batch_header where batchname like '7E6SalariedVac09-06-19.csv.bak%';
select * from batch_header where batchname like '7DDSalariedVac09-06-19.csv.bak%';
select * from batch_header where batchname like '7C9SalariedVac09-06-19.csv.bak%';
select * from batch_header where batchname like '7C8Salaried09-06-19.csv.bak%';
select * from batch_header where batchname like '7C7Salaried09-06-19.csv.bak%';
select * from batch_header where batchname like '7BCSalariedVac09-06-19.csv.bak%';
select * from batch_header where batchname like '7B8SalariedVac09-06-19.csv.bak%';
select * from batch_header where batchname like '7B4SalariedVac09-06-19.csv.bak%';
