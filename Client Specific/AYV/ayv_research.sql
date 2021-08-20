


select * from batch_detail where batchheaderid = '36';
select * from batch_detail where effectivedate = '2018-01-13';
select * from batch_detail where batchheaderid = '29';
select * from pay_schedule_period;
select * from pay_unit;

select * from pers_pos where personid = '6134';
select * from position_job where positionid = '3344';
select * from job_desc where jobid = '740' 
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;

select * from person_names where lname like 'Dykstra%';

select * from pers_pos where personid = '6134';
select * from position_job where positionid = '3344';
select * from job_desc where jobid = '740' 
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;

select * from pers_pos where personid = '6137';
select * from position_job where positionid = '3402';

select * from pers_pos where personid = '6139';
select * from position_job where positionid = '3396';


select * from pers_pos where personid = '6140';
select * from position_job where positionid = '3357';
select * from job_desc where jobid = '740' 
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;

select * from person_names where personid in 
(select personid from pers_pos where positionid in 
(select positionid from position_job where jobid = '740'));


select * from pers_pos where personid = '6384';
select * from position_job where positionid = '3485'
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;
select * from job_desc where jobid = '1122' 
and current_date between effectivedate and enddate 
--and current_timestamp between createts and endts;

select * from person_names where personid in 
(select personid from pers_pos where positionid in 
(select positionid from position_job where jobid = '1122'));


select * from pers_pos where personid = '7372';
select * from position_job where positionid = '4177'
and current_date between effectivedate and enddate
and current_timestamp between createts and endts;
select * from job_desc where jobid = '1133' 
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;

select * from person_names where personid in 
(select personid from pers_pos where positionid in 
(select positionid from position_job where jobid = '1133'));



select * from pers_pos where personid = '6107';
select * from position_job where positionid = '3208'
and current_date between effectivedate and enddate
and current_timestamp between createts and endts;
select * from job_desc where jobid = '813' 
--and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;
select * from job_desc where jobid = '1132'
and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;


select * from person_names where personid in 
(select personid from pers_pos where positionid in 
(select positionid from position_job where jobid = '1133'))






select * from pos_org_rel where positionid = '3463';
select * from rpt_orgstructure where org2id = '788';
select * from organization_code where organizationid = '788';
select * from rpt_orgstructure where org2code = 'L1000-CBP';
select * from job_desc;
select * from person_payroll ;
select * from batch_detail where personid in (select personid from person_identity where identitytype = 'PSPID' and identity like 'AYV25%' group by 1);
select * from batch_header where payunitid in ('8','9');
select * from batch_header where batchheaderid in ('24', '36');
select * from pspay_benefit_mapping ;

select * from pers_pos where personid = '6102';
select * from dcpositiondesc where positionid = '3202';
select * from position_job where positionid = '3202';
select * from positionorgreldetail where positionid = '3202';
select * from pspay_etv_list where etv_id in ('E01','E17') and group_key = 'AYV25';

select * from pspay_benefit_mapping;
select * from benefit_plan_desc;
select * from pspay_group_deductions where group_key <> '$$$$$' and deduction_name <> 'Reserved' 
and deduction_name <> '' and current_timestamp between createts and endts
and group_key in ('AYV20','AYV25')
and etv_id not like 'T%' order by etv_id, etv_id;
select eeperpayamtcode, substring(eeperpayamtcode,3,2) from pspay_benefit_mapping;
select etv_id, substring(etv_id,1,2) from pspay_group_deductions;



select group_key, etv_id, deduction_name, deduction_desc from
pspay_group_deductions where group_key <> '$$$$$' and deduction_name <>
'Reserved'

and deduction_name <> '' and current_timestamp between createts and endts

and group_key in ('AYV20','AYV25')

and etv_id not like 'T%' order by etv_id, etv_id;

select distinct

 'BENEFIT' ::char(6) as benefit
,pgd.deduction_desc ::varchar(30) as dscriptn

