select 
 'A' ::char(1) as record_type
,'0102570' ::char(7) as customer_number --2
,to_char(current_date,'MMDDYYYY')::char(8) as file_create_date
,'HORACE MANN SERVICE CORPORATION' ::char(50) as customer_name
,'N' ::char(1) as change_only_ind