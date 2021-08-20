select individual_key, effectivedate, primary_key_idd_name
, tran_data, 
lpad(tran_data, 9, '0'),position( '.' in tran_data),
lpad( substring(tran_data, 1, position( '.' in tran_data)-1) || right(tran_data, length(tran_data)  -position( '.' in tran_data)), 9, '0')
, transaction_originate, last_updt_dt
from pspay_input_transaction where primary_key_idd_name in ('DN40','EN70','DN43','DN65','DA65' ) and last_updt_dt > '2017-07-21 18:00:00' order by individual_key limit 100 