,pbm.benefitsubclass
,to_char(bbd.effectivedate,'MMDDYYYY')::char(8) as bnfbegdt
,pgd.etv_id ::char(3) as bsdoncde -- pay code or deduction code 

from pspay_group_deductions pgd
join pspay_benefit_mapping pbm
  on substring(pbm.eeperpayamtcode,3,2) = substring(pgd.etv_id,2,2) 
 --and pbm.taxable = 'Y'
join (select benefitsubclass,min(effectivedate) effectivedate
        from benefit_plan_desc 
        where current_date between effectivedate and enddate
          and current_timestamp between createts and endts
        group by 1) bbd on bbd.benefitsubclass = pbm.benefitsubclass  
where group_key <> '$$$$$' 
  and deduction_name <> 'Reserved'
  and deduction_name <> '' 
  and current_timestamp between createts and endts
  and group_key in ('AYV20','AYV25')
  and etv_id not like 'T%' 
  
  order by 2,3
  ;
  



select * from pspay_etv_list where etv_id in 
(
select etv_id
from pspay_group_deductions pgd
join pspay_benefit_mapping pbm
  on substring(pbm.eeperpayamtcode,3,2) = substring(pgd.etv_id,2,2) 
 --and pbm.taxable = 'Y'
join (select benefitsubclass,min(effectivedate) effectivedate
        from benefit_plan_desc 
        where current_date between effectivedate and enddate
          and current_timestamp between createts and endts
        group by 1) bbd on bbd.benefitsubclass = pbm.benefitsubclass  
where group_key <> '$$$$$' 
  and deduction_name <> 'Reserved'
  and deduction_name <> '' 
  and current_timestamp between createts and endts
  and group_key in ('AYV20','AYV25')
  and etv_id not like 'T%' 
)



;

select * from pspay_etv_list where group_key in ('AYV20','AYV25');



select distinct

 'BENEFIT' ::char(6) as benefit
,pgd.deduction_desc ::varchar(30) as dscriptn

,pbm.benefitsubclass
,to_char(bbd.effectivedate,'MMDDYYYY')::char(8) as bnfbegdt
,pgd.etv_id ::char(3) as bsdoncde -- pay code or deduction code 

from pspay_group_deductions pgd
left join pspay_etv_list pel
  on pel.etv_id = pgd.etv_id
 and pel.group_key in ('AYV20','AYV25')
 and pel.etv_id not like 'T%' 
LEFT join pspay_benefit_mapping pbm
  on pbm.eeperpayamtcode = pel.etv_id
 --and pbm.taxable = 'Y'
join (select benefitsubclass,min(effectivedate) effectivedate
        from benefit_plan_desc 
        where current_date between effectivedate and enddate
          and current_timestamp between createts and endts
        group by 1) bbd on bbd.benefitsubclass = pbm.benefitsubclass  
where pgd.group_key <> '$$$$$' 
  and pgd.deduction_name <> 'Reserved'
  and pgd.deduction_name <> '' 
  and current_timestamp between pgd.createts and pgd.endts
  and pgd.group_key in ('AYV20','AYV25')
  and pgd.etv_id not like 'T%' 
  
  order by 2,3
  ;

select * from person_identity where identitytype = 'PSPID' and current_timestamp between createts and endts;
select * from person_payroll;
select * from pers_pos;

select distinct etv_id from pspay_payment_detail where group_key in ('AYV20','AYV25') and etv_id <> 'T';


select * from pspay_etv_list where etv_id = 'VB2';  
select * from pspay_benefit_mapping;
select * from benefit_plan_desc ;
select distinct etv_id from pspay_group_deductions where group_key <> '$$$$$' and deduction_name <> 'Reserved' 
and deduction_name <> '' and current_timestamp between createts and endts
and group_key in ('AYV20','AYV25')
and etv_id not like 'T%' order by etv_id, etv_id;