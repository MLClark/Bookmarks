--- ANK Contribution Details
select distinct
 pi.personid
,ppd.individual_key
,'CONT' ::char(4) as recordType4
,'0001' ::char(4) as recordVersionNbr4
,'061654' ::char(6) as masterContactNbr6
,'PLAN1' ::char(8) as planCode8
,'941051349' ::char(12) as sein12
,pi.identity ::char(9) as ssn9
,to_char(ppd_401k.check_date,'yyyymmdd')::char(8) as paydate8
,to_char(pph.period_begin_date,'yyyymmdd')::char(8) as payPerStartDt8
,to_char(pph.period_end_date,'yyyymmdd')::char(8) as payPerEndDt8
,'DS' ::char(5) as contribSource5
,ppd_401k.etv_amount as deferredSalaryAmt
,elu.feedid as feedid
,elu.lastupdatets as lastupdatets

from person_identity pi

join edi.edi_last_update elu 
  on elu.feedid = 'ANK_MM_401k_Demo_HDR_Export'

join edi.etl_employment_data eed 
  on eed.personid = pi.personid

join person_identity piP 
  on piP.personid = pi.personid
 and current_timestamp between piP.createts and piP.endts
 and piP.identitytype = 'PSPID'
 
JOIN person_identity piE
  on piE.personid = pi.personid
 and current_timestamp between piE.createts and piE.endts
 and piE.identitytype = 'EmpNo' 

JOIN person_names pn 
  ON pn.personid = pi.personid
 AND current_date BETWEEN pn.effectivedate AND pn.enddate
 AND current_timestamp BETWEEN pn.createts AND pn.endts      
 AND pn.enddate > now()
 
JOIN person_address pa 
  ON pa.personid = pi.personid
 AND current_date BETWEEN pa.effectivedate AND pa.enddate
 AND current_timestamp BETWEEN pa.createts AND pa.endts      
 AND pa.enddate > now()
 
JOIN person_vitals pv
  ON pv.personid = pi.personid 
 AND current_date BETWEEN pv.effectivedate AND pv.enddate
 AND current_timestamp BETWEEN pv.createts AND pv.endts    
 AND pv.enddate > now()
 
join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
join pspay_payment_detail ppd 
  on ppd.individual_key = piP.identity
 and ppd.etv_id in ('VB1')
  --and ppd.etv_id in ('VB1', 'VB3', 'VB5', 'VBU', 'V65')
 AND date_part('year', ppd.check_date) = date_part('year',now()) 
 
join pspay_payment_header pph
  on pph.individual_key = ppd.individual_key
 and pph.check_date = ?::DATE
  
JOIN pspay_payment_detail ppd_401k 
  ON ppd_401k.individual_key = ppd.individual_key
 AND ppd_401k.etv_id = 'VB1'
 AND ppd_401k.check_date = ?::DATE

where current_timestamp between pi.createts and pi.endts
  and pi.identitytype = 'SSN'
  and pi.personid = '86349'
  and ppd.check_date = ?::DATE 
--group by 1,2,3,4,5,6,7,8,9,10,12,14,15  
;  