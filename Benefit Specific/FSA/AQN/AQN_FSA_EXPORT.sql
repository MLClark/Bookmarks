select 
 'FH' ::char(2) as record_type
,'IFS' ::char(3) as admin_code
,'4A3103' ::char(6) as employer_code
,'N' ::char(1) as sync_flag
,to_char(current_date,'MMYYDDD') ::char(8) as sub_date
,cast(date_part('hour', current_timestamp) as char(2))||cast(date_part('minute',current_timestamp) as char(2))||cast(date_part('second',current_timestamp) as char(2))::char(6) as sub_time
,'1.0' ::char(1) as file_version