select * from pay_schedule_period where date_part('year',periodpaydate)='2019'and date_part('month',periodpaydate)<='03';

select * from person_bene_election where personid = '10';

select * from person_deduction_setup where personid = '10';
select * from person_identity where identity = '218785314';

select * from person_employment where personid = '125';
select * from person_employment where emplstatus = 'T' and effectivedate >= '2018-12-30';
select * from pspay_payment_detail where personid = '327' and etv_id='V65';


select * from pspay_payment_detail where personid = '327' and etv_id in (select a.etv_id from pspay_etv_operators a where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$' group by 1)
and date_part('year',check_date)='2019';

select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-04-29 15:35:56' where feedid = 'CDE_Principal_Financial_Group_401k_Export'; --- 2019-04-29 15:35:56
refresh materialized view cognos_payment_deductions_by_check_date_mv

select 
 x.personid
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.v65_amount) as v65_amount
from
 

(select distinct
 ppd.personid
,ppd.check_date
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,case when ppd.etv_id = 'V65' then etv_amount  else 0 end as v65_amount
,psp.periodpaydate
,ppd.paymentheaderid

from person_identity pi

join pay_schedule_period psp 
  on psp.payrolltypeid = 1
 and psp.processfinaldate is not null
 and psp.periodpaydate = ?::date

join pspay_payment_header pph
  on pph.check_date = psp.periodpaydate
 and pph.payscheduleperiodid = psp.payscheduleperiodid 
 
join pspay_payment_detail ppd 
  on ppd.personid = pi.personid
 and ppd.check_date = psp.periodpaydate
 and pph.paymentheaderid = ppd.paymentheaderid

where pi.identitytype = 'SSN'::bpchar 
  AND current_timestamp between pi.createts and pi.endts and ppd.etv_id  in  ('VB1','VB2','VB3','VB4','VB5','V25','V65','VCQ') and pi.personid = '111'
  
  ) x
  group by 1
  having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.v65_amount) <> 0

;
 select * from pspay_payment_detail where etv_id in  ('VB1','VB2','VB3','VB4','VB5','V25','V65','VCQ');
 select * from pay_schedule_period where payrolltypeid = 1 and processfinaldate is not null and periodpaydate = '2018-10-31';
 select * from pspay_payment_header where check_date = '2018-10-31' and personid = '341';


-- Pre Taxed 401(k)    
LEFT JOIN (SELECT distinct personid
                 ,sum(etype_hours) AS hours
                 ,sum(etv_amount) as taxable_wage
             FROM pspay_payment_detail            
            WHERE etv_id in ('VB1')             
              AND check_date = ?::DATE
         GROUP BY personid
          ) ppdvb1
  ON ppdvb1.personid = ppd.personid   

select 561.74 - 498.17



(select 
 x.personid
,x.check_date
,x.check_number
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
from
 

(select distinct
 ppd.personid
,ppd.check_date
,ppd.check_number
,case when ppd.etv_id = 'VB1' then etv_amount  else 0 end as vb1_amount
,case when ppd.etv_id = 'VB2' then etv_amount  else 0 end as vb2_amount
,case when ppd.etv_id = 'VB3' then etv_amount  else 0 end as vb3_amount
,case when ppd.etv_id = 'VB4' then etv_amount  else 0 end as vb4_amount
,case when ppd.etv_id = 'VB5' then etv_amount  else 0 end as vb5_amount
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'CDE_Principal_Financial_Group_401k_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in   ('VB1','VB2','VB3','VB4','VB5')) x
  group by 1,2,3 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount ) <> 0) 



(SELECT distinct personid
               ,sum(etype_hours) AS hours
               ,sum(etv_amount) as taxable_wage
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                            where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$'
                            group by 1)
              AND date_part('year', check_date) = date_part('year',?::DATE)
              AND check_date <= ?::DATE 
         GROUP BY personid





select * from person_bene_election 
where current_date between effectivedate and enddate 
  and current_timestamp between createts and endts and benefitelection = 'E' and selectedoption = 'Y' 
  and personid = '341';
and benefitsubclass = '40';
select * from pay_schedule_period 
where payrolltypeid = 1 and processfinaldate is not null
  and date_part('year',periodpaydate)='2018'and date_part('month',periodpaydate)='10';
select * from person_deduction_setup where personid = '100';
select * from person_names where personid = '341';
select * from person_employment;
select * from person_names where personid = '341';

SELECT * 
             FROM pspay_payment_detail            
            WHERE etv_id in ('VB1')             
              AND check_date = '2018-10-31'
              and personid = '341'
         GROUP BY personid;
select sum(etype_hours) from pspay_payment_detail where personid = '100' ;
select * from person_earning_setup where personid = '100';

LEFT JOIN (SELECT distinct personid
               ,sum(etype_hours) AS hours
               ,sum(etv_amount) as taxable_wage
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                            where a.operand = 'WS15' and a.etvindicator = 'E' and group_key <> '$$$$$'
                            group by 1)
              AND date_part('year', check_date) = date_part('year',?::DATE)
              AND check_date <= ?::DATE and personid = '100'
         GROUP BY personid
          ) grossytd
  ON grossytd.personid = pi.personid  
select * from information_schema.columns limit 10;
select * from information_schema.tables limit 10;
select * from pspay_etv_operators;
join (select pd.personid
           , psp.payunitid
           , count(distinct psp.payscheduleperiodid) as distinctpayperiods
           , sum(pd.etype_hours) as workedhours
        from pspay_payment_header ph
        join pspay_payment_detail pd 
          on pd.paymentheaderid = ph.paymentheaderid
         and pd.personid = ph.personid
        join pay_schedule_period psp 
          on ph.payscheduleperiodid = psp.payscheduleperiodid
         and psp.payrolltypeid = 1 ----- NORMAL
   left join pspay_etv_operators peo 
          on peo.group_key = pd.group_key
         and peo.etv_id = pd.etv_id 
         and current_timestamp between peo.createts and peo.endts
         and peo.operand = 'WS102'
         and peo.opcode = 'A'
       where extract(year from ph.check_date) = date_part('year',current_date)
       and peo.etvoperatorpid is not null
       and pd.personid = '100'
       group by 1,2) pdx 
  on pdx.personid = pI.personid