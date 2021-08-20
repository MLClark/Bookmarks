select * from benefit_plan_desc
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
    and benefitsubclass in ('11')  
  ;
select * from person_bene_election
where benefitsubclass in ('10','6Z') 
  and personid = '266'
  ;
select emplstatus from person_employment
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  group by 1
  ;


select * from person_names where lname like 'Walker%';
select * from person_bene_election where personid = '750' 
and current_date between effectivedate and enddate
and current_timestamp between createts and endts 
and personid = '622'

select to_char(date_part('year',current_date),'yyyy')
select make_date(date_part('year',current_date),01 , 01 )
select make_date(2018,01,01)
select cast(extract(year from current_date)as dec (4,0)),
select date_trunc('year', current_date)
select * from pspay_etv_list;

select * from edi.edi_last_update ; 

insert into edi.edi_last_update (feedid, lastupdatets) values ('BEK_PayFlex_HSA_Eligibility_Export','2018-01-01 00:00:00');
update edi.edi_last_update set lastupdatets = '2018-06-01 00:00:00' where feedid in ('BEK_PayFlex_HSA_Eligibility_Export');