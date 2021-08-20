select * from benefit_plan_desc where benefitsubclass in ('21','23','25','2Z'); -- life
select * from benefit_plan_desc where benefitsubclass in ('13');--accident
select * from benefit_plan_desc where benefitsubclass in ('32','31');---ltd


select * from edi.edi_last_update;
insert into edi.edi_last_update (feedid,lastupdatets) values ('CDE_Lincoln_Financial_Group_VolLife_ADD_LTD_Export','2018-01-01 00:00:00');

select * from person_payroll where personid = '263';
select * from person_compensation where personid = '10';

select * from pers_pos where personid = '30';
select * from position_desc;