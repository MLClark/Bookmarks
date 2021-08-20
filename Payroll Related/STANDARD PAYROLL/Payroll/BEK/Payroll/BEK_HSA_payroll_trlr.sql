select 
 '3' ::char(1) as sort_seq
,'T' ::char(1) as record_indicator
,to_char(count(distinct ppd.personid),'FM0000000000') ::char(10) as record_count
,to_char(sum(ppd.etv_amount),'FM000000000D00') ::char(12) as total_contributions

from person_identity pi
  
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 and pe.emplstatus in ('T','A')
 
join pspay_payment_detail ppd
  on ppd.personid = pe.personid
 and ppd.check_date::date = ?::date
 and ppd.etv_id in ('VEI','VEH')  
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  
group by 1