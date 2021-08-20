select * from edi.edi_import_tracking where feedid = 'BA3LM_ImportBilling' and trackingdate = '2017-01-07';
delete from edi.edi_import_tracking where feedid = 'BA3LM_ImportBilling' and trackingdate = '2017-01-07';
select transaction_originate from pspay_input_transaction group by 1;
select * from pspay_input_transaction where transaction_originate = 'BA3LM_ImportBilling' and effectivedate = '2017-01-07';
delete from pspay_input_transaction where transaction_originate = 'BA3LM_ImportBilling' and effectivedate = '2017-01-07';

select check_date::date from pspay_payment_detail where date_part('year',check_date) = '2017'  group by 1 order by 1;

select * from pspay_input_transaction where transaction_originate = 'Kudos Import'  and effectivedate = '2016-12-10';

select transaction_originate from pspay_input_transaction where transaction_originate like 'HMN%'  group by 1;



delete from pspay_input_transaction where transaction_originate like 'HMN%' and current_date = last_updt_dt::date ;
select * from pspay_input_transaction where transaction_originate like 'HMN%'  and current_date = last_updt_dt::date 
and primary_key_idd_name in ('DNEK') ;  
--and primary_key_idd_name in ('DA65','DN65') ;   -- and effectivedate = '2016-12-10';

delete from pspay_input_transaction where transaction_originate like 'HMN Benefits%' and current_date = last_updt_dt::date;   -- and effectivedate = '2016-12-10';

--- Note edi.edi_import_tracking does not get updated if kettle is using the batchDetailEdi
-- To back out import for scripts like kudos import you need to delete from batch_header, batch_detail and pspay_input_transaction

select feedid from edi.edi_import_tracking where trackingdate = '2017-01-07' group by 1;
SELECT * FROM Batch_header where batchnotes like 'HMN%';
SELECT * FROM Batch_detail where batchheaderid = '64';
(SELECT batchheaderid FROM Batch_header where effectivedate = '2016-12-10' and batchnotes = 'Kudos Import');

select batchnotes from Batch_header group by 1;

select transaction_originate from pspay_input_transaction group by 1;
select * from pspay_input_transaction where transaction_originate = 'BA3LM_ImportBilling ' and effectivedate = '2017-01-07';
select max(effectivedate) from pspay_input_transaction where transaction_originate = 'BA3LM_ImportBilling ';

delete FROM Batch_detail where effectivedate = '2016-12-10' and batchheaderid in 
(SELECT batchheaderid FROM Batch_header where effectivedate = '2017-01-07' and batchnotes like 'HMN%');





delete FROM Batch_header where effectivedate = '2016-12-10' and batchnotes = 'Kudos Import'



delete from pspay_input_transaction where transaction_originate = 'BA3LM_ImportBilling ' and effectivedate = '2017-01-07';
select * from pspay_input_transaction where transaction_originate = 'BA3LM_ImportBilling ' and effectivedate = '2017-01-07';
--- edi.edi_import_tracking 


/*
so far those Metlife and Liberty mutual feeds are the only ones that need edi.edi_import_tracking 
it is the export back to MetLife and LibertyMutual so kind of reporting purposes
they send the imports with tracking numbers they expect to get back 
on the confirmation feeds after the payroll deductions have been taken
*/

