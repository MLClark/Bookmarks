select * from pspay_payment_detail where etv_id = 'V65' and check_date >= '2019-12-01';
select * from pay_schedule_period where date_part('year',periodpaydate)='2020' and date_part('month',periodpaydate)='01';

2020/08/12 16:54:57.189000000

select * from edi.edi_last_update;

                             
   select * from pspay_payment_detail where personid = '1773' and etv_id in ('VB1','VB2','VB3','VB4','VB5','VB6','V65','V66') and check_date >= '2020-02-20';    
   
update edi.edi_last_update set lastupdatets = '2020-02-26 18:49:27'  where feedid = 'BAC_JH_401K_Export'; ---2020-02-26 17:49:27

insert into edi.edi_last_update (lastupdatets, feedid) values ('2020-08-12 16:54:10','BAC_JH_401K_Export_mlc');


(select ppd.personid, sum(ppd.etype_hours) as hours, sum(etv_amount) as taxable_amount
             from pspay_payment_detail ppd
             join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key 
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'BAC_JH_401K_Export' 
                            and date_part('year',ppay.statusdate) = date_part('year',elu.lastupdatets)
                             where ppay.pspaypayrollstatusid = 4 )))
     and peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A' and ppd.personid = '2834'
group by 1)


select 
 x.personid
,sum(x.gross_pay) as gross_pay
,max(x.check_date) as max_check_date

from 

(select pph.personid, elu.lastupdatets lastupdate,pph.check_date check_date, sum(pph.gross_pay) as gross_pay
from pspay_payment_header pph
join edi.edi_last_update elu on elu.feedid = 'BAC_JH_401K_Export' 
where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date) and pph.personid = '2834'
                            group by 1,2,3) x  where x.check_date <= x.lastupdate group by personid

union
select 
 x.personid
,sum(x.gross_pay) as gross_pay
,x.check_date as max_check_date

from 

(select pph.personid, elu.lastupdatets lastupdate,pph.check_date check_date, sum(pph.gross_pay) as gross_pay
from pspay_payment_header pph
join edi.edi_last_update elu on elu.feedid = 'BAC_JH_401K_Export' 
where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date) and pph.personid = '2834'
                            group by 1,2,3) x  where x.check_date > x.lastupdate group by personid,max_check_date







--------------------------------------------------             
----- YTD 401K WAGES - BASED ON WS15 OPERAND ----- UPDATED
--------------------------------------------------   
left join (
select 
 x.personid
,sum(x.hours) as prior_hours 
,sum(x.taxable_amount) as taxable_amount
,max(x.check_date) as max_check_date

from

(select ppd.personid, ppd.check_date check_date,  elu.lastupdatets lastupdate,  sum(ppd.etype_hours) as hours, sum(etv_amount) as taxable_amount
             from pspay_payment_detail ppd
             join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key
             join edi.edi_last_update elu on elu.feedid = 'BAC_JH_401K_Export' 
                            and date_part('year',ppd.check_date) = date_part('year',elu.lastupdatets) 
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))               
     and peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A' and ppd.personid = '2834' 
group by 1,2,3 order by 1,2) x
where x.check_date <= x.lastupdate
group by personid

union

select 
 x.personid
,sum(x.hours) as prior_hours 
,sum(x.taxable_amount) as taxable_amount
,x.check_date as max_check_date

from

(select ppd.personid, ppd.check_date check_date,  elu.lastupdatets lastupdate,  sum(ppd.etype_hours) as hours, sum(etv_amount) as taxable_amount
             from pspay_payment_detail ppd
             join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key
             join edi.edi_last_update elu on elu.feedid = 'BAC_JH_401K_Export' 
                            and date_part('year',ppd.check_date) = date_part('year',elu.lastupdatets) 
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay
                             where ppay.pspaypayrollstatusid = 4 )))               
     and peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A' and ppd.personid = '2834' 
group by 1,2,3 order by 1,2) x
where x.check_date > x.lastupdate
group by personid, max_check_date
) ytd401kB ON ytd401kB.personid = pi.personid  and ytd401kB.max_check_date = dedamt.check_date
























(
select 
 x.personid
,sum(x.cum_gross_pay) as gross_pay
,max(x.check_date) as max_check_date

from 

(select pph.personid, elu.lastupdatets lastupdate,pph.check_date check_date, 
        sum(pph.gross_pay) over (order by personid, check_date asc rows between unbounded preceding and current row) as cum_gross_pay
from pspay_payment_header pph
join edi.edi_last_update elu on elu.feedid = 'BAC_JH_401K_Export' 
where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date) 
                            ) x  where x.check_date <= x.lastupdate and x.personid = '2834' group by personid

union
select 
 x.personid
,sum(x.cum_gross_pay) as gross_pay
,x.check_date as max_check_date

from 

(select pph.personid, elu.lastupdatets lastupdate,pph.check_date check_date, 
        sum(pph.gross_pay) over (order by personid, check_date asc rows between unbounded preceding and current row) as cum_gross_pay
from pspay_payment_header pph
join edi.edi_last_update elu on elu.feedid = 'BAC_JH_401K_Export' 
where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date) 
                            ) x  where x.check_date > x.lastupdate and x.personid = '2834' group by personid,max_check_date
) 













