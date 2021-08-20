select distinct
  pi.personid
, 'newhire record' ::char(25) qsource
, pe.effectivedate
, pe.emplstatus
, pc.enddate

, 'WFEM0EZG' ::char(8) as plancode                                      -- col A
--, to_char(coalesce(ppd_401k.check_date,ppd_Roth.check_date,ppd_ERmatch.check_date),'mm/dd/yyyy') as check_date
, to_char(current_date,'mm/dd/yyyy')::char(10) as check_date --col B
, ' ' ::char(5) as funding_code                                         -- col C   
, left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn --col D
, pn.fname ::char(14) as firstname                                      -- col E
, pn.mname ::char(1)  as mi                                             -- col F
, pn.lname ::char(30) as lastname                                       -- col G
, '"'||piE.identity||'"' ::char(11) as employeenbr                      -- col H

, '"'||pa.streetaddress||'"'   ::char(30) as addr1                      -- col I                
, '"'||pa.streetaddress2||'"'  ::char(20) as addr2                      -- col J
, pa.city ::char(30) as city                                            -- col K
, pa.stateprovincecode ::char(2) as state                               -- col L
, pa.postalcode ::char(10) as zip                                       -- col M

,case when pa.countrycode <> 'US' then pa.countrycode else ' ' end ::char(2) as Country -- col N	
, ' '::char(1) as PhoneNumber	                                          -- col O
, ' '::char(1) as EmailAddress	                                       -- col P  
, ' '::char(1) as DivisionCode	                                       -- col Q
, ' '::char(1) as ExtraDivisionCode	                               -- col R
, ' '::char(1) as WorkLocation                                         -- col S


, case pe.emplstatus 
      when 'A' then 'ACTV'
      when 'T' then 'TERM'
      when 'L' then 'LEAV'
      else 'ACTV' end ::char(4) as participant_status                   -- col T


, ' '::char(1) as PayStatus                                             -- col U 	
, ' '::char(1) as HighlyCompensatedStatus	                        -- col V
, ' '::char(1) as TopHeavyStatusCode                                    -- col W
, ' '::char(1) as I6BInsider	                                        -- col X
, ' '::char(1) as PlanEntryEligibilityDate                              -- col Y
      
      
, to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as birthdate            -- col Z

, to_char(pe.emplsenoritydate,'mm/dd/yyyy')::char(10) as orig_hire_date -- col AA


, case when pe.empllasthiredate = pe.emplsenoritydate then ' ' 
       else to_char(pe.empllasthiredate,'mm/dd/yyyy')
        end ::char(10)                                as last_hire_date -- col AB
, case when pe.emplstatus = 'T' then to_char(eed.empleffectivedate,'mm/dd/yyyy')
       else null end  ::char(10) as termdate                            -- col AC
       
, ' '::char(1) as DeathDate                                             -- col AD
, ' '::char(1) as AlternativeVestingDate                                -- col AE

,pc.frequencycode    
, case when eed.schedulefrequency = 'B' then '1'
       when eed.schedulefrequency = 'W' then '0'
       when eed.schedulefrequency = 'H' then '0'
       when eed.schedulefrequency = 'M' then '3'
       when eed.schedulefrequency = 'S' then '2'
       when eed.schedulefrequency = 'Q' then '4'
       when eed.schedulefrequency = 'A' then '2'
       when pc.frequencycode = 'A' then '2'
       when pc.frequencycode = 'H' then '1'       
       end ::char(1) as payrollFreq                                      -- col AF
      
, case pv.gendercode 
      when 'M' then '1'
      when 'F' then '2'
      else '0' end ::char(1) as gender                                  -- col AG
   
, ' '::char(1) as MaritalStatus                                         -- col AH
, ' '::char(1) as LanguageIndicator                                     -- col AI
, ' '::char(1) as FederalTaxExemptions                                  -- col AJ
, ' '::char(1) as TaxFilingStatus                                       -- col AK
, ' '::char(1) as UnionStatus                                           -- col AL 
    
--, hw.ytdhours                          as hoursPlanYTD                  -- col AM Hours Plan YTD
, ' '::char(1) as hoursPlanYTD                                          -- col AM Hours Plan YTD
, ' '::char(1) as PriorMonthsofService                                  -- col AN
, ' '::char(1) as EligibilityMonthsofService                            -- col AO
--, hp.ytd_taxable_wage                  as PlanYTD401KCompAmt            -- col AP Gross wages (excluding GTL & LTD Prem)
, ' '::char(1) as PlanYTD401KCompAmt                                    -- col AP Gross wages (excluding GTL & LTD Prem)
--, ytd_taxable_wage                     as PlanYTDW2CompAmt              -- col AQ Gross wages (excluding GTL & LTD Prem)
, ' '::char(1) as PlanYTDW2CompAmt                                      -- col AQ Gross wages (excluding GTL & LTD Prem)
, case 
      when pc.frequencycode      = 'A' then cast (pc.compamount as dec (18,2))
      --when pc.frequencycode = 'H' then (pc.compamount * 2080 * pe.emplfulltimepercent)
      when pc.frequencycode      = 'H' then cast ( (pc.compamount * 2080) as dec (18,2))
      when eed.schedulefrequency = 'B' then cast ( (pc.compamount * 2080) as dec (18,2))
      end                              as annualSalary                  -- col AR
 
