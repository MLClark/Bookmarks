select * from edi.edi_last_update;
select * from pay_schedule_period where date_part('year',periodpaydate)='2020' and date_part('month',periodpaydate) >= '05';

select * from person_employment where emplstatus in ('R','T') and effectivedate >= current_date - interval '1 year' and personid = '369';
select * from person_vitals;

select * from pers_pos;
select positiontitle from position_desc group by 1;
select * from person_financial_plan_election;
 2020/04/02 01:00:00.000000000
update edi.edi_last_update set lastupdatets = '2020-11-13 10:59:31' where feedid = 'CDS_JH_401K_Export'; ------ 2020-11-16 16:58:32

2020/11/13 10:59:31.064000000


select * from person_names where lname like 'Beck%';


update person_employment set effectivedate = '2020-08-25' where personid = '1250' and emplstatus = 'T';
update person_employment set enddate = '2199-12-31' where personid = '1250' and emplstatus = 'T';
select * from person_employment where personid  in ('1245','1250');


(select personid,sum(etype_hours) as total_hours  from pspay_payment_detail group by 1);          


,cast(date_part('year',age(current_date, pv.birthdate))as dec(18,0))  as ee_age

select * from person_employment where personid = '128';

select * from pay_unit;

select * from person_names where lname like 'Book%';

select * from pspay_payment_detail where personid = '1245' and etv_id in ('VB1','VB2','V25','VDO','VDP','VCG','VB3','VB4','VB5') and check_date = '2020-08-19';
select * from person_employment where personid = '1245';


select * from person_employment where personid = '308';






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
,x.payscheduleperiodid
,sum(x.vb1_amount+x.vb2_amount+x.vdo_amount+x.vdp_amount+x.vcg_amount+x.vb3_amount+x.vb4_amount+x.vb5_amount) as total_401k
from


(select distinct
ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'V25' then etv_amount  else 0 end as v25_amount
,case when ppd.etv_id = 'VDO' then etv_amount  else 0 end as vdo_amount
,case when ppd.etv_id = 'VDP' then etv_amount  else 0 end as vdp_amount
,case when ppd.etv_id = 'VCG' then etv_amount  else 0 end as vcg_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,ppd.paymentheaderid
,pph.payscheduleperiodid
from pspay_payment_detail ppd
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid

where pph.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu  on elu.feedid =  'CDS_JH_401K_Export' and elu.lastupdatets<= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) and ppd.personid = '39'
  and ppd.etv_id  in  ('VB1','VB2','V25','VDO','VDP','VCG','VB3','VB4','VB5')) x
  group by 1,2,payscheduleperiodid  having sum(x.vb1_amount + x.vb2_amount + v25_amount + vdo_amount + vdp_amount + vcg_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount) <> 0) 



select * from pspay_payroll where pspaypayrollstatusid = '4' order by  statusdate ;
  (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu  on elu.feedid =  'CDS_JH_401K_Export' and elu.lastupdatets<= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 );

select * from edi.edi_last_update;
select * from pspay_payroll_pay_sch_periods where pspaypayrollid in ('1183');
select * from pspay_payment_header where payscheduleperiodid in ('3963');




select psp.payunitid, max(periodpaydate) as periodpaydate from pay_schedule_period psp
join pay_unit pu on pu.payunitid = psp.payunitid
left join edi.edi_last_update ed on ed.feedid = 'CDS_JH_401K_Export' 
where psp.payrolltypeid = 1 and psp.processfinaldate::date is not null and psp.periodpaydate >= ed.lastupdatets group by psp.payunitid

select * from person_employment 
select * from pay_schedule_period where date_part('year',periodpaydate)='2020'and date_part('month',periodpaydate)>'01';
select * from person_financial_plan_election where personid = '375';

select benefitsubclass from person_financial_plan_election group by 1;
(select personid, etype_hours as hours, check_date
             from pspay_payment_detail            
            where date_part('year', check_date) = date_part('year',current_date)  and personid = '282'
              and etv_id in (select a.etv_id from pspay_etv_operators a  
                              where a.operand = 'WS15' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1)
           
          )

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
,x.payscheduleperiodid
from


(select distinct
ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'V25' then etv_amount  else 0 end as v25_amount
,case when ppd.etv_id = 'VDO' then etv_amount  else 0 end as vdo_amount
,case when ppd.etv_id = 'VDP' then etv_amount  else 0 end as vdp_amount
,case when ppd.etv_id = 'VCG' then etv_amount  else 0 end as vcg_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,ppd.paymentheaderid
,pph.payscheduleperiodid
from pspay_payment_detail ppd
join pspay_payment_header pph on ppd.paymentheaderid = pph.paymentheaderid
where pph.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid =  'CDS_JH_401K_Export' 
                          where ppay.pspaypayrollstatusid = 4   and ppay.statusdate::date >= elu.lastupdatets::date)))
  and ppd.etv_id  in  ('VB1','VB2','V25','VDO','VDP','VCG','VB3','VB4','VB5')) x
  group by 1,2,payscheduleperiodid  
  having sum(x.vb1_amount + x.vb2_amount + v25_amount + vdo_amount + vdp_amount + vcg_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount) <> 0) 
  ;



