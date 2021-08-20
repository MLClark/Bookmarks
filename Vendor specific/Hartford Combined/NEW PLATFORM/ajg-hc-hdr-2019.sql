select 
 '~HDR~' ::char(5) as section_code
,0 as cust_count
,'?' ::varchar(30) as file_name
,to_char(current_date,'YYYYMMDD hh:mm:ss AM/PM')::char(20) as file_create_date
,'Form Technologies' ::char(20) as cust_name
,'001.10' ::char(6) as file_version_nbr