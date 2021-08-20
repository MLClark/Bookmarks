select distinct
 '1' ::char(1) as sort_seq
,'H' ::char(1) as record_indicator
,'F' ::char(1) as format_type
,'D' ::char(1) as layout_type
,to_char(current_date,'YYYYMMDD')::char(8) as date_created
,to_char(current_timestamp,'HHMMSS')::char(6) as time_created
,'146534' ::char(7) as employer_id
,'MedSource' ::char(50) as employer_name
,' ' ::char(25) as memo
,' ' ::char(9) as layout_version
,'F' ::char(1) as online_enrollment
,'F' ::char(1) as online_commuter
,'T' ::char(1) as change_only