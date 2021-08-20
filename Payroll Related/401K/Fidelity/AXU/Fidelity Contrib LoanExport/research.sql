--select * from edi.edi_last_update;
(
			select	lkup.value1 as ATcode
			from	edi.lookup_schema ls
			join	edi.lookup lkup on lkup.lookupid = ls.lookupid
				and lkup.active = 1
				and current_date between lkup.effectivedate and lkup.enddate
			where	ls.lookupname = 'FidelityContributionLoan'
				and lkup.key1 = 'After-Tax'
				and current_date between ls.effectivedate and ls.enddate
				and ls.active = 1)



( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1,lkup.value2,lkup.value3
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname in ('Fidelity_Deferral_Feedback_Import','FidelityContributionLoan','FidelityPlanNumber','FidelityLoanETVIdMap')
      );
      select * from person_names where personid = '873';
      
      select * from person_names where lname like 'Crowl%';

 (

		select distinct
  individual_key, sum(etv_amount) as contribution_employee
  
  from pspay_payment_detail ppd
  
  where personid = '884' and  paymentheaderid in 
          (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                  (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                          (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
--                               on elu.feedid = 'Fidelity_ContributionLoan' and '2019-09-15'::DATE <= ppay.statusdate
                               on elu.feedid = 'Fidelity_ContributionLoan' and elu.lastupdatets <= ppay.statusdate
                               where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id  in  ('VB1', 'VB2')
		group by ppd.individual_key
		order by ppd.individual_key

)


(select distinct  individual_key, sum(etv_amount) as contribution_aftertax
  
  from pspay_payment_detail ppd
  
  where personid = '873' and paymentheaderid in 
          (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                  (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                          (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'Fidelity_ContributionLoan' and elu.lastupdatets <= ppay.statusdate
                               where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id  in  ('V25')  
		group by ppd.individual_key
		order by ppd.individual_key

			)
			

select * from person_identity where personid = '1030';      
select * from person_names where lname like 'Kinsella%';      
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2020-11-06 06:00:17' where feedid = 'Fidelity_ContributionLoan' --2020-11-06 07:00:17


select * from pspay_payment_detail where personid = '876' and check_date = '2020-10-30' and etv_id  = 'V25';


INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'Roth', '08'
from edi.lookup_schema where lookupname = 'FidelityContributionLoan';

update edi.lookup set key1 = 'Roth' where lookupid = 8 and value1 = '08';

select * from pspay_payment_detail where personid in ('1030') and check_date = '2020-09-18';

( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1,lkup.value2,lkup.value3
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname in ('FidelityContributionLoan')
      )

(
		select distinct
  individual_key, sum(etv_amount) as contribution_roth
  
  from pspay_payment_detail ppd
  
  where paymentheaderid in 
          (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                  (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                          (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
--                                 on elu.feedid = 'Fidelity_ContributionLoan' and '2019-09-15'::DATE <= ppay.statusdate
                             on elu.feedid = 'Fidelity_ContributionLoan' and elu.lastupdatets <= ppay.statusdate
                               where ppay.pspaypayrollstatusid = 4 )))
    and ppd.etv_id  in  -- ('VB3', 'VB4', 'V25') -- Do we need to add V25?
     (
				select	distinct unnest(array[value1,value2,value3,value4,value5,value6,value7,value8,value9,value10])
				from	edi.lookup_schema ls
				join	edi.lookup lkup on lkup.lookupid = ls.lookupid
					and lkup.active = 1
					and current_date between lkup.effectivedate and lkup.enddate
				where	ls.lookupname = 'FidelityRothContribETVIdMap'
					and current_date between ls.effectivedate and ls.enddate
					and ls.active = 1
					and value1 is not null)
						group by ppd.individual_key
						order by ppd.individual_key

     )