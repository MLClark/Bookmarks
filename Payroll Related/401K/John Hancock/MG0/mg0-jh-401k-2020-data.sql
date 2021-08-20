select distinct
 pi.personid
,elu.lastupdatets
,'comb.d' ::char(8) as comb_h10 --col 1 A
,'36765 ' ::char(7) as cont --col 2 B
,replace(pi.identity,'-','')::char(9) as SSN -- col 3
,TRIM(UPPER(pn.fname))::varchar(18) as FirstName -- col 4
,TRIM(UPPER(pn.lname))::varchar(20) as LastName -- col 5
,TRIM(UPPER(coalesce(LEFT(pn.mname,1),'')))::varchar(1) as Initial -- col 6
,null :: varchar(4) as NamePrefix --col 7
,pie.identity ::char(9) as EEID -- col 8
,replace(pa.streetaddress,',',' ') ::varchar(30) as Address1 -- col 9
,replace(pa.streetaddress2,',',' ') ::varchar(30) as Address2 -- col 10
,pa.city::varchar(25) as city -- col 11

,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as state -- col 12
,pa.postalcode::varchar(10) as zip -- col 13
,null :: char(3) as country -- col 14
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as StateRes -- col 15
,null :: char(99) as ERProvEmail --col 16

,replace(pu.payunitdesc,'-','') as division -- col 17
-------------------------------------------------------------------------------------------------------------------------   
,to_char(pv.birthdate,'mmddyyyy')::char(8) as dob -- col 18
,to_char(pe.emplhiredate,'mmddyyyy') ::char(8) as doh -- col 19 original date of hire
,case when pe.emplstatus in ('A','L','P') then 'A' 
      when pe.emplstatus in ('T','D') then 'T'  end ::char(1) as empstatus -- col 20
-------------------------------------------------------------------------------------------------------------------------   
,case when pe.emplstatus in ('A','L') then to_char(coalesce(pe.emplhiredate,pe.empllasthiredate),'mmddyyyy')
      when pe.emplstatus in ('R','T') then to_char(pe.effectivedate,'mmddyyyy') 
      else '' end ::char(8) as EmplStatDate -- col 21
------------------------------------------------------------------------------------------------------------------------- 
--,pfpe.benefitsubclass
--,to_char(pe.emplhiredate,'mmddyyyy')
--- Use pfpe table to determine if ee is currently contributing.
--- Send a 'Y' if they are not currently contributing to a 401k plan
,case when pe.emplstatus in ('A','L','P') and coalesce(pfpe.personid,pfpe1.personid) is not null then ' ' 
      when pe.emplstatus in ('R','T')     then ' '
      else 'Y' end ::char(1) as EligInd -- col 22
--- Send the hire date + 6 months - only for employees who are not currently contributing
,case when pe.emplstatus in ('A','L') and coalesce(pfpe.personid,pfpe1.personid) is not null then ' ' 
      when pe.emplstatus in ('R','T')     then ' '
      else to_char(pe.emplhiredate + interval '6 months','mmddyyyy') end ::char(8) as EligDate --col 23
,null ::char(1) as OptOutInd --col 24

---------------------------------------------------------------------------------------------------------------------------------------------------------------- 
,case when dedamt.total_401k <> 0 then total_hours.hours end as YTDhrs --col 25  YTD eligible hours worked for 401K Plan  
,wage_amount.Amount as PlanYTDComp --col 26  YTD eligible compensation amount for 401K Plan  
----- YTDHrsWkCompDt required if either YTDhrs or PlanYTDComp is submitted
,case when dedamt.total_401k  <> 0 then to_char(coalesce(dedamt.check_date,psp.periodpaydate),'mmddyyyy')
      when wage_amount.Amount <> 0 then to_char(coalesce(dedamt.check_date,psp.periodpaydate),'mmddyyyy') end ::char(8) as YTDHrsWkCompDt --col 27 as paydate
---------------------------------------------------------------------------------------------------------------------------------------------------------------- 

,case when pc.frequencycode = 'A' then to_char(pc.compamount,'FM0000000000D00')
      when ((pe.emplstatus in ('R','T')) or pos.scheduledhours = 0) and pc.frequencycode = 'H' then to_char((pc.compamount * 2080 ) ,'FM0000000000D00')
      when pc.frequencycode = 'H' then to_char(pc.compamount * (pos.scheduledhours * fcpos.annualfactor) ,'FM0000000000D00') end as BaseSalary -- col 28

