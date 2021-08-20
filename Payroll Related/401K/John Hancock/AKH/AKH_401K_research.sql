select * from pay_schedule_period where date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)='01';


select * from person_names where lname like 'Bhu%';
select * from person_employment where personid = '8188';

select * from pspay_payment_detail where personid = '8188' and check_date = '2019-01-11';
select * from pspay_etv_operators where group_key = 'AKH00' and operand = 'WS102' and opcode = 'A' and current_timestamp between createts and endts and etv_id = 'VB1';

(select pd.personid
           , psp.payunitid ,peo.etvoperatorpid ,pd.group_key, pd.etv_id
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
       --and peo.etvoperatorpid is not null
       -- and pd.personid = '8188'
       and pd.etv_id = 'VB1'
       group by 1,2,3,4,5)

    --   select * from pspay_payment_detail where paymentheaderid = '25697';
       select * from pay_schedule_period where payrolltypeid = 1 and payunitid in (2,5) and date_part('year',periodpaydate)= '2017';
       select count(distinct payscheduleperiodid) as distinctpayperiods 
       from pay_schedule_period where payrolltypeid = 1 and payunitid in (2,5) and date_part('year',periodpaydate)= '2017'
       and processfinaldate is not null;
select * from person_names where lname like 'Raven%';       
select * from pspay_payment_detail where check_date <= '2018-04-27' and personid = '7352' and etv_id IN ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')  ;
select * from person_identity where personid = '7352';