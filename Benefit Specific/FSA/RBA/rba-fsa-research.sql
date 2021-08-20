select * from benefit_plan_desc where benefitsubclass in ('60','61');

select distinct personid 
from person_bene_election where benefitsubclass in ('60','61') and selectedoption = 'Y' and benefitelection = 'E' 
and current_date between effectivedate and enddate and current_timestamp between createts and endts;
--- rba does not use payroll only stored benefits
select * from pay_schedule_period where date_part('year',periodpaydate)= '2018' and date_part('month',periodpaydate) = '07' and payrolltypeid = 1;
select * from pspay_payment_detail where etv_id in ('VBA','VBB');
select * from pspay_etv_list;
select * from pay_unit;

select * from person_bene_election where benefitsubclass in ('60','61') and selectedoption = 'Y' and benefitelection = 'E'  and personid in 
(select personid from person_employment where emplstatus in ('T','R') group by 1)

select * from person_names where lname like 'Menz%';
select * from person_names where personid = '427';
select * from person_employment where emplstatus = 'T';
select emplstatus from person_employment group by 1;

SELECT * from edi.edi_last_update;
2018-10-23 07:01:21
update edi.edi_last_update set lastupdatets = '2018-10-23 07:01:21' where feedid = 'RBA_Sound_Admin_FSA_Export';
insert into edi.edi_last_update (feedid,lastupdatets) values ('RBA_Sound_Admin_FSA_Export','2018-01-01 00:00:00');
select * from person_names where lname like 'Lamphiear%';
select * from person_bene_election where personid in ('1643','2056');


select * from person_bene_election where benefitsubclass in ('60','61') and selectedoption = 'Y' and benefitelection = 'E' ;
select * from person_employment where effectivedate > '2018-01-01' and personid in 
(select personid from  person_bene_election where benefitsubclass in ('60','61') and selectedoption = 'Y' and benefitelection = 'E' );