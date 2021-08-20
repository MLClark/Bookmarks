select distinct
 pi.personid
,piP.identity 
,'502939-01' ::char(13) as plan_number
,replace(pi.identity,'-','') ::char(11) as ssn 
,ltrim(pne.lname,' ') ::varchar(20) as lname
,ltrim(pne.fname,' ') ::varchar(35) as fname
,ltrim(pne.mname,' ') ::varchar(1) as mname
,pne.title ::char(4) as title
,to_char(pve.birthdate,'MM/DD/YYYY')::char(10) as dob 
,pv.gendercode ::char(1) as gender
,case when pm.maritalstatus = 'R' then 'M' else coalesce(pm.maritalstatus,'S') end ::char(1) as maritalstatus
,replace(pae.streetaddress,',',' ') ::varchar(30) as addr1
,replace(pae.streetaddress2,',',' ') ::varchar(30) as addr2
,ltrim(pae.city,' ') ::varchar(25) as city
,pae.stateprovincecode ::char(2) as state
,ltrim(pae.postalcode,' ') ::varchar(10) as zip
,pncw.url::varchar(100) as email
,replace(ppcH.phoneno,'-','') ::char(15) as homephone
,replace(ppcW.phoneno,'-','') ::char(15) as workphone
,substring(ppcW.phoneno,11,5) ::char(5) as workphone_ext
,pae.countrycode ::char(3) as country
,to_char(pe.emplhiredate,'MM/DD/YYYY')::char(10) as doh 

,case when pe.emplstatus = 'T' then to_char(pe.enddate,'MM/DD/YYYY') 
      when pe.emplstatus = 'A' and pe.empllasthiredate > pe.emplhiredate THEN TO_CHAR(pe_term.enddate,'MM/DD/YYYY')
      else ' ' end ::char(10) as termdate

,case when pe.empllasthiredate > pe.emplhiredate then to_char(pe.empllasthiredate,'MM/DD/YYYY') else ' ' end ::char(10) as rehiredate 
,to_char(ppd.check_date,'MM/DD/YYYY')::char(10) as paydate

,dedamt.vb1_amount + dedamt.vb2_amount as "Employee Before Tax Contribution (BTK1)"
,dedamt.vb3_amount + dedamt.vb4_amount as "Employee Roth Contribution (RTH1)"
,dedamt.vb5_amount AS "Employer Match Amount (ERM1)"
,dedamt.v65_amount AS "Loan Repayment Amount (LON1)"
,case when dedamt.vb1_amount <> 0 then dedamt.vb1_amount else null end as eePreTaxDeferral                -- Pre Taxed 401(k) - Employee Deferral  
,case when dedamt.vb3_amount <> 0 then dedamt.vb3_amount else null end as rothDeferral                    -- roth deferrel - employee roth
,case when dedamt.vb5_amount <> 0 then dedamt.vb5_amount else null end as erMatch                         -- 403BCMAE Employer Match 
,0 as oercontrib                                      -- OTHER EMPLOYER CONTRIBUTIONS (ERO 01)
,case when dedamt.v65_amount <> 0 then dedamt.v65_amount else null end as loanamt                         -- loan amount
,ytdcomp.hours as hours
,ytdcomp.taxable_wage as PlanYTD401KCompAmt           -- col AP Gross wages (excluding GTL & LTD Prem)
, case when pc.frequencycode = 'A' and ipe.imputed_partner_earnings is null then pc.compamount
       when pc.frequencycode = 'A' and ipe.imputed_partner_earnings is not null then (pc.compamount - ipe.imputed_partner_earnings)
       when pc.frequencycode = 'H' and ipe.imputed_partner_earnings is null then (pc.compamount * 2080 ) 
       when pc.frequencycode = 'H' and ipe.imputed_partner_earnings is not null then ((pc.compamount * 2080 ) - ipe.imputed_partner_earnings)
       end    as PlanYTDW2CompAmt     
,pc.hce_ind
,pc.compamount as annualSalary     
,pc.frequencycode as sal_qualifier

 
from person_identity pi

left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts 
 
left join (select personid, compamount, increaseamount, compevent, frequencycode, hce_ind, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode, hce_ind) as pc on pc.personid = pi.personid and pc.rank = 1  
 
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
 AND ppd.check_date = ?::DATE
 and ppd.individual_key = piP.identity

-- ee total hours 
-- ee total gross based on federal tax

LEFT JOIN (SELECT personid
                 ,sum(etype_hours) AS hours
                 ,sum(etv_amount)  as taxable_wage
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
             -- 6/16 feedback need holiday pay included in ytd totals adding ECZ, EC8, E17
            WHERE etv_id in  ('E01','E02','E03','E15','E19','E18','E08', 'E61','E05')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date <= ?::DATE
         GROUP BY personid
          ) ytdcomp
  ON ytdcomp.personid = pi.personid  

left JOIN (SELECT personid
                 ,coalesce(sum(etv_amount),0) as imputed_partner_earnings
             FROM pspay_payment_detail            
             -- Hours include Reg,OT,DT,PTO,Jury,Bereavement - exclude reg shift and OT shift
            WHERE etv_id in  ('E46')           
              AND date_part('year', check_date) = date_part('year',now())
              AND check_date <= ?::DATE
         GROUP BY personid
          ) ipe
  ON ipe.personid = pi.personid

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 
left join person_employment pe_term
  on pe_term.personid = pi.personid
 and pe_term.enddate <> '2199-12-31'
 --and current_date between pe_term.effectivedate and pe_term.enddate
 --and current_timestamp between pe_term.createts and pe_term.endts  
 
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

left join 
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.v25_amount) as v25_amount
,sum(x.v65_amount) as v65_amount
,sum(x.vcq_amount) as vcq_amount
from
 

(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'V25' then etv_amount  else 0 end as v25_amount
,case when ppd.etv_id = 'V65' then etv_amount  else 0 end as v65_amount
,case when ppd.etv_id = 'VCQ' then etv_amount  else 0 end as vcq_amount
,psp.periodpaydate
,ppd.paymentheaderid

from person_identity pi

join pay_schedule_period psp 
  on psp.payrolltypeid = 1
 and psp.processfinaldate is not null
 and psp.periodpaydate = ?::date

join pspay_payment_header pph
  on pph.check_date = psp.periodpaydate
 and pph.payscheduleperiodid = psp.payscheduleperiodid 
 
join pspay_payment_detail ppd 
  on ppd.personid = pi.personid
 and ppd.check_date = psp.periodpaydate
 and pph.paymentheaderid = ppd.paymentheaderid

where pi.identitytype = 'SSN'::bpchar 
  AND current_timestamp between pi.createts and pi.endts and ppd.etv_id  in  ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')) x
  group by 1,2 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.v25_amount + x.v65_amount + x.vcq_amount) <> 0) dedamt on dedamt.personid = pi.personid 
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts

