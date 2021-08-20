select * from person_bene_election where benefitsubclass in ('6Z','14','11','10','61','60') and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where benefitsubclass in ('6Z','14','11','10','61','60') and benefitelection = 'E' and selectedoption = 'Y'  and personid = '770';
select * from person_bene_election where benefitsubclass in ('6Z','14','11','10','61','60') and benefitelection = 'E' and selectedoption = 'Y' -- and personid = '288'
and personid not in (select distinct personid from person_bene_election where benefitsubclass in ('6Z','14','11','10','61','60') and benefitelection = 'E' and selectedoption = 'Y' 
and effectivedate < current_date);
select * from person_names where personid = '336';

select * from person_bene_election where benefitsubclass in ('6Z','14','11','10','61','60') and benefitelection = 'E' and selectedoption = 'Y'and effectivedate >= current_date;
select * from person_names where personid = '336';

select * from person_names where lname like 'Test%';
select * from

select * from pay_schedule_period where date_part('year',periodpaydate)='2018' and date_part('month',periodpaydate)='09';
select * from person_employment where personid = '770';
select * from pers_pos where personid = '770';
select * from position_desc where positionid = '505';
select * from person_net_contacts where personid = '770';