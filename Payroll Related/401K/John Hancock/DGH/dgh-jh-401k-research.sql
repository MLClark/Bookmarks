(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.vb6_amount) as vb6_amount
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
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))) and ppd.personid = '17532'
  and ppd.etv_id  in  ('VB1','VB2','VB3','VB4','VB5','VB6')) x
  group by 1,2 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.vb6_amount) <> 0);
  
  
  select * from pspay_payment_detail where etv_id = 'VB1' and personid = '17532';





select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-09-16 13:40:30' where feedid = 'DGH_JH_401K_Export'; --2019-09-16 13:40:30

select * from pay_schedule_period where date_part('year',periodpaydate)='2019'and date_part('month',periodpaydate)='09';




















(SELECT distinct personid,etv_id
               ,sum(etype_hours) AS hours
               ,sum(etv_amount) AS taxable_amount
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A' --and etv_id = 'ECC'
                            group by 1)
               AND check_date = ?::DATE 
         GROUP BY personid,etv_id
          ) 


(SELECT distinct personid,etv_id
               ,sum(etype_hours) AS hours
               ,sum(etv_amount) AS taxable_amount
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A'
                            group by 1)
              AND date_part('year', check_date) = date_part('year',?::DATE)
              AND check_date <= ?::DATE 
         GROUP BY personid,etv_id
          )


select * from pspay_payment_detail where check_date = '2019-05-03' and personid = '18070' and etv_id in 
 (select a.etv_id 
                             from pspay_etv_operators a
                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A' --and etv_id = 'ECC'
                            group by 1)
                            

select * from pspay_payment_header where check_date = '2019-05-03' and personid = '18070';
select * from pspay_payment_detail where personid = '18070' and etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'N' )


select * from pspay_payment_header where date_part('year',check_date)=date_part('year',current_date) and personid = '18070';

select * from pay_schedule_period where date_part('year',periodenddate)= '2019' and date_part('month',periodenddate)='05';
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid in ('766');
select * from pspay_payroll where pspaypayrollid in ('19') and pspaypayrollstatusid = 4;

select * from pspay_etv_operators;

select * from pay_schedule_period where payrolltypeid = 1 and date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)<='12';

update edi.edi_last_update set lastupdatets = '2019-05-15 13:48:40' where feedid = 'DGH_JH_401K_Export'; -- 2019-05-29 06:05:17 2019-05-15 13:48:40 2019-05-14 16:40:33 2019-04-30 15:20:51 2019/04/02 16:02:32 2019-04-17 12:45:02 2019-04-30 15:20:51
select * from edi.edi_last_update;
select * from person_names where lname like 'House%';

select * from position_desc where positionid = '52470';


(select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc  group by positionid, grade, positiontitle, flsacode)
             
select * from pers_pos where personid = '19742';

( select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
              from pers_pos where personid ='19742'
             group by personid, positionid, scheduledhours, schedulefrequency);


select * from pspay_payroll where pspaypayrollstatusid = 4;
select * from pay_schedule_period where processfinaldate is not null;
select * from pspay_payroll_pay_sch_periods;


(SELECT distinct personid, etv_id, etv_amount
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' --and a.opcode = 'A'
                            group by 1)
               AND check_date = ?::DATE and personid = '18070' 
         GROUP BY personid,  etv_id, etv_amount
          )
;
 (SELECT personid, etv_id, etype_hours, etv_amount
          FROM pspay_payment_detail 
          WHERE etv_id in (select a.etv_id 
                             from pspay_etv_operators a
                            where a.operand = 'WS15' and a.etvindicator = 'E' and a.group_key <> '$$$$$' and a.opcode = 'A'
                            group by 1)
              AND date_part('year', check_date) = date_part('year',?::DATE)
              AND check_date <= ?::DATE  and personid = '18070' 
         GROUP BY personid,  etv_id, etype_hours, etv_amount
          )
;
(select distinct
 pph.personid
,pph.check_date
,pph.gross_pay
,pph.paymentheaderid

from pspay_payment_header pph

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
                             and pph.personid = '18070')
                             ;

