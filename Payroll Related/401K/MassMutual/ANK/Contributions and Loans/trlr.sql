--- ANK Contribution Details Trailer
select distinct
 count(*) AS totalDSrowsByETV
,CASE WHEN PPD.ETV_ID = 'V65' THEN (sum(ppd.etv_amount)*100) end as totalLoanAmt
,CASE WHEN PPD.ETV_ID <> 'V65' THEN (sum(ppd.etv_amount)*100) end as totalContribAmt
,CASE WHEN PPD.ETV_ID = 'V65' THEN 'LOAN' ELSE 'CONT' END as rec
,ppd.etv_id
,elu.feedid as feedid
,elu.lastupdatets as lastupdatets

from person_identity pi

join edi.edi_last_update elu 
  on elu.feedid = 'ANK_MM_401k_Demo_HDR_Export'

join person_identity piP 
  on piP.personid = pi.personid
 and current_timestamp between piP.createts and piP.endts
 and piP.identitytype = 'PSPID'

join pspay_payment_detail ppd 
  on ppd.individual_key = piP.identity
 and ppd.etv_id in ('VB1','VB3','VB5','V65')
  --and ppd.etv_id in ('VB1', 'VB3', 'VB5', 'VBU', 'V65')
 --AND date_part('year', ppd.check_date) = date_part('year',now()) 
 and ppd.check_date = ?::DATE

where current_timestamp between pi.createts and pi.endts
  and pi.identitytype = 'SSN'
  and ppd.check_date = ?::DATE 
group by 4,5,6
; 