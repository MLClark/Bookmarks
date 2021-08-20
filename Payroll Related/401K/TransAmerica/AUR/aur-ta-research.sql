select * from edi.edi_last_update;
2020/07/15 18:56:31.896000000
update edi.edi_last_update set lastupdatets = '2020-07-15 22:21:02' where feedid = 'AUR_TransAmerica_401k_Contributions_Export'; ----2020/07/15 18:56:31.896000000  2020-07-31
insert into edi.edi_last_update (lastupdatets, feedid) values ('2020-07-15 22:21:02', 'AUR_TransAmerica_401k_Contributions_Export_mlc');
update edi.edi_last_update set lastupdatets = '2020-05-20 19:00:49' where feedid = 'AUR_TransAmerica_401k_Contributions_Export'; ----2020-05-20 19:00:49
delete from edi.edi_last_update where feedid = 'AUR_TransAmerica_401k_Contributions_Export_mlc';


select * from pay_unit;
  (select ppd.personid from pspay_payment_detail ppd 
		   join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
		   join pay_schedule_period psp on psp.payscheduleperiodid = pph.payscheduleperiodid
		   where ppd.paymentheaderid in 
			(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
			(select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
		           join edi.edi_last_update elu on elu.feedid = 'AUR_TransAmerica_401k_Contributions_Export_mlc' and elu.lastupdatets <= ppay.statusdate
                          where ppay.pspaypayrollstatusid = 4 )))      
		   and ppd.etv_id in ('V73','V65','VB1','VB2','VB3','VB4','VB5')
		   ;
(select ppd.personid from pspay_payment_detail ppd
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
where pph.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid =  'AUR_TransAmerica_401k_Contributions_Export_mlc' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('V73','V65','VB1','VB2','VB3','VB4','VB5') 
  and ppd.personid = '7258') 
		   ;
		   
select * from person_deduction_setup where personid = '7258';		   
select * from person_deduction_setup where etvid  in  ('V73','V65','VB1','VB2','VB3','VB4','VB5') ;		

select * from cognos_pspay_etv_names where etv_id like 'V%';
select * from pspay_payment_header where paymentheaderid = '30333';
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid = '803';
select * from pspay_payroll where pspaypayrollid in ('191');
select * from pspay_payment_detail where personid = '7258';


select * from pay_schedule_period where date_part('year',periodpaydate) = '2020' and date_part('month',periodpaydate) = '05';


select * from pspay_payroll ppay join edi.edi_last_update elu on elu.feedid = 'AUR_TransAmerica_401k_Contributions_Export' and '2020-03-25 09:30:35' <= ppay.statusdate  and ppay.pspaypayrollstatusid = 4;
select * from pspay_payroll where pspaypayrollid in ('193', '191');
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid in ('803','651','675','696');
select * from pspay_payment_header where payscheduleperiodid in ('803','651','675','696') and personid = '5933';
select * from pspay_payment_detail where personid = '5933' and paymentheaderid in ('30466','30333') and etv_id  in ('VB1','VB2','VB3','VB4','VB5','V65');

select * from pspay_payment_detail where personid = '5933' and check_date = '2020-03-13' and etv_id = 'VB2';




(SELECT ppd.*
           FROM pspay_payment_detail ppd
           join edi.edi_last_update els on els.feedid = 'AUR_TransAmerica_401k_Contributions_Export'  
	   join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
	   join pspay_payroll_pay_sch_periods ppsp on ppsp.payscheduleperiodid = pph.payscheduleperiodid
	   join pspay_payroll ppay on ppay.pspaypayrollid = ppsp.pspaypayrollid and ppay.pspaypayrollstatusid = 4 and ppay.statusdate is not null
           WHERE ppd.etv_id in (select etv_id from pspay_etv_operators
                                where operand = 'WS15' and etvindicator in ('E') and group_key <> '$$$$$' and opcode = 'A' group by 1)
                                                       AND date_part('year', ppd.check_date) = date_part('year',current_date::DATE)
	   and ppay.statusdate <= '2020-03-25 09:30:35'	
	   and ppd.personid = '5933'
           
           )
           ;




















(select 
 x.personid
,x.periodpaydate
,sum(x.vb1_amount) as vb1_amount -- Pre Taxed 401(k)  
,sum(x.vb2_amount) as vb2_amount -- Pre Taxed 401(k) Catch Up 
,sum(x.vb3_amount) as vb3_amount -- roth
,sum(x.vb4_amount) as vb4_amount -- Roth Catch Up  
,sum(x.vb5_amount) as vb5_amount -- 401KCMAE 
,sum(x.v65_amount) as v65_amount -- loan 1 amount
,sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.v65_amount) as total_payroll_amount
from

(select
ppd.personid
,psp.periodpaydate
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'V65' then etv_amount  else 0 end as v65_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd 
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
join  psp on psp.payscheduleperiodid = pph.payscheduleperiodid
where ppd.personid = '5933' and ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
							join edi.edi_last_update elu on elu.feedid = 'AUR_TransAmerica_401k_Contributions_Export' 
								and elu.lastupdatets <= ppay.statusdate 										
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in ('VB1','VB2','VB3','VB4','VB5','V65')) x
  group by 1,2 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.v65_amount) <> 0);
  select * from pay_schedule_period where date_part('year',periodpaydate) = '2020' and date_part('month',periodpaydate)>='04';