(select 
 pph.personid
,pph.check_date
,pph.gross_pay 
,sum(pph.gross_pay) as ytd_gross_pay

from pspay_payment_header pph

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay 
                             where ppay.pspaypayrollstatusid = 4 )))
                             AND date_part('year', pph.check_date) = date_part('year',current_date)
                             and pph.personid = '18070'
                            group by 1,2,3)
                             ;
                             



DGH_PersonPTOPlans_Import
select * from pspay_payment_detail where personid in ('18070');
select * from pspay_payment_header where personid = '18070';

select * from person_names where fname like 'Viann%';
select * from person_employment where personid in ('19594');
select * from pspay_payment_detail where personid in ('17933');

select * from person_names where lname like 'Zeno%';
select * from pspay_payment_header where personid = '19594';

select * from pspayetvlist where operand = 'WS23';

select * from tax_lookup_aggregators ;
select * from pspay_etv_accumulator_codes where personid = '19320';

  (select distinct pe.personid 
     from person_employment pe 
     join pspay_payment_detail ppd on ppd.personid = pe.personid
    where pe.emplstatus in ('R','T')
      and ppd.paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 ))))



(select 
 x.personid
,x.check_date
,sum(x.vb1_amount) as vb1_amount
,sum(x.vb2_amount) as vb2_amount
,sum(x.vb3_amount) as vb3_amount
,sum(x.vb4_amount) as vb4_amount
,sum(x.vb5_amount) as vb5_amount
,sum(x.vb6_amount) as vb6_amount
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
,ppd.paymentheaderid

from pspay_payment_detail ppd

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))
  and ppd.etv_id  in  ('VB1','VB2','VB3','VB4','VB5','VB6')
  and ppd.personid in ('18170')) x
  group by 1,2 having sum(x.vb1_amount + x.vb2_amount + x.vb3_amount + x.vb4_amount + x.vb5_amount + x.vb6_amount) <> 0)
  ;
  
select * from pspay_payment_detail where personid in ('17545') and etv_id in  ('VB1','VB2','VB3','VB4','VB5','VB6')


select * from pspay_payment_detail where personid in ('17545') and etv_id in  ('VB1','VB2','VB3','VB4','VB5','VB6');
select * from pspay_payment_header where paymentheaderid in ('8504','9516');
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid in (select payscheduleperiodid from pspay_payroll where pspaypayrollstatusid = 4 and statusdate <= '2019/04/02');
select * from pay_schedule_period where payscheduleperiodid in ('619','1056');




select * from paymentheaderclassifications where payscheduleperiodid in ('613') and paymentheaderid in ('14');


select * from paymentheaderclassifications where paymentheaderid in ('3291');


select pppsp.pspaypayrollid, pppsp.payscheduleperiodid, pppsp.updatets from pspay_payroll_pay_sch_periods pppsp
         join edi.edi_last_update elu on elu.feedid = 'DGH_JH_401K_Export'
         where pppsp.updatets >= elu.lastupdatets 
         ;
select * from pspay_payroll_pay_sch_periods where payscheduleperiodid = '615';

select * from person_names where lname like 'Pineda%';