select ppd.personid, sum(ppd.etype_hours) as hours, sum(etv_amount) as taxable_amount
             from pspay_payment_detail ppd
             join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key 
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'BAC_JH_401K_Export' 
                            and date_part('year',ppay.statusdate) >= date_part('year',elu.lastupdatets)
                             where ppay.pspaypayrollstatusid = 4 ))) and ppd.personid = '2834'  group by 1;
                             
   select * from pspay_payment_detail where personid = '1773' and etv_id in ('VB1','VB2','VB3','VB4','VB5','VB6','V65','V66') and check_date >= '2020-02-20';               
                             
 select * from pspay_payment_detail where personid = '2834'  and date_part('year',check_date)='2020'                   
    and etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A' group by 1)                  


select * from benefit_plan_desc where benefitsubclass in (select benefitsubclass from person_bene_election group by 1);
select * from pspay_etv_list where etv_id in (select etv_id from pspay_payment_detail where etv_id like 'V%' group by 1);

select * from pspay_payment_detail where etv_id in (select etv_id from pspay_etv_list where etv_id like 'V%' group by 1);
select distinct personid from pspay_payment_detail where etv_id in ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ');

select * from pspay_payment_detail where etv_id = 'V65' and check_date >= '2019-04-01';
select * from pspay_payment_detail where etv_id = 'VB3' and check_date >= '2019-04-01';
select * from pspay_payment_detail where etv_id = 'VB4' and check_date >= '2019-04-01';

select * from person_employment where emplstatus in ('T', 'R', 'D')
and effectivedate < enddate and enddate >= '2199-12-30' and current_timestamp between createts and endts and current_date - interval '45 days' <= effectivedate  
;   
select * from person_employment where personid = '1029';
SELECT CURRENT_DATE - INTERVAL '45 DAYS';
select * from person_payroll where personid = '2657';
select * from pay_unit where payunitid = '14';
select * from person_names where personid = '2657';
select * from person_employment where emplstatus = 'A' and personid not in 
(select distinct ppd.personid from pspay_payment_detail ppd
where ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'BAC_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','VB3','VB4','VB5','VB6','V65','V66'))



select * from pay_schedule_period where payrolltypeid = 1 and date_part('year',periodpaydate)='2020' and date_part('month',periodpaydate)>='02';

select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-04-12 06:00:08' where feedid = 'BAC_JH_401K_Export';
insert into edi.edi_last_update (feedid,lastupdatets) values ('BAC_JH_401K_Export','2019-06-10 00:00:00');

select * from pay_unit;
select * from pspay_payment_detail limit 100;


--left join 
(select ppd.personid, ppd.etv_id, sum(ppd.etype_hours) as hours, sum(etv_amount) AS taxable_amount
             from pspay_payment_detail ppd
             join pspay_etv_operators peo on peo.etv_id = ppd.etv_id and peo.group_key = ppd.group_key 
            where ppd.paymentheaderid in 
                  (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                     (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'BAC_JH_401K_Export' 
                            and ppay.statusdate >= elu.lastupdatets
                             where ppay.pspaypayrollstatusid = 4 )))
    --and ppd.etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A' group by 1) 
    
     and peo.operand = 'WS15' and peo.etvindicator = 'E' and peo.group_key <> '$$$$$' and peo.opcode = 'A' 
    and ppd.personid = '1088'                 
group by 1,2) 
--cur401k  ON cur401k.personid = pi.personid 
;
select * from pspay_payment_detail limit 10;
(SELECT distinct personid, etv_id
               ,sum(etype_hours) AS hours
               ,sum(etv_amount) AS taxable_amount
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A'
                            group by 1)
               AND check_date = '2019-04-19' -- ?::DATE
               and personid = '1088' 
         GROUP BY personid, etv_id
          )
;

 (SELECT distinct personid, etv_id
               ,sum(etype_hours) AS hours
               ,sum(etv_amount) as taxable_wage
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                             join pspay_etv_list b 
                               on a.etv_id = b.etv_id
                              and a.group_key = b.group_key
                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' group by 1)
           AND check_date = '2019-04-19'
           and personid = '1088' 

         GROUP BY personid, etv_id
          ) 
          ;

select * from pspay_etv_list where etv_id = 'E70';
(select * from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A' and etv_id = 'E70');
                                      
left join 
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.vb6_amount) as vb6_amount
,sum(x.v65_amount) as v65_amount
,sum(x.v66_amount) as v66_amount
from
 

(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'VB6' then etv_amount  else 0 end as vb6_amount
,case when ppd.etv_id = 'V65' then etv_amount  else 0 end as v65_amount
,case when ppd.etv_id = 'V66' then etv_amount  else 0 end as v66_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd

where ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'BAC_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','VB3','VB4','VB5','VB6','V65','V66'))
  and ppd.group_key in ('BAC05','BAC15') x
  group by 1,2 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.vb6_amount + x.v65_amount + x.v66_amount) <> 0) union_dedamt on union_dedamt.personid = pi.personid 