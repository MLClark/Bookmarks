( select personid, SUM(ETV_AMOUNT) commission
              from pspay_payment_detail
             where DATE_PART('YEAR',CHECK_DATE) = date_part('year',current_date - interval '1 year')
               and etv_id like ('E%') and etv_id not in ('ECB','EC8','EC9')
               group by 1
          )

;

( select *
              from pspay_payment_detail
             where DATE_PART('YEAR',CHECK_DATE) <= date_part('year',current_date)
               and etv_id like ('E%') and etv_id not in ('ECB','EC8','EC9')
               and personid = '68410'
          )

;
select * from pers_pos where personid in (select personid from dxpersonpositiondet where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and positiontitle like ('%Financial Advisor%') group by 1) and current_date between effectivedate and enddate and current_timestamp between createts and endts
;
select * from person_employment where personid = '68410';

EXTRACT(year FROM age(end_date,start_date))*12 + EXTRACT(month FROM age(end_date,start_date))
select * from pers_pos where personid = '68410';
select * from dxpersonpositiondet where positionid in ('405769','406631');
select * from pers_pos where personid = '68398';
select * from dxpersonpositiondet where positionid in ('405757','406623');
select * from pers_pos where personid = '68400';
select * from dxpersonpositiondet where positionid in ('405759','406624');

SELECT (date_trunc('MONTH', current_date) + INTERVAL '1 MONTH - 1 day')::DATE;
SELECT age(TIMESTAMP '2012-06-13 10:38:40', TIMESTAMP '2011-04-30 14:38:40');

( select ppd.personid
       , pe.empllasthiredate ::date as doh
      -- , ppd.etv_amount 
       , ppd.check_date ::date as check_date
       , cast (extract(year from age(date_trunc('year', current_date - interval '1 day'),ppd.check_date))*12 + extract(month from age(date_trunc('year', current_date - interval '1 day'),ppd.check_date)) as dec(18,2)) as months
       , date_trunc('year', current_date - interval '1 year') ::date as boy       
       , (date_trunc('year', current_date) - interval '1 day') ::date as eoy 

       , case -- hired before 1-1-2019 and check_date between 1-1-19 and 12-31-19 - sum 
              when pe.empllasthiredate ::date <= date_trunc('year', current_date - interval '1 year') ::date and ppd.check_date between date_trunc('year', current_date - interval '1 year') ::date and (date_trunc('year', current_date) - interval '1 day')::date then SUM(ETV_AMOUNT)
              end prior_year_commission
       , case when pe.empllasthiredate ::date <= date_trunc('year', current_date) ::date and ppd.check_date >= date_trunc('year', current_date)::date then SUM(ETV_AMOUNT) 
              end current_year_commission
                     
              from pspay_payment_detail ppd
              join dxpersonpositiondet dxp on dxp.personid = ppd.personid and current_date between dxp.effectivedate and dxp.enddate and current_timestamp between dxp.createts and dxp.endts and dxp.positiontitle like '%Financial Advisor%'
              join person_employment pe on pe.personid = ppd.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts and pe.emplstatus in ('L','A','P')
             where CHECK_DATE >= current_date - interval '1 year'
               and etv_id like ('E%') and etv_id not in ('ECB','EC8','EC9')
               and ppd.etv_amount <> 0
               and ppd.personid in ('68398','68843')
             group by 1,2,3,4,5,ppd.check_date) order by ppd.personid, ppd.check_date
;


select * from pspay_etv_list where etv_id in ('ECB','EC8','EC9');


select  date_trunc('year', current_date - interval '1 year');


select * from dxpersonpositiondet where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and positiontitle like ('%Financial Advisor%');

select * from pers_pos where personid in ('67736','68410','68406');

select * from pers_pos where personid in (select personid from dxpersonpositiondet where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and positiontitle like ('%Financial Advisor%') group by 1) and current_date between effectivedate and enddate and current_timestamp between createts and endts
;


select positiontitle from dxpersonpositiondet group by 1 order by 1;

( select personid, sum(etv_amount) as etv_amount
              from pspay_payment_detail
             where DATE_PART('YEAR',CHECK_DATE) = date_part('year',current_date - interval '1 year')
               and etv_id like ('E%') and etv_id not in ('ECB','EC8','EC9') and personid in ('68849')
             group by personid
             )
select * from dxpersonpositiondet where ((positiontitle in ('Agent')) or (positiontitle ilike ('%Financial Advisor%')) or (positiontitle ilike '%Acct Rep%' ))


Acct Rep


