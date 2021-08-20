select * from edi.edi_import_tracking where feedid = 'BA3LM_ImportBilling' and personid = '85102' and trackingcode = '0000429198';
;
select * from pspay_input_transaction where individual_key = 'BA300000002221'  and transaction_originate = 'BA3LM_ImportBilling';

select * from pspay_input_transaction where last_updt_dt::date='2020-03-04' and transaction_originate = 'BA3LM_ImportBilling';
select * from person_identity where personid = '85102';
select * from person_names where lname like 'Baker%';
select * from person_names where personid = '85124';

select * from pspay_payment_detail where individual_key = 'BA300000002221' and date_part('year',check_date::date)='2020';
select * from pspay_payment_header where check_date::date = '2020-03-06';


select * from pspay_input_transaction where transaction_originate = 'BA3LM_ImportBilling' AND last_updt_dt::date = current_date::date;
select * from edi.edi_import_tracking where feedid = 'BA3LM_ImportBilling' and responsesentts::date  is null;


delete from pspay_input_transaction where last_updt_dt::date = '2020-03-04' and transaction_originate = 'BA3LM_ImportBilling';
delete from edi.edi_import_tracking where feedid = 'BA3LM_ImportBilling' and responsesentts::date = '2020-03-04';



select pi.personid
, trim(pi.identity)::varchar(9) as empno
, 1234 as logid --, l.logid
, substring(pit.identity from 1 for 5)::char(5) as groupno
, pit.identity::char(15) as trankey
, current_timestamp as rightnow
, pis.identity as ssn
, npdate.periodenddate::date next_periodenddate
from person_identity pi 
join person_identity pit on pi.personid = pit.personid
	and current_timestamp between pit.createts and pit.endts
	and pit.identitytype = 'PSPID'
join person_identity pis on pi.personid = pis.personid
	and current_timestamp between pis.createts and pis.endts
	and pis.identitytype = 'SSN'
--cross join ( select nextval('log_seq') as logid from dual )l
join person_payroll pp on pp.personid = pi.personid and current_date between pp.effectivedate and pp.enddate and current_timestamp between pp.createts and pp.endts

join (select payscheduleperiodid, psp.payunitid, periodstartdate, periodenddate, periodpaydate 
			from pay_schedule_period psp
			join (Select payunitid, min(periodpaydate) lastpaydate 
				from pay_schedule_period where periodpaydate > ?::DATE and payrolltypeid = 1 group by payunitid ) as ppd on ppd.payunitid = psp.payunitid
				and ppd.lastpaydate = psp.periodpaydate
				where payrolltypeid = 1 ) npdate on npdate.payunitid = pp.payunitid

where current_timestamp between pi.createts and pi.endts
and pi.identitytype = 'EmpNo'
order by pi.identity
;;