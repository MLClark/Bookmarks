select distinct
 pi.personid
,ppd.paymentheaderid

,'comb.d' ::char(8) as census_recid
,'56554' ::char(7) as contnbr
,pi.identity ::char(9) as ssn 
,pne.fname ::varchar(18) as fname
,pne.lname ::varchar(20) as lname
,pne.mname ::varchar(1) as mname
,' ' ::char(4) as title
,pie.identity ::char(9) as EEIDnbr
,replace(pae.streetaddress,',','') ::varchar(30) as addr1
--,replace(pae.streetaddress2,',','') ::varchar(30) as addr2
,case when octet_length(pae.streetaddress2) = 1 then pae.streetaddress2||'.'
      when pae.streetaddress2 is null then '  ' 
      else replace(pae.streetaddress2,',','') 
      end ::varchar(30) as addr2
,pae.city ::varchar(25) as city
,pae.stateprovincecode ::char(2) as state
,pae.postalcode ::varchar(10) as zip
,pae.countrycode ::char(3) as country
,pae.stateprovincecode ::char(2) as stateres
,' ' ::varchar(99) as email
,div.member_organization ::varchar(25) as division
,to_char(pve.birthdate,'mmddyyyy')::char(8) as dob 
,to_char(pe.emplhiredate,'mmddyyyy')::char(8) as doh 
,pe.emplstatus ::char(1) as empstatus
----,to_char(pe.emplhiredate,'mmddyyyy')::char(8) as empl_status_date
,to_char(pe.effectivedate,'mmddyyyy')::char(8) as empl_status_date

,'Y' ::char(1) as eligind
,' ' ::char(8) as eligdate --- specs say not to map - JH will calculate
,' ' ::char(1) as optoutind
,fcpos.annualfactor
,pp.scheduledhours
--,pdx.distinctpayperiods
--, case when pc.personid is not null then cast(((pp.scheduledhours * fcpos.annualfactor)/ fcpay.annualfactor) * pdx.distinctpayperiods as dec (18,2))
--                else pdx.workedhours end as hours
,0 as hours
--,ytdhw.hours as hours
,pdx.workedhours
,ytdcomp.taxable_wage as PlanYTD401KCompAmt            -- col AP Gross wages (excluding GTL & LTD Prem)
,to_char(coalesce(ppd.check_date,pspdate.periodpaydate),'MMDDYYYY') ::char(8)  as ytd_hrs_wk_comp_dt
,case when pc.frequencycode = 'A' then pc.compamount
      when pc.frequencycode = 'H' then (pc.compamount * 2080 ) end as annualSalary                  -- col AR

,' ' ::char(7) as BfTxDefPct
,' ' ::char(9) as BfTxFltDoDef   
,' ' ::char(7) as DesigRothPct
,ppdvb3.etv_amount as DesigRothAmt
,'505' ::char(3) as transnbr
,to_char(coalesce(pph.period_end_date,pspdate.periodenddate),'mmddyyyy')::char(8) as period_end_date

,ppdvb1.etv_amount
,ppdvb2.etv_amount


,ppdvb1.etv_amount+ppdvb2.etv_amount as eedef           -- col AY should have the PreTax EE Catchup Amount (per pay)
,ppdvb5.etv_amount as ermat -- employer match
,' ' ::char(9) as qmac                      