-------------------------------------------------------------------------------------------------------------------------   
,pfpe.financialelectionrate as BfTxDefPct --col 29
,pfpe.financialelectionamount as BfTxFltDoDef --col 30
,pfpe1.financialelectionrate as DesigRothPct --col 31
,pfpe1.financialelectionamount as DesigRothAmt --col 32
-------------------------------------------------------------------------------------------------------------------------   
,'505' as Trans --33
,to_char(coalesce(dedamt.check_date,loans.check_date),'mmddyyyy')::char(8) as Date_end --col 34 Pay Period End Date
,coalesce (dedamt.vb1_amount + dedamt.vb2_amount + dedamt.vb3_amount + dedamt.vb4_amount, 0) as EEDEF --col 35 AI Employee Deferral Total Pre-Tax Deferral + Total Pre-Tax Catch-up
----------------------------------------------------------------------
,null as col36aj
,null as col37ak
,null as col38al
,null as col39am
,null as col40an
,null as col41ao
-----------------------------------------------------------------------
,coalesce (dedamt.vb6_amount, 0)  as SHNEC -- col 42 AP safe harbor
-----------------------------------------------------------------------
,null as col43aq
,null as col44ar
,null as col45as
,null as col46at
,null as col47au
,null as col48av
,null as col49aw
,null as col50ax
,null as col51ay
,null as col52az
,null as col53ba
,null as col54bb
,null as col55bc
,null as col56bd
,null as col57be
,null as col58bf
---------------------------------------------------------------------------
--- for MG0 - only submit the sum of all the loans. 
,case when loans.total_loan_amount <> 0 then loans.referencenumber else ' ' end as LoanID_1 -- col 59 BG Loan 1
,case when loans.total_loan_amount <> 0 then coalesce (loans.total_loan_amount,0) end as LoanAmt_1 -- col 60 BH Loan 1 amt
,null as LoanID_2 -- col 61 BI
,null as LoanAmt_2 -- col 62 BJ
---------------------------------------------------------------------------
,null as LoanID_3 --63
,null as LoanAmt_3 --64
,null as LoanID_4 --65
,null as LoanAmt_4 --66
,null as LoanID_5 --67
,null as LoanAmt_5 --68
,null as LoanID_6 --69
,null as LoanAmt_6  --70
,null as LoanID_7  --71
,null as LoanAmt_7  --72
,null as LoanID_8  --73
,null as LoanAmt_8  --74
,null as LoanID_9  --75
,null as LoanAmt_9  --76
,null as LoanID_10  --77
,null as LoanAmt_10  --78
 
from person_identity pi
join edi.edi_last_update elu  on elu.feedid =  'MG0_JH_401K_Export_P20_testing' 

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and (current_date between pn.effectivedate and pn.enddate
  or (pn.effectivedate > current_date and pn.enddate > pn.effectivedate and extract(year from pn.effectivedate) = extract(year from current_date)))
 
left join person_address pa
  on pa.personid = pi.personid
 and (current_date between pa.effectivedate and pa.enddate
  or (pa.effectivedate > current_date and pa.enddate > pa.effectivedate and extract(year from pa.effectivedate) = extract(year from current_date)))
 
left join person_vitals pv
  on pv.personid = pi.personid
 and (current_date between pv.effectivedate and pv.enddate
  or (pv.effectivedate > current_date and pv.enddate > pv.effectivedate and extract(year from pv.effectivedate) = extract(year from current_date)))
   
left join person_employment pe
  on pe.personid = pi.personid
 and (current_date between pe.effectivedate and pe.enddate
  or (pe.effectivedate > current_date and pe.enddate > pe.effectivedate and extract(year from pe.effectivedate) = extract(year from current_date)))
 and current_timestamp between pe.createts and pe.endts

left join ( select personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
              from person_compensation where effectivedate < enddate and current_timestamp between createts and endts  
             group by personid, compamount, increaseamount, compevent, frequencycode, earningscode) as pc on pc.personid = pi.personid and pc.rank = 1   

left join person_payroll pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
left join pers_pos pos
  on pos.personid = pe.personid 
 and current_date between pos.effectivedate and pos.enddate
 and current_timestamp between pos.createts and pos.endts 
 
left join frequency_codes fcpos
  on fcpos.frequencycode = pos.schedulefrequency  

left join pay_unit pu
  on pu.payunitid = pp.payunitid
 and current_timestamp between pu.createts and pu.endts

-------------------------------------------------------------------------------------------------------------------------                               
left join 
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount ---- 401K P/T    
,sum(x.vb2_amount) as vb2_amount ---- 401K C/U    
,sum(x.v25_amount) as v25_amount ---- 401k        
,sum(x.vdp_amount) as vdp_amount ---- 403b C/U    
,sum(x.vb3_amount) as vb3_amount ---- ROTH        
,sum(x.vb4_amount) as vb4_amount ---- ROTH C/U    
,sum(x.vb6_amount) as vb6_amount ---- SHNEC      
,sum(x.vb1_amount+x.vb2_amount+x.v25_amount+x.vdp_amount+x.vb3_amount+x.vb4_amount+x.vb6_amount) as total_401k 
,x.payscheduleperiodid
from


