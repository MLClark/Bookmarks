SELECT 
 'FH' ::char(2) as record_type
,'OPT' ::char(3) as admin_code
,'C42029' ::char(6) as employer_code
,'N' ::char(1) as synch_flag
,to_char(current_date,'MMDDYYYY') ::char(8) as created_date
,to_char(current_timestamp,'HHMMSS')::char(6) as createTime
,'3.3' ::char(6) as file_version
,'0000000' as personid
,'0' as sort_seq