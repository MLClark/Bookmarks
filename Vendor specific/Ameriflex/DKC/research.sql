
select elu.lastupdatets, statusdate from pspay_payroll 
join edi.edi_last_update elu  on elu.feedid = 'Ameriflex_FLEX_Payroll_Deduction' 
where pspaypayrollstatusid = 4 and pspaypayrollid in 
(select pspaypayrollid from pspay_payroll_pay_sch_periods where payscheduleperiodid in 
(select payscheduleperiodid from payroll.payment_header where paymentheaderid in 
(select paymentheaderid from payroll.payment_detail where check_date = '2021-02-05' and paycode in  ('VBA'))))
;



select * from person_names where lname like 'Daniels%';
select * from person_employment where personid = '209' and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from person_bene_election where personid = '125' and current_date between effectivedate and enddate and current_timestamp between createts and endts and selectedoption = 'E' and benefitelection = 'Y'

select * from pspay_payment_detail where check_date = '2020-12-17' and etv_id in ('VBA','VBB','VL1','VC1','VS1','VC0','VEH','VEK')


(select lp.lookupid, value1 as GroupCode, value2 as PlanID, lp.effectivedate as plan_year_start_date, lp.enddate as plan_year_end_date
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Ameriflex_FLEX_Eligibility_Election' 
and current_date between lp.effectivedate and lp.enddate
 )
 ;
 select * from edi.lookup_schema;
 select * from edi.lookup;
 
 select * from edi.edi_last_update;
 
(select lp.lookupid, value1 as GroupCode, value2 as PlanID, lp.effectivedate as plan_year_start_date, lp.enddate as plan_year_end_date
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Ameriflex_FLEX_Eligibility_Election' 
and current_date between lp.effectivedate and lp.enddate
 ) 
 
select * from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election';
select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');



update edi.edi_last_update set lastupdatets = '2021-01-10 00:00:00' where feedid = 'Ameriflex_FLEX_Payroll_Deduction';


insert into edi.edi_last_update (feedid,lastupdatets) values ('Ameriflex_FLEX_Eligibility_Election','2020-12-05 11:58:55');
update edi.edi_last_update set lastupdatets = '2020-12-05 11:58:55' where feedid = 'Ameriflex_FLEX_Eligibility_Election';



update edi.lookup set effectivedate = '20210101' where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');

update edi.lookup set enddate = '20211231' where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');

 ( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.value1,lkup.value2
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate and lkups.lookupname  in ('Ameriflex_FLEX_Eligibility_Election')
      ) 
      ;


Please create file
Group Name: ProTapes
Group ID: AMFPROTSP
Plan ID: PROTSP

Plan types expected on the files:
Flex Spending Health Care
Flex Spending Dep Day Care

Plan start date: 20210101

Plan end date: 20211231      

select * from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election';

select * from edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');

(select lp.lookupid, value1 as GroupCode, value2 as PlanID, lp.VALUE3 as plan_year_start_date, lp.VALUE4 as plan_year_end_date
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'Ameriflex_FLEX_Eligibility_Election' 
and current_date between lp.effectivedate and lp.enddate
 )

select * from Comp_plan_plan_year 


update edi.lookup_schema set valcoldesc3 = 'PlanYearStartDate' where lookupname = 'Ameriflex_FLEX_Eligibility_Election'; 
update edi.lookup_schema set valcoldesc4 = 'PlanYearEndDate' where lookupname = 'Ameriflex_FLEX_Eligibility_Election'; 
update edi.lookup set value3 = '2021-01-01'  where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election'); 
update edi.lookup set value4 = '2199-12-31'  where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election'); 

insert into edi.lookup_schema (lookupid, valcoldesc1, valcoldesc2,valcoldesc3,valcoldesc4, lookupname, lookupdesc) select nextval('edi.lookup_id_seq'),'Group Code','Plan ID','PlanYearStartDate','PlanYearEndDate','Ameriflex_FLEX_Eligibility_Election', 'Group Code/PlanID';
insert into edi.lookup (lookupid,value1,value2,value3,value4) select lkups.lookupid,'AMFPROTSP','PROTSP','2021-01-01','2199-12-31' from edi.lookup_schema lkups where lkups.lookupname  in ('Ameriflex_FLEX_Eligibility_Election');


delete from  edi.lookup where lookupid in (select lookupid from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election');
delete from edi.lookup_schema where lookupname = 'Ameriflex_FLEX_Eligibility_Election';

--populate lookup_schema
INSERT INTO edi.lookup_schema (lookupid, valcoldesc1,lookupname, lookupdesc)
select nextval('edi.lookup_schema_seq'),'CompCode', 'AmeriFlex CompName','AmeriFlex Comp Name used in AmeriFlex feeds');

INSERT INTO edi.lookup_schema (lookupid, valcoldesc1,valcoldesc2, lookupname, lookupdesc)
VALUES (5, 'PlanYearStartDate', 'PlanYearEndDate','AmeriFlex Plan year','AmeriFlex Year used in AmeriFlex feeds');

select * from edi.lookup_schema
select nextval('edi.lookup_schema_id_seq')
--populate lookup table

--companyCode
INSERT INTO edi.lookup (lookupid, value1)
VALUES (4,'AMFAJG');

--Plan Year
INSERT INTO edi.lookup (lookupid, value1,value2)
VALUES (5,'20190101','20191231');

select * from edi.lookup