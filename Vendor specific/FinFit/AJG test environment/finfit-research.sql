select * from pay_unit;
select * from pspay_payment_detail;

update edi.lookup set value1 = '04/02/2020' where lookupid = 7;
update edi.edi_last_update set lastupdatets = '2020-03-31 00:00:00' where feedid = 'FinFit_Demographic_File';
update edi.edi_last_update set lastupdatets = '2020-03-21 00:00:00' where feedid = 'FinFit_Demographic_File';
update edi.edi_last_update set lastupdatets = '2020-03-23 00:00:00' where feedid = 'FinFit_Demographic_File';
update edi.lookup set value1 = '04/02/2020' where lookupid = 7;
update edi.lookup set value1 = '03/02/2020' where lookupid = 7;
update edi.lookup set value1 = '04/02/2020' where lookupid = 7;


select * from person_compensation where personid = '9742';

select * from person_employment where personid = '9838';

select * from cognos_pspay_etv_names where etv_id = 'V72';
select netcontacttype from person_net_contacts group by 1;

select * from pspay_payment_detail where personid = '9635' and check_date = '2020-04-02';
select * from pspay_payment_header where personid = '9635' and check_date = '2020-04-02';
select * from payroll.paymentdisbursements where personid = '10003' and check_date = '2020-04-02'; 
left join person_payroll pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

left join pay_unit pu
  on pu.payunitid = pp.payunitid
 and current_timestamp between pu.createts and pu.endts

delete from edi.edi_last_update where feedid = 'FinFit';

INSERT into edi.edi_last_update (feedid,lastupdatets) values ('FinFit_Demographic_File','2020-09-01 00:00:00');
update edi.edi_last_update set lastupdatets = '2020-07-14 00:00:00' where feedid = 'FinFit_Demographic_File';
select * from edi.edi_last_update;

select * from pspay_payment_detail where personid = '9635' and check_date = '2020-04-02';
select * from pspay_payment_header where personid = '9635' and check_date = '2020-04-02';

(
select x.personid, x.check_date, sum(x.gross) from 
(

select 
ppd.personid
,ppd.check_date::date
,pph.gross_pay as gross
from pspay_payment_detail ppd
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid

where pph.personid = '9635' and pph.check_date = ?::date and pph.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu  on elu.feedid =  'FinFit_Demographic_File' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) 
                             group by ppd.personid, ppd.check_date, pph.gross_pay, pph.net_pay, pph.paymentheaderid order by ppd.personid) x
                             group by x.personid, x.check_date)