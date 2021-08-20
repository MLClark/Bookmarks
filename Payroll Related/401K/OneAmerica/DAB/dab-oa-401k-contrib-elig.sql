select 
 pi.personid
,'Eligibility' as source_seq
,to_char(current_date,'yyyy-mm-dd')::char(10) as run_date
,to_char(elu.lastupdatets,'yyyy-mm-dd')::char(10) as lookback_date
,'Standlee Premium Forage (DAB)' as client_name
,'DAB_OneAmerica_401K_Export Control Report' as report_name
,cnbr.value1 ::char(6) as contract_nbr -- A
,dnbr.value1 ::char(4) as division --B
-- total of 30 characters combined for First, Middle and Last name can be used. 
-- First and last name may be in same column if separated by a space or delimiter.
,(pn.fname||' '||coalesce(pn.mname::char(1),'')||' '||pn.lname) ::char(30) as fullname --C,D,E 
,pi.identity as ssn --F
,pv.gendercode as gender --G
,pe.emplstatus --H
,' ' ::char(1) as union_status --I
,pa.streetaddress as addr1 --J
,pa.streetaddress2 as addr2 --K
,pa.city --L
,pa.stateprovincecode --M
,pa.postalcode --N
,to_char(pv.birthdate,'mm/dd/yyyy') as dob --O
,to_char(pe.emplhiredate,'mm/dd/yyyy') as doh --P
,to_char(pe.empllasthiredate,'mm/dd/yyyy') as ldoh --Q
,case when pe.emplstatus in ('R','T') then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end as termdate --R
,to_char(dedamt.check_date,'mm/dd/yyyy') as payroll_date --S
,' ' ::char(1) as e415_amount --T
,' ' ::char(1) as plan_earnings --U
,' ' ::char(1) as hours --V
,' ' ::char(1) as excluded_earnings --W
,(dedamt.vb1_amount + dedamt.vb2_amount) as ee_def  --X -- sum of VB1 & VB2 amounts from payroll, includes catchup amounts
,(dedamt.vb3_amount + dedamt.vb4_amount) as ee_roth --Y -- sum of VB3 & VB4 amounts from payroll, includes catchup amounts
,' ' ::char(1) as after_tax --Z
,' ' ::char(1) as er_match --AA
,dedamt.vb5_amount as safe_harbor_match --AB
,' ' ::char(1) as qual_matching_contrib --AC
,' ' ::char(1) as sh_non_elec --AD
,' ' ::char(1) as qual_non_elec --AE
,' ' ::char(1) as profit_share --AF
,' ' ::char(1) as money_purchase --AG
,' ' ::char(1) as rollover --AH
,' ' ::char(1) as ro_roth --AI
,case when loans.etv_id = 'V65' then loans.referencenumber end as loan_number1 --AJ
,case when loans.etv_id = 'V65' then loans.v65_amount end as loan_amount1 --AK
,case when loans.etv_id = 'V73' then loans.referencenumber end as loan_number2 --AL
,case when loans.etv_id = 'V73' then loans.v73_amount end as loan_amount1 --AM
,case when loans.etv_id = 'V31' then loans.referencenumber end as loan_number3 --AN
,case when loans.etv_id = 'V31' then loans.v31_amount end as loan_amount1 --AO
,' ' ::char(1) as loan_number4 --AP
,null as loan_amount4 --AQ
,pnch.url as email_addr
,pncw.url as work_email

from person_identity pi
join edi.edi_last_update elu on elu.feedid = 'DAB_OneAmerica_401K_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 
 
left join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
left join person_payroll ppay
  on ppay.personid = pi.personid
 and current_date between ppay.effectivedate and ppay.enddate
 and current_timestamp between ppay.createts and ppay.endts 

left join person_net_contacts pnch
  on pnch.personid = pe.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate  
 
left join person_net_contacts pncw 
  on pncw.personid = pe.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate  
 
left join pers_pos pp
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
  
left join pay_unit pu
  on pu.payunitid = ppay.payunitid
 and current_timestamp between pu.createts and pu.endts
