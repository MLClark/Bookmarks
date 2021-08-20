select
 'DMTR' ::char(4) as recordType4
,'0001' ::char(4) as recordVersionNbr4
,'061654' ::char(6) as masterContactNbr6
,elu.feedid as feedid
,elu.lastupdatets  as lastupdatets

,count(pi.personid) as totDetail12


from person_identity pi
join edi.edi_last_update elu on elu.feedid = 'ANK_MM_401k_Demo_HDR_Export'

join person_identity piP 
  on piP.personid = pi.personid
 and current_timestamp between piP.createts and piP.endts
 and piP.identitytype = 'PSPID' 
 
join 
(select ppd.individual_key from pspay_payment_detail ppd
  where ppd.etv_id IN ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')
 AND ppd.check_date = ?::DATE
 group by 1) ppd
 on ppd.individual_key = piP.identity 
     
where current_date between pi.createts and pi.endts 
  and pi.identitytype = 'SSN'

group by 1,2,3,4,5
;