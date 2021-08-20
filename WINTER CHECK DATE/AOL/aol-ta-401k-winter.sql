---- see research for new joins 


select distinct
  pi.personid
, piP.identity
,pph.check_date
,psp.periodpaydate
, 'WFEM0EZG' ::char(8) as plancode
--, to_char(coalesce(ppd_401k.check_date,ppd_Roth.check_date,ppd_ERmatch.check_date),'mm/dd/yyyy') as check_date
, ?::DATE as check_date
, ' ' ::char(5) as funding_code
, left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn
, pn.fname ::char(14) as firstname
, pn.mname ::char(1)  as mi
, pn.lname ::char(30) as lastname
, piE.identity ::char(9) as employeenbr
, pa.streetaddress  ::char(30) as addr1
, pa.streetaddress2 ::char(20) as addr2
, pa.city ::char(30) as city
, pa.stateprovincecode ::char(2) as state
, pa.postalcode ::char(10) as zip
, ' '::char(1) as Country	
, ' '::char(1) as PhoneNumber	
, ' '::char(1) as EmailAddress	
, ' '::char(1) as DivisionCode	
, ' '::char(1) as ExtraDivisionCode	
, ' '::char(1) as WorkLocation

, case pe.emplstatus 
      when 'A' then 'ACTV'
      when 'T' then 'TERM'
      when 'L' then 'LEAV'
      else 'ACTV' end ::char(4) as participant_status
, ' '::char(1) as PayStatus 	
, ' '::char(1) as HighlyCompensatedStatus	
, ' '::char(1) as TopHeavyStatusCode
, ' '::char(1) as I6BInsider	
, ' '::char(1) as PlanEntryEligibilityDate
      
, to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as birthdate
, to_char(eed.emplhiredate,'mm/dd/yyyy') ::char(10) as orighiredate
, to_char(eed.empllasthiredate,'mm/dd/yyyy') ::char(10) as rehiredate
, case when pe.emplstatus = 'T' then to_char(eed.empleffectivedate,'mm/dd/yyyy')else null end  ::char(10) as termdate
, ' '::char(1) as DeathDate
, ' '::char(1) as AlternativeVestingDate 

, case eed.schedulefrequency 
      when 'B' then '1'
      when 'W' then '0'
      when 'H' then '0'
      when 'M' then '3'
      when 'S' then '2'
      when 'Q' then '4'
      end ::char(1) as payrollFreq
, case pv.gendercode 
      when 'M' then '1'
      when 'F' then '2'
      else '0' end ::char(1) as gender 

, ' '::char(1) as MaritalStatus
, ' '::char(1) as LanguageIndicator 
, ' '::char(1) as FederalTaxExemptions 
, ' '::char(1) as TaxFilingStatus 
, ' '::char(1) as UnionStatus 


, hw.ytdhours                          as hoursPlanYTD                  -- col AM Hours Plan YTD
, ' '::char(1) as PriorMonthsofService
, ' '::char(1) as EligibilityMonthsofService
, hp.ytd_taxable_wage                     as PlanYTD401KCompAmt            -- col AP Gross wages (excluding GTL & LTD Prem)
, hp.ytd_taxable_wage                     as PlanYTDW2CompAmt              -- col AQ Gross wages (excluding GTL & LTD Prem)
, pc.frequencycode
, pc.compamount
, pe.emplfulltimepercent
, case 
      when pc.frequencycode = 'A' then pc.compamount
      --when pc.frequencycode = 'H' then (pc.compamount * 2080 * pe.emplfulltimepercent)
      when pc.frequencycode = 'H' then (pc.compamount * 2080 )
      end                              as annualSalary                  -- col AR

, hp.ytd_taxable_wage                     as PlanYTDAllocCompAmt           -- col AS Gross wages (excluding GTL & LTD Prem) 
, eeptd.eepretaxdeferral               as eePreTaxDeferral              -- col AT should be the per pay Employee deduction

, ' '::char(1) as ERMatchContribAmt                                     -- col AU should be the per pay Employer deduction
, ' '::char(1) as ProfitSharingContribAmt                               -- col AV
, ' '::char(1) as OtherContribAmt                                       -- col AW
, ' '::char(1) as eeAfterTaxContribAmt                                  -- col AX
, ppdvb2.etv_amount                    as PretaxCUpContribAmt           -- col AY should have the PreTax EE Catchup Amount (per pay) 
, ' '::char(1) as QNECContribAmt 
, ' '::char(1) as QMACContribAmt
, ' '::char(1) as MoneyPurchaseContribAmt	

, shm.safeharbormatch                  as safeharbormatch               -- col BC as safeharborMatch the per pay Company Match amount 

, ' '::char(1) as SafeHarborNonElectiveContribAmt

, ppdvb3.etv_amount                    as rothDeferral                  -- col BE roth deferrel

