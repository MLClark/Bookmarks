select * from pspay_etv_list where etv_id in ('V65','VB1','VB2','VB3','VB5');
select * from person_names where lname like 'Potter%';
select * from person_employment where personid = '8504';
select * from person_locations where personid = '8504';

select * from pay_schedule_period where date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)='02';

select * from pspay_payment_detail
where etv_id in ('V65','VB1','VB2','VB3','VB5') and personid = '8504';
and check_date = '2018-06-07';

select * from cognos_orgstructure;
select * from person_locations where personid = '5974';
select * from location_address;
select * from org_rel;
select * from companylocations;
select * from pspay_payment_header where personid = '5981' and check_date = '2018-08-17';
select * from pay_schedule_period where payscheduleperiodid = '48';

(select pd.personid
           --, psp.payunitid
           , sum(case when peo.etvoperatorpid is null then pd.etype_hours else 0 end) as workedhours
           , extract(year from pd.check_date) as payyear
           , count(distinct psp.payscheduleperiodid) as distinctpayperiods
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
       where extract(year from pd.check_date) = date_part('year',?::DATE) and pd.personid = '5981'
       group by pd.personid, extract(year from pd.check_date), psp.payunitid, ph.payscheduleperiodid)