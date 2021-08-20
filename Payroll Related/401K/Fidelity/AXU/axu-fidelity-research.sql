select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2020-09-25 07:15:46' where feedid = 'Fidelity_ContributionLoan'; ----2020-10-01 16:20:47
select * from person_names where lname like 'Darby%';
select * from person_identity where personid = '873';

select * from PERSON_FINANCIAL_PLAN_ELECTION where benefitsubclass = '4Z';


select distinct
 bpd.benefitplanid
,bpd.benefitplancode
,trim(upper(bpd.benefitsubclass)) as benefitsubclass

,'P'::char(1) as benefitcalctype
,bo.benefitoptionid
,current_timestamp as createts
from benefit_plan_desc bpd
join benefit_option bo on bo.benefitplanid = bpd.benefitplanid --and bo.edtcode = bpd.edtcode
 and current_date between bo.effectivedate and bo.enddate and current_timestamp between bo.createts and bo.endts
where bpd.edtcode like '%401%' and current_date between bpd.effectivedate and bpd.enddate and current_timestamp between bpd.createts and bpd.endts

/*
2019-04-15
	AXU - There was a problem with benefitcalctype from the table being "B" and the eHCM defaulting to amount instead of %.
	If the eHCM gets fixed, this can be put back to handle amounts and percentages.
*/
;

select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts and edtcode like '%401%';
select * from benefit_option where current_date between effectivedate and enddate and current_timestamp between createts and endts and edtcode like '%401%';

select * from PERSON_FINANCIAL_PLAN_ELECTION where createts::date = current_date ;
select * from person_deduction_setup where createts::date = current_date ;

delete from PERSON_FINANCIAL_PLAN_ELECTION where updatets::date >= current_date;
delete from person_deduction_setup where updatets::date >= current_date;



select * from edi.lookup_schema where lookupname = 'FidelityContributionLoan';
select * from edi.lookup where lookupid = 8;
select * from edi.lookup_schema where lookupname = 'Fidelity_Deferral_Feedback_Import';
select * from edi.lookup where lookupid = 10;
select * from edi.lookup_schema where lookupname = 'FidelityPlanNumber';
select * from edi.lookup where lookupid = 1;
select * from edi.lookup_schema where lookupname = 'FidelityLoanETVIdMap';
select * from edi.lookup where lookupid = 11;
select * from edi.lookup_schema where lookupname = 'FidelityContribETVIdMap';
select * from edi.lookup where lookupid = 11;

select * from PERSON_FINANCIAL_PLAN_ELECTION where personid = '876'
select * from financial_plan_event;
select * from person_payroll  where personid = '876';
select * from person_bene_election where personid = '876';

select * from PERSON_FINANCIAL_PLAN_ELECTION where personid = '876' and benefitsubclass = '4KP' and financialelectionrate = 6.00000000

delete from PERSON_FINANCIAL_PLAN_ELECTION where personid = '876' and benefitsubclass = '4KP' and financialelectionrate = 6.00000000

--delete from PERSON_FINANCIAL_PLAN_ELECTION where personid = '876' and effectivedate = '2020-07-25';

loans etv_ids 'V15','V31','V57','V58','V60','V61','V62','V63','V64','V65','V66','V73','V75','VCJ','VFP','VFQ','VFR','VFS','VFT'

select * from cognos_pspay_etv_names where etv_name ilike '%roth%' or etv_name ilike '%401%';
   
select * from person_deduction_setup where personid = '876' and current_date between effectivedate and enddate and current_timestamp  between createts and endts and effectivedate > '2020-04-24';

select * from person_names where lname like 'Kins%';
select * from person_names where personid = '956';
select * from person_deduction_setup where personid = '876' and etvid in ('V25','VB1','VB2','VB3') and current_date between effectivedate and enddate and current_timestamp  between createts and endts ;
select * from PERSON_FINANCIAL_PLAN_ELECTION where personid = '876' ;

select etvid from person_deduction_setup where etvid in 
('EEJ','V15','V25','V31','V57','V58','V60','V61','V62','V63','V64','V65','V66','V72','V73','V75','VAJ','VB1','VB2','VB3','VB4','VB5','VB6','VBF','VBG','VCI','VCJ','VFP','VFQ','VFR','VFS','VFT') group by 1;

select * from person_deduction_setup where etvid = 'V66';

select * from pspay_payment_detail where personid = '876';
select * from benefit_plan_desc where edtcode ilike '401K%';

select personid, benefitplanid, financialelectionrate, financialelectionaftrate, financialplanaccountno, effectivedate, enddate, createts, endts from PERSON_FINANCIAL_PLAN_ELECTION where personid = '876'  and   createts::date = current_date::date;

select * from pspay_group_deductions where etv_id in ('V25','VB1','VB2','VB3');

select * from person_names where lname like 'Kinsella%';
select * from person_deduction_setup where current_date between effectivedate and enddate and current_timestamp between createts and endts and etvid = 'VB3' order by effectivedate;
select * from person_names where personid = '783';
--- mirrored atq
--delete from edi.lookup where lookupid = 8;
--delete from edi.lookup where lookupid = 10;

( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1,lkup.value2,lkup.value3
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname in ('Fidelity_Deferral_Feedback_Import','FidelityContributionLoan','FidelityPlanNumber','FidelityLoanETVIdMap')
      )

;
-- *********************************************************
-- Insert values for Fidelity Contribution Loan (Record 19)
-- *********************************************************
/* already inserted
INSERT INTO edi.lookup_schema (lookupid, lookupname, lookupdesc)
select max(lookupid) + 1, 'FidelityContributionLoan', 'Fidelity Contribution Loan for Record 19'
from edi.lookup_schema;
*/

select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2020-07-17 06:00:10' where feedid = 'Fidelity_ContributionLoan';

delete from edi.lookup where key1 = 'After-Tax' and lookupid = 8;
-- Map Employee/Employer/Roth

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'Employee', '01'
from edi.lookup_schema where lookupname = 'FidelityContributionLoan';

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'Employer', '07'
from edi.lookup_schema where lookupname = 'FidelityContributionLoan';

----- CSD-29826 Beach & CO 401k Deduction Setup for Roth


INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'RothDeferral', '08'
from edi.lookup_schema where lookupname = 'FidelityContributionLoan';

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'After-Tax', '10'
from edi.lookup_schema where lookupname = 'FidelityContributionLoan';

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'SafeHarbor', '07'
from edi.lookup_schema where lookupname = 'Fidelity_Deferral_Feedback_Import';

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'RothDeferral', '08'
from edi.lookup_schema where lookupname = 'Fidelity_Deferral_Feedback_Import';

INSERT INTO edi.lookup (lookupid,key1, value1)
select lookupid, 'After-Tax', '10'
from edi.lookup_schema where lookupname = 'Fidelity_Deferral_Feedback_Import';

( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1,lkup.value2,lkup.value3
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname in ('Fidelity_Deferral_Feedback_Import','FidelityContributionLoan','FidelityPlanNumber','FidelityLoanETVIdMap')
      )

;


INSERT INTO edi.lookup (lookupid,key1, value4)
select lookupid, 'ETVList', 'VB3'
from edi.lookup_schema where lookupname = 'FidelityLoanETVIdMap';

INSERT INTO edi.lookup (lookupid,key1, value4)
select lookupid, 'ETVList', 'VB4'
from edi.lookup_schema where lookupname = 'FidelityLoanETVIdMap';

INSERT INTO edi.lookup (lookupid,key1, value4)
select lookupid, 'ETVList', 'V25'
from edi.lookup_schema where lookupname = 'FidelityLoanETVIdMap';