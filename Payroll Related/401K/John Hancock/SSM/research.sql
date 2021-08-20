
update edi.edi_last_update set lastupdatets = '2020-05-13 09:08:22' where feedid = 'SSM_JH_401K_Export'; ----2020-05-13 09:08:22
select * from edi.edi_last_update;
select * from person_financial_plan_election where personid = '1003';

select * from pay_unit;



(select psp.payunitid,  periodpaydate
             from pay_schedule_period psp
             join pay_unit pu on pu.payunitid = psp.payunitid
             left join edi.edi_last_update ed on ed.feedid = 'SSM_JH_401K_Export' 
            where psp.payrolltypeid = 1 and psp.processfinaldate is not null and psp.processfinaldate <= ed.lastupdatets group by psp.payunitid,periodpaydate order by periodpaydate)
            ;

SELECT (date_trunc('month', '2017-01-05'::date) + interval '1 month' - interval '1 day')::date
AS end_of_month;

select (date_trunc(month,current_date);
select * from person_payroll where personid in ('1003');
(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.v25_amount) as v25_amount
,sum(x.vdo_amount) as vdo_amount
,sum(x.vdp_amount) as vdp_amount
,sum(x.vcg_amount) as vcg_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.vbf_amount) as vbf_amount
,x.payscheduleperiodid
,x.group_key
,sum(x.vb1_amount+x.vb2_amount+x.v25_amount+x.vdo_amount+x.vdp_amount+x.vcg_amount+x.vb3_amount+x.vb4_amount+x.vb5_amount+x.vbf_amount) as total_401k
from


(select distinct
ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount else 0 end as vb2_amount
,case when ppd.etv_id = 'V25' then etv_amount else 0 end as v25_amount
,case when ppd.etv_id = 'VDO' then etv_amount else 0 end as vdo_amount
,case when ppd.etv_id = 'VDP' then etv_amount else 0 end as vdp_amount
,case when ppd.etv_id = 'VCG' then etv_amount else 0 end as vcg_amount
,case when ppd.etv_id = 'VB3' then etv_amount else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount else 0 end as vb5_amount
,case when ppd.etv_id = 'VBF' then etv_amount else 0 end as vbf_amount
,ppd.paymentheaderid
,pph.payscheduleperiodid
,pph.group_key
from pspay_payment_detail ppd
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
---join edi.edi_last_update elu  on elu.feedid =  'SSM_JH_401K_Export' and elu.lastupdatets::date <= ppd.check_date::date
where pph.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                           join edi.edi_last_update elu on elu.feedid =  'SSM_JH_401K_Export' and elu.lastupdatets::date < ppay.statusdate::date
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','V25','VDO','VDP','VCG','VB3','VB4','VB5','VBF')) x
  group by 1,2,payscheduleperiodid, group_key  having sum(x.vb1_amount + x.vb2_amount + v25_amount + vdo_amount + vdp_amount + vcg_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.vbf_amount) <> 0) 

    
 select * from pspay_payment_header;    
    
select * from person_names where lname like 'Mog%';
select * from person_deduction_setup where personid = '885';

select * from pspay_payment_detail where personid = '885' and etv_id in ('V65','V73','V31');

select * from person_employment where emplstatus in ('R','T') and effectivedate >= current_date - interval '1 year' ;
select * from pspay_payment_detail where etv_id in ('VB1','VB2','V25','VDO','VDP','VCG','VB3','VB4','VB5','VBF','V65','V73','V31')
and personid = '1013' and check_date >= '2020-02-12'

select * from pay_unit;
select * from person_financial_plan_election;
select * from person_compensation 
select * from pers_pos

select * from pay_schedule_period where date_part('year',periodpaydate)='2020'and date_part('month',periodpaydate)='01';

--INSERT into edi.edi_last_update (feedid,lastupdatets) values ('SSM_JH_401K_Export','2020-01-01 00:00:00');
update edi.edi_last_update set lastupdatets = '2020/03/09 10:23:57' where feedid = 'SSM_JH_401K_Export'; ----2020-03-20 13:03:34
select * from edi.edi_last_update;
select * from pay_schedule_period where date_part('year',periodpaydate)='2020'and date_part('month',periodpaydate)>='01';

select * from cognos_pspay_etv_names where etv_id in 
(select distinct etv_id from pspay_payment_detail where check_date >= '2020-03-01' and ETV_ID LIKE 'V%');

select * from pspay_etv_operators where operand = 'WS15';

select * from pspay_payment_header


select * from pspay_payment_detail where etv_id in ('VB1','VB2','V25','VDO','VDP','VCG','VB3','VB4','VB5','VBF','V65','V73','V31')
and personid = '885' ;

select * from pspay_payment_detail where personid = '1003' and check_date = '2019-01-31' and etv_id in 
(select a.etv_id from pspay_etv_operators a  
                                 where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by etv_id);
                                 
select * from                                  

-----------------
-- total_hours --
----------------- 
LEFT JOIN (SELECT h.personid
             --,h.check_date 
                 ,sum(h.etype_hours) as Hours
             FROM          
 (Select distinct
    ppdh.personid
   ,ppdh.check_date

   ,ppdh.etype_hours
   ,ppdh.paymentheaderid
    from pspay_payment_detail ppdh
   where ppdh.check_date >= date_trunc('year',now()) and ppdh.paymentheaderid in 
         (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                 (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid 
                           from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid =  'SSM_JH_401K_Export'  --and ppay.statusdate >= date_trunc('year',now())
                          where ppay.pspaypayrollstatusid = 4 ))) and ppdh.etv_id  in 
                               (select a.etv_id from pspay_etv_operators a  
                                 where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by etv_id))
 h group by 1) total_hours on total_hours.personid = pi.personid --and total_hours.check_date = dedamt.check_date
-----------------
-- wage_amount --
-----------------
LEFT JOIN (SELECT w.personid
             ,w.check_date 
                 ,sum(w.etv_amount) as  Amount
             FROM          
            
       (Select distinct
             ppdw.personid
             ,ppdw.check_date
             ,ppdw.etv_amount 
             ,ppdw.paymentheaderid
             from pspay_payment_detail ppdw
             where ppdw.check_date >= date_trunc('year',now()) and ppdw.paymentheaderid in 
                    (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                           (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                                 (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                                      on elu.feedid =  'SSM_JH_401K_Export'-- and elu.lastupdatets <= ppay.statusdate
                                      where ppay.pspaypayrollstatusid = 4 ))) and ppdw.etv_id  in  (select a.etv_id from pspay_etv_operators a
                                                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1)) w group by 1,2) 
                                                            wage_amount on wage_amount.personid = pi.personid 
                                                            and wage_amount.check_date = dedamt.check_date

                                                                                 