--,' ' ::char(1) as annualSalary                  -- col AR  
--, HP.ytd_taxable_wage                   as PlanYTDAllocCompAmt           -- col AS Gross wages (excluding GTL & LTD Prem)
, ' '::char(1) as PlanYTDAllocCompAmt                                   -- col AS Gross wages (excluding GTL & LTD Prem) 
--, eeptd.eepretaxdeferral               as eePreTaxDeferral              -- col AT should be the per pay Employee deduction
, ' '::char(1) as eePreTaxDeferral                                      -- col AT should be the per pay Employee deduction

, ' '::char(1) as ERMatchContribAmt                                     -- col AU should be the per pay Employer deduction
, ' '::char(1) as ProfitSharingContribAmt                               -- col AV
, ' '::char(1) as OtherContribAmt                                       -- col AW
, ' '::char(1) as eeAfterTaxContribAmt                                  -- col AX
-----, ppdvb2.etv_amount                    as PretaxCUpContribAmt           -- col AY should have the PreTax EE Catchup Amount (per pay) 
, ' '::char(1) as PretaxCUpContribAmt                                   -- col AY should have the PreTax EE Catchup Amount (per pay) 
, ' '::char(1) as QNECContribAmt                                        -- col AZ
, ' '::char(1) as QMACContribAmt                                        -- col BA
, ' '::char(1) as MoneyPurchaseContribAmt	                              -- col BB

--, shm.safeharbormatch                  as safeharbormatch               -- col BC as safeharborMatch the per pay Company Match amount 
, ' '::char(1) as safeharbormatch                                       -- col BC as safeharborMatch the per pay Company Match amount 

, ' '::char(1) as SafeHarborNonElectiveContribAmt                       -- col BD

--, ppdvb3.etv_amount                    as rothDeferral                  -- col BE roth deferrel
, ' '::char(1) as rothDeferral                                          -- col BE roth deferrel

, ' '::char(1) as OtherContribAmt                                       -- col BF
-----, ppdvb4.etv_amount                    as RothCUContribAmt              -- col BG Roth Catch Up Contribution Amount
, ' '::char(1) as RothCUContribAmt                                      -- col BG Roth Catch Up Contribution Amount
, ' '::char(1) as OtherContribAmt                                       -- col BH
, ' '::char(1) as LoanNbrForLoanRepayment1                              -- col BI

--, ppdv65.etv_amount                    as loan1payment                  -- col BJ loan repayment
, ' '::char(1) as loan1payment                                          -- col BJ loan repayment
 
, ' '::char(1) as LoanNbrForLoanRepayment2                              -- col BK
, ' '::char(1) as LoanRepayment2                                        -- col BL
, ' '::char(1) as LoanNbrForLoanRepayment3                              -- col BM
, ' '::char(1) as LoanRepayment3                                        -- col BN
, ' '::char(1) as LoanNbrForLoanRepayment4                              -- col BO
, ' '::char(1) as LoanRepayment4                                        -- col BP
, ' '::char(1) as LoanNbrForLoanRepayment5                              -- col BQ
, ' '::char(1) as LoanRepayment5                                        -- col BR
, ' '::char(1) as LoanNbrForLoanRepayment6                              -- col BS
, ' '::char(1) as LoanRepayment6                                        -- col BT
, ' '::char(1) as LoanNbrForLoanRepayment7                              -- col BU
, ' '::char(1) as LoanRepayment7                                        -- col BV
, ' '::char(1) as LoanNbrForLoanRepayment8                              -- col BW
, ' '::char(1) as LoanRepayment8                                        -- col BX
, ' '::char(1) as LoanNbrForLoanRepayment9                              -- col BY
, ' '::char(1) as LoanRepayment9                                        -- col BZ
, ' '::char(1) as LoanNbrForLoanRepayment10                             -- col CA
, ' '::char(1) as LoanRepayment10	                                -- col CB
, '1'::char(1) as querysource
      
from person_identity pi
--- select * from edi.edi_last_update 2018-08-22 11:30:10
--- update edi.edi_last_update set lastupdatets = '2018-07-01 00:00:00' where feedid = 'AOL_Wellsfargo_401K_Eligibility_Export';

JOIN edi.edi_last_update elu
  ON elu.feedid = 'AOL_Wellsfargo_401K_Eligibility_Export'

left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

left join edi.etl_employment_data eed 
  on eed.personid = pi.personid
   
JOIN person_identity piE
  on piE.personid = pi.personid
 and current_timestamp between piE.createts and piE.endts
 and piE.identitytype = 'EmpNo'  

join person_identity piP 
  on piP.personid = pi.personid
 and current_timestamp between piP.createts and piP.endts
 and piP.identitytype = 'PSPID'
 
JOIN person_names pn 
  ON pn.personid = pi.personid
 and pn.nametype = 'Legal'  
 AND current_date BETWEEN pn.effectivedate AND pn.enddate
 AND current_timestamp BETWEEN pn.createts AND pn.endts      
 AND pn.enddate > now() 
 
LEFT JOIN person_address pa 
  ON pa.personid = pi.personid
 AND current_date BETWEEN pa.effectivedate AND pa.enddate
 AND current_timestamp BETWEEN pa.createts AND pa.endts      
 AND pa.enddate > now() 
 
JOIN person_vitals pv
  ON pv.personid = pi.personid 
 AND current_date BETWEEN pv.effectivedate AND pv.enddate
 AND current_timestamp BETWEEN pv.createts AND pv.endts    
 AND pv.enddate > now() 
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 


