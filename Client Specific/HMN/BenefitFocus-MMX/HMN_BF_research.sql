SELECT * FROM person_names where personid = '68004';

select * from person_employment where personid = '67973';

select * from person_compensation where personid = '67429';




select personid, max(percomppid



select * from person_employment where personid = 




select * from edi.etl_personal_info where lastname = 'Casteel'



select * from person_employment where emplstatus = 'L';

select * from  peremplleavesprop where personid = '67771';
select * from  peremplleavesprop where type = 'Military' and enddate > current_date;
select * from person_names where personid = '67771';
select * from person_employment where personid = '66027' ;

    select personid from dxpersonpositiondet x
       where ((positiontitle in ('Agent','Acct Rep')
         and current_date between effectivedate and enddate));
         
select * from person_names where personid = '67400';         
         
select * from dxpersonpositiondet 
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and positiontitle in ('Agent','Acct Rep');     


select SUM(ETV_AMOUNT) from pspay_payment_detail
where etv_id in ('E62','EBB','EC3','EC7','ECB','EC8')
  AND DATE_PART('YEAR',CHECK_DATE) = '2017'
  and personid = '67575';

select SUM(ETV_AMOUNT) from pspay_payment_detail
where DATE_PART('YEAR',CHECK_DATE) = '2017'
  and personid = '67575';  
  
 select personid, SUM(ETV_AMOUNT) commission
              from pspay_payment_detail
             where etv_id in ('E62')
               AND DATE_PART('YEAR',CHECK_DATE) = date_part('year',current_date - interval '1 year')   and personid = '67575'
               group by 1  ;
select * from person_names where lname like 'Aaron%';
select * from person_names where personid = '67545';
select * from person_employment where personid = '64838';
select * from financial_account;
select * from pspay_etv_operators;
select * from pspay_etv_accumulator_codes;

select pd.personid
           , psp.payunitid
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
       where DATE_PART('YEAR',pd.CHECK_DATE) = date_part('year',current_date - interval '1 year') 
         and pd.personid = '67575'
       group by pd.personid, extract(year from pd.check_date), psp.payunitid
       