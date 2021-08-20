select * from batch_header where batchname='HMN Separate Bonus';-- 29 rows
select batchnotes from batch_header group by 1;
select * from batch_detail where batchheaderid in ('140');
select * from edi.edi_last_update;
select * from person_identity where identity = '223195612';
select * from person_identity where personid = '66857';
select * from person_identity where identitytype = 'PSPID';

select * from person_identity where identity = 'HMN00000070118';

09/18/2019 13:51:52
update edi.edi_last_update set lastupdatets = '2019-09-18 13:51:42' where feedid = 'AMJ_EBC_HSA_Eligibility_Export'; --2019-03-26 07:00:

select * from batch_header limit 10;
select * from batch_header 
select * from batch_detail where effectivedate = '2019-09-16';

select batchpaymenttypeid
, trim(batchpaymenttypename)::varchar(30) as batchpaymenttypename
from batch_payment_type
order by batchpaymenttypename;

select * from batch_header where batchheaderid = '799';

select * from batch_detail where effectivedate='2019-09-16';
select * from batch_header where createts::date = current_date;

delete from batch_detail where effectivedate='2019-09-16';
delete from batch_header where createts::date = current_date;


select * from pspay_input_transaction where last_updt_dt::date = current_date::date;


delete from batch_detail where batchheaderid in (select batchheaderid from batch_header where batchheaderid='799');
delete from batch_header where batchheaderid='799';
