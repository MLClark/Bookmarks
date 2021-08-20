 SELECT 
 bh.batchheaderid
,count(distinct pea.etv_id) as  CNTRLTRX 
,count(distinct bd.personid) as CTRLEMPCT


        
        
FROM batch_header bh

JOIN batch_detail bd 
  ON bd.batchheaderid = bh.batchheaderid 
 AND current_date between bd.effectivedate and bd.enddate 
 AND current_timestamp between bd.createts AND bd.endts
 
JOIN person_payroll ppay 
  ON ppay.personid = bd.personid 
 AND bd.effectivedate >= ppay.effectivedate 
 AND bd.effectivedate <= ppay.enddate 
 AND current_timestamp between ppay.createts and ppay.endts 
 AND ppay.payunitrelationship = 'M'::bpchar
 
JOIN pers_pos pp 
  ON pp.personid = bd.personid 
 AND bd.effectivedate >= pp.effectivedate 
 AND bd.effectivedate <= pp.enddate 
 AND current_timestamp between pp.createts AND pp.endts 
 AND pp.persposrel = 'Occupies'::bpchar
 
join person_identity pi 
  on pi.personid = pp.personid
 and pi.identitytype = 'EmpNo'
 and current_timestamp between pi.createts and pi.endts
 
join person_identity pip
  on pip.personid = pp.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts 
 

join pspay_earning_accumulators pea
  on pea.individual_key = pip.identity
 and pea.year = '2017'
  

JOIN pay_schedule_period psp 
  ON psp.payscheduleperiodid = bh.payscheduleperiodid
 and psp.periodstartdate >= '2017-11-15'


WHERE current_date between bh.effectivedate and bh.enddate 
  AND current_timestamp between bh.createts AND bh.endts
  --and psp.periodpaydate = ?
  AND bd.personid = '4061'
  group by 1
  
  ;
  select * from batch_header