select 
 'H' ::char(1) as hdr_id
,'PYRL' ::char(4) as file_type
,to_char(psp.periodpaydate,'YYYYMMDD')::char(8) as post_date
,'Horace Mann-GENESYS' ::char(20) as source_name
,'09878' ::char(5) as client_id

from pay_schedule_period psp

where psp.periodpaydate = ?::date