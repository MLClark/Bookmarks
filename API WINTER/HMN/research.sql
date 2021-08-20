select * from person_financial_plan_election where createts::date = current_date and personid = '63512';

delete from person_financial_plan_election where createts::date = current_date 



select * from person_identity where identity like 'HMN00000017153%';
select * from edi.lookup_schema ;

update edi.lookup_schema set keycoldesc1='Client' where lookupname='HMN_401KCONTRIBS_TransAmerica_Import';

select 
 lu.key2 ::char(3) as etv_id
,lu.value1 as benefitplanid
,lu.value2 ::char(5)  as benefitsubclass
,lu.value3 ::char(10) as benefitplancode
,lu.value4 ::char(1)  as benefitcalctype
,lu.value5 as benefitoptionid
,lookupname
,current_timestamp as createts
from edi.lookup lu
join edi.lookup_schema ls on ls.lookupid = lu.lookupid
where lu.key1='HMN' and ls.keycoldesc1='Client' and lookupname='HMN_401KCONTRIBS_TransAmerica_Import' --and 



select * from process_process_links WHERE VIEWNAME LIKE 'PERSON_DEDUCTION_SETUP%';

select * from payroll.staged_transaction where paycodeaffiliationid = '216078';


select * from PERSON_DEDUCTION_SETUP where etvid in ('VBC','VCB') and personid in (select distinct personid from person_identity where identity = 'HMN00000099939');
select * from PERSON_EARNING_SETUP where personid in (select distinct personid from person_identity where identity = 'HMN00000099939');
select * from PERSON_EARNING_SETUP where personid in (select distinct personid from person_identity where etvid in ('EC8','ECB','E70','EC9'))

select COUNT(*) from PERSON_EARNING_SETUP where personid in (select distinct personid from person_identity where etvid in ('EC8','ECB','E70','EC9'))
GROUP BY ETVID HAVING COUNT(*) > 2;




--delete from person_financial_plan_election where createts::date = current_date;
select * from person_deduction_setup where createts::date = current_date::date;




select * from person_deduction_setup where etvid IN ('VBT','V65') and createts::date = current_date::date;
DELETE from person_deduction_setup where etvid IN ('VBT','V65');

delete from person_financial_plan_election where createts::date = current_date;
delete from person_deduction_setup where createts::date = current_date;

select * from benefit_plan_desc;

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
	
	
select * from benefit_option;	
select * from pspay_etv_list where etv_id in ('VB1','VB2','V65','VB3','VB4') ;


select * from person_deduction_setup where etvid = 'VC3' AND personid = '65104';
delete from person_deduction_setup where createts::date = current_date and etvid = 'VC3';
select * from person_identity where personid = '65104';



select * from person_identity where identity = '018505728';
select * from person_deduction_setup where etvid = 'VBV' and personid = '63660';


select * from person_deduction_setup where etvid = 'VBV' and createts::date = current_date --- - interval '1 day' 

delete from  person_deduction_setup where etvid = 'VBV' and createts::date = current_date ;


select * from person_identity where identity = '304681208';

select * from person_deduction_setup where personid = '67431' and etvid in ('VBY','VC9');
enddate = '2199-12-31';

select * from person_deduction_setup where ETVID in ('VBY','VC9') and createts::date = current_date ;
delete from person_deduction_setup where ETVID in ('VBY','VC9') and createts::date = current_date ;

select * from person_identity where identity = 'HMN00000099935';
select * from PERSON_EARNING_SETUP where personid = '68423' and etvid in ('E70','EC8','ECB','EC9');

delete from PERSON_EARNING_SETUP where personid = '68423' and etvid in ('E70','EC8','ECB','EC9') and createts::date = current_date;

select * from person_deduction_setup where etvid like 'E%';
select * from PERSON_EARNING_SETUP where etvid like 'E%';

select * from pspay_etv_list where etv_id in ('E70','EC8','ECB','EC9') ;


HMN00000014992

HMN00018505728
HMN00304681208
HMN00000099935
HMN00000100030

select * from person_identity where identity = '223195612';
select * from PERSON_EARNING_SETUP where personid = '66857' and  createts::date = current_date - interval '1 day';
select * from PERSON_EARNING_SETUP where createts::date = current_date and etvid not in ('E70','EC8','ECB','EC9') ;

delete from PERSON_EARNING_SETUP where createts::date = current_date and etvid not in ('E70','EC8','ECB','EC9') ;
HMN00223195612

select * from person_identity where identity = 'HMN00000014992';

select * from person_user_field_vals where personid = '68523';

select * from person_user_field_vals WHERE createts::date = current_date AND UFID = '8';
DELETE from person_user_field_vals WHERE createts::date = current_date AND UFID = '8';

select * from person_financial_plan_election;

select * from benefit_plan_desc where 
select * from person_user_field_vals WHERE createts::date = current_date AND UFID in ('9','10','11');
delete from person_user_field_vals WHERE createts::date = current_date AND UFID in ('9','10','11');
select	
 pi.personid
 
,trim(pi.identity)::varchar(20) as trankey
,trim(pie.identity)::varchar(20) as EmpNo
from person_identity pi
left join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
where pi.identitytype = 'PSPID' and current_timestamp between pi.createts and pi.endts
order by pie.identity;


select * from person_employment where personid = '66315';
select * from person_identity;
select * from person_deduction_setup where personid = '139' and etvid = 'VC3';

select * from person_deduction_setup where updatets::date = current_date::date and enddate = '2199-12-31';
----- log table -----

select * from log_entries where processName = 'PersDeductionsSetup' and viewName = 'PERSON_DEDUCTION_SETUP' and pageName = 'MetaUpdateRow';
select * from PERSON_DEDUCTION_SETUP;

select * from process_process_links WHERE viewname like 'PERSON_FINANCIAL%'

select * from PERSON_FINANCIAL_PLAN_ELECTION;
For testing use AEB on BFX – since they also have a user field with a similar type (ufdatatype = ‘TXT’)

select * from user_field_desc;



select distinct viewName from log_entries;
select * from log_entries where viewname = 'PERSON_FINANCIAL_PLAN_ELECTION';
select distinct processName from log_entries;
select * from log_entries where viewname like '%USER%';

select * from person_user_field_vals;
select * from person_names where personid = '4633';
select * from person_identity where personid = '4646';
select * from PERSON_USER_FIELD_VALS where personid = '62958' and ufid in ('9','10','11');


select * from person_names where personid = '62958';
select * from PERSON_USER_FIELD_VALS where createts::date = current_date;
select * from user_field_desc;

select	ufname::varchar(20),ufid from	user_field_desc where 'now'::text::date >= effectivedate AND 'now'::text::date <= enddate AND now() >= createts AND now() <= endts;



select pi1.identity as API,pi2.identity as APIsk,1 as lookup_constant,current_timestamp as createts
from	person_identity pi1 
join	person_identity pi2 on pi1.personid = pi2.personid
		and pi2.identitytype = 'APIsk'
		and current_timestamp between pi2.createts and pi2.endts

where pi1.identitytype  = 'API'
	and pi1.personid = '1'
	and current_timestamp between pi1.createts and pi1.endts

delete from person_user_field_vales where personid = '62958' and persufpid < 18;
delete from person_user_field_vals where personid = '62958' and persufpid = 18 and ufid in ('9','10','11');