where pi.identitytype in ('SIN', 'SSN')
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 

union

select distinct
  pi.personid
, 'termination record' ::char(25) qsource
, pe.effectivedate
, pe.emplstatus
, pc.enddate

, 'WFEM0EZG' ::char(8) as plancode                                      -- col A
--, to_char(coalesce(ppd_401k.check_date,ppd_Roth.check_date,ppd_ERmatch.check_date),'mm/dd/yyyy') as check_date
, to_char(current_date,'mm/dd/yyyy')::char(10) as check_date --col B
, ' ' ::char(5) as funding_code                                         -- col C   
, left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn --col D
, pn.fname ::char(14) as firstname                                      -- col E
, pn.mname ::char(1)  as mi                                             -- col F
, pn.lname ::char(30) as lastname                                       -- col G
, '"'||piE.identity||'"' ::char(11) as employeenbr                      -- col H
, '"'||pa.streetaddress||'"'   ::char(30) as addr1                      -- col I                
, '"'||pa.streetaddress2||'"'  ::char(20) as addr2                      -- col J
, pa.city ::char(30) as city                                            -- col K
, pa.stateprovincecode ::char(2) as state                               -- col L
, pa.postalcode ::char(10) as zip                                       -- col M

,case when pa.countrycode <> 'US' then pa.countrycode else ' ' end ::char(2) as Country -- col N	
, ' '::char(1) as PhoneNumber	                                          -- col O
, ' '::char(1) as EmailAddress	                                       -- col P  
, ' '::char(1) as DivisionCode	                                       -- col Q
, ' '::char(1) as ExtraDivisionCode	                                    -- col R
, ' '::char(1) as WorkLocation                                          -- col S


, case pe.emplstatus 
      when 'A' then 'ACTV'
      when 'T' then 'TERM'
      when 'L' then 'LEAV'
      else 'ACTV' end ::char(4) as participant_status                   -- col T


, ' '::char(1) as PayStatus                                             -- col U 	
, ' '::char(1) as HighlyCompensatedStatus	                              -- col V
, ' '::char(1) as TopHeavyStatusCode                                    -- col W
, ' '::char(1) as I6BInsider	                                          -- col X
, ' '::char(1) as PlanEntryEligibilityDate                              -- col Y
      
      
, to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as birthdate            -- col Z

, to_char(pe.emplsenoritydate,'mm/dd/yyyy')::char(10) as orig_hire_date -- col AA

, case when pe.empllasthiredate = pe.emplsenoritydate then ' ' 
       else to_char(pe.empllasthiredate,'mm/dd/yyyy')
        end ::char(10)                                as last_hire_date -- col AB
        
, case when pe.emplstatus = 'T' then to_char(eed.empleffectivedate,'mm/dd/yyyy')
       else null end  ::char(10) as termdate                            -- col AC
       
, ' '::char(1) as DeathDate                                             -- col AD
, ' '::char(1) as AlternativeVestingDate                                -- col AE

    
,pc.frequencycode    
, case when eed.schedulefrequency = 'B' then '1'
       when eed.schedulefrequency = 'W' then '0'
       when eed.schedulefrequency = 'H' then '0'
       when eed.schedulefrequency = 'M' then '3'
       when eed.schedulefrequency = 'S' then '2'
       when eed.schedulefrequency = 'Q' then '4'
       when eed.schedulefrequency = 'A' then '2'
       when pc.frequencycode = 'A' then '2'
       when pc.frequencycode = 'H' then '1'       
       end ::char(1) as payrollFreq                                      -- col AF
      
, case pv.gendercode 
      when 'M' then '1'
      when 'F' then '2'
      else '0' end ::char(1) as gender                                  -- col AG
   
, ' '::char(1) as MaritalStatus                                         -- col AH
, ' '::char(1) as LanguageIndicator                                     -- col AI
, ' '::char(1) as FederalTaxExemptions                                  -- col AJ
, ' '::char(1) as TaxFilingStatus                                       -- col AK
, ' '::char(1) as UnionStatus                                           -- col AL 
    
--, hw.ytdhours                          as hoursPlanYTD                  -- col AM Hours Plan YTD
, ' '::char(1) as hoursPlanYTD                                          -- col AM Hours Plan YTD
, ' '::char(1) as PriorMonthsofService                                  -- col AN
, ' '::char(1) as EligibilityMonthsofService                            -- col AO
--, hp.ytd_taxable_wage                  as PlanYTD401KCompAmt            -- col AP Gross wages (excluding GTL & LTD Prem)
, ' '::char(1) as PlanYTD401KCompAmt                                    -- col AP Gross wages (excluding GTL & LTD Prem)
--, ytd_taxable_wage                     as PlanYTDW2CompAmt              -- col AQ Gross wages (excluding GTL & LTD Prem)
, ' '::char(1) as PlanYTDW2CompAmt                                      -- col AQ Gross wages (excluding GTL & LTD Prem)

, case 
      when pc.frequencycode      = 'A' then cast (pc.compamount as dec (18,2))
      --when pc.frequencycode = 'H' then (pc.compamount * 2080 * pe.emplfulltimepercent)
      when pc.frequencycode      = 'H' then cast ( (pc.compamount * 2080) as dec (18,2))
      when eed.schedulefrequency = 'B' then cast ( (pc.compamount * 2080) as dec (18,2))
      end                              as annualSalary                  -- col AR
    