select * from person_employment where effectivedate::date > current_date::date;

select * from pspay_payment_detail where personid = '96' and etv_id in ('VB1');
select paymentheaderid from pspay_payment_detail where personid = '417' and etv_id in ('VB1');

select paymentheaderid, payscheduleperiodid from pspay_payment_header where paymentheaderid in 
(select paymentheaderid from pspay_payment_detail where personid = '417' and etv_id in ('VB1'));

select * from pspay_payroll_pay_sch_periods where payscheduleperiodid in 
(select  payscheduleperiodid from pspay_payment_header where paymentheaderid in 
(select paymentheaderid from pspay_payment_detail where personid = '417' and etv_id in ('VB1')));

select * from edi.edi_last_update;


select * from pspay_payroll join edi.edi_last_update elu on elu.feedid =  'CDS_JH_401K_Export' where pspaypayrollid in 
(select pspaypayrollid from pspay_payroll_pay_sch_periods where payscheduleperiodid in 
(select  payscheduleperiodid from pspay_payment_header where paymentheaderid in 
(select paymentheaderid from pspay_payment_detail where personid = '417' and etv_id in ('VB1')))) 
and pspaypayrollstatusid = 4 and statusdate::date >= elu.lastupdatets::date

 (SELECT h.personid
                 ,h.check_date 
                 ,sum(h.etype_hours) as Hours
             FROM          
            
 (Select distinct
    ppdh.personid
   ,ppdh.check_date

   ,ppdh.etype_hours
   ,ppdh.paymentheaderid
    from pspay_payment_detail ppdh
   where ppdh.personid = '282' and ppdh.check_date >= date_trunc('year',now()) and ppdh.paymentheaderid in 
         (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                 (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid 
                           from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid =  'CDS_JH_401K_Export'  --and ppay.statusdate >= date_trunc('year',now())
                          where ppay.pspaypayrollstatusid = 4 ))) and ppdh.etv_id  in 
                               (select a.etv_id from pspay_etv_operators a  
                                 where a.operand = 'WS23' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by etv_id))
                                  h group by personid, check_date) 




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
             where and ppdh.check_date >= date_trunc('year',now()) and ppdh.paymentheaderid in 
                    (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                           (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                                 (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                                      on elu.feedid =  'CDS_JH_401K_Export'  and date_part('year',elu.lastupdatets) = date_part('year',ppay.statusdate)
                                      where ppay.pspaypayrollstatusid = 4 ))) and ppdh.etv_id  in  (select a.etv_id from pspay_etv_operators a  
                                                where a.operand = 'WS23' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1)) h group by 1) 
                                                            total_hours on total_hours.personid = pi.personid --and total_hours.check_date = dedamt.check_date





(select * 
                           from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid =  'CDS_JH_401K_Export' -- and date_part('year',elu.lastupdatets) = date_part('year',ppay.statusdate)
                          where ppay.pspaypayrollstatusid = 4 )






















(SELECT h.personid
             ,h.check_date 
                 ,sum(h.etype_hours) as Hours
             FROM          
            
       (Select distinct
             ppdh.personid
             ,ppdh.check_date
             ,ppdh.etype_hours
             ,ppdh.paymentheaderid
             from pspay_payment_detail ppdh
             where ppdh.paymentheaderid in 
                    (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                           (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                                 (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                                      on elu.feedid =  'CDS_JH_401K_Export' and date_part('year',elu.lastupdatets) = date_part('year',ppay.statusdate)
                                      where ppay.pspaypayrollstatusid = 4 ))) and ppdh.etv_id  in  (select a.etv_id from pspay_etv_operators a  
                                                where a.operand = 'WS23' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1)) h where h.personid = '282' group by 1,2)
                                                ;
                                                
       (Select distinct
             ppdh.personid
             ,ppdh.check_date
             ,ppdh.etype_hours
             ,ppdh.paymentheaderid
             from pspay_payment_detail ppdh
             where   ppdh.personid = '282' and ppdh.paymentheaderid in 
                    (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                           (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                                 (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                                      on elu.feedid =  'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                                      where ppay.pspaypayrollstatusid = 4 ))) and ppdh.etv_id  in  (select a.etv_id from pspay_etv_operators a  
                                                where a.operand = 'WS23' and a.etvindicator = 'E' and a.opcode = 'A' and a.group_key <> '$$$$$' group by 1));                                                

select * from pspay_payroll ppay where ppay.pspaypayrollstatusid = 4;
select * from pspay_payroll ppay join edi.edi_last_update elu  on elu.feedid =  'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate where ppay.pspaypayrollstatusid = 4;

select * 

  (select distinct 'Y' ::char(1) as elig_indicator 
     from person_employment pe 
     join pspay_payment_detail ppd on ppd.personid = pe.personid
    where ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDS_JH_401K_Export' and elu.lastupdatets > ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))))
                             
select * from person_names where personid in   (select distinct pe.personid 
     from person_employment pe 
     join pspay_payment_detail ppd on ppd.personid = pe.personid
    where pe.emplstatus in ('R','T')
      and ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDS_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))));                             