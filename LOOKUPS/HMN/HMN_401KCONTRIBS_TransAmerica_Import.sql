----- Debbie's 

-- DEMQA HMN
--select * from edi.etl_personal_info where personid = '63054'   --'000008474'

--select * from person_employment where personid = '63054'

--select * from person_deduction_setup where effectivedate = '2020-02-20'  and etvid in ('VC9','VBY')
--SELECT * from person_deduction_setup where enddate = '2020-02-19'  and etvid in ('VC9','VBY')

--delete from person_deduction_setup where effectivedate = '2020-02-20'  and etvid in ('VC9','VBY');
--update person_deduction_setup set enddate = '2199-12-31' where enddate = '2020-02-19'  and etvid in ('VC9','VBY');

--select * from log_entries where transactionstart = '2020-03-06 10:43:36.955-05'

/*
HMN
*/

SELECT * FROM edi.lookup_schema;

select * from edi.lookup;



select nextval('edi.lookup_schema_id_seq');

INSERT INTO edi.lookup_schema (lookupid, lookupname, lookupdesc, effectivedate, enddate, createts, endts)
select  nextval('edi.lookup_schema_id_seq'), 'HMN_401KCONTRIBS_TransAmerica_Import', 'HMN_401KCONTRIBS_TransAmerica_Import - etvid to benefitplan mapping', '2020-01-01', '2199-12-31',current_timestamp,'2199-12-31 00:00:00'
;

update edi.lookup_schema set keycoldesc1='Client' where lookupname='HMN_401KCONTRIBS_TransAmerica_Import';

INSERT INTO edi.lookup (id,lookupid,key1,key2, value1, value2, value3, value4, value5)
select nextval('edi.lookup_id_seq'), lookupid, 'HMN', 'VB1', '117','40','401K','B','12603'
from edi.lookup_schema
where lookupname = 'HMN_401KCONTRIBS_TransAmerica_Import';

INSERT INTO edi.lookup (id,lookupid,key1,key2, value1, value2, value3, value4, value5)
select nextval('edi.lookup_id_seq'), lookupid, 'HMN', 'VB2', '120','4CU','401K C/U','B','12604'
from edi.lookup_schema
where lookupname = 'HMN_401KCONTRIBS_TransAmerica_Import';


INSERT INTO edi.lookup (id,lookupid,key1,key2, value1, value2, value3, value4, value5)
select nextval('edi.lookup_id_seq'),lookupid, 'HMN', 'VB3', '123','4R','Roth','B','12605'
from edi.lookup_schema
where lookupname = 'HMN_401KCONTRIBS_TransAmerica_Import';

INSERT INTO edi.lookup (id,lookupid,key1,key2, value1, value2, value3, value4, value5)
select nextval('edi.lookup_id_seq'),lookupid, 'HMN', 'VB4', '126','4RCU','Roth C/U','B','12606'
from edi.lookup_schema
where lookupname = 'HMN_401KCONTRIBS_TransAmerica_Import';










----- below was first stab 

delete from edi.lookup_schema;
delete from edi.lookup;


INSERT INTO edi.lookup_schema (lookupid, keycoldesc1, valcoldesc1, lookupname, lookupdesc)
VALUES (1,'Client','ETVID','HMN_401KCONTRIBS_TransAmerica_Import','key=lookupname');


insert into edi.lookup 
(lookupid,key1,key2,value1,value2,value3,value4,value5)
select distinct
 1 --lookupid 
,'HMN' ::char(3) as client --key1
,case when trim(upper(bpd.benefitsubclass)) = '40'    and bpd.benefitplanid = '102' then 'VB1'
      when trim(upper(bpd.benefitsubclass)) = '4CU'   and bpd.benefitplanid = '105' then 'VB2'
      when trim(upper(bpd.benefitsubclass)) = '4ROTH' and bpd.benefitplanid = '111' then 'VB3'
      when trim(upper(bpd.benefitsubclass)) = '4RCU'  and bpd.benefitplanid = '114' then 'VB4'
      end ::char(3) as etv_id -- key2
,bpd.benefitplanid as benefitplanid --value 1
,bpd.benefitsubclass as benefitsubclass --value 2
,bpd.benefitplancode::char(10) as benefitplancode --value 3
,'P'::char(1) as benefitcalctype --value 4
,max(bo.benefitoptionid) as benefitoptionid --value 5

from benefit_plan_desc bpd
join benefit_option bo on bo.benefitplanid = bpd.benefitplanid 
 and bo.edtcode = bpd.edtcode
 and bpd.benefitplanid = bo.benefitplanid
 and current_date between bo.effectivedate and bo.enddate 
 and current_timestamp between bo.createts and bo.endts 

where bpd.edtcode like '%401%'
 and current_date between bpd.effectivedate and bpd.enddate 
 and current_timestamp between bpd.createts and bpd.endts 
 group by 1,2,3,4,5,6,7

;

select * from edi.lookup_schema;
select * from edi.lookup;


select 
 lu.key2 ::char(3) as etv_id
,lu.value1 as benefitplanid
,lu.value2 ::char(5)  as benefitsubclass
,lu.value3 ::char(10) as benefitplancode
,lu.value4 ::char(1)  as benefitcalctype
,lu.value5 as benefitoptionid
from edi.lookup lu
join edi.lookup_schema ls on ls.lookupid = lu.lookupid
where lu.key1='HMN' and ls.keycoldesc1='Client' and lookupname='HMN_401KCONTRIBS_TransAmerica_Import' --and 
;
  