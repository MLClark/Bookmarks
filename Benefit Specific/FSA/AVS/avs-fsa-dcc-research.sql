select * from person_employment where personid in 
(select personid from person_bene_election where benefitsubclass in ('60','61') and benefitelect

select * from personbenoptioncostl where personid = '5241' and costsby = 'M' and personbeneelectionpid = '116266';
select * from personbenoptioncostl where personid = '5241' and costsby = 'P' and personbeneelectionpid = '116266';
select * from person_bene_election where personid = '5241' and benefitsubclass in ('60','61') and benefitelection = 'E';

select * from person_bene_election where personid in (

select distinct personid from person_bene_election where benefitsubclass in ('60','61') and benefitelection = 'T') and benefitsubclass in ('60','61') and benefitelection <> 'W'
and effectivedate < enddate and current_timestamp between createts and endts and effectivedate <= '2018-09-01';

select * from person_bene_election where benefitsubclass in ('60','61') and selectedoption = 'Y' and benefitelection = 'E' and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from person_names where lname like 'Yarbrough%';
select * from person_bene_election where personid = '5178' and benefitsubclass in ('60','61');
select * from person_bene_election where personid = '5180' and benefitsubclass in ('60','61');

select * from person_bene_election where personid = '5113' and benefitsubclass in ('60','61');
select * from person_names where personid in ('5178','5180','5353');

select * from person_employment where personid = '5241';
select * from edi.edi_last_update ;
2018-11-14 07:00:04
update edi.edi_last_update set lastupdatets = '2018-09-01 00:00:00' where feedid = 'AVS_BasicPacific_FSA_DDC_Export';
select * from benefit_plan_desc
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitsubclass in ('60','61');
  
select distinct personid from person_bene_election  
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitelection = 'E'
  and selectedoption = 'Y'
  and benefitsubclass in ('60','61');

select * from person_bene_election  
where current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  and benefitelection = 'E'
  and selectedoption = 'Y'
  and benefitsubclass in ('60')
  and personid = '5135';

select * from person_vitals where personid = '5104';
select * from person_maritalstatus where personid = '5104';
select * from person_locations where personid = '5104';
select * from locations where locationid = '16';
select * from location_address where locationid = '16';
select * from dxcompanyname;
select * from empl_status;
select * from person_employment where personid = '5104';
select * from person_compensation where personid = '5135';
select * from person_payroll where personid = '5135';
select * from pers_pos where personid = '5135';
select * from pay_unit;
select * from pspay_payment_detail where personid = '5135' and etv_id = 'VBA';
select * from pay_schedule_period where 
