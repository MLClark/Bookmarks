select distinct
 pi.personid
,piP.identity 
--,'502939-01' ::char(13) as plan_number
,lu.value1   ::char(13) as plan_number
,replace(pi.identity,'-','') ::char(11) as ssn 
,substring(pip.identity,1,5) ::char(20) as divnbr


,ltrim(pne.lname,' ') ::char(35) as lname
,ltrim(pne.fname,' ') ::char(20) as fname
,ltrim(pne.mname,' ') ::char(20) as mname
,pne.title ::char(15) as name_suffix
,to_char(pve.birthdate,'MM/DD/YYYY')::char(10) as dob 
,pv.gendercode ::char(1) as gender
--,coalesce(pm.maritalstatus,'S') ::char(1) maritalstatus
,case when pm.maritalstatus = 'R' then 'M' else coalesce(pm.maritalstatus,'S') end ::char(1) as maritalstatus
,replace(pae.streetaddress,',',' ') ::char(35) as addr1
,replace(pae.streetaddress2,',',' ') ::char(35) as addr2
,ltrim(pae.city,' ') ::char(20) as city
,upper(pae.stateprovincecode) ::char(2) as state
,ltrim(pae.postalcode,' ') ::char(10) as zip
,replace(ppcH.phoneno,'-','') ::char(10) as homephone
,replace(ppcW.phoneno,'-','') ::char(10) as workphone

,' ' ::char(4) as workphone_ext
,pae.countrycode ::char(2) as country_code
,to_char(pe.emplhiredate,'MM/DD/YYYY')::char(10) as doh 
,case when pe.emplstatus = 'T' then to_char(pe.enddate,'MM/DD/YYYY') 
      when pe.emplstatus = 'A' and pe.empllasthiredate > pe.emplhiredate THEN TO_CHAR(pe_term.enddate,'MM/DD/YYYY')
      else ' ' end ::char(10) as termdate
,case when pe.empllasthiredate > pe.emplhiredate then to_char(pe.empllasthiredate,'MM/DD/YYYY') else ' ' end ::char(10) as rehiredate 
,to_char(ppd.check_date,'MM/DD/YYYY')::char(10) as checkdate

,to_char(COALESCE(ppdvb1.etv_amount,0) + COALESCE(ppdvb2.etv_amount,0),'0000000d00') AS contribution_amount1 ----"Employee Before Tax Contribution (BTK01)"                                  -- OTHER EMPLOYER CONTRIBUTIONS (ERO 01)
,to_char(COALESCE(ppdvb5.etv_amount,0),'0000000d00')                                 AS contribution_amount2 ----"Employer Match Amount (ERM01)"
,to_char(COALESCE(ppdv65.etv_amount,0),'0000000d00')                                 AS contribution_amount3 ----"Loan Repayment Amount (LON01)"
,to_char(COALESCE(ppdvb3.etv_amount,0) + COALESCE(ppdvb4.etv_amount,0),'0000000d00') AS contribution_amount4 ----"Employee Roth Contribution (RTH01)"
,to_char(0,'0000000d00')                                                             AS contribution_amount5 -----as required by plan
,to_char(0,'0000000d00')                                                             AS contribution_amount6 -----as required by plan 
,to_char(0,'0000000d00')                                                             AS contribution_amount7 -----as required by plan  
,to_char(0,'0000000d00')                                                             AS contribution_amount8 -----as required by plan 
,to_char(pea.ytd_earn_hours,'00000')                                                 AS hours_worked
--,to_char(ytdcomp.taxable_wage,'0000000d00') as ytd_total_compensation           -- col AP Gross wages (excluding GTL & LTD Prem)
,to_char(grossytd.taxable_wage,'0000000d00') as ytd_total_compensation           -- col AP Gross wages (excluding GTL & LTD Prem)
, case 
      when pc.frequencycode  = 'A' and ipe.imputed_partner_earnings is null then to_char(pc.compamount,'00000000d00')
      when pc.frequencycode  = 'A' and ipe.imputed_partner_earnings is not null then to_char((pc.compamount - ipe.imputed_partner_earnings),'00000000d00')
     --when pc.frequencycode = 'H' then (pc.compamount * 2080 * pe.emplfulltimepercent)
      when pc.frequencycode  = 'H' and ipe.imputed_partner_earnings is null then to_char((pc.compamount * 2080 ) ,'00000000d00')
      when pc.frequencycode  = 'H' and ipe.imputed_partner_earnings is not null then to_char( ((pc.compamount * 2080 ) - ipe.imputed_partner_earnings),'00000000d00')
      when pc1.frequencycode = 'A' and ipe.imputed_partner_earnings is null then to_char(pc1.compamount,'00000000d00')
      when pc1.frequencycode = 'A' and ipe.imputed_partner_earnings is not null then to_char((pc1.compamount - ipe.imputed_partner_earnings),'00000000d00')
     --when pc.frequencycode = 'H' then (pc.compamount * 2080 * pe.emplfulltimepercent)
      when pc1.frequencycode = 'H' and ipe.imputed_partner_earnings is null then to_char((pc1.compamount * 2080 ) ,'00000000d00')
      when pc1.frequencycode = 'H' and ipe.imputed_partner_earnings is not null then to_char(((pc1.compamount * 2080 ) - ipe.imputed_partner_earnings),'00000000d00')
       end as ytd_plan_compensation 

