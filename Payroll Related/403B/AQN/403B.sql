select distinct
 pi.personid 
,pip.identity
,'1009884-01' ::char(10) as plannbr
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4)::char(11) as essn
,' ' ::char(1) as divnbr
,rtrim(pne.lname,' ') as lname
,rtrim(pne.fname,' ') as fname
---,rtrim(pne.mname,' ') as mname --- Column F – This data is not required. – Ashaffer: Okay, I will ask to have it removed.
,' ' ::char(1) as mname
,rtrim(pne.title,' ') as name_suffix
,to_char(pve.birthdate,'mm/dd/yyyy')::char(10) as dob
,pve.gendercode ::char(1) as gender
,coalesce(pmse.maritalstatus,'S') ::char(1) as maritalstatus
,rtrim(pae.streetaddress,' ') as addr1
,rtrim(pae.streetaddress2,' ') as addr2
,rtrim(pae.city,' ') as city
,rtrim(pae.stateprovincecode,' ') as state
,rtrim(pae.postalcode,' ') as zip
,coalesce(ppcH.phoneno,ppcM.phoneno) ::char(10) as homephone
,coalesce(ppcW.phoneno,ppcB.phoneno) ::char(10) as workphone
,substring(ppcW.phoneno,11,5) ::char(5) as workphone_ext
--,rtrim(pae.countrycode,' ') as countrycode --Column S - This data is not required. – Ashaffer: Okay, I will ask to have it removed.
,' ' ::char(1) as countrycode
,to_char(pe.emplhiredate,'MM/DD/YYYY') ::char(10) as emp_doh
,case when pe.emplstatus = 'T' then to_char(pe.enddate,'MM/DD/YYYY') else ' ' end ::char(10) as termdate
,case when pe.empllasthiredate > pe.emplhiredate then to_char(pe.empllasthiredate,'MM/DD/YYYY') else ' ' end ::char(10) as rehiredate 
--Column V – Re-Hire Date – This should only be populated if the employee is rehired.  Ashaffer: This one will not be corrected until the 3rd test file as Julius will need to load the Re-hire 
,to_char(ppd.check_date,'MM/DD/YYYY')::char(10) as paydate

      
,ppdvb1.etv_amount as eePreTaxDeferral              -- Pre Taxed 401(k) - Employee Deferral  
,ppdvb5.etv_amount as erMatch                       -- 403BCMAE Employer Match
,ppdvb3.etv_amount as rothDeferral    -- roth deferrel - employee roth
,'0' ::char(1) as contrib4
,ppdv65.etv_amount as loan1payment                  -- loan repayment Column AB – This should be the current loan deduction amount.
,' ' ::char(1) as contrib6  --Columns AC –AE – These can be blank  Ashaffer: Okay, I will ask to have it removed
,' ' ::char(1) as contrib7
,' ' ::char(1) as contrib8

,hw.ytdhours       as hoursPlanYTD                  -- Hours Plan YTD 
,ytd_taxable_wage  as PlanYTD401KCompAmt            -- Gross wages (excluding GTL & LTD Prem)

, case 
      when pc.frequencycode = 'A' and ipe.imputed_partner_earnings is null then pc.compamount
      when pc.frequencycode = 'A' and ipe.imputed_partner_earnings is not null then (pc.compamount - ipe.imputed_partner_earnings)
      --when pc.frequencycode = 'H' then (pc.compamount * 2080 * pe.emplfulltimepercent)
      when pc.frequencycode = 'H' and ipe.imputed_partner_earnings is null then (pc.compamount * 2080 ) 
      when pc.frequencycode = 'H' and ipe.imputed_partner_earnings is not null then ((pc.compamount * 2080 ) - ipe.imputed_partner_earnings)
      end    as PlanYTDW2CompAmt                -- Column AH – This should be the YTD total compensation minus the domestic Partner  imputed. (TC15-OE46)
     
,ipe.imputed_partner_earnings as pre_entry_comp   -- Column AI – This should be the YTD total compensation for domestic Partner. (E46) 
,pc.hce_ind
,' ' ::char(1) as pct_of_ownership
,' ' ::char(1) as officer_det
,to_char(ppd.check_date,'MM/DD/YYYY') ::char(10) as participation_date --Column AM – Participation Date – This should match the payroll date
,'Y' ::char(1) as elig_code
,' ' ::char(1) as b4_tax_pct
,' ' ::char(1) as b4_tax_amt
,' ' ::char(1) as af_tax_pct
,' ' ::char(1) as af_tax_amt
,' ' ::char(1) as email_addr
,' ' ::char(1) as sal_amt
,' ' ::char(1) as sal_amt_qual
,' ' ::char(1) as term_rsn_cd
,' ' ::char(1) as sar_ox_ind
,' ' ::char(1) as fed_exempt
,' ' ::char(1) as empid
,' ' ::char(1) as comply_code







,ppdvb2.etv_amount as PretaxCUpContribAmt           -- PreTax EE Catchup Amount (per pay) 