--,' ' ::char(1) as annualSalary                  -- col AR
--, HP.ytd_taxable_wage                   as PlanYTDAllocCompAmt           -- col AS Gross wages (excluding GTL & LTD Prem)
, ' '::char(1) as PlanYTDAllocCompAmt                                   -- col AS Gross wages (excluding GTL & LTD Prem) 
--, eeptd.eepretaxdeferral               as eePreTaxDeferral              -- col AT should be the per pay Employee deduction
, ' '::char(1) as eePreTaxDeferral                                      -- col AT should be the per pay Employee deducti

, ' '::char(1) as ERMatchContribAmt                                     -- col AU should be the per pay Employer deduction
, ' '::char(1) as ProfitSharingContribAmt                               -- col AV
, ' '::char(1) as OtherContribAmt                                       -- col AW
, ' '::char(1) as eeAfterTaxContribAmt                                  -- col AX
-----, ppdvb2.etv_amount                    as PretaxCUpContribAmt           -- col AY should have the PreTax EE Catchup Amount (per pay) 
, ' '::char(1) as PretaxCUpContribAmt                                   -- col AY should have the PreTax EE Catchup Amount (per pay) 
, ' '::char(1) as QNECContribAmt                                        -- col AZ
, ' '::char(1) as QMACContribAmt                                        -- col BA
, ' '::char(1) as MoneyPurchaseContribAmt	                              -- col BB

--, shm.safeharbormatch                  as safeharbormatch               -- col BC as safeharborMatch the per pay Company Match amount 
, ' '::char(1) as safeharbormatch                                       -- col BC as safeharborMatch the per pay Company Match amount 

, ' '::char(1) as SafeHarborNonElectiveContribAmt                       -- col BD

--, ppdvb3.etv_amount                    as rothDeferral                  -- col BE roth deferrel
, ' '::char(1) as rothDeferral                                          -- col BE roth deferrel

, ' '::char(1) as OtherContribAmt                                       -- col BF
-----, ppdvb4.etv_amount                    as RothCUContribAmt              -- col BG Roth Catch Up Contribution Amount
, ' '::char(1) as RothCUContribAmt                                      -- col BG Roth Catch Up Contribution Amount
, ' '::char(1) as OtherContribAmt                                       -- col BH
, ' '::char(1) as LoanNbrForLoanRepayment1                              -- col BI

--, ppdv65.etv_amount                    as loan1payment                  -- col BJ loan repayment
, ' '::char(1) as loan1payment                                          -- col BJ loan repayment
 
, ' '::char(1) as LoanNbrForLoanRepayment2                              -- col BK
, ' '::char(1) as LoanRepayment2                                        -- col BL
, ' '::char(1) as LoanNbrForLoanRepayment3                              -- col BM
, ' '::char(1) as LoanRepayment3                                        -- col BN
, ' '::char(1) as LoanNbrForLoanRepayment4                              -- col BO
, ' '::char(1) as LoanRepayment4                                        -- col BP
, ' '::char(1) as LoanNbrForLoanRepayment5                              -- col BQ
, ' '::char(1) as LoanRepayment5                                        -- col BR
, ' '::char(1) as LoanNbrForLoanRepayment6                              -- col BS
, ' '::char(1) as LoanRepayment6                                        -- col BT
, ' '::char(1) as LoanNbrForLoanRepayment7                              -- col BU
, ' '::char(1) as LoanRepayment7                                        -- col BV
, ' '::char(1) as LoanNbrForLoanRepayment8                              -- col BW
, ' '::char(1) as LoanRepayment8                                        -- col BX
, ' '::char(1) as LoanNbrForLoanRepayment9                              -- col BY
, ' '::char(1) as LoanRepayment9                                        -- col BZ
, ' '::char(1) as LoanNbrForLoanRepayment10                             -- col CA
, ' '::char(1) as LoanRepayment10	                                    -- col CB
, '2'::char(1) as querysource


from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'AOL_Wellsfargo_401K_Eligibility_Export'

left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

left join edi.etl_employment_data eed 
  on eed.personid = pi.personid
  
JOIN person_identity piE
  on piE.personid = pi.personid
 and current_timestamp between piE.createts and piE.endts
 and piE.identitytype = 'EmpNo'  

join person_identity piP 
  on piP.personid = pi.personid
 and current_timestamp between piP.createts and piP.endts
 and piP.identitytype = 'PSPID'
 
JOIN person_names pn 
  ON pn.personid = pi.personid
 and pn.nametype = 'Legal'  
 AND current_date BETWEEN pn.effectivedate AND pn.enddate
 AND current_timestamp BETWEEN pn.createts AND pn.endts      
 AND pn.enddate > now() 
 
LEFT JOIN person_address pa 
  ON pa.personid = pi.personid
 AND current_date BETWEEN pa.effectivedate AND pa.enddate
 AND current_timestamp BETWEEN pa.createts AND pa.endts      
 AND pa.enddate > now() 
 
JOIN person_vitals pv
  ON pv.personid = pi.personid 
 AND current_date BETWEEN pv.effectivedate AND pv.enddate
 AND current_timestamp BETWEEN pv.createts AND pv.endts    
 AND pv.enddate > now() 
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and pc.enddate = pe.effectivedate - interval '1 day'

where pi.identitytype in ('SIN', 'SSN')
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'T'
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 

union 

select distinct
  pi.personid
, 'name change record' ::char(25) qsource
, pn.effectivedate
, pe.emplstatus
, pc.enddate

