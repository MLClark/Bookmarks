(select distinct personid, enddate, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('32','31','22','20','21','2Z','25')
   and benefitelection  <> 'W'
   and selectedoption = 'Y'
   and current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and effectivedate < enddate
   and personid = '11082'
   group by 1,2)
 
 select * from person_employment where personid = '7455';
 
  select * from benefit_plan_desc;
  select * from person_bene_election where personid in ('8648','8513','9536','8388','8386') and selectedoption = 'Y';
  select * from person_bene_election where personid in ('10561') and selectedoption = 'Y' and benefitsubclass in ('20','21');
  select * from person_bene_election where personid in ('10561') and selectedoption = 'Y' and benefitsubclass in ('30','31');  
  
   (select distinct personid, enddate, max(effectivedate) as effectivedate,
  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) desc) AS RANK
  from person_bene_election 
 where benefitsubclass in ('32','31','22','20','21','2Z','25')
   and benefitelection  = 'E'
   and selectedoption = 'Y'
   and current_timestamp between createts and endts
   and effectivedate < enddate and personid = '9536'
   group by 1,2);
       
        
(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in  ('31')
              and benefitelection <> 'W' and selectedoption = 'Y'
              and current_timestamp between createts and endts
              and effectivedate < enddate
              and date_part('year',effectivedate)>='2018' and personid in ('7455')
            group by personid, benefitsubclass, benefitelection,  personbeneelectionpid, coverageamount)        ;
        
  
 select * from person_bene_election where benefitsubclass in ('32','31','22','20','21','2Z','25','10')
 --and current_date between effectivedate and enddate 
 and current_timestamp between createts and endts
 and benefitelection = 'E' and selectedoption = 'Y'
 and personid = '7894';
 
 select * from benefit_plan_desc where benefitsubclass in ('10','20','22','21');
 select * from benefit_plan_desc where benefitplanid = '30';
 
 select * from person_bene_election where benefitsubclass in ('10','20','22')
 --and current_date between effectivedate and enddate 
 and current_timestamp between createts and endts
 and benefitelection = 'E' and selectedoption = 'Y'
 and personid = '10655';

 select * from person_identity where personid = '10655';

(select distinct personid,benefitelection,benefitsubclass, case when benefitsubclass = '10' and benefitelection = 'E' then 'Y' else 'N' end as medical_enrolled_flag
             from person_bene_election
            where benefitsubclass in ('10')
              and current_timestamp between createts and endts
              and benefitelection = 'E' and selectedoption = 'Y'
              and personid = '8513'
            order by 1 ) ;
 
 (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election
            where benefitsubclass in ('32','31','22','20','21','2Z','25')
              and benefitelection in ('E') and selectedoption = 'Y'
              and effectivedate < enddate and personid = '10638'
            group by 1,2,3,4) ;
select * from person_bene_election where benefitsubclass in ('32','31','22','20','21','2Z','25','10') and personid = '11082'
 and benefitelection = 'E' --and selectedoption = 'Y'  
 --and current_timestamp between createts and endts 
 and effectivedate < enddate;  
 

 
 
 
 
 
 -- select dependentrelationship from person_dependent_relationship group by 1;
 -- select * from dependent_relationship;
 select * from edi.edi_last_update;
 
 select * from person_names where lname like 'Butler';
 select * from person_employment where personid = '7534';
 
 select * from person_payroll where personid = '7534';
 select * from pay_unit where payunitid = '2';
 
 update edi.edi_last_update set lastupdatets = '2018-08-01 00:00:00' where feedid = 'AKH_Mutual_Of_Omaha_STD_LTD_Export';
 
 select * from person_bene_election where  benefitsubclass in  ('2Z','25') and personid = '8132';
 
  select * from person_bene_election where personid = '1026' and benefitsubclass in  ('30','32','31','22','20','21','2Z','25');
  
  (select personid, benefitsubclass, benefitelection,  personbeneelectionpid, enddate, MAX(effectivedate) AS effectivedate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) asc) AS RANK
             from person_bene_election
            where benefitsubclass in ('21','2Z','2X','27','30','31','2C','2S','13')
              and benefitelection in ('E') and selectedoption = 'Y'
              --and effectivedate < enddate
              and personid = '1026'
            group by 1,2,3,4,5) 
 
 select * from benefit_plan_desc where benefitsubclass in  ('30','32','31','22','20','21','2Z','25') ;
  select * from benefit_plan_desc where benefitsubclass in  ('30','32') ;
  
  select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in  ('30','32','31','22','20','21','2Z','25')and benefitelection = 'E' and selectedoption = 'Y'
                         and personid = '8062';
