select distinct
pi.personid
,pp.payunitid
,elu.lastupdatets
---------------start -------------------------------------------------------------------------------------------------------------------------------------------
,'comb.d  ' ::char(8) as comb_h10 --col 1
----- monthly only have 2 contract groups - distinquished by benefitplanid (82 and 129) 
----- benefitplanid goes to contract # 80304 otherwise everyone goes to '800952'
,case when pfpe.benefitplanid = '129' then '800952' else '80304' end ::char(7) as Cont --col 2
,replace(pi.identity,'-','')::char(9) as SSN -- col 3


,TRIM(UPPER(pn.fname))::varchar(18) as FirstName -- col 4
,TRIM(UPPER(pn.lname))::varchar(20) as LastName -- col 5
,TRIM(UPPER(coalesce(LEFT(pn.mname,1),'')))::varchar(1) as Initial -- col 6
,null :: varchar(4) as NamePrefix --col 7
,pie.identity ::char(9) as EEID -- col 8

,replace(pa.streetaddress,',',' ') ::varchar(30) as Address1 -- col 9
,replace(pa.streetaddress2,',',' ') ::varchar(30) as Address2 -- col 10
,replace(pa.city,',',' ') ::varchar(25) as city -- col 11

,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as state -- col 12
,pa.postalcode::varchar(10) as zip -- col 13
,null :: char(3) as country -- col 14
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as StateRes -- col 15
,null :: char(99) as ERProvEmail --col 16

--,replace(pu.employertaxid,'-','') as division -- col Q
,replace(pu.payunitdesc,'-','') as division -- col 17
-------------------------------------------------------------------------------------------------------------------------   
,to_char(pv.birthdate,'mmddyyyy')::char(8) as dob -- col 18
,case when pe.emplhiredate > current_date then '' else to_char(pe.emplhiredate,'mmddyyyy') end::char(8) as doh -- col 19 original date of hire
,case when pe.emplstatus in ('A','L','P') then 'A' 
      when pe.emplstatus in ('T','D') then 'T'  end ::char(1) as empstatus -- col 20
----------------------------------------------------------------------
,case when pe.emplstatus in ('A','L') then to_char(coalesce(pe.emplhiredate,pe.empllasthiredate),'mmddyyyy')
      when pe.emplstatus in ('R','T') then to_char(pe.effectivedate,'mmddyyyy') 
      else '' end ::char(8) as EmplStatDate -- col 21
----------------------------------------------------------------------
,case when pe.emplstatus in ('A','L','P') and coalesce(pfpe.personid,pfpe1.personid) is not null then ' ' 
      when pe.emplstatus in ('R','T')     then ' '
      else 'Y' end ::char(1) as EligInd -- col 22
--- Send the hire date + 6 months - only for employees who are not currently contributing
,case when pe.emplstatus in ('A','L') and coalesce(pfpe.personid,pfpe1.personid) is not null then ' ' 
      when pe.emplstatus in ('R','T')     then ' '
      else to_char(pe.emplhiredate + interval '6 months','mmddyyyy') end ::char(8) as EligDate --col 23
