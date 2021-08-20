select 
 ' ' ::char(48) as hdr1_filler
,'HEADER RECORD' ::char(13) as record_type
,' ' ::char(1) as hdr3_filler
,'715621' ::char(8) as client_job_nbr  ----????
,' ' ::char(1) as hdr5_filler
,to_char(current_date,'YYYYMMDD') ::char(8) as file_create_date
,' ' ::char(355) as hd7_filler