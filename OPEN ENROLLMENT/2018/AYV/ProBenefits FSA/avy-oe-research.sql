select * from benefit_plan_desc where benefitsubclass in ('10');
select distinct personid from person_bene_election where effectivedate >= date_trunc('year', current_date + interval '1 year') 
and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('60','61','6Z');

select * from person_bene_election where effectivedate >= date_trunc('year', current_date + interval '1 year') 
and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('60','61','6Z') and personid = '7285';
select * from personbenoptioncostl where personid  = '7285' and personbeneelectionpid in ('371704', '142251');

select * from person_bene_election where benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('60','61','6Z','10','11') and personid = '5974';

select * from person_bene_election where benefitelection  = 'E' and effectivedate >= date_trunc('year', current_date + interval '1 year') and enddate >= '2199-12-30' and benefitsubclass = '10' and personid = '5974';

select * from pay_schedule_period where date_part('year',periodenddate)= '2018' and date_part('month',periodenddate)='12';
select * from pspay_payment_detail where personid = '5994' and etv_id in ('VBA','VBB') and check_date = '2018-12-07';