select * from person_bene_election where personid = '4292' and benefitsubclass in ('60','61')
and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts;

select * from person_bene_election where personid = '4348' and benefitsubclass in ('60','61')
and selectedoption = 'Y' and benefitelection = 'E' and effectivedate < enddate and current_timestamp between createts and endts;


select * from person_bene_election where personid = '4549' and benefitsubclass in ('60','61')
and selectedoption = 'Y' and benefitelection = 'E' and effectivedate < enddate and current_timestamp between createts and endts;




select * from person_employment where personid = '4374';
select * from person_names where lname like 'Tran%';


select * from person_employment where personid in (select distinct personid from person_bene_election where personid = '4135' and benefitsubclass in ('60','61')) 
and emplstatus in ('T','R');




select * from person_bene_election where benefitsubclass in ('60','61') and selectedoption = 'Y' and benefitelection = 'E' and effectivedate < enddate and current_timestamp between createts and endts
and effectivedate >= '2019-01-01' and personid = '4549'




select * from edi.edi_last_update where feedid = 'ASP_Optum_FSA_Export';
insert into edi.edi_last_update (feedid,lastupdatets) values ('ASP_Optum_FSA_Exchange','2018-07-01 00:00:00');
update edi.edi_last_update set lastupdatets = '2018-01-01 00:00:00' where feedid = 'ASP_Optum_FSA_Export';
select * from benefit_plan_desc where benefitsubclass in ('60','61');
select * from person_bene_election where personid = '4067' and benefitsubclass in ('60','61');
select * from personbenoptioncostl where personid = '4252' and costsby = 'P' and personbeneelectionpid = '121249';
select * from person_bene_election where benefitsubclass in ('60','61') and selectedoption = 'Y' and enddate < '2199-12-31' and effectivedate >= '2018-01-01'
   and  current_timestamp between createts and endts
    and personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y')
   
   
select * from person_names where personid = '4122';   


select * from person_bene_election where personid = '4123' and benefitsubclass in ('60','61') and selectedoption = 'Y' and current_timestamp between createts and endts ;

select * from person_bene_election where personid in 
(select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus = 'A')
 and benefitsubclass in ('60','61') and benefitelection <> 'W';
 select * from person_names where personid = '4123';
 4123
 4252
 4375
 
 left join 
 -- rank 1 coverage = 0 - this is current
 -- rank 2 coverage > 0 - this is prior record
 -- locate ee's enrolled in fsa in current plan year that have term'd fsa benefit
( select personid, coverageamount, enddate, personbeneelectionpid, max(effectivedate) as effectivedate, rank() over (partition by personid order by max(effectivedate) desc) as rank
   from person_bene_election 
  where effectivedate < enddate 
    and current_timestamp between createts and endts
    and benefitsubclass in ('60','61') and selectedoption = 'Y' and benefitelection = 'E'
    and date_part('year',deductionstartdate)>=date_part('year',current_date)
   group by personid, coverageamount, enddate, personbeneelectionpid) prevfsa on prevfsa.personid = pbe.personid and prevfsa.enddate >= elu.lastupdatets and prevfsa.coverageamount <> 0
 
 
  (select personid, scheduledhours, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,      
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
   from pers_pos pp
   left join edi.edi_last_update elu ON elu.feedid = 'ASP_Optum_FSA_Exchange'
  group by personid,scheduledhours);
 
 select * from personbenoptioncostl where personid = '4252' and costsby = 'P' and personbeneelectionpid in ('193366','149161');
 select * from person_bene_election where personid = '4123' and benefitsubclass in ('60','61');
 
 -- rank 1 coverage = 0 - this is current
 -- rank 2 coverage > 0 - this is prior record
 -- locate ee's enrolled in fsa in current plan year that have term'd fsa benefit
 select personid, coverageamount, enddate, personbeneelectionpid, max(effectivedate) as effectivedate, rank() over (partition by personid order by max(effectivedate) desc) as rank
   from person_bene_election 
  where effectivedate < enddate 
    and current_timestamp between createts and endts
    and benefitsubclass in ('60','61') and selectedoption = 'Y' and benefitelection = 'E'
    and date_part('year',deductionstartdate)>=date_part('year',current_date)
    --and personid = '4252'
   group by personid, coverageamount, enddate, personbeneelectionpid
   ;
       