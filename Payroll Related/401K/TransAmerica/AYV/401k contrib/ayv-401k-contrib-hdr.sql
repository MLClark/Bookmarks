select distinct
 '01' ::char(2) as recordtype
,'PeopleStrategy' ::char(30) as vendorname 
,to_char(current_timestamp,'YYYYMMDDhhmmss')::char(14) as file_create_dt
--,'222224' ::char(9) as contractid
,'809180' ::char(9) as contractid
,'00000' ::char(5) as subid
,'0' ::char(1) as ismep
,'Strategic Link' ::char(40) as company_name
,to_char(?::date,'yyyymmdd') ::char(8) as check_date
,cast(sum(etv_amount) as dec(12,2)) as total_payroll_amount
,cast(sum(etv_amount) as dec(12,2)) as deposit_amount
,'0' ::char(1) as deposit_method
,' ' ::char(26) as ach_number
,' ' ::char(8) as mode --- validate for test blank for prod
from pspay_payment_detail
where etv_id in ('V65','V66','VB1','VB2','VB3','VB4','VB5')
and check_date = ?::date
group by 1,2,3,4,5,6,7,8