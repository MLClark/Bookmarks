select * from pspay_etv_list;
select * from pspay_payment_detail 
where etv_id in ('VEI','VEH')
and CHECK_DATE = '2018-03-15'
;