select distinct
 pi.personid 
,'2' ::char(1) as sort_seq
,'DEPOSIT' ::char(7) as record_type
,'146534' ::char(7) as employer_id
,pi.identity ::char(9) as member_number 
,' ' ::char(10) as plan_year_eff_date
,'16' ::char(2) as account_type 
,'3' ::char(1) as deposit_type
,ppd.etv_id
,ppd.etv_amount as deposit_amount
,to_char(ppd.check_date,'MM/DD/YYYY')::char(10) as deposit_date
,to_char(ppd.etv_amount, 'FM00000d00 ') ::char(8) as deposit_amount_char
,date_part('year',ppd.check_date) ::char(4) as tax_year
 
from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 --and pe.emplstatus <> 'T'

join person_bene_election pbe
  on pbe.personid = pe.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'   
 and pbe.benefitsubclass in ('6Z')

join pspay_payment_detail ppd
  on ppd.personid = pe.personid
 and ppd.check_date::date = ?::date
 and ppd.etv_id in ('VEI','VEH') 


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts