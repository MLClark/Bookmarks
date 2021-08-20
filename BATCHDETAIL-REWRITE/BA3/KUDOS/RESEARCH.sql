select batchname from batch_header group by 1;
select * from batch_header where batchname like 'Kudo%' order by createts desc;
select * from batch_header where batchpaymenttypeid = '1' and batchname = 'Kudos Import';


delete from batch_detail where batchheaderid in 
(select batchheaderid from batch_header where batchpaymenttypeid = '1' and batchname = 'Kudos Import');

delete from batch_header where batchpaymenttypeid = '1' and batchname = 'Kudos Import';




select * from batch_header where effectivedate::date = '2020-04-11' and batchname = 'Kudos Import';

select * from batch_detail where batchheaderid in 
(select batchheaderid from batch_header where effectivedate::date = '2020-04-11' and batchname = 'Kudos Import');

delete from batch_detail where batchheaderid in 
(select batchheaderid from batch_header where effectivedate::date = '2020-04-11' and batchname = 'Kudos Import');

delete from batch_header where effectivedate::date = '2020-04-11' and batchname = 'Kudos Import';

select * from pspay_input_transaction where transaction_originate like 'Kudo%' and  effectivedate::date = '2020-04-11';


delete from pspay_input_transaction where transaction_originate like 'Kudo%' and  effectivedate::date = '2020-04-11';