,ppdvb5.etv_amount as shmac               -- col BC as safeharborMatch the per pay Company Match amount  
,' ' ::char(9) as ermc3
,' ' ::char(9) as eerot
,' ' ::char(9) as qnec
,' ' ::char(9) as shnec
,' ' ::char(9) as erps -- employer profit sharing contribution
,' ' ::char(9) as eerc -- employee roll over contributions
,' ' ::char(9) as eevnd -- employee voluntary non-deductible contributions
,' ' ::char(9) as eevd -- employee voluntary deductible contributions
,' ' ::char(9) as eeman -- employee mandatory contributions
,' ' ::char(9) as ermp -- employer money purchase
,' ' ::char(9) as ercon -- employer contribution
,' ' ::char(9) as shgr -- safe harbor graded contributions
,' ' ::char(9) as eemt1 -- employee user defined money type 1
,' ' ::char(9) as eemt2 -- employee user defined money type 2
,' ' ::char(9) as ermt1 -- employer user defined money type 1
,' ' ::char(9) as ermt2 -- employer user defined money type 2
,' ' ::char(9) as ermt3 -- employer user defined money type 3
,' ' ::char(9) as ermt4 -- employer user defined money type 4
,' ' ::char(9) as ermt5 -- employer user defined money type 5
,' ' ::char(9) as ermt6 -- employer user defined money type 6


-- LoanID fields are L1NC and L2NC, but per Brian, these are not in the postgres tables and these fields are not available on any page to maintain.  
--- The prior email from the vendor said we could leave the LoanID blank, so just make the other changes and we will remind them of that when we send the next test file
,' ' ::char(6) as loanid 
,ppdv65.etv_amount as loanamt
,' ' ::char(6) as loanid2
,' ' ::char(9) as loanamt2
,' ' ::char(6) as loanid3
,' ' ::char(9) as loanamt3
,' ' ::char(6) as loanid4
,' ' ::char(9) as loanamt4
,' ' ::char(6) as loanid5
,' ' ::char(9) as loanamt5
,' ' ::char(6) as loanid6
,' ' ::char(9) as loanamt6
,' ' ::char(6) as loanid7
,' ' ::char(9) as loanamt7
,' ' ::char(6) as loanid8
,' ' ::char(9) as loanamt8
,' ' ::char(6) as loanid9
,' ' ::char(9) as loanamt9

,' ' ::char(6) as loanid10
,' ' ::char(9) as loanamt10

 
 
from person_identity pi

left join pers_pos pp
  on pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate
 and current_Timestamp between pp.createts and pp.endts

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts 
 
left join person_compensation pc
  on pc.personid = pp.personid 
 and pc.earningscode in ('Regular','ExcHrly', 'RegHrly')
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts
 and pc.frequencycode <> 'H'  
 


left JOIN person_phone_contacts ppch 
  ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'
left JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'   
left JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'      
left JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'  
  
left join dxpersonposition div
  on div.personid = pi.personid  

left join pspay_payment_header pph
  on pph.personid = pi.personid
 AND pph.check_date = ?::DATE
 and pph.personid = piP.personid 
 
left join pspay_payment_detail ppd
  on ppd.check_date = pph.check_date
 and ppd.personid = piP.personid
 and ppd.etv_id IN ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')  

left join (select pd.personid
           , psp.payunitid
           , count(distinct psp.payscheduleperiodid) as distinctpayperiods
           , sum(pd.etype_hours) as workedhours
        from pspay_payment_header ph
        join pspay_payment_detail pd 
          on pd.paymentheaderid = ph.paymentheaderid
         and pd.personid = ph.personid
        join pay_schedule_period psp 
          on ph.payscheduleperiodid = psp.payscheduleperiodid
         and psp.payrolltypeid = 1 ----- NORMAL
   left join pspay_etv_operators peo 
          on peo.group_key = pd.group_key
         and peo.etv_id = pd.etv_id 
         and current_timestamp between peo.createts and peo.endts
         and peo.operand = 'WS102'
         and peo.opcode = 'A'
       where extract(year from ph.check_date) = date_part('year',current_date)
       and peo.etvoperatorpid is not null
       --and pd.personid = '7352'
       group by 1,2) pdx 
  on pdx.personid = pI.personid
  
left join pay_schedule_period psp 
  on psp.payscheduleperiodid = pph.payscheduleperiodid
 and psp.payrolltypeid in ( 1 ) ----- NORMAL 

left join (select periodstartdate, periodenddate, periodpaydate from pay_schedule_period) pspdate
  on pspdate.periodpaydate = ?::date


