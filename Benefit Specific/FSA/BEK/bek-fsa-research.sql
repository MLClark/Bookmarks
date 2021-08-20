select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from person_bene_election where current_timestamp between createts and endts and personid = '288';
select * from pers_pos where personid = '1003';

select personid, benefitsubclass, benefitplanid from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and personid in ('315','141','276','287','326','357') and benefitsubclass = '60';


select * from pay_unit;
select * from pay_schedule_period where date_part('year',periodpaydate)='2018'and date_part('month',periodpaydate)='09';

select * from person_bene_election where benefitsubclass in ('6Z','14','11','10','61','60') and benefitelection = 'E' and selectedoption = 'Y' and personid = '288'
--and current_date between effectivedate and enddate
and current_timestamp between createts and endts;


select * from person_bene_election where benefitsubclass in ('10') and benefitelection = 'E' and selectedoption = 'Y' and personid = '758'
and current_date between effectivedate and enddate
and current_timestamp between createts and endts;

select * from person_bene_election where benefitsubclass in ('10') and benefitelection = 'E' and selectedoption = 'Y' and personid = '288'
and enddate > effectivedate
and enddate > current_date
and current_timestamp between createts and endts;


and benefitsubclass = '61';
select * from person_names where personid = '758';
select * from person_employment where personid = '758';
select * from person_names where lname like 'Younker%';


select * from pspay_payment_detail where personid = '139' and check_date = '2018-04-13';
select * from personbenoptioncostl where personid = '139';

select * from person_net_contacts where personid in (select distinct personid from person_bene_election where benefitsubclass = '60'
and current_date between effectivedate and enddate and current_timestamp between createts and endts);

select * from person_net_contacts where personid = '139'
and current_date between effectivedate and enddate and current_timestamp between createts and endts
and netcontacttype = 'WRK'
;
select * from pay_schedule_period where date_part('year',periodpaydate)='2018' and date_part('month',periodpaydate)='09';

select * from edi.edi_last_update;
insert into edi.edi_last_update (feedid,lastupdatets) values ('BEK_ProBenefits_FSA_DCA_Export','2018-02-01 00:00:00');
update edi.edi_last_update set lastupdatets = '2018-09-01 00:00:00' where feedid = 'BEK_ProBenefits_FSA_DCA_Export' ;

select * from person_bene_election where benefitsubclass = '6Z' and benefitelection = 'E' and selectedoption = 'Y' and effectivedate >= '2018-09-01';
select * from person_bene_election where benefitsubclass = '60' and benefitelection = 'E' and selectedoption = 'Y' and effectivedate >= '2018-09-01';
select * from person_bene_election where benefitsubclass = '61' and benefitelection = 'E' and selectedoption = 'Y' and effectivedate >= '2018-09-01';
select * from person_bene_election where benefitsubclass = '10' and benefitelection = 'E' and selectedoption = 'Y' and effectivedate >= '2018-09-01';
select * from person_bene_election where benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y' and effectivedate >= '2018-09-01';
select * from person_bene_election where benefitsubclass = '14' and benefitelection = 'E' and selectedoption = 'Y' and effectivedate >= '2018-09-01';