(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'V25' then etv_amount  else 0 end as v25_amount

,case when ppd.etv_id = 'VDP' then etv_amount  else 0 end as vdp_amount

,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount

,case when ppd.etv_id = 'VB6' then etv_amount  else 0 end as vb6_amount

,ppd.paymentheaderid
,pph.payscheduleperiodid
from pspay_payment_detail ppd
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid

where pph.paymentheaderid in                                        
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                           join edi.edi_last_update elu  on elu.feedid =  'MG0_JH_401K_Export_P20_testing' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','V25','VDP','VB3','VB4','VB6')) x
  group by 1,2,payscheduleperiodid  having sum(x.vb1_amount + x.vb2_amount + v25_amount + vdp_amount + x.vb3_amount + x.vb4_amount + x.vb6_amount) <> 0)
        dedamt on dedamt.personid = pi.personid  
-------------------------------------------------------------------------------------------------------------------------   
-- New Hours Start 
left join (select personid,sum(etype_hours) as hours
             from pspay_payment_detail            
            where date_part('year', check_date) = date_part('year',current_date) 
              and etv_id in (select a.etv_id from pspay_etv_operators a  
                              where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1)
           GROUP BY personid
          ) total_hours on total_hours.personid = pi.personid 
          
-- Hours End 
-------------------------------------------------------------------------------------------------------------------------   

-------------------------------------------------------------------------------------------------------------------------   
--New Wages Start 

LEFT JOIN (SELECT w.personid
             ,w.check_date 
                 ,sum(w.etv_amount) as  Amount
             FROM          
            
       (Select distinct
             ppdw.personid
             ,ppdw.check_date
             ,ppdw.etv_amount 
             ,ppdw.paymentheaderid
             from pspay_payment_detail ppdw
             where ppdw.paymentheaderid in 
                    (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                           (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                                 (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                                      on elu.feedid =  'MG0_JH_401K_Export_P20_testing' and elu.lastupdatets <= ppay.statusdate
                                      where ppay.pspaypayrollstatusid = 4 ))) and ppdw.etv_id  in  (select a.etv_id from pspay_etv_operators a
                                                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1)) w group by 1,2) 
                                                            wage_amount on wage_amount.personid = pi.personid 
                                                            and wage_amount.check_date::date = dedamt.check_date::date
-------------------------------------------------------------------------------------------------------------------------   
left join 
(select 
 x.personid
,x.check_date
,x.referencenumber
,x.rank as key_rank
,sum(x.v65_amount) as v65_loan1 -- loan 1
,sum(x.v73_amount) as v73_loan2 -- loan 2
,sum(x.v31_amount) as v31_loan3 -- loan 3
,sum(x.v65_amount+x.v73_amount+x.v31_amount) as total_loan_amount

from
(select distinct
 ppd.personid
,ppd.check_date
,pds.referencenumber
,pds.rank 
,case when ppd.etv_id = 'V65' then etv_amount  else 0 end as v65_amount
,case when ppd.etv_id = 'V73' then etv_amount  else 0 end as v73_amount
,case when ppd.etv_id = 'V31' then etv_amount  else 0 end as v31_amount

,ppd.paymentheaderid

from pspay_payment_detail ppd
left join (select distinct pds.personid, pds.etvid, pds.referencenumber, rank() over(partition by pds.personid order by pds.etvid desc) as rank
     from person_deduction_setup pds where current_date between pds.effectivedate and pds.enddate and current_timestamp between pds.createts and pds.endts
      and pds.etvid in ('V65','V73','V31')) pds on pds.personid = ppd.personid and pds.etvid = ppd.etv_id
    
where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'MG0_JH_401K_Export_P20_testing' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) -- pspaypayrollstatusid = 4 means payroll completed
  and ppd.etv_id  in ('V65','V73','V31')) x  
group by personid, check_date, referencenumber, key_rank) loans on loans.personid = pe.personid  
   
-------------------------------------------------------------------------------------------------------------------------   
-- Eligibility Indicator - pfpe table should be used to determine if the EE is already contributing.
left join person_financial_plan_election pfpe --percent
  on pfpe.personid = pi.personid
 and pfpe.benefitsubclass in  ('40')
 and current_date between pfpe.effectivedate and pfpe.enddate
 and current_timestamp between pfpe.createts and pfpe.endts
-------------------------------------------------------------------------------------------------------------------------
left join person_financial_plan_election pfpe1 --flat amt
  on pfpe1.personid = pi.personid
 and pfpe1.benefitsubclass in   ('4Z')
 and current_date between pfpe1.effectivedate and pfpe1.enddate
 and current_timestamp between pfpe1.createts and pfpe1.endts
-------------------------------------------------------------------------------------------------------------------------
left join pay_schedule_period psp on psp.payscheduleperiodid = dedamt.payscheduleperiodid
----- Keep terms on file for up to one year 
----- Send future dated new hires  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and ((pe.emplstatus in ('L','A','P')) 
   or  (pe.emplstatus in ('R','T') and pe.effectivedate >= current_date - interval '1 year'))
  order by ssn
