select distinct
 pi.personid
,pip.identity
,'n' ::char(1) as emplstatus
,'NON PARTICIPATIONING EE' ::varchar(50) as qsource
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(15) as ssn
,pn.fname ||' '||coalesce(pn.mname,'')||' '||pn.lname ::char(40) as ee_name

,'0' ::char(1) as key_rank --- for row denormaliser step
                      

,0.00 as contrib_amt
      
      
,' '::char(1) as contrib_code
            

      
from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_employment pe
  on pe.personid = pi.personid
 and pe.effectivedate < pe.enddate
 and current_timestamp between pe.createts and pe.endts 

where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  and pi.personid not in 
 (select distinct ppd.personid as personid 
    from person_identity pi

    join pay_schedule_period psp 
      on psp.payrolltypeid in (1,2)
     and psp.processfinaldate is not null
     and psp.periodpaydate = ?::date

    join pspay_payment_header pph
      on pph.check_date = psp.periodpaydate
     and pph.payscheduleperiodid = psp.payscheduleperiodid 
 
    join pspay_payment_detail ppd 
      on ppd.personid = pi.personid
     and ppd.check_date = psp.periodpaydate
     and pph.paymentheaderid = ppd.paymentheaderid

    where pi.identitytype = 'SSN'::bpchar 
      and current_timestamp between pi.createts and pi.endts and ppd.etv_id  in  ('VB1','VBU','VB2','V65','VBT','VB5','VB3','VB4')
    group by 1) 
  
  order by 2
  