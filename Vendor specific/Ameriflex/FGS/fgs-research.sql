select * from person_names where lname like 'Gua%';
select * from pspay_payment_detail where personid = '4787' and check_date = '2021-05-07' and etv_id  in  ('VBA','VBB','VL1','VC1','VS1','VC0','VEH','VEK','VGA');
select * from pspay_payroll where pspaypayrollstatusid = 4 ;
update edi.edi_last_update set lastupdatets = '2021-05-01 00:00:00' where feedid = 'Ameriflex_FLEX_Payroll_Deduction'

select regexp_replace('test1234test45abc', '[^0-9]+', '', 'g');

select 
 pa.personid
,pa.postalcode::char(9)
,regexp_replace('test1234test45abc', '[^0-9]+', '', 'g')
,regexp_replace(pa.postalcode, '[^0-9]+', '','g'):: char(9) as emp_zip
,regexp_replace(pa.postalcode, '[^0-9]+', ''):: char(9) as emp_zip
from person_address pa

  ;