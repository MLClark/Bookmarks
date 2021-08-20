select transaction_originate from pspay_input_transaction where transaction_originate like 'HMN%' group by 1;
select * from pspay_input_transaction where transaction_originate = 'HMN_GTL';
delete from pspay_input_transaction where transaction_originate = 'HMN_GTL';
select * from person_user_field_vals where ufid = '8';
delete  from person_user_field_vals where ufid = '8';
select * from person_identity where identity in ('HMN00000022136', 'HMN00000022037');

select
	personid::varchar(20),
	trankey::varchar(100)
from
	edi.etl_personal_info;
	
	select	ufname::varchar(20),
		ufid
from	user_field_desc
where
		'now'::text::date >= effectivedate AND 'now'::text::date <= enddate AND now() >= createts AND now() <= endts;


select	distinct
		pv.personid,
		(select max(persufpid) from person_user_field_vals  where pv.personid = personid)::integer as maxpersufpid

from	person_user_field_vals as pv
where pv.personid in ('23509')

order by pv.personid;


select pi.personid
, trim(pi.identity)::varchar(9) as empno
, 1234 as logid --, l.logid
, substring(pit.identity from 1 for 5)::char(5) as groupno
, pit.identity::varchar(20) as trankey
, current_timestamp as rightnow
, pis.identity as ssn
, npdate.next_periodenddate::date next_periodenddate
from person_identity pi 
join person_identity pit on pi.personid = pit.personid
	and current_timestamp between pit.createts and pit.endts
	and pit.identitytype = 'PSPID'
join person_identity pis on pi.personid = pis.personid
	and current_timestamp between pis.createts and pis.endts
	and pis.identitytype = 'SSN'
--cross join ( select nextval('log_seq') as logid from dual )l
cross join (select distinct

--psp.paydate::date,    Column name changed in the pay_schedule_period table 1/6/2017
psp.periodpaydate::date,

npay.next_periodenddate
from pay_schedule_period psp
join 
(select distinct periodpaydate::date,lag(periodenddate) over (order by periodpaydate desc)::date as next_periodenddate
-- FROM pay_schedule_period where paydate >= ?::date   Column name changed in the pay_schedule_period table 1/6/2017
 FROM pay_schedule_period where periodpaydate >= ?::date 

-- order by 1) npay on npay.paydate = psp.paydate 
 order by 1) npay on npay.periodpaydate = psp.periodpaydate

--where psp.paydate = ?::date   Column name changed in the pay_schedule_period table 1/6/2017
where psp.periodpaydate = ?::date 


 and npay.next_periodenddate > ?::date) npdate  --Original...put this back!



where current_timestamp between pi.createts and pi.endts
and pi.identitytype = 'EmpNo'
order by pi.identity
;