, ' '::char(1) as OtherContribAmt 
, ppdvb4.etv_amount                    as RothCUContribAmt              -- col BG Roth Catch Up Contribution Amount
, ' '::char(1) as OtherContribAmt
, ' '::char(1) as LoanNbrForLoanRepayment1

, ppdv65.etv_amount                    as loan1payment                  -- col BJ loan repayment
 
, ' '::char(1) as LoanNbrForLoanRepayment2 
, ' '::char(1) as LoanRepayment2
, ' '::char(1) as LoanNbrForLoanRepayment3
, ' '::char(1) as LoanRepayment3
, ' '::char(1) as LoanNbrForLoanRepayment4
, ' '::char(1) as LoanRepayment4
, ' '::char(1) as LoanNbrForLoanRepayment5
, ' '::char(1) as LoanRepayment5
, ' '::char(1) as LoanNbrForLoanRepayment6 
, ' '::char(1) as LoanRepayment6
, ' '::char(1) as LoanNbrForLoanRepayment7
, ' '::char(1) as LoanRepayment7
, ' '::char(1) as LoanNbrForLoanRepayment8
, ' '::char(1) as LoanRepayment8
, ' '::char(1) as LoanNbrForLoanRepayment9
, ' '::char(1) as LoanRepayment9
, ' '::char(1) as LoanNbrForLoanRepayment10
, ' '::char(1) as LoanRepayment10	


from person_identity pi

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
 AND pn.effectivedate - interval '1 day' <> pn.enddate
 
LEFT JOIN person_address pa 
  ON pa.personid = pi.personid
 AND current_date BETWEEN pa.effectivedate AND pa.enddate
 AND current_timestamp BETWEEN pa.createts AND pa.endts      
 AND pa.effectivedate - interval '1 day' <> pa.enddate
 
JOIN person_vitals pv
  ON pv.personid = pi.personid 
 AND current_date BETWEEN pv.effectivedate AND pv.enddate
 AND current_timestamp BETWEEN pv.createts AND pv.endts    
 AND pv.effectivedate - interval '1 day' <> pv.enddate
 
join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 AND pe.effectivedate - interval '1 day' <> pe.enddate

left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 AND pc.effectivedate - interval '1 day' <> pc.enddate

join pay_schedule_period psp 
  on psp.payrolltypeid = 1
 and psp.processfinaldate is not null
 and psp.periodpaydate = ?::date

join pspay_payment_header pph
  on pph.check_date = psp.periodpaydate
 and pph.payscheduleperiodid = psp.payscheduleperiodid  

join pspay_payment_detail ppd
  on ppd.etv_id IN ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')
 and ppd.personid = pi.personid
 and ppd.check_date = psp.periodpaydate
 and pph.paymentheaderid = ppd.paymentheaderid
 
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
LEFT JOIN pspay_payment_detail ppdv65
  ON ppdv65.personid        = ppd.personid
 AND ppdv65.check_date      = ppd.check_date
 AND ppdv65.check_number    = ppd.check_number
 AND ppdv65.payment_number  = ppd.payment_number
 AND ppdv65.etv_code        = ppd.etv_code
 AND ppdv65.etv_id          = 'V65'   

-- ee total hours 
-- ee total gross based on federal tax
LEFT JOIN (SELECT personid
                 ,sum(etype_hours) AS ytdhours
                 --,sum(etv_amount) as ytd_taxable_wage
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
             -- 6/16 feedback need holiday pay included in ytd totals adding ECZ, EC8, E17
            WHERE etv_id in  ('E01','E02','E03','E15','E19','E18','E08', 'E61','E05','ECZ','EC8','E17')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date <= ?::DATE
         GROUP BY personid
          ) hw
  ON hw.personid = pi.personid 
  
LEFT JOIN (SELECT personid
                 --,sum(etype_hours) AS ytdhours
                 ,sum(etv_amount) as ytd_taxable_wage
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
             -- 6/16 feedback need holiday pay included in ytd totals adding ECZ, EC8, E17
            WHERE etv_id in  ('E01','E02','E03','E15','E19','E18','E08', 'E61','E05','ECZ','EC8','E17')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date <= ?::DATE
         GROUP BY personid
          ) hp
  ON hp.personid = pi.personid

left JOIN (SELECT personid
                 ,sum(etv_amount) as eepretaxdeferral
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
            WHERE etv_id in  ('VB1')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date = ?::DATE
         GROUP BY personid
          ) eeptd
  ON eeptd.personid = pi.personid
  
left JOIN (SELECT personid
                 ,sum(etv_amount) as safeharbormatch
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
            WHERE etv_id in  ('VB5')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date = ?::DATE
         GROUP BY personid
          ) shm
  ON shm.personid = pi.personid
  
   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pi.personid in ('1961', '1936' , '1917' , '2000' , '2182', '1971', '2059' ,'1932')
  --and pi.personid in ( '1971', '2059' )
  --and pi.personid = '2228'

order by ssn  