LEFT join frequency_codes fcpos 
  on pp.schedulefrequency = fcpos.frequencycode

join pay_unit pu 
  on psp.payunitid = pu.payunitid
  
join frequency_codes fcpay 
  on pu.frequencycode = fcpay.frequencycode     
 
        
-- Pre Taxed 401(k)                             
LEFT JOIN pspay_payment_detail ppdvb1
  ON ppdvb1.personid        = ppd.personid
 AND ppdvb1.check_date      = ppd.check_date
 AND ppdvb1.check_number    = ppd.check_number
 AND ppdvb1.payment_number  = ppd.payment_number
 AND ppdvb1.etv_code        = ppd.etv_code
 AND ppdvb1.etv_id          = 'VB1'
-- Pre Taxed 401(k) Catch Up  
LEFT JOIN pspay_payment_detail ppdvb2
  ON ppdvb2.personid        = ppd.personid
 AND ppdvb2.check_date      = ppd.check_date
 AND ppdvb2.check_number    = ppd.check_number
 AND ppdvb2.payment_number  = ppd.payment_number
 AND ppdvb2.etv_code        = ppd.etv_code
 AND ppdvb2.etv_id          = 'VB2'                  
-- roth
LEFT JOIN pspay_payment_detail ppdvb3
  ON ppdvb3.personid        = ppd.personid
 AND ppdvb3.check_date      = ppd.check_date
 AND ppdvb3.check_number    = ppd.check_number
 AND ppdvb3.payment_number  = ppd.payment_number
 AND ppdvb3.etv_code        = ppd.etv_code
 AND ppdvb3.etv_id          = 'VB3' 
-- Roth Catch Up                                
LEFT JOIN pspay_payment_detail ppdvb4
  ON ppdvb4.personid        = ppd.personid
 AND ppdvb4.check_date      = ppd.check_date
 AND ppdvb4.check_number    = ppd.check_number
 AND ppdvb4.payment_number  = ppd.payment_number
 AND ppdvb4.etv_code        = ppd.etv_code
 AND ppdvb4.etv_id          = 'VB4' 
-- 401KCMAE
LEFT JOIN pspay_payment_detail ppdvb5
  ON ppdvb5.personid        = ppd.personid
 AND ppdvb5.check_date      = ppd.check_date
 AND ppdvb5.check_number    = ppd.check_number
 AND ppdvb5.payment_number  = ppd.payment_number
 AND ppdvb5.etv_code        = ppd.etv_code
 AND ppdvb5.etv_id          = 'VB5' 
-- loan 1
left JOIN pspay_payment_detail ppdv65
  ON ppdv65.personid        = ppd.personid
 AND ppdv65.check_date      = ppd.check_date
 AND ppdv65.check_number    = ppd.check_number
 AND ppdv65.payment_number  = ppd.payment_number
 AND ppdv65.etv_code        = ppd.etv_code
 AND ppdv65.etv_id          = 'V65'    

 
LEFT JOIN (SELECT personid 

                 ,sum(etv_amount) as taxable_wage
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
             -- 6/16 feedback need holiday pay included in ytd totals adding ECZ, EC8, E17
            WHERE etv_id in (select etv_id from pspay_etv_operators where operand = 'WS15' and etvindicator = 'E' group by 1)       
--              AND date_part('year', check_date) = date_part('year',now())
              AND date_part('year',check_date) = date_part('year',?::DATE)
         GROUP BY personid
          ) ytdcomp
  ON ytdcomp.personid = piP.personid  
 
LEFT JOIN (SELECT personid
                 ,sum(etype_hours) AS hours
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
            WHERE date_part('year', check_date) = date_part('year',now())
           GROUP BY personid
          ) ytdhw
  ON ytdhw.personid = piP.personid  
 
left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 
join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts  
 
join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts
  
join person_address pae 
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts 
 and pae.addresstype = 'Res'


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus <> 'L'

 order by 1
