select distinct
 pi.personid
,elu.lastupdatets
,'CT' ::char(2) as rectype
,replace(pi.identity,'-','') ::char(20) as ee_ssn
--HSA
--Dependent Care
--Limited Health FSA
--Combined Health FSA
,ppd.etv_id
,ppd.etv_code
,pn.lname ::char(20) as lname 
,pn.fname ::char(12) as fname
,fsa.counter
      
--VL1	Park-P/T          PK - PK CONTRIB 2020 - PARKING PRE TAX Contribution
--VS1	Trns-P/T          TR - TR CONTRIB 2020 - TRANSIT PRE TAX Contribution
      
---- Combination FSA is for when the employee also has the HSA deduction.  If they only have FSA then the plan is Health FSA
      
,case when fsa.counter >= 1 and ppd.etv_id = 'VBA' then 'Combination FSA '
      when ppd.etv_id = 'VBA' then 'Health FSA'
      when ppd.etv_id = 'VBB' then 'Dependent Care'
      when ppd.etv_id = 'VL1' then 'Parking Account'
      when ppd.etv_id = 'VS1' then 'Transit Account'
      when ppd.etv_id in ('VEH','VEJ','VEK') then 'HSA' else ' ' end ::varchar(100) as plan_name -- based on payroll codes 
      
,to_char(ppd.check_date,'mmddyyyy')::char(8) as check_date
,to_char(ppd.check_date,'yyyymmdd')::char(8) as cr_check_date

,case when ppd.etv_id = 'VEK'  then 'Employer Contribution'
      when ppd.etv_code = 'EE' then 'Payroll Deduction'
      else ' ' end ::varchar(100) as contrib_desc -- based on payroll codes either ee or er contrib
-- EE or ER contribution amount from Payroll
-- Note: HSA amount = HSA and HSA Catchup combined

,case when ppd.etv_id = 'VBA' then lpad(''||to_char(ppd.vba_amount,'99999V99'),17,' ')
      when ppd.etv_id = 'VBB' then lpad(''||to_char(ppd.vbb_amount,'99999V99'),17,' ')
      when ppd.etv_id = 'VEJ' then lpad(''||to_char(ppd.vej_amount,'99999V99'),17,' ')
      when ppd.etv_id = 'VEH' then lpad(''||to_char(ppd.veh_amount,'99999V99'),17,' ')
      when ppd.etv_id = 'VEK' then lpad(''||to_char(ppd.vek_amount,'99999V99'),17,' ') 
      when ppd.etv_id = 'VL1' then lpad(''||to_char(ppd.vl1_amount,'99999V99'),17,' ') 
      when ppd.etv_id = 'VS1' then lpad(''||to_char(ppd.vs1_amount,'99999V99'),17,' ') 
      end as cr_contrib_amt -- based on payroll codes either ee or er contrib   


,case when ppd.etv_id = 'VBA' then to_char(ppd.vba_amount,'99999d99')
      when ppd.etv_id = 'VBB' then to_char(ppd.vbb_amount,'99999d99')
      when ppd.etv_id = 'VEJ' then to_char(ppd.vej_amount,'99999d99')
      when ppd.etv_id = 'VEH' then to_char(ppd.veh_amount,'99999d99')
      when ppd.etv_id = 'VEK' then to_char(ppd.vek_amount,'99999d99') 
      when ppd.etv_id = 'VL1' then to_char(ppd.vl1_amount,'99999d99') 
      when ppd.etv_id = 'VS1' then to_char(ppd.vs1_amount,'99999d99') 
      end as contrib_amt -- based on payroll codes either ee or er contrib
           
,'ACTUAL|' ::char(7) as amount_type
,date_part('year',ppd.check_date)::char(4) as tax_year 
,to_char(current_date,'mmddyyyy')::char(8) as sub_date
,replace(x.chartime,':','')::char(6) as sub_time
,replace(pu.employertaxid,'-','') ::char(15) as fein

,case when ppd.etv_id = 'VBA' then 'DP'
      when ppd.etv_id = 'VBB' then 'HC'
      when ppd.etv_id = 'VL1' then 'PK'
      when ppd.etv_id = 'VS1' then 'TR'
      when ppd.etv_id in ('VEJ','VEH','VEK') then 'EX' end as cr_transtype 


,case when ppd.etv_id in ('VEJ','VEH') then 'EE CONTRIB '||date_part('year',current_date)
      when ppd.etv_id = 'VEK' then 'ER CONTRIB '||date_part('year',current_date)
      when ppd.etv_id = 'VBA' then 'DP CONTRIB '||date_part('year',current_date)
      when ppd.etv_id = 'VBB' then 'HC CONTRIB '||date_part('year',current_date)
      when ppd.etv_id = 'VL1' then 'PK CONTRIB '||date_part('year',current_date)
      when ppd.etv_id = 'VS1' then 'TR CONTRIB '||date_part('year',current_date)
      end ::char(15) as cr_transtype_desc  
      
