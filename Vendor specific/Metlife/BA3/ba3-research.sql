select * from benefit_plan_desc where benefitsubclass in ('2SA','2SL','2EA','2EL');
select * from person_names where personid = '87035';
select * from pspay_etv_list where etv_id in ('VEO', 'VAB', 'VA9', 'VA4', 'VER', 'VES', 'V9A', 'VA3','VAK','VAI','VAJ','VAE') ;
select * from pay_schedule_period where date_part('year',periodpaydate)='2020' and date_part('month',periodpaydate)<=2;

       WHEN ppd.etv_id in ('VA3', 'VA4', 'V9A', 'VA9', 'VAB') THEN 'Opt Life Emp Cost'