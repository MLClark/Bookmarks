SELECT
 pi.personid
,pi.identity  ::char(9) as pi_ssn
,pie.identity ::char(9) as empnbr
,pib.identity ::char(9) as badgeid
,pip.identity ::char(9) as pspid
,substring(pip.identity from 1 for 5)::char(5) as groupno
,npdate.payunitid ::char(2) as payunitid
,pn.fname ::varchar(50) as fname
,pn.lname ::varchar(50) as lname
,pn.mname ::char(1) as mname
,logid ::char(4) as logid
,to_char(npdate.periodenddate,'mm/dd/yyyy')::char(10) as next_periodenddate


from person_identity pi

cross join ( select 1234::int  as logid )l

left join person_identity pie
  on pie.personid = pi.personid
 and current_timestamp between pie.createts and pie.endts
 and pie.identitytype = 'EmpNo'

left join person_identity pib
  on pib.personid = pi.personid
 and current_timestamp between pib.createts and pib.endts
 and pib.identitytype = 'Badge'
 
left join person_identity pip
  on pip.personid = pi.personid
 and current_timestamp between pip.createts and pip.endts
 and pip.identitytype = 'PSPID' 
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 and pe.effectivedate - interval '1 day' <> pe.enddate
 
left JOIN person_names pn
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

join person_payroll ppy on ppy.personid = pi.personid and current_date between ppy.effectivedate and ppy.enddate and current_timestamp between ppy.createts and ppy.endts

join (select payscheduleperiodid, psp.payunitid, periodstartdate, periodenddate, periodpaydate
        from pay_schedule_period psp
        join (Select payunitid, min(periodpaydate) lastpaydate 
                from pay_schedule_period where periodpaydate > ?::DATE and payrolltypeid = 1 group by payunitid ) as ppd on ppd.payunitid = psp.payunitid and ppd.lastpaydate = psp.periodpaydate
               where payrolltypeid = 1 ) npdate on npdate.payunitid = ppy.payunitid
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
order by badgeid