,' ' ::char(9) as cr_acctnbr   

,to_char(current_date,'mm/dd/yyyy')::char(10) as curdate

/*
HSA total - appears to be Total HSA (VEH) less etv_code = EE
HSACO total - appears to be Total HSA (VEK) less etv_code = ER
HCRA total - appears to be Total FSA (VBA) less Health FSA (fsa.counter = 1)
OTHER toal - appears to be Total FSA (VBA) less Combination FSA (fsa.counter > 1)
DCRA total - appears to be Total Dep Care FSA (VBB)
*/      

,case when ppd.etv_id = 'VEH' then ppd.veh_amount       --- TOTAL DEDUCTION AMOUNT HSA 
      when ppd.etv_id = 'VEK' then ppd.vek_amount       --- TOTAL DEDUCTION AMOUNT HSA CO
      when ppd.etv_id = 'VBB' then ppd.vbb_amount                               --- TOTAL DEDUCTION AMOUNT DCRA
      when ppd.etv_id = 'VBA' and fsa.counter > 1 then ppd.vba_amount           --- TOTAL DEDUCTION AMOUNT HCRA
      when ppd.etv_id = 'VBA' and fsa.counter = 1 then ppd.vba_amount           --- TOTAL DEDUCTION AMOUNT OTHER
      when ppd.etv_id = 'VL1' then ppd.vl1_amount
      when ppd.etv_id = 'VS1' then ppd.vs1_amount
       end as cr_total_contrib_amt
       
,case when ppd.etv_id = 'VEH' then 'HSA   ' 
      when ppd.etv_id = 'VEK' then 'HSA CO' 
      when ppd.etv_id = 'VBB' then 'DCRA  '
      when ppd.etv_id = 'VBA' and fsa.counter > 1 then 'HCRA  '  
      when ppd.etv_id = 'VBA' and fsa.counter = 1 then 'OTHER ' 
      when ppd.etv_id = 'VL1' then 'ParkPT'
      when ppd.etv_id = 'VS1' then 'TrnsPT'
      
       end ::char(6) as cr_total_filter


from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'HMN_DiscoveryBenefits_FSAHSAContrib_Export' 

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts                     
                                            
left join person_payroll ppay
  on ppay.personid = pi.personid
 and current_date between ppay.effectivedate AND ppay.enddate
 and current_timestamp between ppay.createts AND ppay.endts 
 
left join pay_unit pu
  on pu.payunitid = ppay.payunitid
 and current_timestamp between pu.createts and pu.endts 
 
join (select to_char(current_timestamp ,'HH24:MI:SS') as chartime) x on 1=1 
 
join 
(select 
 x.personid
,x.check_date
,x.etv_id
,x.etv_code
,sum(x.vba_amount) as vba_amount
,sum(x.vbb_amount) as vbb_amount
,sum(x.vej_amount) as vej_amount
,sum(x.vek_amount) as vek_amount
,sum(x.veh_amount) as veh_amount
,sum(x.vl1_amount) as vl1_amount
,sum(x.vs1_amount) as vs1_amount
from
(select distinct
 ppd.personid
,ppd.check_date
,ppd.etv_id
,ppd.etv_code
,case when ppd.etv_id = 'VBA' then etv_amount  else 0 end as vba_amount
,case when ppd.etv_id = 'VBB' then etv_amount  else 0 end as vbb_amount
,case when ppd.etv_id = 'VEJ' then etv_amount  else 0 end as vej_amount
,case when ppd.etv_id = 'VEK' then etv_amount  else 0 end as vek_amount
,case when ppd.etv_id = 'VEH' then etv_amount  else 0 end as veh_amount
,case when ppd.etv_id = 'VL1' then etv_amount  else 0 end as vl1_amount
,case when ppd.etv_id = 'VS1' then etv_amount  else 0 end as vs1_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'HMN_DiscoveryBenefits_FSAHSAContrib_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VBA','VBB','VEJ','VEK','VEH','VS1','VL1')) x
  group by 1,2,3,4 having sum(x.vba_amount + x.vbb_amount + x.vej_amount + x.vek_amount + x.veh_amount + x.vs1_amount + x.vl1_amount) <> 0) ppd on ppd.personid = pi.personid 

-----------------------
----- FSA COUNTER -----
-----------------------
left join (select distinct ppd.personid, count(ppd.etv_id) as counter
from pspay_payment_detail ppd
where ppd.etv_id  in ('VEJ','VEK','VEH') and paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'HMN_DiscoveryBenefits_FSAHSAContrib_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid in ( 4 ) )))
  group by 1) fsa on fsa.personid = ppd.personid

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
-- and pi.identity = '348425179'
 and pi.personid = '66578'

  order by personid