, 'WFEM0EZG' ::char(8) as plancode                                      -- col A
--, to_char(coalesce(ppd_401k.check_date,ppd_Roth.check_date,ppd_ERmatch.check_date),'mm/dd/yyyy') as check_date
, to_char(current_date,'mm/dd/yyyy')::char(10) as check_date --col B
, ' ' ::char(5) as funding_code                                         -- col C   
, left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn --col D
, pn.fname ::char(14) as firstname                                      -- col E
, pn.mname ::char(1)  as mi                                             -- col F
, pn.lname ::char(30) as lastname                                       -- col G
, '"'||piE.identity||'"' ::char(11) as employeenbr                      -- col H
, '"'||pa.streetaddress||'"'   ::char(30) as addr1                      -- col I                
, '"'||pa.streetaddress2||'"'  ::char(20) as addr2                      -- col J
, pa.city ::char(30) as city                                            -- col K
, pa.stateprovincecode ::char(2) as state                               -- col L
, pa.postalcode ::char(10) as zip                                       -- col M

,case when pa.countrycode <> 'US' then pa.countrycode else ' ' end ::char(2) as Country -- col N	
, ' '::char(1) as PhoneNumber	                                          -- col O
, ' '::char(1) as EmailAddress	                                       -- col P  
, ' '::char(1) as DivisionCode	                                       -- col Q
, ' '::char(1) as ExtraDivisionCode	                                    -- col R
, ' '::char(1) as WorkLocation                                          -- col S


, case pe.emplstatus 
      when 'A' then 'ACTV'
      when 'T' then 'TERM'
      when 'L' then 'LEAV'
      else 'ACTV' end ::char(4) as participant_status                   -- col T


, ' '::char(1) as PayStatus                                             -- col U 	
, ' '::char(1) as HighlyCompensatedStatus	                              -- col V
, ' '::char(1) as TopHeavyStatusCode                                    -- col W
, ' '::char(1) as I6BInsider	                                          -- col X
, ' '::char(1) as PlanEntryEligibilityDate                              -- col Y
      
      
, to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as birthdate            -- col Z

, to_char(pe.emplsenoritydate,'mm/dd/yyyy')::char(10) as orig_hire_date -- col AA

, case when pe.empllasthiredate = pe.emplsenoritydate then ' ' 
       else to_char(pe.empllasthiredate,'mm/dd/yyyy')
        end ::char(10)                                as last_hire_date -- col AB
        
, case when pe.emplstatus = 'T' then to_char(eed.empleffectivedate,'mm/dd/yyyy')
       else null end  ::char(10) as termdate                            -- col AC
       
, ' '::char(1) as DeathDate                                             -- col AD
, ' '::char(1) as AlternativeVestingDate                                -- col AE

,pc.frequencycode    
, case when eed.schedulefrequency = 'B' then '1'
       when eed.schedulefrequency = 'W' then '0'
       when eed.schedulefrequency = 'H' then '0'
       when eed.schedulefrequency = 'M' then '3'
       when eed.schedulefrequency = 'S' then '2'
       when eed.schedulefrequency = 'Q' then '4'
       when eed.schedulefrequency = 'A' then '2'
       when pc.frequencycode = 'A' then '2'
       when pc.frequencycode = 'H' then '1'
       end ::char(1) as payrollFreq                                      -- col AF
      
, case pv.gendercode 
      when 'M' then '1'
      when 'F' then '2'
      else '0' end ::char(1) as gender                                  -- col AG
   
, ' '::char(1) as MaritalStatus                                         -- col AH
, ' '::char(1) as LanguageIndicator                                     -- col AI
, ' '::char(1) as FederalTaxExemptions                                  -- col AJ
, ' '::char(1) as TaxFilingStatus                                       -- col AK
, ' '::char(1) as UnionStatus                                           -- col AL 
    
--, hw.ytdhours                          as hoursPlanYTD                  -- col AM Hours Plan YTD
, ' '::char(1) as hoursPlanYTD                                          -- col AM Hours Plan YTD
, ' '::char(1) as PriorMonthsofService                                  -- col AN
, ' '::char(1) as EligibilityMonthsofService                            -- col AO
--, hp.ytd_taxable_wage                  as PlanYTD401KCompAmt            -- col AP Gross wages (excluding GTL & LTD Prem))
, ' '::char(1) as PlanYTD401KCompAmt                                    -- col AP Gross wages (excluding GTL & LTD Prem)
--, ytd_taxable_wage                     as PlanYTDW2CompAmt              -- col AQ Gross wages (excluding GTL & LTD Prem)
, ' '::char(1) as PlanYTDW2CompAmt                                      -- col AQ Gross wages (excluding GTL & LTD Prem)
, case 
      when pc.frequencycode      = 'A' then cast (pc.compamount as dec (18,2))
      --when pc.frequencycode = 'H' then (pc.compamount * 2080 * pe.emplfulltimepercent)
      when pc.frequencycode      = 'H' then cast ( (pc.compamount * 2080) as dec (18,2))
      when eed.schedulefrequency = 'B' then cast ( (pc.compamount * 2080) as dec (18,2))
      end                              as annualSalary                  -- col AR

--,' ' ::char(1) as annualSalary                  -- col AR      
      
