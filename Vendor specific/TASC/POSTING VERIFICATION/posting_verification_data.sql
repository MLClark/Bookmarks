select distinct
 pi.personid as group_personid
,lkclient.value1 as client_tasc_id -- 1
,pie.identity  as indv_tasc_id --2 *File must contain Employee ID or Individual TASC ID to identify Participant Must match value found in Universal Benefit Account
,pie.identity  as employee_id --3 *If unable to provide the Individual TASC ID then Employee ID is required. Employee ID is required for new enrollees.
,pn.lname as lname --4
,pn.fname as fname --5
,dedamt.planid as benefit_plan_id --6
,to_char(dedamt.check_date,'mm/dd/yyyy')::char(10) as contribution_date --7
,dedamt.amount as part_contrib_amt --8
,null as client_contrib_amount --9 - only required if client funds plan (how would I know this?)
,elu.lastupdatets

from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'TASC_FSA_Posting_Verification_File_Export'

left join pers_pos pp 
  on pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate 
 and current_timestamp between pp.createts and pp.endts

join person_identity pie 
  on pie.personid = pp.personid 
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_names pn
  on pn.personid = pp.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join ( select lkups.lookupname,lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
      ) lkclient on lkclient.lookupname = 'TASC_FSA_Exports' and lkclient.key1 = 'ClientTASCID' 

--------------------
-- dedamt         --
--------------------
join 
(select 
 x.personid
,x.check_date
,x.planid
,case when x.paycode_key = 'HCRA P/T'   then sum(x.amount)  --VBA
      when x.paycode_key = 'DCRA P/T'   then sum(x.amount)  --VBB
      when x.paycode_key = 'ERHCRA P/T' then sum(x.amount)  --VBA-ER
      when x.paycode_key = 'ERDCRA P/T' then sum(x.amount)  --VBB-ER
      when x.paycode_key = 'ERHSA C/U'  then sum(x.amount)  --VEJ-ER
      when x.paycode_key = 'ERHSA Fam'  then sum(x.amount)  --VEI-ER
      when x.paycode_key = 'ERPark-P/T' then sum(x.amount)  --VL1-ER
      when x.paycode_key = 'ERTrns-P/T' then sum(x.amount)  --VS1-ER
      when x.paycode_key = 'HSA C/U'    then sum(x.amount)  --VEJ
      when x.paycode_key = 'HSA Co'     then sum(x.amount)  --VEK
      when x.paycode_key = 'HSA Fam'    then sum(x.amount)  --VEI
      when x.paycode_key = 'HSA Ind'    then sum(x.amount)  --VEH
      when x.paycode_key = 'Park-P/T'   then sum(x.amount)  --VL1
      when x.paycode_key = 'Trns-P/T'   then sum(x.amount)  --VS1
      else null end as amount
      
from

(select 
 ppd.personid
,ppd.check_date
,ppd.paycode
,lkup.key1 as paycode_key
,lkup.planid
,ppd.amount
from PAYROLL.payment_detail ppd
join PAYROLL.payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
join ( select lkup.value1 as paycode, lkup.key1, lkup.value2 as planid
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
          and current_timestamp between lkups.createts and lkups.endts
          and lkups.lookupname = 'TASC_FSA_Exports' and lkup.key2 in ('PAYCODE')
      ) lkup on lkup.paycode = ppd.paycode 
where pph.paymentheaderid in 
        (select paymentheaderid from PAYROLL.payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu  on elu.feedid = 'TASC_FSA_Posting_Verification_File_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
) x 
group by personid, check_date, paycode_key, planid order by personid, check_date) dedamt on dedamt.personid = pp.personid  

where pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts 
