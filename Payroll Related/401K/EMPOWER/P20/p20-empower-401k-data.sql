select distinct
 pi.personid
,lkup_plan.client
--,pe.emplstatus
--,pe.effectivedate 
,elu.lastupdatets
,lkup_plan.value1 ::char(13) as plan_number
,pi.identity ::char(11) as ssn 
--,pu.payunitxid
--,lkup_div.key2
,lkup_div.value1 ::char(20) as div_nbr
,pn.lname ::char(35) as lname
,pn.fname ::char(20) as fname
,pn.mname ::char(20) as mname
,pn.title ::char(15) as suffix
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,pv.gendercode ::char(1) as gender
,case when pm.maritalstatus in ('M','R','C') then 'M'
      when pm.maritalstatus in ('D','P') then 'D'
      when pm.maritalstatus in ('W') then 'W'
      when pm.maritalstatus in ('S') then 'S' else ' ' end ::char(1) as marital_status
,pa.streetaddress ::char(35) as addr1
,pa.streetaddress2 ::char(35) as addr2
,pa.city ::char(20) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(10) as zip
,ppch.phoneno ::char(10) as home_phone
,ppcw.phoneno ::char(10) as work_phone
,' ' ::char(4) as work_ext
,case when pa.countrycode = 'US' then ' ' else pa.countrycode end ::char(2) as country_code
,to_char(pe.emplhiredate,'mm/dd/yyyy')::char(10) as hire_date

,case when pe.emplstatus in ('T','R','D') then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date
,case when pe.emplhiredate <> empllasthiredate then to_char(pe.empllasthiredate,'mm/dd/yyyy') else ' ' end ::char(10) as rehire_date
,to_char(dedamt.check_date,'mm/dd/yyyy')::char(10) as check_date

,case when (dedamt.vb1_amount + dedamt.vb2_amount) < 0 then  to_char(coalesce((dedamt.vb1_amount + dedamt.vb2_amount),0),'FM000000D00') else  to_char(coalesce((dedamt.vb1_amount + dedamt.vb2_amount),0),'FM0000000D00') end ::char(10) as contrib1
,case when dedamt.vb5_amount < 0 then to_char(coalesce(dedamt.vb5_amount,0),'FM000000D00') else to_char(coalesce(dedamt.vb5_amount,0),'FM0000000D00') end ::char(10) as contrib2
,case when dedamt.v65_amount < 0 then to_char(coalesce(dedamt.v65_amount,0),'FM000000D00') else to_char(coalesce(dedamt.v65_amount,0),'FM0000000D00') end ::char(10) as contrib3
,case when (dedamt.vb3_amount + dedamt.vb4_amount) < 0 then to_char(coalesce((dedamt.vb3_amount + dedamt.vb4_amount),0),'FM000000D00') else to_char(coalesce((dedamt.vb3_amount + dedamt.vb4_amount),0),'FM0000000D00') end ::char(10) as contrib4

,to_char(0,'FM0000000D00')::char(10) as contrib5
,to_char(0,'FM0000000D00')::char(10) as contrib6
,to_char(0,'FM0000000D00')::char(10) as contrib7
,to_char(0,'FM0000000D00')::char(10) as contrib8
,to_char(ytd.hours,'FM00000')::char(5) as ytd_hours

,to_char(ytd.amount,'FM00000000D00')::char(11) as ytd_gross

,to_char(ytd401k.subject_wages,'FM00000000D00')::char(11) as ytd_401k_wages

,' ' ::char(11) as ytd_preentry_comp
,' ' ::char(1) as highly_comp_indv
,' ' ::char(6) as pct_of_ownership
,' ' ::char(1) as officer
,' ' ::char(10) as participation_date
,' ' ::char(1) as elig_code
,' ' ::char(1) as filler_451_452
,' ' ::char(1) as loa_reason_code
,' ' ::char(10) as loa_start_date
,' ' ::char(10) as loa_end_date
,pncw.url ::char(80) as work_email
,to_char(pc.compamount,'FM00000000000000D00')::char(17) as salary
,pc.frequencycode ::char(2) as salary_freq
,' ' ::char(20) as term_rsn_cd
,' ' ::char(1) as sars_ox_cd
,' ' ::char(6) as filler_594_599
,' ' ::char(2) as fed_exempt
,pie.identity ::char(10) as empno
,' ' ::char(6) as comp_status_code
,pnch.url ::char(80) as home_email
,ppcm.phoneno ::char(10) as cell_phone
,to_char(current_date,'yyyy-mm-dd') as currentdate
,to_char(dedamt.check_date,'yyyy-mm-dd') as checkdate
,dedamt.vb1_amount
,dedamt.vb2_amount
,dedamt.vb3_amount
,dedamt.vb4_amount
,dedamt.vb5_amount
,dedamt.v65_amount
,dedamt.v73_amount
,dedamt.v31_amount


from person_identity pi

join edi.edi_last_update elu  on elu.feedid =  'Empower 401k Plan Number Lookup' 

