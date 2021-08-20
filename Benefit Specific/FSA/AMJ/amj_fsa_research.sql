select * from benefit_plan_desc
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitsubclass in ('60', '61' )
  ;



select * from person_bene_election 
where current_timestamp between createts and endts
  and effectivedate < enddate
  and benefitsubclass in ('60', '61' )
  and selectedoption = 'Y'
and personid = '1996'
  ;
select * from personbenefitcostl where personid = '2381';
select * from pay_schedule_period where date_part('year',periodpaydate)='2018'and date_part('month',periodpaydate)='04';
select * from pspay_payment_detail where personid = '918' and date_part('year',check_date::date)='2018';
select * from pspay_payment_detail where personid = '918' and check_date::date = '2018-04-06'

select * from pay_unit;  
select * from benefit_coverage_desc;


select * from benefit_plan_desc
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitsubclass in ('60', '61' )
  ;
select * from person_names where lname like 'Luce%';  
select * from person_bene_election 
where current_timestamp between createts and endts
  and benefitsubclass in ('60', '61' )
  and benefitelection = 'T'
  and effectivedate >= current_date  - interval '30 days' 
  and personid in 
  (select personid from person_bene_election 
    where current_timestamp between createts and endts
      and date_part('year',effectivedate)=date_part('year',current_date)
      and benefitsubclass in ('60', '61' )
      and benefitelection = 'E')
  ;  

  (select * from person_bene_election 
    where current_timestamp between createts and endts
      and date_part('year',effectivedate)=date_part('year',current_date)
      and benefitsubclass in ('60', '61' )
      and benefitelection = 'E')  ;
      
select * from pspay_etv_list where etv_id in ('VBA','VBB');
select * from pay_unit;
      
select personid, sum(etv_amount) from pspay_payment_detail 
 where date_part('year',check_date)='2018'    
   and etv_id in ('VBA','VBB')
   and personid in ('886')
   and check_date >= '2018-02-01'
   group by 1
   ;
   
select * from person_employment
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and emplstatus = 'T' 
  and personid in 
  ( 
    select personid from person_bene_election 
    where current_timestamp between createts and endts
      --and date_part('year',effectivedate)=date_part('year',current_date)
      and benefitsubclass in ('60', '61' )
      and benefitelection = 'E'
      group by 1 ) 
;      

select 192.31 * 24; -- bobo
select 75 * 24; -- moore
select 25 * 24; -- sawicki
select 75 * 22; -- woodward

select * from person_names where personid = '919';
   
select psp.periodstartdate
   from pspay_payment_header ph
   join pay_schedule_period psp
     on ph.payscheduleperiodid = psp.payscheduleperiodid
    and psp.payrolltypeid = 1 ----- NORMAL
  where date_part('year',psp.periodstartdate)=date_part('year',current_date)
  ;

select * from payfrequencycode;
select count(*) from pay_schedule_period psp  where date_part('year',psp.periodstartdate)=date_part('year',current_date) 
and psp.payrolltypeid = 1 ----- NORMAL
and psp.payunitid = '1';

select distinct * from pay_schedule_period psp  
where date_part('year',psp.periodstartdate)=date_part('year',current_date) 
and psp.periodstartdate >= '2018-02-01'
and psp.payrolltypeid = 1 ----- NORMAL
and psp.payunitid = '1';



select 
 ppd.personid
,ppd.payperiods
,hcra.etv_amount
,(hcra.etv_amount * ppd.payperiods) as annualized_election_amount


from 
(
select pbe.personid,pbe.effectivedate,count(psp.*) payperiods
  from person_bene_election pbe
  join pay_schedule_period psp  
    on date_part('year',psp.periodstartdate)=date_part('year',current_date) 
   and psp.periodstartdate >= pbe.effectivedate
   and psp.payrolltypeid = 1 ----- NORMAL
   and psp.payunitid = '1'
 where current_date between pbe.effectivedate and pbe.enddate
   and current_timestamp between pbe.createts and pbe.endts
   and pbe.benefitsubclass in ('60', '61' )
   AND pbe.benefitelection in ('E')
   AND pbe.selectedoption = 'Y'---
   and pbe.personid = '886'
   group by 1,2
) ppd
join 
(
select distinct pbe.personid,pbe.effectivedate,ppd.etv_amount,ppd.etv_id
  from person_bene_election pbe
  join pspay_payment_detail ppd  
    on date_part('year',ppd.check_date)=date_part('year',current_date) 
   and ppd.check_date >= pbe.effectivedate
   and ppd.etv_id in ('VBB')
   and ppd.personid = pbe.personid
 where current_date between pbe.effectivedate and pbe.enddate
   and current_timestamp between pbe.createts and pbe.endts
   and pbe.benefitsubclass in ('60', '61' )
   AND pbe.benefitelection in ('E')
   AND pbe.selectedoption = 'Y'---
   and pbe.personid = '886'
) hcra on hcra.personid = ppd.personid




select * from pspay_payment_detail where personid = '886' and etv_id = 'VBB';
select * from pspay_etv_list where etv_id in ('VBB','VBA') and group_key = 'AMJ00';


        select pbe.personid,pbe.effectivedate,psp.*
          from person_bene_election pbe
          join pay_schedule_period psp  
            on date_part('year',psp.periodstartdate)=date_part('year',current_date) 
           and psp.periodstartdate >= pbe.effectivedate
           and psp.payrolltypeid = 1 ----- NORMAL
           and psp.payunitid = '1'
         where current_date between pbe.effectivedate and pbe.enddate
           and current_timestamp between pbe.createts and pbe.endts
           and pbe.benefitsubclass in ('60' )
           AND pbe.benefitelection in ('E')
           AND pbe.selectedoption = 'Y'---
           and pbe.personid = '2187'
           --group by 1,2
           ;



