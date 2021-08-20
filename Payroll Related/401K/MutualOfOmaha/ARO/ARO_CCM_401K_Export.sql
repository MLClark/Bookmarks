select distinct
 pi.personid
,pip.identity
,'G35767' ::char(6) as contract_nbr
,' '::char(1) as division
,pne.fname ::varchar(30) as fname
,pne.mname ::char(1) as mname
,lname ::varchar(30) as lname
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn
,pve.gendercode ::char(1) as gender
,case when pe.emplstatus = 'A' then ' ' 
      when pe.emplstatus = 'P' then ' ' else pe.emplstatus end ::char(1) as emplstatus
,'N' ::char(1) as union_status 
,pae.streetaddress ::varchar(50) as addr1
,pae.streetaddress2::varchar(50) as addr2
,pae.city::varchar(25) as city
,pae.stateprovincecode::char(2) as state
,pae.postalcode::varchar(10) as zip
,to_char(pve.birthdate,'MM/DD/YYYY')::char(10) as dob
,to_char(pe.emplhiredate,'MM/DD/YYYY') ::char(10) as doh
,to_char(pe.empllasthiredate,'MM/DD/YYYY') ::char(10) as rehire_date
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'MM/DD/YYYY') else ' ' end ::char(10) as term_date
,to_char(ppd.check_date,'MM/DD/YYYY')::char(10) as paydate
,hw.taxable_wage as e415_earnings -- all 401k wages see Anita's Template
,hw.taxable_wage as plan_earnings -- all 401k wages see Anita's Template
,hw.hours as hours --hours paid
,' ' as excluded_earnings -- leave blank
,ppdvb1.etv_amount as eePreTaxDeferral -- Report everyone whether deferrred or not - Pre Taxed 401(k) - Employee Deferral 
,ppdvb3.etv_amount as rothDeferral    -- roth deferrel - employee roth
,' ' as eeAfterTaxDeferral -- leave blank
,' ' as erMatch -- leave blank
,' ' as safeharbormatch -- leave blank
,' ' as Qualified_Matching_Contribution -- leave blank
,' ' as Safe_Harbor_NonElective --leave blank
,' ' as qualified_non_elective_contrib  -- leave blank
,' ' as profit_sharing  -- leave blank
,' ' as money_purchase  -- leave blank
,' ' as rollover   -- leave blank    
,' ' as rollover_roth   -- leave blank
,case when ppdv65.etv_amount is not null then ppd.payment_number else null end as loan_number1  -- Anita to provide - custom field in payroll profile called loan number
,ppdv65.etv_amount as loan1payment  -- only provide this amount field.  Employees aren't allowed to have two open loans.  Only one at a time.
,' ' as loan_number2  -- leave blank
,' ' as loan_payment2  -- leave blank
,' ' as loan_number3  -- leave blank
,' ' as loan_payment3  -- leave blank
,' ' as loan_number4  -- leave blank
,' ' as loan_payment4  -- leave blank

from person_identity pi

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts 
 
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
                 ,etype_hours AS hours
                 ,etv_amount as taxable_wage
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
            WHERE etv_id in  ('E01')           
              --AND date_part('year', check_date) = date_part('year',now())
              AND check_date = ?::DATE
         --GROUP BY individual_key
          ) hw
  ON hw.individual_key = piP.identity


left JOIN (SELECT individual_key
                 ,sum(etv_amount) as eepretaxdeferral
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
            WHERE etv_id in  ('VB1')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date = ?::DATE
         GROUP BY individual_key
          ) eeptd
  ON eeptd.individual_key = piP.identity
  
left JOIN (SELECT individual_key
                 ,sum(etv_amount) as safeharbormatch
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
            WHERE etv_id in  ('VB5')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date = ?::DATE
         GROUP BY individual_key
          ) shm
  ON shm.individual_key = piP.identity
  

left JOIN (SELECT individual_key
                 ,coalesce(sum(etv_amount),0) as imputed_partner_earnings
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
            WHERE etv_id in  ('E46')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date <= ?::DATE
         GROUP BY individual_key
          ) ipe
  ON ipe.individual_key = piP.identity
 

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
 
 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pe.emplstatus not in ('A','P')