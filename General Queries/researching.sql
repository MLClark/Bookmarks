select distinct positiontitle from position_desc group by 1;-- where positionid = '22266';
select * from position_job;
select * from pers_pos;-- where personid = '10';
select * from job;
select * from job_desc;

select * from dependent_enrollment where personid = '4030' and benefitsubclass = '10';

select * from pspay_etv_list;

select *
  from person_bene_election 
 where personid = '3992'
   and benefitsubclass = '10'
   and effectivedate < enddate
   and date_part('year',enddate) = '2017'
   and benefitelection = 'E'
  ;
  select personid, benefitplanid, count(personid) as counter from person_benE_election 
  where benefitsubclass = '10'

  and current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  group by 1,2
  having count(*) > 1
  ;
  select * from person_bene_election where benefitsubclass = '10'
      and current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  ;
  
    select * from benefit_plan_desc where benefitsubclass = '10'
    and current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  ;
    select personid, benefitplanid, benefitsubclass from person_bene_election where benefitsubclass = '10'
      and current_date between effectivedate and enddate
  and current_timestamp between createts and endts
  order by 1
  ;
  select * from person_names where personid = '3386';
select *
  from person_bene_election 
 where personid = '3666'
   and benefitsubclass = '10'
   and date_part('year',enddate) = '2017'   
   and effectivedate < enddate

   and benefitelection = 'E'
  ;
  select * from person_names where lname like 'Camp%';
  
  select *
  from person_bene_election 
 where personid = '3386'
   and benefitsubclass = '10'
   and date_part('year',enddate) = '2017'   
   and date_part('year',effectivedate) = '2016' 
   and effectivedate < enddate

   and benefitelection = 'E'
  ;