--, HP.ytd_taxable_wage                   as PlanYTDAllocCompAmt           -- col AS Gross wages (excluding GTL & LTD Prem)
, ' '::char(1) as PlanYTDAllocCompAmt                                   -- col AS Gross wages (excluding GTL & LTD Prem) 
--, eeptd.eepretaxdeferral               as eePreTaxDeferral              -- col AT should be the per pay Employee deduction
, ' '::char(1) as eePreTaxDeferral                                      -- col AT should be the per pay Employee deducti

, ' '::char(1) as ERMatchContribAmt                                     -- col AU should be the per pay Employer deduction
, ' '::char(1) as ProfitSharingContribAmt                               -- col AV
, ' '::char(1) as OtherContribAmt                                       -- col AW
, ' '::char(1) as eeAfterTaxContribAmt                                  -- col AX
-----, ppdvb2.etv_amount                    as PretaxCUpContribAmt           -- col AY should have the PreTax EE Catchup Amount (per pay) 
, ' '::char(1) as PretaxCUpContribAmt                                   -- col AY should have the PreTax EE Catchup Amount (per pay) 
, ' '::char(1) as QNECContribAmt                                        -- col AZ
, ' '::char(1) as QMACContribAmt                                        -- col BA
, ' '::char(1) as MoneyPurchaseContribAmt	                              -- col BB

--, shm.safeharbormatch                  as safeharbormatch               -- col BC as safeharborMatch the per pay Company Match amount 
, ' '::char(1) as safeharbormatch                                       -- col BC as safeharborMatch the per pay Company Match amount 

, ' '::char(1) as SafeHarborNonElectiveContribAmt                       -- col BD

--, ppdvb3.etv_amount                    as rothDeferral                  -- col BE roth deferrel
, ' '::char(1) as rothDeferral                                          -- col BE roth deferrel

, ' '::char(1) as OtherContribAmt                                       -- col BF
-----, ppdvb4.etv_amount                    as RothCUContribAmt              -- col BG Roth Catch Up Contribution Amount
, ' '::char(1) as RothCUContribAmt                                      -- col BG Roth Catch Up Contribution Amount
, ' '::char(1) as OtherContribAmt                                       -- col BH
, ' '::char(1) as LoanNbrForLoanRepayment1                              -- col BI

--, ppdv65.etv_amount                    as loan1payment                  -- col BJ loan repayment
, ' '::char(1) as loan1payment                                          -- col BJ loan repayment
 
, ' '::char(1) as LoanNbrForLoanRepayment2                              -- col BK
, ' '::char(1) as LoanRepayment2                                        -- col BL
, ' '::char(1) as LoanNbrForLoanRepayment3                              -- col BM
, ' '::char(1) as LoanRepayment3                                        -- col BN
, ' '::char(1) as LoanNbrForLoanRepayment4                              -- col BO
, ' '::char(1) as LoanRepayment4                                        -- col BP
, ' '::char(1) as LoanNbrForLoanRepayment5                              -- col BQ
, ' '::char(1) as LoanRepayment5                                        -- col BR
, ' '::char(1) as LoanNbrForLoanRepayment6                              -- col BS
, ' '::char(1) as LoanRepayment6                                        -- col BT
, ' '::char(1) as LoanNbrForLoanRepayment7                              -- col BU
, ' '::char(1) as LoanRepayment7                                        -- col BV
, ' '::char(1) as LoanNbrForLoanRepayment8                              -- col BW
, ' '::char(1) as LoanRepayment8                                        -- col BX
, ' '::char(1) as LoanNbrForLoanRepayment9                              -- col BY
, ' '::char(1) as LoanRepayment9                                        -- col BZ
, ' '::char(1) as LoanNbrForLoanRepayment10                             -- col CA
, ' '::char(1) as LoanRepayment10	                                    -- col CB
, '3'::char(1) as querysource
      
      
from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'AOL_Wellsfargo_401K_Eligibility_Export'

left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

left join edi.etl_employment_data eed 
  on eed.personid = pi.personid
  
JOIN person_identity piE
  on piE.personid = pi.personid
 and current_timestamp between piE.createts and piE.endts
 and piE.identitytype = 'EmpNo'  

join person_identity piP 
  on piP.personid = pi.personid
 and current_timestamp between piP.createts and piP.endts
 and piP.identitytype = 'PSPID'
 
JOIN person_names pn 
  ON pn.personid = pi.personid
 and pn.nametype = 'Legal'  
 AND current_date BETWEEN pn.effectivedate AND pn.enddate
 AND current_timestamp BETWEEN pn.createts AND pn.endts      

 
LEFT JOIN person_address pa 
  ON pa.personid = pi.personid
 AND current_date BETWEEN pa.effectivedate AND pa.enddate
 AND current_timestamp BETWEEN pa.createts AND pa.endts      

 
JOIN person_vitals pv
  ON pv.personid = pi.personid 
 AND current_date BETWEEN pv.effectivedate AND pv.enddate
 AND current_timestamp BETWEEN pv.createts AND pv.endts    
 AND pv.enddate > now() 
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 