,null ::char(1) as OptOutInd --col 24
---------------------------------------------------------------------------------------------------------------------------------------------------------------- 
,case when coalesce(dedamt.total_401k,loans.total_loan_amount) <> 0 then total_hours.hours end as YTDhrs --col 25  YTD eligible hours worked for 401K Plan  
,wage_amount.Amount as PlanYTDComp --col 26  YTD eligible compensation amount for 401K Plan  
----- YTDHrsWkCompDt required if either YTDhrs or PlanYTDComp is submitted
,case when coalesce(dedamt.total_401k,loans.total_loan_amount) <> 0 then to_char(coalesce(dedamt.check_date,loans.check_date,psp.periodpaydate),'mmddyyyy')
      when wage_amount.Amount <> 0 then to_char(coalesce(dedamt.check_date,loans.check_date,psp.periodpaydate),'mmddyyyy') end ::char(8) as YTDHrsWkCompDt --col 27 as paydate
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
--,psp.payenddate as Date_end --col 34 Pay Period End Date
,to_char(coalesce(dedamt.check_date,loans.check_date),'mmddyyyy')::char(8) as Date_end --col 34 Pay Period End Date
,(dedamt.vb1_amount + dedamt.vb2_amount + dedamt.v25_amount + dedamt.vdo_amount + dedamt.vdp_amount + dedamt.vcg_amount) as EEDEF --35 Employee Deferral
,(dedamt.vb5_amount) as ERMAT --36 Employer Match
,null as QMAC --37
,null as SHMAC --38
,null as ERMC3 --39
,(dedamt.vb3_amount + dedamt.vb4_amount) as EEROT --40 Employee Roth
,null as QNEC  --41
,null as SHNEC --42
,null as ERPS --43
,null as EERC --44
,null as EEVND --45
,null as EEVD --46
,null as EEMAN --47
,null as ERMP --48
,null as ERCON --49
,null as S_HGR --50
,null as EEMT1 --51
,null as EEMT2 --52
,null as ERMT1 --53
,null as ERMT2 --54
,null as ERMT3 --55
,null as ERMT4 --56
,null as ERMT5 --57
,null as ERMT6 --58
------------------------------------------------------------------------------------------------------------------------- 
,coalesce(loans.key_rank,1) as key_rank
,coalesce(loans.v65_loan1,loans.v73_loan2,loans.v31_loan3) as loan_amount
,loans.referencenumber as loanid
-- the loan columns will be populated in the denormalizer step.
,case when loans.v65_loan1 <> 0 then loans.referencenumber else ' ' end as LoanID_1 -- col 59 BG Loan 1
,loans.v65_loan1 as LoanAmt_1 -- col 60 BH Loan 1 amt
,case when loans.v73_loan2 <> 0 then loans.referencenumber else ' ' end as LoanID_2 -- col 61 BI
,loans.v73_loan2 as LoanAmt_2 -- col 62 BJ
,case when loans.v31_loan3 <> 0 then loans.referencenumber else ' ' end as LoanID_3 -- col 61 BI
,loans.v31_loan3 as LoanAmt_3 -- col 62 BJ
-------------------------------------------------------------------------------------------------------------------------   
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

,to_char(current_date,'mmddyyyy')::char(8) as currentdate
,current_timestamp as updatets

from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'SSM_JH_401K_Export'

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
 and pa.addresstype = 'Res'
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
 and pp.effectivedate - interval '1 day' <> pp.enddate
 
left join pers_pos pos
  on pos.personid = pe.personid 
 and current_date between pos.effectivedate and pos.enddate
 and current_timestamp between pos.createts and pos.endts 
 
left join frequency_codes fcpos
  on fcpos.frequencycode = pos.schedulefrequency  
  
left join pay_unit pu
  on pu.payunitid = pp.payunitid
 and current_timestamp between pu.createts and pu.endts
 
left join (select psp.payunitid, max(periodpaydate) as periodpaydate
             from pay_schedule_period psp
             join pay_unit pu on pu.payunitid = psp.payunitid
             left join edi.edi_last_update ed on ed.feedid = 'SSM_JH_401K_Export' 
            where psp.payrolltypeid = 1 and psp.processfinaldate is not null and psp.processfinaldate >= ed.lastupdatets group by psp.payunitid) --- 4/22 removed cast to date
            psp on psp.payunitid = pu.payunitid
 
------------
-- dedamt --
------------ 
left join 
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.v25_amount) as v25_amount
,sum(x.vdo_amount) as vdo_amount
,sum(x.vdp_amount) as vdp_amount
,sum(x.vcg_amount) as vcg_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.vbf_amount) as vbf_amount
,x.payscheduleperiodid
,sum(x.vb1_amount+x.vb2_amount+x.v25_amount+x.vdo_amount+x.vdp_amount+x.vcg_amount+x.vb3_amount+x.vb4_amount+x.vb5_amount+x.vbf_amount) as total_401k
from


