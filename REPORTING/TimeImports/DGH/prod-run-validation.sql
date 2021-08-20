select * from batch_header where batchname like '%.csv%' and createts::date >= '2019-04-29';
select * from batch_detail where batchheaderid = '887';
select identity from person_identity where personid in (select personid from batch_detail where batchheaderid = '887') and identitytype = 'Badge';

select * from person_identity where identity = '7B4907141';
select * from person_identity where personid = '19921';
select * from person_names where lname like 'Goldm%';
select * from batch_detail where personid = '17368' and etv_id = 'E03';
select * from batch_detail where personid = '17368' and createts::date >= '2019-04-29' and etv_id in ('E01','E02','E03');
select * from batch_header where batchheaderid = '911';

select distinct
 bh.batchheaderid
,bh.batchname
,bh.batchnotes
,pi.identity::char(9) as badge_id
,bd.personid
,etv.etv_name
,bd.etv_id::char(3) as etv_id
,bd.amount
,bd.hours
,bd.overriderate
,bd.effectivedate
from
(
select
 batchheaderid
,batchname
,batchnotes

from batch_header where batchname ilike '%.csv%' and createts::date >= '2019-04-29'
) bh

join 
(select distinct
 personid
,etv_id
,amount
,hours
,overriderate
,effectivedate
,batchheaderid

from batch_detail
) bd on bd.batchheaderid = bh.batchheaderid

join 
(select 
 personid
,identity
,identitytype
 from person_identity
) pi on pi.personid = bd.personid and pi.identitytype = 'Badge'

join 
(select 
 group_key
,etv_id
,etv_name

from cognos_pspay_etv_names) etv on etv.etv_id = bd.etv_id

order by batchnotes, batchname, badge_id