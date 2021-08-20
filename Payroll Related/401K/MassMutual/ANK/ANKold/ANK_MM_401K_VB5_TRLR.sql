--- ANK Contribution Details
select distinct
 count(*)
,sum(ppd.etv_amount ) as totalcompanyMatchAmt

from person_identity pi


join person_identity piP 
  on piP.personid = pi.personid
 and current_timestamp between piP.createts and piP.endts
 and piP.identitytype = 'PSPID'

join pspay_payment_detail ppd 
  on ppd.individual_key = piP.identity
 and ppd.etv_id in ('VB5')
  --and ppd.etv_id in ('VB1', 'VB3', 'VB5', 'VBU', 'V65')
 --AND date_part('year', ppd.check_date) = date_part('year',now()) 
 and ppd.check_date = ?::DATE

where current_timestamp between pi.createts and pi.endts
  and pi.identitytype = 'SSN'
  and pi.personid = '86349'
  and ppd.check_date = ?::DATE 
--group by 1,2,3,4,5,6,7,8,9,10,12,14,15  
;  