(select distinct
ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount else 0 end as vb2_amount
,case when ppd.etv_id = 'V25' then etv_amount else 0 end as v25_amount
,case when ppd.etv_id = 'VDO' then etv_amount else 0 end as vdo_amount
,case when ppd.etv_id = 'VDP' then etv_amount else 0 end as vdp_amount
,case when ppd.etv_id = 'VCG' then etv_amount else 0 end as vcg_amount
,case when ppd.etv_id = 'VB3' then etv_amount else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount else 0 end as vb5_amount
,case when ppd.etv_id = 'VBF' then etv_amount else 0 end as vbf_amount
,ppd.paymentheaderid
,pph.payscheduleperiodid
from pspay_payment_detail ppd
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid

where pph.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid =  'SSM_JH_401K_Export' 
                            and elu.lastupdatets < ppay.statusdate --4/23 - changed from <=
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','V25','VDO','VDP','VCG','VB3','VB4','VB5','VBF')) x
  group by 1,2,payscheduleperiodid  having sum(x.vb1_amount + x.vb2_amount + v25_amount + vdo_amount + vdp_amount + vcg_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.vbf_amount) <> 0) 
        dedamt on dedamt.personid = pi.personid 

-----------------
-- total_hours --
----------------- 
LEFT JOIN (SELECT h.personid
             --,h.check_date 
                 ,sum(h.etype_hours) as Hours
             FROM          
 (Select distinct
    ppdh.personid
   ,ppdh.check_date

   ,ppdh.etype_hours
   ,ppdh.paymentheaderid
    from pspay_payment_detail ppdh
   where ppdh.check_date >= date_trunc('year',now()) and ppdh.paymentheaderid in 
         (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                 (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid 
                           from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid =  'SSM_JH_401K_Export'  
                          where ppay.pspaypayrollstatusid = 4 ))) and ppdh.etv_id  in 
                               (select a.etv_id from pspay_etv_operators a  
                                 where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by etv_id))
 h group by 1) total_hours on total_hours.personid = pi.personid 
-----------------
-- wage_amount --
-----------------
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
             where ppdw.check_date >= date_trunc('year',now()) and ppdw.paymentheaderid in 
                    (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                           (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                                 (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                                      on elu.feedid =  'SSM_JH_401K_Export'
                                      where ppay.pspaypayrollstatusid = 4 ))) and ppdw.etv_id  in  (select a.etv_id from pspay_etv_operators a
                                                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1)) w group by 1,2) 
                                                            wage_amount on wage_amount.personid = pi.personid 
                                                            and wage_amount.check_date = dedamt.check_date
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
,sum(x.v65_amount) as v65_loan1 -- loan 1
,sum(x.v73_amount) as v73_loan2 -- loan 2
,sum(x.v31_amount) as v31_loan3 -- loan 3
,sum(x.v65_amount+x.v73_amount+x.v31_amount) as total_loan_amount

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
                             on elu.feedid = 'SSM_JH_401K_Export' and elu.lastupdatets < ppay.statusdate --4/23 - changed from <=
                             where ppay.pspaypayrollstatusid = 4 ))) -- pspaypayrollstatusid = 4 means payroll completed
  and ppd.etv_id  in ('V65','V73','V31')) x  
group by personid, check_date, etv_id, referencenumber, rank ) loans on loans.personid = pe.personid  
-------------------------------------------------------------------------------------------------------------------------   
left join person_financial_plan_election pfpe --percent
  on pfpe.personid = pi.personid
 and pfpe.benefitsubclass in  ('40')
 and current_date between pfpe.effectivedate and pfpe.enddate
 and current_timestamp between pfpe.createts and pfpe.endts
-------------------------------------------------------------------------------------------------------------------------
left join person_financial_plan_election pfpe1 --flat amt
  on pfpe1.personid = pi.personid
--and pfpe1.benefitsubclass in   ('4R','4Z')
 and pfpe1.benefitsubclass in   ('4Z')
 and current_date between pfpe1.effectivedate and pfpe1.enddate
 and current_timestamp between pfpe1.createts and pfpe1.endts

  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  ----4/22  added and psp.payunitid = pp.payunitid to active ee filter to only pull part and non-part ee's from current payroll
  and ((pe.emplstatus in ('L','A','P') and psp.payunitid = pp.payunitid) or (pe.emplstatus in ('T','R') and (pe.effectivedate >= current_date - interval '1 year' )))
  --and pe.personid = '885'
  order by pi.personid, date_end