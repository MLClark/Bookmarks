select 
 pi.personid
,pay.gross as lastcheckamt_gross
,pn.lname as lname
,pn.fname as fname
,cn.companycode as compcode
,to_char(pv.birthdate,'MM/DD/YYYY') as dob
,pie.identity as empno
,replace(pa.streetaddress,',','') as addr1
,replace(pa.streetaddress2,',','') as addr2
,pa.city as city
,pa.stateprovincecode as state
,pa.postalcode ::char(5) as zip
,coalesce(pncw.url,pnch.url,pnco.url) as email
,pi.identity as ssn
,pc.compamount as pay_amount
,case when pc.frequencycode = 'A' then 'Annual Salary' 
      when pc.frequencycode = 'H' then 'Hourly Rate' 
      else ' ' end as paytype
,case when ppos.schedulefrequency = 'W' then 'Weekly'
      when ppos.schedulefrequency = 'B' then 'Bi Weekly'
      when ppos.schedulefrequency = 'S' then 'Semi-Monthly'
      when ppos.schedulefrequency = 'M' then 'Monthly'
      else ' ' end as paycycle
,to_char(pe.empllasthiredate,'MM/DD/YYYY') as hiredate
,case when pe.emplclass = 'F' then 'Full Time' 
      when pe.emplclass in ('P','N','O','T','C','X','B') then 'Part Time' 
      else ' ' end as empltype
,case when pe.emplstatus in ('A') then 'Active'
      when pe.emplstatus not in ('A') then 'Terminated' --- Any EE not active are considered as terminated even those on leave
      else ' ' end as emplstatus
,case when pe.emplstatus in ('R','T') then to_char(pe.effectivedate,'MM/DD/YYYY') else ' ' end as termdate
,to_char(pay.check_date,'MM/DD/YYYY') as lastcheckdate
,pay.gross as lastcheckamt
,elu.lastupdatets

 
from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'FinFit_Demographic_File' 
--select * from edi.edi_last_update 

join ( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname in ('FinFit_Demographic_File')
      ) lkups on 1 = 1

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
  
left join person_net_contacts pncw
  on pncw.personid = pi.personid
 and pncw.netcontacttype = 'WRK'::bpchar
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate
 
left join person_net_contacts pnch
  on pnch.personid = pi.personid
 and pnch.netcontacttype = 'HomeEmail'::bpchar
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate

left join person_net_contacts pnco
  on pnco.personid = pi.personid
 and pnco.netcontacttype = 'OtherEmail'::bpchar
 and current_date between pnco.effectivedate and pnco.enddate
 and current_timestamp between pnco.createts and pnco.enddate
  
join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1  
            
left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos  where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) ppos on ppos.personid = pe.personid and ppos.rank = 1             
            
 
left join 
(select companyname, companycode FROM companyname cn
 WHERE current_date between cn.effectivedate and cn.enddate AND current_timestamp between cn.createts and cn.endts AND (NOT (cn.companyid IN ( SELECT company_usage.companyid
           FROM company_usage WHERE company_usage.companyusage = 'Vendor'::bpchar)) AND NOT (cn.companyid IN ( SELECT payee.payeeid FROM payee WHERE payee.payeeid = cn.companyid)) 
           OR (EXISTS ( SELECT 1 FROM pay_unit pu   WHERE pu.companyid = cn.companyid))) AND cn.ispayee <> 'Y'::bpchar ) cn on 1 = 1


-----------------
-- wage_amount --
-----------------
left join 
(
select x.personid, sum(x.gross) as gross,MAX(x.check_date) AS check_date, RANK() OVER (PARTITION BY personid ORDER BY MAX(check_date) DESC) AS RANK 
from 
(

select 
ppd.personid
,ppd.check_date::date
,pph.gross_pay as gross
from pspay_payment_detail ppd
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
join pay_schedule_period psp  on psp.payscheduleperiodid = pph.payscheduleperiodid and psp.payrolltypeid = 1 ----- NORMAL
where pph.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay --join edi.edi_last_update elu  on elu.feedid =  'FinFit_Demographic_File' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) 
                             group by ppd.personid, ppd.check_date, pph.gross_pay, pph.net_pay, pph.paymentheaderid order by ppd.personid) x  group by x.personid, x.check_date)
                              pay on pay.personid = pi.personid  and pay.rank = 1
      
      
      


                                                            
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus in ('A') 
   or (pe.emplstatus not in ('A') and pe.createts >= elu.lastupdatets))  --- Any EE not active are considered as terminated even those on leave
  
  
  --and pi.personid = '9635'
  
  order by personid, empno