
select * from batch_header where batchname = 'Novatime_Imports';
select * from batch_detail where batchheaderid in (select distinct batchheaderid from batch_header where batchname = 'Novatime_Imports');

delete from batch_detail where batchheaderid in (select distinct batchheaderid from batch_header where batchname = 'Novatime_Imports');
delete from batch_header where batchname = 'Novatime_Imports';

select * from PersonPayCompanyLkup where personid = '1012' and asofdate = current_date;

select * from person_identity where personid = '1012';