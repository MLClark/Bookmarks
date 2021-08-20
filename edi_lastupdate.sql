  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
   
   
   
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-12-17 06:05:53'  where feedid = 'AVS_BasicPacific_COBRA_QB_Export'; ---2019-12-17 06:05:53

update edi.edi_last_update set lastupdatets = '2019-05-08 00:00:00'  where feedid = 'AXU_Infinisource_Cobra_QE_Export'; ---2019-10-29 07:00:25

update edi.edi_last_update set lastupdatets = '2019-08-06 06:05:36'  where feedid = 'AMJ_COBRA_EBC_QB'; ---2019-08-13 06:05:36  2019-08-06 06:05:36

update edi.edi_last_update set lastupdatets = '2019-12-31 07:00:00' where feedid = 'BAC_Benefitfocus_Demographic_Export';  --2019-08-14 07:00:05 2019/04/16 07:00:15.835000000

update edi.edi_last_update set lastupdatets = '2019-07-23 06:06:19' where feedid = 'DAB_Assurity_CI_HI_Accident_Export';  --2019-07-23 06:06:19


select * from edi.edi_last_update where feedid = 'CDE_Principal_Financial_Group_401k_Export';
2019-02-26 07:00:02

update edi.edi_last_update set lastupdatets = '2019-02-01 08:00:42' where feedid = 'AXU_Infinisource_Cobra_QE_Export'; --2019-03-26 07:00:

update edi.edi_last_update set lastupdatets = '2019-01-01 00:00:00' where feedid = 'AVS_BasicPacific_COBRA_NPM_Export'; --2019-03-26 07:00:03

2019-02-08 00:00:00

update edi.edi_last_update set lastupdatets = '2019-01-01 00:00:00' where feedid = 'AMJ_EBC_HSA_Eligibility_Export'; ---2019/04/16 07:01:50  2019-04-23 06:03:00
update edi.edi_last_update set lastupdatets = '2019-04-09 00:00:00' where feedid = 'DGH_Benefitfocus_Demographic_Export'; --2019-04-16 07:06:12 2017-12-31 23:00:00


 '10/09/2018 23:59:36' where feedid = 'HMN_401k_Census_File_Export';

INSERT into edi.edi_last_update (feedid,lastupdatets) values ('CDS_UHC_Life_ADD_Export','2020-10-01 00:00:00');

2018-10-23 07:06:37


select * from pspay_payment_detail where personid = '5994' and etv_id in ('VBA','VBB') and check_date = '2018-12-07';

DGH_Benefitfocus_Demographic_Export 2018-01-01 00:00:00

select * from pay_schedule_period where date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)>='01';

select * from batch_header where batchname like  '%2019%';



select * from pay_schedule_period where payrolltypeid = 1 and date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)<='11';



update edi.edi_last_update set lastupdatets = '2019/04/17 13:45:10' where feedid = 'DGH_JH_401K_Export'; --2019/04/17 13:45:10

update edi.edi_last_update set lastupdatets = '2019-01-01 00:00:00' where feedid = 'DAB_EBenefits_Cobra_Export'; --
update edi.edi_last_update set lastupdatets = '2019-02-01 00:00:00' where feedid = 'AVS_Mutual_Of_Omaha_Carrier_Export';
select * from edi.edi_last_update;

update edi.edi_last_update set lastupdatets = '2019-03-22 07:00:53' where feedid = 'Fidelity_ContributionLoan'; --2019-03-19 16:01:50
03/22/2019 07:00:53

update edi.edi_last_update set lastupdatets = '2019-04-12 13:00:00' where feedid = 'CDE_Principal_Financial_Group_401k_Export';

select * from edi.edi_last_update where feedid = 'RBA_Sound_Admin_Cobra_QE_Export';
update edi.edi_last_update set lastupdatets = '2019-06-11 07:03:08' where feedid = 'RBA_Sound_Admin_Cobra_QE_Export'; ---'2019-06-04 07:03:08' 