---------------------------
----- contract number -----
---------------------------
left join 
   ( select lkups.lookupname, lkups.lookupid, lkup.lookupid, lkup.key1, lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
   ) cnbr on cnbr.lookupname = 'DAB_OneAmerica_401K_Export' and cnbr.key1 = 'Contract_Number'  
---------------------------
----- Division number -----
---------------------------
left join 
   ( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.key2,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
   ) dnbr on dnbr.lookupname = 'DAB_OneAmerica_401K_Export' and dnbr.key1 = 'DivNbr' and dnbr.key2 = pu.payunitxid
------------
-- dedamt --
------------
left join 
(select 
 x.personid
,x.check_date
,sum(x.v25_amount) as v25_amount
,sum(x.v27_amount) as v27_amount
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.vcg_amount) as vcg_amount
,sum(x.vch_amount) as vch_amount

,x.payscheduleperiodid
from


(select distinct
ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'V25' then etv_amount  else 0 end as v25_amount
,case when ppd.etv_id = 'V27' then etv_amount  else 0 end as v27_amount
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'VCG' then etv_amount  else 0 end as vcg_amount
,case when ppd.etv_id = 'VCH' then etv_amount  else 0 end as vch_amount
,ppd.paymentheaderid
,pph.payscheduleperiodid
from pspay_payment_detail ppd
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid

where pph.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DAB_OneAmerica_401K_Export' and elu.lastupdatets < ppay.statusdate --include contributions from current payroll cycle
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('V25','V27','VB1','VB2','VB3','VB4','VB5','VCG','VCH')) x
  group by 1,2,payscheduleperiodid  having sum(x.v25_amount + x.v27_amount + x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.vcg_amount + x.vch_amount) <> 0) 
        dedamt on dedamt.personid = pi.personid 

-----------
-- loans --
-----------
left join 

(select 
 x.personid
,x.check_date
,x.etv_id
,x.referencenumber
,substring(x.referencenumber from char_length(x.referencenumber)-1 for 2) ::char(2) as loanid
,x.rank as key_rank
,sum(x.v65_amount) as v65_amount -- loan 1
,sum(x.v73_amount) as v73_amount -- loan 2
,sum(x.v31_amount) as v31_amount -- loan 3
,sum(coalesce(x.v65_amount,0) + coalesce(x.v73_amount,0) + coalesce(x.v31_amount,0)) as total_loan_amount

from
(select distinct
 ppd.personid
,ppd.check_date
,ppd.etv_id
,pds.referencenumber
,pds.rank 
,case when ppd.etv_id = 'V65' then etv_amount end as v65_amount
,case when ppd.etv_id = 'V73' then etv_amount end as v73_amount
,case when ppd.etv_id = 'V31' then etv_amount end as v31_amount

,ppd.paymentheaderid

from pspay_payment_detail ppd
left join (select distinct pds.personid, pds.etvid, pds.referencenumber, rank() over(partition by pds.personid order by pds.etvid desc) as rank
   from person_deduction_setup pds where current_date between pds.effectivedate and pds.enddate and current_timestamp between pds.createts and pds.endts
    and pds.etvid in ('V65','V73','V31')) pds on pds.personid = ppd.personid and pds.etvid = ppd.etv_id

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DAB_OneAmerica_401K_Export' and elu.lastupdatets < ppay.statusdate --include loans from current payroll cycle
                             where ppay.pspaypayrollstatusid = 4 ))) -- pspaypayrollstatusid = 4 means payroll completed
  and ppd.etv_id  in ('V65','V73','V31')) x  
group by personid, check_date, etv_id, referencenumber, rank ) loans on loans.personid = pe.personid  
        
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplpermanency = 'P' --- exclude temporary ee's
  and date_part('year',age(pv.birthdate)) >= 21.0 -- exclude ee's under 21 years
  and ((pe.emplstatus in ('L','A','P') and (pp.schedulefrequency = 'B' and pp.scheduledhours > 35.0)) --include biweekly scheduled hours > 35
   or (pe.emplstatus in ('T','R') and pe.createts >= elu.lastupdatets ))


  order by ssn