(select personid, max(effectivedate) as effectivedate
        from person_bene_election 
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('2Z','25')
         and benefitelection in ('E')
       group by 1)                  
          

,case when date_part('year',pbe_max.effectivedate) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when pbe_max.effectivedate is null then '20180101'
      else to_char(pbe_max.effectivedate,'yyyymmdd') end ::char(8)
      
,case when greatest(pbe.effectivedate,pbebSPvlife.effectivedate)::date < '2018-01-01' then '20180101'
      else to_char(greatest(pbe.effectivedate,pbebSPvlife.effectivedate), 'YYYYMMDD') end ::char(8) as emp_eff_date -- position 317 date          

,case when date_part('year',pbe_max.effectivedate) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when pbe_max.effectivedate is null then '20180101'
      else to_char(pbe_max.effectivedate,'yyyymmdd') end ::char(8) as bsedate
          
,case when pbe_max.effectivedate::date < '2018-01-01' then '20180101' 
      when pbe_max.effectivedate is null then '20180101'
      else to_char(pbe_max.effectivedate, 'YYYYMMDD')end ::char(8)  as basic_sal_eff_date
                               
     (select personid, max(effectivedate) as effectivedate
     
,case when greatest(date_part('year',pbe.effectivedate),date_part('year',pbebSPvlife.effectivedate)) < date_part('year',current_date) then date_part('year',current_date)||'0101'
      when greatest(pbe.effectivedate,pbebSPvlife.effectivedate) is null then '20180101'
      else to_char(greatest(pbe.effectivedate,pbebSPvlife.effectivedate), 'YYYYMMDD') end ::char(8) as dattte
        from person_bene_election pbe
       where current_date between effectivedate and enddate
         and current_timestamp between createts and endts
         and benefitsubclass in ('30','32','31','22','20','21','2Z','25')
         and benefitelection in ('E')
       group by 1,3)

                         
select  * from edi.edi_last_update;
insert into edi.edi_last_update (feedid, lastupdatets) values ( 'AKH_Mutual_Of_Omaha_STD_LTD_Export','2018-01-01 00:00:00');
update edi.edi_last_update set lastupdatets = '2018-08-01 00:00:00' where feedid in ( 'AKH_Mutual_Of_Omaha_STD_LTD_Export');

left join (SELECT personid, emplstatus, emplevent,  empleventdetcode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_employment pe1
            WHERE enddate > effectivedate 
                   AND current_timestamp BETWEEN createts AND endts
                   and emplstatus = 'L'
                   and enddate <= current_date
            GROUP BY personid, emplstatus, emplevent, empleventdetcode ) leavest on leavest.rank = 1 and leavest.personid = pe.personid

select * from person_bene_election where personid = '8062' and benefitsubclass in  ('20');

(select personid, benefitsubclass, benefitelection,  personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        from person_bene_election
       where benefitsubclass in  ('20')
         and benefitelection = 'E' and selectedoption = 'Y'
         and effectivedate - interval '1 day' <> enddate
         and personid = '8062'
         group by 1,2,3,4)












select * from person_bene_election 
where personid = '8062'
and benefitsubclass = '21';

select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('32','31','22','20','21','2Z','25') and benefitelection = 'E' and selectedoption = 'Y'
                         and personid = '10589';

select * from person_compensation where personid = '8237';                         

select personid, max(percomppid) as percomppid
  from person_compensation 
 where current_timestamp between createts and endts
 group by 1
 ;
 select * from person_names where lname like 'Huskey%'
 select * from person_employment where personid = '8074';
 
 select * from benefit_plan_desc;
 select personid,  benefitsubclass from person_bene_election 
 where benefitsubclass in ('30','32')
 and current_date between effectivedate and enddate
 and current_timestamp between createts and endts
 
 select * from dependent_enrollment where personid = '8136';