where pi.identitytype in ('SIN', 'SSN')
  and current_timestamp between pi.createts and pi.endts
  ---- don't pull new hires as name changes
  and pe.emplstatus = 'A'
  and pe.emplevent <> 'Hire'
  and (pn.effectivedate >= elu.lastupdatets::DATE 
   or (pn.createts > elu.lastupdatets and pn.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 

union

select distinct
  pi.personid
, 'address change record' ::char(25) qsource
, pa.effectivedate
, pe.emplstatus
, pc.enddate

, 'WFEM0EZG' ::char(8) as plancode                                      -- col A
--, to_char(coalesce(ppd_401k.check_date,ppd_Roth.check_date,ppd_ERmatch.check_date),'mm/dd/yyyy') as check_date
, to_char(current_date,'mm/dd/yyyy')::char(10) as check_date --col B
, ' ' ::char(5) as funding_code                                         -- col C   
, left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn --col D
, pn.fname ::char(14) as firstname                                      -- col E
, pn.mname ::char(1)  as mi                                             -- col F
, pn.lname ::char(30) as lastname                                       -- col G
, '"'||piE.identity||'"' ::char(11) as employeenbr                      -- col H
, '"'||pa.streetaddress||'"'   ::char(30) as addr1                      -- col I                
, '"'||pa.streetaddress2||'"'  ::char(20) as addr2                      -- col J
, pa.city ::char(30) as city                                            -- col K
, pa.stateprovincecode ::char(2) as state                               -- col L
, pa.postalcode ::char(10) as zip                                       -- col M

,case when pa.countrycode <> 'US' then pa.countrycode else ' ' end ::char(2) as Country -- col N	
, ' '::char(1) as PhoneNumber	                                          -- col O
, ' '::char(1) as EmailAddress	                                       -- col P  
, ' '::char(1) as DivisionCode	                                       -- col Q
, ' '::char(1) as ExtraDivisionCode	                                    -- col R
, ' '::char(1) as WorkLocation                                          -- col S


, case pe.emplstatus 
      when 'A' then 'ACTV'
      when 'T' then 'TERM'
      when 'L' then 'LEAV'
      else 'ACTV' end ::char(4) as participant_status                   -- col T


, ' '::char(1) as PayStatus                                             -- col U 	
, ' '::char(1) as HighlyCompensatedStatus	                              -- col V
, ' '::char(1) as TopHeavyStatusCode                                    -- col W
, ' '::char(1) as I6BInsider	                                          -- col X
, ' '::char(1) as PlanEntryEligibilityDate                              -- col Y
      
      
, to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as birthdate            -- col Z

, to_char(pe.emplsenoritydate,'mm/dd/yyyy')::char(10) as orig_hire_date -- col AA

, case when pe.empllasthiredate = pe.emplsenoritydate then ' ' 
       else to_char(pe.empllasthiredate,'mm/dd/yyyy')
        end ::char(10)                                as last_hire_date -- col AB
        
, case when pe.emplstatus = 'T' then to_char(eed.empleffectivedate,'mm/dd/yyyy')
       else null end  ::char(10) as termdate                            -- col AC
       
, ' '::char(1) as DeathDate                                             -- col AD
, ' '::char(1) as AlternativeVestingDate                                -- col AE

    
,pc.frequencycode    
, case when eed.schedulefrequency = 'B' then '1'
       when eed.schedulefrequency = 'W' then '0'
       when eed.schedulefrequency = 'H' then '0'
       when eed.schedulefrequency = 'M' then '3'
       when eed.schedulefrequency = 'S' then '2'
       when eed.schedulefrequency = 'Q' then '4'
       when eed.schedulefrequency = 'A' then '2'
       when pc.frequencycode = 'A' then '2'
       when pc.frequencycode = 'H' then '1'
       end ::char(1) as payrollFreq                                      -- col AF
      
, case pv.gendercode 
      when 'M' then '1'
      when 'F' then '2'
      else '0' end ::char(1) as gender                                  -- col AG
   
, ' '::char(1) as MaritalStatus                                         -- col AH
, ' '::char(1) as LanguageIndicator                                     -- col AI
, ' '::char(1) as FederalTaxExemptions                                  -- col AJ
, ' '::char(1) as TaxFilingStatus                                       -- col AK
, ' '::char(1) as UnionStatus                                           -- col AL 
    
--, hw.ytdhours                          as hoursPlanYTD                  -- col AM Hours Plan YTD
, ' '::char(1) as hoursPlanYTD                                          -- col AM Hours Plan YTD
, ' '::char(1) as PriorMonthsofService                                  -- col AN
, ' '::char(1) as EligibilityMonthsofService                            -- col AO
--, hp.ytd_taxable_wage                  as PlanYTD401KCompAmt            -- col AP Gross wages (excluding GTL & LTD Prem)
, ' '::char(1) as PlanYTD401KCompAmt                                    -- col AP Gross wages (excluding GTL & LTD Prem)
--, ytd_taxable_wage                     as PlanYTDW2CompAmt              -- col AQ Gross wages (excluding GTL & LTD Prem)
, ' '::char(1) as PlanYTDW2CompAmt                                      -- col AQ Gross wages (excluding GTL & LTD Prem)


, case 
      when pc.frequencycode      = 'A' then cast (pc.compamount as dec (18,2))
      --when pc.frequencycode = 'H' then (pc.compamount * 2080 * pe.emplfulltimepercent)
      when pc.frequencycode      = 'H' then cast ( (pc.compamount * 2080) as dec (18,2))
      when eed.schedulefrequency = 'B' then cast ( (pc.compamount * 2080) as dec (18,2))
      end                              as annualSalary                  -- col AR

--,' ' ::char(1) as annualSalary                  -- col AR      
--, HP.ytd_taxable_wage                   as PlanYTDAllocCompAmt           -- col AS Gross wages (excluding GTL & LTD Prem) 
, ' '::char(1) as PlanYTDAllocCompAmt                                   -- col AS Gross wages (excluding GTL & LTD Prem) 
--, eeptd.eepretaxdeferral               as eePreTaxDeferral              -- col AT should be the per pay Employee deduction
, ' '::char(1) as eePreTaxDeferral                                      -- col AT should be the per pay Employee deducti

, ' '::char(1) as ERMatchContribAmt                                     -- col AU should be the per pay Employer deduction
, ' '::char(1) as ProfitSharingContribAmt                               -- col AV
, ' '::char(1) as OtherContribAmt                                       -- col AW
, ' '::char(1) as eeAfterTaxContribAmt                                  -- col AX
-----, ppdvb2.etv_amount                    as PretaxCUpContribAmt           -- col AY should have the PreTax EE Catchup Amount (per pay) 
, ' '::char(1) as PretaxCUpContribAmt                                   -- col AY should have the PreTax EE Catchup Amount (per pay) 
, ' '::char(1) as QNECContribAmt                                        -- col AZ
, ' '::char(1) as QMACContribAmt                                        -- col BA
, ' '::char(1) as MoneyPurchaseContribAmt	                              -- col BB

--, shm.safeharbormatch                  as safeharbormatch               -- col BC as safeharborMatch the per pay Company Match amount 
, ' '::char(1) as safeharbormatch                                       -- col BC as safeharborMatch the per pay Company Match amount 

, ' '::char(1) as SafeHarborNonElectiveContribAmt                       -- col BD

--, ppdvb3.etv_amount                    as rothDeferral                  -- col BE roth deferrel
, ' '::char(1) as rothDeferral                                          -- col BE roth deferrel

, ' '::char(1) as OtherContribAmt                                       -- col BF
-----, ppdvb4.etv_amount                    as RothCUContribAmt              -- col BG Roth Catch Up Contribution Amount
, ' '::char(1) as RothCUContribAmt                                      -- col BG Roth Catch Up Contribution Amount
, ' '::char(1) as OtherContribAmt                                       -- col BH
, ' '::char(1) as LoanNbrForLoanRepayment1                              -- col BI

--, ppdv65.etv_amount                    as loan1payment                  -- col BJ loan repayment
, ' '::char(1) as loan1payment                                          -- col BJ loan repayment
 
, ' '::char(1) as LoanNbrForLoanRepayment2                              -- col BK
, ' '::char(1) as LoanRepayment2                                        -- col BL
, ' '::char(1) as LoanNbrForLoanRepayment3                              -- col BM
, ' '::char(1) as LoanRepayment3                                        -- col BN
, ' '::char(1) as LoanNbrForLoanRepayment4                              -- col BO
, ' '::char(1) as LoanRepayment4                                        -- col BP
, ' '::char(1) as LoanNbrForLoanRepayment5                              -- col BQ
, ' '::char(1) as LoanRepayment5                                        -- col BR
, ' '::char(1) as LoanNbrForLoanRepayment6                              -- col BS
, ' '::char(1) as LoanRepayment6                                        -- col BT
, ' '::char(1) as LoanNbrForLoanRepayment7                              -- col BU
, ' '::char(1) as LoanRepayment7                                        -- col BV
, ' '::char(1) as LoanNbrForLoanRepayment8                              -- col BW
, ' '::char(1) as LoanRepayment8                                        -- col BX
, ' '::char(1) as LoanNbrForLoanRepayment9                              -- col BY
, ' '::char(1) as LoanRepayment9                                        -- col BZ
, ' '::char(1) as LoanNbrForLoanRepayment10                             -- col CA
, ' '::char(1) as LoanRepayment10	                                    -- col CB
, '4'::char(1) as querysource
      
      
from person_identity pi

JOIN edi.edi_last_update elu
  ON elu.feedid = 'AOL_Wellsfargo_401K_Eligibility_Export'

left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 

left join edi.etl_employment_data eed 
  on eed.personid = pi.personid
  
JOIN person_identity piE
  on piE.personid = pi.personid
 and current_timestamp between piE.createts and piE.endts
 and piE.identitytype = 'EmpNo'  

join person_identity piP 
  on piP.personid = pi.personid
 and current_timestamp between piP.createts and piP.endts
 and piP.identitytype = 'PSPID'
 
JOIN person_names pn 
  ON pn.personid = pi.personid
 and pn.nametype = 'Legal'  
 AND current_date BETWEEN pn.effectivedate AND pn.enddate
 AND current_timestamp BETWEEN pn.createts AND pn.endts      
 AND pn.enddate > now() 
 
LEFT JOIN person_address pa 
  ON pa.personid = pi.personid
 AND current_date BETWEEN pa.effectivedate AND pa.enddate
 AND current_timestamp BETWEEN pa.createts AND pa.endts      

 
JOIN person_vitals pv
  ON pv.personid = pi.personid 
 AND current_date BETWEEN pv.effectivedate AND pv.enddate
 AND current_timestamp BETWEEN pv.createts AND pv.endts    
 AND pv.enddate > now() 
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 

  
where pi.identitytype in ('SIN', 'SSN')
  and current_timestamp between pi.createts and pi.endts
  ---- don't pull new hires as address changes  
  and pe.emplstatus = 'A'
  and pe.emplevent <> 'Hire'  
  and (pa.effectivedate >= elu.lastupdatets::DATE 
   or (pa.createts > elu.lastupdatets and pa.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 

