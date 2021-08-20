select distinct
 lkup.value1  ::varchar(19) as client_id
,to_char(current_date,'yyyymmdd') ::char(8) as create_date
,to_char(current_timestamp,'hhmm')::char(4) as create_time
,'FF' ::char(2) as file_type
,0   as record_count
,'Y' ::char(1) as safeguard_usage
,'Y' ::char(1) as auto_approve_benefits
,'2' ::char(1) as log_id_method
,'""' ::char(1) as password_method
,'V8' ::char(2) as version

 from edi.lookup lkup
 join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid
  and current_date between lkups.effectivedate and lkups.enddate
where current_date between lkup.effectivedate and lkup.enddate
  and lkups.lookupname = 'BAC_Benefitfocus_Demographic_Export'