select * from pspay_payment_detail where check_date::date = '2019-02-22' and etv_id in  ('VB6')
where paymentheaderid not in (select distinct pph.paymentheaderid from pay_schedule_period psp 






select * from paymentheaderclassifications where is_immediatecheck = true limit 100;
JOIN paymentheaderclassifications phc ON phc.paymentheaderid = ph.paymentheaderid


where check_date = '2019-02-22' and personid in ('18383','18537') and etv_id like 'V%';
select * from pay_schedule_period where periodpaydate = '2019-02-22' and payrolltypeid = 1 and processfinaldate is not null;
select * from pspay_payment_header where paymentheaderid in ('3147','4137');
select * from pay_schedule_period where periodpaydate = '2019-02-22' and payscheduleperiodid in ('616','617','587','588','615','936');

select * from pay_schedule_period where payscheduleperiodid  in ('616','617','587','588','615','936');


select * from pspay_payment_detail where personid in ('18505') and etv_id like 'V%';;
select * from pspay_payment_header where paymentheaderid in ('4127','3068');
select * from pay_schedule_period where payscheduleperiodid  in ('616','615');



select * from pspay_payment_detail where personid in ('18661') and etv_id like 'V%';


          
// use payscheduleperiodid to tie back to pay_schedule_period
 
select * from edi.edi_last_update;

select  pspaypayrollid, updatets, max(payscheduleperiodid) as payscheduleperiodid, rank() over (partition by pspaypayrollid order by max(payscheduleperiodid)asc) AS rank
from pspay_payroll_pay_sch_periods 
group by 1,2


 where 
select * from person_names where lname like 'Houseman%';

select * from person_employment where personid in ('17277');




(select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode ) 




select * from pspay_payment_detail where check_date = '2019-02-22' and personid = '18383' and etv_id like 'V%';
select * from pay_schedule_period where payrolltypeid = 1 and periodpaydate = '2019-02-22' ;
select * from pspay_payment_header where check_date = '2019-02-22' and paymentheaderid in ('4459','5413') and personid = '18383' ;














select * from pers_pos where effectivedate < enddate and current_timestamp between createts and endts and personid = '19759' ;
select * from position_desc where positionid in ('52674','52469');
--select * from person_names where personid in ('18451');

( select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
             from pers_pos where current_timestamp between createts and endts and effectivedate < enddate
             and personid = '19759'
            group by personid, positionid, scheduledhours, schedulefrequency)
            ;
            
(select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
             and positionid in ('52674','52469')
            group by positionid, grade, positiontitle, flsacode)
            ;
            

(select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
             and positionid in ('52674','52469')
            group by positionid, grade, positiontitle, flsacode) 
            ;           


select * from pay_schedule_period where date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)='01';

select * from person_names where lname like 'Rivera%';
select * from person_names where lname like 'Reyes%';

select * from person_employment where personid = '18451';

select * from person_employment where personid in ('17487');
select * from pspay_payment_detail where personid = '18238';



select * from person_locations where personid = '17723';

select personid, locationid, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(createts),max(effectivedate) DESC) AS RANK
  from person_locations where current_date between effectivedate and enddate and current_timestamp between createts and endts 
   and personid = '17723'
 group by personid, locationid

(select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(createts),max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
             and personid = '17361'
            group by personid, positionid, scheduledhours, schedulefrequency)


select distinct pe.personid, pe.emplstatus, pe.effectivedate, ppd.check_date
 from person_employment pe 
 
 join person_names pn
   on pn.personid = pe.personid
  and pn.nametype = 'Legal'
  and current_date between pn.effectivedate and pn.enddate
  and current_timestamp between pn.createts and pn.endts
 
 join pay_schedule_period psp 
   on psp.payrolltypeid = 1
  and psp.processfinaldate is not null
  and psp.periodpaydate = ?::date

 join pspay_payment_header pph
   on pph.check_date = psp.periodpaydate
  and pph.payscheduleperiodid = psp.payscheduleperiodid 
 
 join pspay_payment_detail ppd 
  on ppd.personid = pe.personid
  and ppd.check_date = psp.periodpaydate
  and pph.paymentheaderid = ppd.paymentheaderid  
 where pe.emplstatus in (select emplstatus from empl_status where payrollstatus = 'T')
   and current_date between pe.effectivedate and pe.enddate 
   and current_timestamp between pe.createts and pe.endts

select * from person_names where lname like 'Rivera%';
select * from person_employment where personid in ('18459');
select * from person_identity where  personid in ('18459');
select * from person_locations where personid in ('18459');
select * from pspay_payment_detail where personid = '18459';


select * from pay_schedule_period where date_part('year',periodpaydate)= '2019' and date_part('month',periodpaydate)< '03';

select * from pspay_payment_detail where personid in ('18459') and etv_id in ('VB1','VB2','VB3','VB4','VB5','VB6')

