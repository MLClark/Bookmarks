select
 bh.batchheaderid ::char(15) as BACHNUMB
,'1' ::char(2) as UPRBCHOR
,pu.payunitdesc ::char(60) as BCHCOMNT
,'3' ::char(2) as UPRBCHFR
,to_char(bh.effectivedate,'yyyy/mm/dd') ::char(10) as POSTEDDT
,0000   as CNTRLTRX
,00   as CTRLEMPCT
,'0' ::char(1) as UpdateIfExists
,'0' ::char(2) as RequesterTrx
,' ' ::char(50) as USRDEFND1
,' ' ::char(50) as USRDEFND2
,' ' ::char(50) as USRDEFND3
,' ' ::char(1) as USRDEFND4
,' ' ::char(1) as USRDEFND5
,bh.payscheduleperiodid
,bh.payunitid
,?::date

FROM batch_header bh

JOIN pay_schedule_period psp 
  on psp.payscheduleperiodid = bh.payscheduleperiodid
 and psp.periodpaydate = ?::date

JOIN pay_unit pu 
  ON pu.payunitid = bh.payunitid  
  
-- select * from pay_unit  
     
WHERE current_date between bh.effectivedate and bh.enddate 
  AND current_timestamp between bh.createts AND bh.endts
  and bh.enddate = '2199-12-31'
  and pu.payunitxid in ('20');