join ( select lkups.valcoldesc1 as client,lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkup_plan on lkup_plan.lookupname  in ('Empower 401k Plan Number Lookup') and lkup_plan.key1 = 'PlanNumber'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_identity pie
  on pie.personid = pe.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
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

left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and ppch.phonecontacttype = 'Home'  
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 

left join person_phone_contacts ppcw 
  on ppcw.personid = pi.personid
 and ppcw.phonecontacttype = 'Work'    
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 
left JOIN person_phone_contacts ppcb 
  on ppcb.personid = pi.personid
 and ppcb.phonecontacttype = 'BUSN'     
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts   
 
left join person_phone_contacts ppcm 
  on ppcm.personid = pi.personid
 and ppcm.phonecontacttype = 'Mobile'    
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 

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

left join ( select personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
              from person_compensation where effectivedate < enddate and current_timestamp between createts and endts  
             group by personid, compamount, increaseamount, compevent, frequencycode, earningscode) as pc on pc.personid = pi.personid and pc.rank = 1   
 

left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts

left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 
 
left join person_payroll ppay
  on ppay.personid = pi.personid
 and current_date between ppay.effectivedate AND ppay.enddate
 and current_timestamp between ppay.createts AND ppay.endts 
 
left join pay_unit pu
  on pu.payunitid = ppay.payunitid
 and current_timestamp between pu.createts and pu.endts 

left join ( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkup_div on lkup_div.lookupname  in ('Empower 401k Plan Number Lookup') and lkup_div.key1 = 'DivNbr' and lkup_div.key2 = pu.payunitxid

------------
-- dedamt --
------------
left join 
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

,x.payscheduleperiodid
,sum(x.vb1_amount+x.vb2_amount+x.vb3_amount+x.vb4_amount+x.vb5_amount+x.v65_amount+x.v73_amount+x.v31_amount) as total_401k
from
(select distinct
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
,ppd.paymentheaderid
,pph.payscheduleperiodid
from PAYROLL.payment_detail ppd
join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid

where pph.paymentheaderid in 
        (select paymentheaderid from PAYROLL.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu  on elu.feedid =  'Empower 401k Plan Number Lookup' and elu.lastupdatets<= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.paycode  in  ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31')) x
  group by 1,2,payscheduleperiodid  having sum(x.vb1_amount + x.vb2_amount + vb3_amount + vb4_amount + vb5_amount + v65_amount + x.v73_amount + x.v31_amount) <> 0) 
        dedamt on dedamt.personid = pi.personid  

-----------------------------------
-- wage_amount -- -- total_hours -- 
-----------------------------------
left join 
(SELECT wh.personid, wh.check_date, sum(wh.units_ytd) as hours, sum(wh.amount_ytd) as amount
   from    
       (Select distinct
              ppd.personid
             ,ppd.amount_ytd 
             ,ppd.check_date
             ,ppd.paymentheaderid
             ,ppd.units_ytd
             from PAYROLL.payment_detail ppd
             where ppd.paymentheaderid in (select paymentheaderid from PAYROLL.payment_header 
             where payscheduleperiodid in (select payscheduleperiodid from pspay_payroll_pay_sch_periods 
             where pspaypayrollid in (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid =  'Empower 401k Plan Number Lookup' and date_part('year',elu.lastupdatets) >= date_part('year',ppay.statusdate) where ppay.pspaypayrollstatusid = 4 ))) 
               and ppd.paycode in (select a.paycode from payroll.pay_code_relationships a where a.paycoderelationshiptype in ('401kWg') and current_date between a.effectivedate and a.enddate and current_timestamp between a.createts and a.endts group by paycode)
       ) wh group by 1,2
) ytd on ytd.personid = pi.personid and ytd.check_date = dedamt.check_date  
----------------                                          
-- 401k wages --
----------------
left join 
(SELECT distinct x.personid,sum(x.subject_wages) as subject_wages
   from    
       (Select distinct
              ppd.personid
             ,ppd.subject_wages 
             ,ppd.paycode
             ,ppd.paymentheaderid
             from PAYROLL.payment_detail ppd
             where ppd.paymentheaderid in (select paymentheaderid from PAYROLL.payment_header 
             where payscheduleperiodid in (select payscheduleperiodid from pspay_payroll_pay_sch_periods 
             where pspaypayrollid in (select pspaypayrollid from pspay_payroll ppay where ppay.pspaypayrollstatusid = 4 ))) 
               and ppd.paycode in ('VB1','VB2','VB3','VB4','VB5','V65','V73','V31')
               and date_part('year',current_date) >= date_part('year',ppd.check_date)
               and ppd.subject_wages <> 0
       ) x group by personid order by personid
) ytd401k on ytd401k.personid = pi.personid --and ytd401k.check_date = dedamt.check_date 
                                         
left join (select personid, check_date, gross_pay_ytd from pspay_payment_header) ph on ph.personid = dedamt.personid and ph.check_date = dedamt.check_date                                         

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and ((pe.emplstatus in ('C','A','M','P','I','L','Q')) or (pe.emplstatus in ('T','R','D') and date_part('year',pe.effectivedate) >= date_part('year',current_date)))
  and dedamt.check_date is not null
  order by personid, check_date