select * from location_address where locationid = '21';
select distinct
 pp.personid
,pn.name 
,pp.positionid 
,wdr.organizationdesc
,lat.organizationdesc
,bed.organizationdesc
,case when hay.organizationdesc = 'CER' then 'HAY' else null end 
from pers_pos pp
join pos_org_rel porb 
  ON porb.positionid = pp.positionid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
join person_names pn
  on pn.personid = pp.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
left join (select organizationdesc::char(3) as organizationdesc, organizationid
             from organization_code 
            where current_date between effectivedate and enddate 
              and current_timestamp between createts and endts 
              and organizationtype = 'Dept' and orgcode like 'Y%' group by 1,2) wdr on wdr.organizationid = porb.organizationid
left join (select organizationdesc::char(3) as organizationdesc, organizationid
             from organization_code 
            where current_date between effectivedate and enddate 
              and current_timestamp between createts and endts 
              and organizationtype = 'Dept' 
              and orgcode in (select orgcode from organization_code where current_date between effectivedate and enddate and current_timestamp between createts and endts and organizationtype = 'Dept' and organizationdesc like 'LAT%' group by 1)
         group by 1,2) lat on lat.organizationid = porb.organizationid
left join (select organizationdesc::char(3) as organizationdesc, organizationid
             from organization_code 
            where current_date between effectivedate and enddate 
              and current_timestamp between createts and endts 
              and organizationtype = 'Dept' 
              and orgcode in (select orgcode from organization_code where current_date between effectivedate and enddate and current_timestamp between createts and endts and organizationtype = 'Dept' and organizationdesc like 'BED%' group by 1)
         group by 1,2) bed on bed.organizationid = porb.organizationid
left join (select organizationdesc::char(3) as organizationdesc, organizationid
             from organization_code 
            where current_date between effectivedate and enddate 
              and current_timestamp between createts and endts 
              and organizationtype = 'Dept' 
              and orgcode in (select orgcode from organization_code where current_date between effectivedate and enddate and current_timestamp between createts and endts and organizationtype = 'Dept' and organizationdesc like 'CER%' group by 1)
         group by 1,2) hay on hay.organizationid = porb.organizationid                
         
         
where current_date between pp.effectivedate and pp.enddate 
  and current_timestamp between pp.createts and pp.endts
  ;

SELECT  * from pay_schedule_period where date_part('year',periodpaydate) = '2018' and date_part('month',periodpaydate)='11' and processfinaldate is not null and payrolltypeid = 1;
select * from pspay_payment_detail where check_date = '2018-12-11' and etv_id in 

select * from person_compensation where personid = '18326';
(SELECT personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                     RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
            FROM person_compensation WHERE effectivedate < enddate AND ((current_timestamp BETWEEN createts AND endts) or (createts < endts)) and personid = '18326'
            GROUP BY personid, compamount, increaseamount, compevent, frequencycode, earningscode);

select * from person_employment  where personid = '17279';
select * from person_names where personid = '18991';


select distinct personid, lname,name from person_names where current_date between effectivedate and enddate and current_timestamp between createts and endts and nametype = 'Legal' and personid in 
(select distinct personid from pspay_payment_detail where etv_id = 'V51');


select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from person_compensation where personid = '17279'
and current_timestamp BETWEEN createts AND endts
(SELECT personid, compamount, increaseamount, compevent, frequencycode, earningscode, enddate, MAX(effectivedate) AS effectivedate,
                     RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
            FROM person_compensation 
            WHERE current_date between effectivedate and enddate AND current_timestamp BETWEEN createts AND endts and personid = '17279'
            GROUP BY personid, compamount, increaseamount, compevent, frequencycode, earningscode,enddate )

SELECT * FROM SALARY_GRADE;
select * from location_codes;

select * from person_compensation where personid = '18326'and current_timestamp BETWEEN createts and endts
( select personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
               from person_compensation where effectivedate < enddate and createts < endts and personid = '18326'
              group by personid, compamount, increaseamount, compevent, frequencycode, earningscode)