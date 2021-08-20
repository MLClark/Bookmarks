select 
 pi.personid
,pu.payunitxid
,pi.identity as ssn --A
,case when pn.mname is not null then (pn.fname||' '||pn.lname||' '||coalesce(pn.mname::char(1),''))
      else pn.fname||' '||pn.lname end ::char(30) as fullname --B
,replace(pa.streetaddress,',','')  ::char(40) as addr1 --C 
,replace(pa.streetaddress2,',','') ::char(40) as addr2 --D
,pa.city ::char(28) as city --E
,pa.stateprovincecode ::char(2) as state --F
,pa.postalcode as zip --G
,pu.payunitxid as division --H
,to_char(pv.birthdate,'yyyymmdd')::char(8) as dob --I
,to_char(pe.emplhiredate,'yyyymmdd')::char(8) as orig_doh --J
,'' as doe --K
,case when pe.emplhiredate <> empllasthiredate then to_char(pe.empllasthiredate,'mm/dd/yyyy') else ' ' end ::char(10) as rehire_date --L
,case when pe.emplstatus in ('T','R','D') then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date --M
,to_char(cpp.hours,'00.000000') ::char(10)  as cpp_hour --N
,to_char(dedamt.gross_pay,'00000000d00') as cpp_gross --O payment header gross
,to_char(cpp.gross,'00000000d00') as cpp_excluded_comp --P (sum up wages included in paycode relationship '401kHrs')
,dedamt.vb1_amount + dedamt.vb2_amount as cpp_ee_def --Q
,dedamt.vb3_amount + dedamt.vb4_amount as cpp_roth_def --R
,dedamt.vb5_amount as cpp_er_match --S
,0.00 as cpp_er_desc --T
,0.00 as cpp_after_tax --U
,0.00 as cpp_safe_harbor_ps --V (profit sharing)
,0.00 as cpp_safe_harbor_mtch --W
,0.00 as cpp_pension --X
,coalesce(dedamt.v65_amount,dedamt.v31_amount,dedamt.v73_amount,0.00) as cpp_loan --Y
--Enter the employee’s payroll frequency.  7=Weekly, 6=Bi-Weekly, 5=Semi-Monthly, 4=Monthly
,case when pp.schedulefrequency = 'S' then '5' 
      when pp.schedulefrequency = 'W' then '7' 
      when pp.schedulefrequency = 'B' then '6'
      when pp.schedulefrequency = 'M' then '4' end as payroll_freq --Z
,pncw.url as email_addr --AA
,to_char(dedamt.check_date,'yyyymmdd')::char(8) as payroll_date --- for trailer record
,to_char(current_date,'yyyymmdd')::char(8) as currentdate --- for file splitter
,elu.lastupdatets
,'CCB' as client
,dedamt.vb1_amount
,dedamt.vb2_amount
,dedamt.vb3_amount
,dedamt.vb4_amount
,dedamt.vb5_amount
,dedamt.v65_amount
,dedamt.v31_amount
,dedamt.v73_amount
 
from person_identity pi

join edi.edi_last_update elu  on elu.feedid = 'CCB_Alerus_401K_Export' 

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_payroll ppay
  on ppay.personid = pi.personid
 and current_date between ppay.effectivedate and ppay.enddate
 and current_timestamp between ppay.createts and ppay.endts 
 
left join  (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
              from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
             group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pi.personid and pp.rank = 1 

left join person_net_contacts pncw 
  on pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate  
  
left join pay_unit pu
  on pu.payunitid = ppay.payunitid
 and current_timestamp between pu.createts and pu.endts 

--------------------
-- dedamt         --
--------------------
join 
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.v65_amount) as v65_amount
,sum(x.v73_amount) as v73_amount
,sum(x.v31_amount) as v31_amount
,x.gross_pay  as gross_pay
,sum(x.vb1_amount+x.vb2_amount+x.vb3_amount+x.vb4_amount+x.vb5_amount+x.v65_amount+x.v73_amount+x.v31_amount) as total_401k

from

(select 
ppd.personid
,ppd.check_date
,case when ppd.paycode = 'VB1' then amount  else 0 end as vb1_amount
,case when ppd.paycode = 'VB2' then amount  else 0 end as vb2_amount
,case when ppd.paycode = 'VB3' then amount  else 0 end as vb3_amount
,case when ppd.paycode = 'VB4' then amount  else 0 end as vb4_amount
,case when ppd.paycode = 'VB5' then amount  else 0 end as vb5_amount
,case when ppd.paycode = 'V65' then amount  else 0 end as v65_amount
,case when ppd.paycode = 'V73' then amount  else 0 end as v73_amount
,case when ppd.paycode = 'V31' then amount  else 0 end as v31_amount
,pph.gross_pay

from PAYROLL.payment_detail ppd
join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
where pph.paymentheaderid in 
        (select paymentheaderid from PAYROLL.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu  on elu.feedid = 'CCB_Alerus_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.paycode  in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31')) x
group by personid, check_date, gross_pay having sum(x.vb1_amount + x.vb2_amount + vb3_amount + vb4_amount + vb5_amount + v65_amount + x.v73_amount + x.v31_amount) <> 0) dedamt on dedamt.personid = pi.personid  

---------------------------------------
-- cpp  - current pp wages and hours --
---------------------------------------
left join 
(select wh.personid, wh.check_date, sum(wh.units) as hours, sum(wh.amount) as gross
   from    
       (select distinct
              ppd.personid
             ,ppd.amount
             ,ppd.check_date
             ,ppd.paymentheaderid
             ,ppd.units
             from PAYROLL.payment_detail ppd
             where ppd.paymentheaderid in (select paymentheaderid from PAYROLL.payment_header 
             where payscheduleperiodid in (select payscheduleperiodid from pspay_payroll_pay_sch_periods 
             where pspaypayrollid in (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'CCB_Alerus_401K_Export' and elu.lastupdatets < ppay.statusdate where ppay.pspaypayrollstatusid = 4 ))) 
               and ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode)
       ) wh group by personid, check_date order by personid
) cpp on cpp.personid = pi.personid and cpp.check_date = dedamt.check_date  

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pi.personid in ('1161')
  
  order by personid