,coalesce(ppdvb4.etv_amount,'0') as RothCU          -- Roth Catch Up Contribution Amount






from person_identity pi

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts 

left join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts

left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts

left join person_maritalstatus pmse
  on pmse.personid = pi.personid
 and current_date between pmse.effectivedate and pmse.enddate
 and current_timestamp between pmse.createts and pmse.endts
 
LEFT JOIN person_employment pe 
  ON pe.personid = pi.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_address pae 
  on pae.personid = pi.personid
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts
 
left JOIN person_phone_contacts ppch ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'
left JOIN person_phone_contacts ppcw ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'   
left JOIN person_phone_contacts ppcb ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'      
left JOIN person_phone_contacts ppcm ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'  
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
 
join pspay_payment_detail ppd
  on ppd.etv_id IN ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')
 AND ppd.check_date = ?::DATE
 and ppd.individual_key = piP.identity
 
 
-- Pre Taxed 401(k)                             
LEFT JOIN pspay_payment_detail ppdvb1
  ON ppdvb1.individual_key  = ppd.individual_key
 AND ppdvb1.check_date      = ppd.check_date
 AND ppdvb1.check_number    = ppd.check_number
 AND ppdvb1.payment_number  = ppd.payment_number
 AND ppdvb1.etv_code        = ppd.etv_code
 AND ppdvb1.etv_id          = 'VB1'
-- Pre Taxed 401(k) Catch Up  
LEFT JOIN pspay_payment_detail ppdvb2
  ON ppdvb2.individual_key  = ppd.individual_key
 AND ppdvb2.check_date      = ppd.check_date
 AND ppdvb2.check_number    = ppd.check_number
 AND ppdvb2.payment_number  = ppd.payment_number
 AND ppdvb2.etv_code        = ppd.etv_code
 AND ppdvb2.etv_id          = 'VB2'                  
-- roth
LEFT JOIN pspay_payment_detail ppdvb3
  ON ppdvb3.individual_key  = ppd.individual_key
 AND ppdvb3.check_date      = ppd.check_date
 AND ppdvb3.check_number    = ppd.check_number
 AND ppdvb3.payment_number  = ppd.payment_number
 AND ppdvb3.etv_code        = ppd.etv_code
 AND ppdvb3.etv_id          = 'VB3' 
-- Roth Catch Up                                
LEFT JOIN pspay_payment_detail ppdvb4
  ON ppdvb4.individual_key  = ppd.individual_key
 AND ppdvb4.check_date      = ppd.check_date
 AND ppdvb4.check_number    = ppd.check_number
 AND ppdvb4.payment_number  = ppd.payment_number
 AND ppdvb4.etv_code        = ppd.etv_code
 AND ppdvb4.etv_id          = 'VB4' 
-- 401KCMAE
LEFT JOIN pspay_payment_detail ppdvb5
  ON ppdvb5.individual_key  = ppd.individual_key
 AND ppdvb5.check_date      = ppd.check_date
 AND ppdvb5.check_number    = ppd.check_number
 AND ppdvb5.payment_number  = ppd.payment_number
 AND ppdvb5.etv_code        = ppd.etv_code
 AND ppdvb5.etv_id          = 'VB5' 
-- loan 1


left JOIN pspay_payment_detail ppdv65
  ON ppdv65.individual_key  = ppd.individual_key
 AND ppdv65.check_date      = ppd.check_date
 AND ppdv65.check_number    = ppd.check_number
 AND ppdv65.payment_number  = ppd.payment_number
 AND ppdv65.etv_code        = ppd.etv_code
 AND ppdv65.etv_id          = 'V65'    





-- ee total hours 
-- ee total gross based on federal tax
LEFT JOIN (SELECT individual_key
                 ,sum(etype_hours) AS ytdhours
                 ,sum(etv_amount) as ytd_taxable_wage
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
            WHERE etv_id in  ('E01','E02','E03','E15','E19','E18','E08', 'E61','E05','E07')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date <= ?::DATE
         GROUP BY individual_key
          ) hw
  ON hw.individual_key = piP.identity

left JOIN (SELECT individual_key
                 ,sum(etv_amount) as eepretaxdeferral
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VB1')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date = ?::DATE
         GROUP BY individual_key
          ) eeptd
  ON eeptd.individual_key = piP.identity
  
left JOIN (SELECT individual_key
                 ,sum(etv_amount) as safeharbormatch
             FROM pspay_payment_detail            
            WHERE etv_id in  ('VB5')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date = ?::DATE
         GROUP BY individual_key
          ) shm
  ON shm.individual_key = piP.identity
  

left JOIN (SELECT individual_key
                 ,coalesce(sum(etv_amount),0) as imputed_partner_earnings
             FROM pspay_payment_detail            
            WHERE etv_id in  ('E46')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date <= ?::DATE
         GROUP BY individual_key
          ) ipe
  ON ipe.individual_key = piP.identity
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  
  --and pi.personid = '4698'
  order by 1
  ;
  
  