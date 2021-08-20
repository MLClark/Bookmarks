select
'A' ::char(1)
,' ' ::char(24) as payer_name
,'Peoples Community Clinic' ::char(24) as er_group_name
,to_char(current_date,'YYYYMMDD')::char(8) as posting_date
,' ' ::char(511) as filler511