( select *
              from pspay_payment_detail
             where DATE_PART('YEAR',CHECK_DATE) >= date_part('year',current_date - interval '1 year')
               and etv_id like ('E%') and etv_id not in ('ECB','EC8','EC9') and personid in ('68449')
            
          )

;
( select *
              from pspay_payment_detail
             where CHECK_DATE >= date_trunc('year',current_date - interval '1 year')
               and etv_id like ('E%') and etv_id not in ('ECB','EC8','EC9') and personid in ('68449')
            
          )

;
select date_trunc('year',current_date);

 ( select ppd.personid, sum(ppd.etv_amount) as etv_amount
              from pspay_payment_detail ppd
              join person_employment pe on pe.personid = ppd.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts 
             where ppd.CHECK_DATE >= date_trunc('year',current_date - interval '1 year')
               and etv_id like ('E%') and etv_id not in ('ECB','EC8','EC9')
               and ((pe.empllasthiredate >= date_trunc('year',current_date)) -- 2020-01-01
                or  (pe.empllasthiredate > date_trunc('year',current_date - interval '1 year')))
                and ppd.personid in ('68449')
             group by ppd.personid) 


select * from pspay_payment_detail where personid = '68849' and date_part('year',check_date) >= date_part('year',current_date - interval '1 year')
and etv_id not in ('ECB','EC8','EC9');


( select personid, SUM(ETV_AMOUNT) commission
              from pspay_payment_detail
             where DATE_PART('YEAR',CHECK_DATE) = date_part('year',current_date)
               and etv_id like ('E%') and etv_id not in ('ECB','EC8','EC9')
               and personid = '68410' 
               group by 1
          );

( select personid, SUM(ETV_AMOUNT) commission
              from pspay_payment_detail
             where DATE_PART('YEAR',CHECK_DATE) >= date_part('year',current_date - interval '1 year')
               and etv_id like ('E%') and etv_id not in ('ECB','EC8','EC9')
               and personid = '68410' 
               group by 1
          )
          ;

select * from person_names where personid = '68501';
select * from person_compensation where personid = '68410';

select * from dxpersonpositiondet where personid in ('68792') and current_date between effectivedate and enddate and current_timestamp between createts and endts

select personid, sum(etv_amount) from pspay_payment_detail where personid in
(select personid from dxpersonpositiondet where current_date between effectivedate and enddate and current_timestamp between createts and endts and positiontitle in ('Financial Advisor') group by 1)
and date_part('year',check_date) = date_part('year',current_date - interval '1 year') and etv_id like ('E%') and etv_id not in ('ECB','EC8','EC9') 
group by 1;



select * from cognos_pspay_etv_names  WHERE ETV_ID = 'E12';

select * from batch_header where batchheaderid > '29';
select batchnotes from batch_header group by 1;


SELECT * from batch_detail where batchheaderid > '29';
select * from batch_header where batchheaderid > '29';

delete from batch_detail where batchheaderid > '29';
delete from batch_header where batchheaderid > '29';

select * from pay_schedule_period where date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)='07';
SELECT * FROM log_entries where userid = 'EDI';



select * from batch_detail limit 100;
select * from batch_header where batchname  = '7C7 Hourly 06-14-19.csv';
select	batchtaxdedscheduleid,
		batchtaxdedschedulecode,
		upper(trim(batchtaxdedscheduledesc))::varchar(50) as batchtaxdedscheduledesc
from	batch_taxded_schedule;
select batchpaymenttypeid
, trim(batchpaymenttypename)::varchar(30) as batchpaymenttypename
from batch_payment_type
order by batchpaymenttypename;
 INSERT INTO Batch_detail (batchdetailid, batchheaderid, personid, etv_id, etvindicator, amount, hours, generalledgeroverride, overriderate, sequencenumber, processed, effectivedate, enddate, createts, endts, batchtaxdedscheduleid, fedtaxlumpytd, provincetaxlumpytd, medicaltaxlumpytd, qhiptaxlumpytd, protectedoverriderate, batchtaxdedscheduleid_1, pspaypaymentactionpid, checknumber, memberorgcode, divorgcode, budgetorgcode, matrixorgcode, locationcode, jobcode, jobcode2, jobcode3, jobcode4, jobcode5, jobcode6, yearendwage, yearenddataid, yearendtypeid) VALUES ( 3282,  37,  '1012        ',  'E01',  'E',  0.0,  23.75,  NULL,  NULL,  NULL,  'R',  '2019-07-31 00:00:00-05',  '2199-12-31 00:00:00-06',  '2019-09-04 12:57:26.430000-05',  '2199-12-30 00:00:00-06',  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL)
