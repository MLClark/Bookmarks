select distinct personid, individual_key, sum(etv_amount) from pspay_payment_detail where etv_id = 'V65' and personid in (select personid from person_deduction_setup where etv_id = 'V65' and effectivedate > '2020-03-01') group by 1,2 order by 1;

select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2020-10-27 09:10:45' where feedid = 'HMN_TransAmerica401k_Contribution_Export'; ---- '2020-10-27 09:10:45'


LAST_UPDATE_TIMESTAMP = 2020/10/09 09:05:39.333000000
select * from person_identity where identity = 'HMN00000022240';



select * from pspay_payment_detail where personid = '65370' and check_date = '2020-10-30'
and etv_id in ('VB5','VB1','VB3','VB4','VB2','VBU','VBT','V65');

select * from pspay_payment_header where paymentheaderid in (143664,143663);


select * from person_identity where identity = 'HMN00000021565';

select * from pspay_payment_detail where personid = '65370' and check_date = '2020-10-30'
and etv_id in ('VB5','VB1','VB3','VB4','VB2','VBU','VBT','V65');

(select 
 x.personid
,x.check_date
,x.etv_id
,x.vb1_amount as vb1_amount  
,x.vbu_amount as vbu_amount
,x.vb2_amount as vb2_amount
,x.v65_amount as v65_amount
,x.vbt_amount as vbt_amount
,x.vb5_amount as vb5_amount
,x.vb3_amount as vb3_amount
,x.vb4_amount as vb4_amount


,x.svb1_amount as svb1_amount
,x.svbu_amount as svbu_amount
,x.svb2_amount as svb2_amount
,x.sv65_amount as sv65_amount
,x.svbt_amount as svbt_amount
,x.svb5_amount as svb5_amount
,x.svb3_amount as svb3_amount
,x.svb4_amount as svb4_amount

from

(select 
 ppd.personid
,ppd.check_date
,ppd.etv_id
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VBU' then etv_amount  else 0 end as vbu_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'V65' then etv_amount  else 0 end as v65_amount
,case when ppd.etv_id = 'VBT' then etv_amount  else 0 end as vbt_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount

,case when ppd.etv_id = 'VB1' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB1' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb1_amount
,case when ppd.etv_id = 'VBU' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VBU' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svbu_amount
,case when ppd.etv_id = 'VB2' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB2' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb2_amount
,case when ppd.etv_id = 'V65' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'V65' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as sv65_amount
,case when ppd.etv_id = 'VBT' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VBT' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svbt_amount
,case when ppd.etv_id = 'VB5' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB5' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb5_amount
,case when ppd.etv_id = 'VB3' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB3' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb3_amount
,case when ppd.etv_id = 'VB4' and ppd.etv_amount <  0 then to_char(etv_amount*-1,'0000000000009v99') 
      when ppd.etv_id = 'VB4' and ppd.etv_amount >= 0 then to_char(etv_amount* 1,'0000000000009v99') end ::char(16) as svb4_amount



from pspay_payment_detail ppd

where ppd.personid = '65370' and paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'HMN_TransAmerica401k_Contribution_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VBU','VB2','V65','VBT','VB5','VB3','VB4')) x
  )
  
  



select * from pspay_payment_header where paymentheaderid in (143664,143663);

select * from pspay_payroll_pay_sch_periods where payscheduleperiodid in (117);
select * from pspay_payroll where pspaypayrollid = '116';

select * from person_names where personid = '65370';
select * from person_deduction_setup where etvid in ('V65','VBT') and createts::date = current_date;
delete from person_deduction_setup where createts::date = current_date;
delete from PERSON_FINANCIAL_PLAN_ELECTION where createts::date = current_date;

(select personid, etv_id, sum(etv_amount) as initial_balance      
   from pspay_payment_detail ppd 
   where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))  
     and ppd.etv_id  in  ('V65','VBT') group by personid, etv_id order by personid) 
;

SELECT * FROM edi.edi_last_update ;
select * from person_deduction_setup where etvid = 'V65';
select * from person_names where personid = '66027';
select * from person_deduction_setup where createts::date = current_date and personid = '66027';
select * from PERSON_FINANCIAL_PLAN_ELECTION where createts::date = current_date;

select * from benefit_plan_desc;
select 14 * 12;

select * from person_deduction_setup where createts::date = current_date and personid = '66027';
select * from PERSON_FINANCIAL_PLAN_ELECTION where createts::date = current_date and personid = '66207';

select distinct
	bpd.benefitplanid,
	bpd.benefitplancode,
	trim(upper(bpd.benefitsubclass)) as benefitsubclass,
--	bpd.benefitcalctype,
	'P'::char(1) as benefitcalctype,
	bo.benefitoptionid,
	current_timestamp as createts
from benefit_plan_desc bpd
join 	benefit_option bo on bo.benefitplanid = bpd.benefitplanid and bo.edtcode = bpd.edtcode
		and 'now'::text::date >= bo.effectivedate AND 'now'::text::date <= bo.enddate AND now() >= bo.createts AND now() <= bo.endts
where
	bpd.edtcode like '%401%'
	and 'now'::text::date >= bpd.effectivedate AND 'now'::text::date <= bpd.enddate AND now() >= bpd.createts AND now() <= bpd.endts
;

