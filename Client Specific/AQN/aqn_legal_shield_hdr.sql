select
 'H' ::char(1) as record_type
,to_char(current_date,'YYYY-MM-DD')::char(10) as file_date
,'Peoples Community Clinic' ::char(25) as transmitter_name