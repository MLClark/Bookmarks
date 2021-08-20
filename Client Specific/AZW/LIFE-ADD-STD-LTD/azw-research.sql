select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts;
-- basic life 20
-- ee vol life ad&d 21
-- basic life salaried or hourly 23
-- vol life spouse 2Z
-- vol life dep 25
-- ltd hourly or salaried 31
select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts
and benefitsubclass in ('20','21','23','25','31','2Z');
select * from position_desc where positionid = '11849';
select * from person_employment where personid = '4799';