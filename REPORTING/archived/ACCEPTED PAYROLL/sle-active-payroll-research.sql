select * from pay_schedule_period where date_part('year',periodpaydate)='2020'and date_part('month',periodpaydate)>='01';
select * from cognos_preview_payment_earnings_by_check_date where check_date::date = '2020-02-14';