,to_char(0,'00000000d00') as ytd_pre_entry_compensation
,pc.hce_ind ::char(1)     as highly_comp_emp_code
,to_char(0,'000000')      as pct_of_ownership
,' ' ::char(1)            as officer_determination
,to_char(pc.effectivedate,'MM/DD/YYYY') ::char(10) as participation_date
,'Y' ::char(1)            as eligibility_code
,to_char(0,'000')         as before_tax_contrib_pct
,to_char(0,'00000d00')    as before_tax_contrib_amt
,to_char(0,'000')         as after_tax_contrib_pct
,to_char(0,'00000d00')    as after_tax_contrib_amt


,pncw.url::varchar(40) as work_email
,to_char(coalesce(pc.compamount,pc1.compamount),'00000000000000d00') as salary_amt
,coalesce(pc.frequencycode,pc1.frequencycode) ::char(2)              as sal_amt_qualifier
,' '::char(20) as term_rsn_code
,' '::char(1)  as sarbanes_oxley_rpt_ind
,' '::char(2)  as fed_exemptions
,pie.identity  ::char(10) as employer_assigned_id
,' '::char(6)  as compliance_status_code
 
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
 
join 
(select distinct personid,frequencycode,max(compamount) compamount
   from person_compensation 
   --where personid = '1784'
 group by 1,2
) pc1
  on pc1.personid = pi.personid  
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts 
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.enddate 
 
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

join pspay_payment_header pph
  on pph.personid = pi.personid
 AND pph.check_date = ?::DATE
 and pph.individual_key = piP.identity 
 
join pspay_payment_detail ppd
  on ppd.etv_id IN ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')
 AND ppd.check_date<= ?::DATE
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
                 --,sum(etype_hours) AS ytdhours
                 ,sum(etv_amount) as taxable_wage
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
             -- 6/16 feedback need holiday pay included in ytd totals adding ECZ, EC8, E17
            WHERE etv_id in  ('E01','E02','E03','E15','E19','E18','E08', 'E61','E05')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date <= ?::DATE
         GROUP BY individual_key
          ) ytdcomp
  ON ytdcomp.individual_key = piP.identity  

--- 3/13/2018 using the WS15 operand to determine which etv's should be included for 401k taxable wage
LEFT JOIN (SELECT distinct personid
               ,sum(etype_hours) AS hours
               ,sum(etv_amount) as taxable_wage
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                             join pspay_etv_list b 
                               on a.etv_id = b.etv_id
                              and a.group_key = b.group_key
                            where a.operand = 'WS15' and a.etvindicator = 'E' group by 1)
              AND date_part('year', check_date) = date_part('year',?::DATE)
              AND check_date <= ?::DATE
         GROUP BY personid
          ) grossytd
  ON grossytd.personid = piP.personid     

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
 
left join person_employment pe_term
  on pe_term.personid = pi.personid
 and pe_term.enddate <> '2199-12-31'
 --and current_date between pe_term.effectivedate and pe_term.enddate
 --and current_timestamp between pe_term.createts and pe_term.endts  
 
left join person_vitals pve
  on pve.personid = pi.personid
 and current_date between pve.effectivedate and pve.enddate
 and current_timestamp between pve.createts and pve.endts  
 
join person_names pne
  on pne.personid = pi.personid
 and pne.nametype = 'Legal'
 and current_date between pne.effectivedate and pne.enddate
 and current_timestamp between pne.createts and pne.endts
  
left join person_address pae 
  on pae.personid = pi.personid
 and pae.addresstype = 'Res'
 and current_date between pae.effectivedate and pae.enddate
 and current_timestamp between pae.createts and pae.endts 
 
left join pspay_earning_accumulators pea
  on pea.individual_key = piP.identity 
 and pea.etv_id = 'E01'
 and pea.current_payroll_status = 'A'

join ( select lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname = 'Empower 401k Plan Number Lookup'
      ) lu on 1 = 1


where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  --and pi.personid = '1784'