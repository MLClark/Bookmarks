select * from person_bene_election where benefitsubclass in ('10', '1Y') and selectedoption = 'Y' and benefitelection = 'E'
and current_date between effectivedate and enddate and current_timestamp between createts and endts
and date_part('year',effectivedate) >= date_part('year',current_date);


left join (SELECT personid, emplstatus, emplevent,  empleventdetcode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_employment pe1
            WHERE enddate > effectivedate 
                   AND current_timestamp BETWEEN createts AND endts
                   and emplstatus = 'L'
                   and enddate <= current_date
            GROUP BY personid, emplstatus, emplevent, empleventdetcode ) leavest on leavest.rank = 1 and leavest.personid = pe.personid
            
            
select personid, benefitsubclass, max(effectivedate) as effectivedate, max(enddate) as enddate,
  rank () over (partition by personid order by max(effectivedate) desc) as rank
  from person_bene_election 
 where current_date between effectivedate and enddate
   and current_timestamp between createts and endts
   and benefitelection = 'E'
               
               select * from person_names where personid = '575';

select * from benefit_plan_desc where benefitsubclass in ('10','1Y');     

select * from benefit_plan_desc where benefitsubclass in ('60','61');  
select * from personbenoptioncostl where personid = '2078' and costsby='P' and benefitelection = 'E'

select personid, employeerate, max(personbeneelectionpid) as personbeneelectionpid,
  rank() over (partition by personid order by max(personbeneelectionpid) desc) as rank
  from personbenoptioncostl where personid = '2078' and costsby='P' and benefitelection = 'E'
  group by personid, employeerate

  
select * from pay_schedule_period where date_part('year',periodpaydate)='2018'and date_part('month',periodpaydate)='09'  and processfinaldate is not null;
select * from person_names where lname like 'Bauer%';       
select * from person_employment where personid = '1895';
select * from person_dependent_relationship where personid = '598';

select * from edi.edi_last_update;

update edi.edi_last_update set lastupdatets = '2018-01-01 06:00:32' where feedid = 'RSI_DBS_HRA_Enrollment';

select * from dependent_enrollment where personid = '598';      
select * from person_bene_election where personid = '1179' and benefitplanid in ('10','11');   

   (SELECT MAX(pbe2.personbeneelectionpid)
      FROM person_bene_election pbe2
     WHERE pbe2.personid = '1179'
       AND pbe2.benefitplanid in ('10','11')
       AND pbe2.benefitelection = 'E') ;
       
       
select * from person_names where personid = '1833';      


select * from pers_pos where personid = '1182';
select * from pos_org_rel where positionid = '713' and posorgreltype = 'Member';
select * from cognos_orgstructure where org1id = '226';  ---org2desc

select * from person_bene_election where personid = '1619' and benefitsubclass = '10' and selectedoption = 'Y'

      (SELECT personid, benefitsubclass, benefitplanid, MAX(effectivedate) AS effectivedate, enddate,
       RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              FROM person_bene_election 
              join edi.edi_last_update elu on elu.feedid = 'RSI_DBS_HRA_Enrollment'
             WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts
               and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass = '1Y'
               and effectivedate >= elu.lastupdatets::DATE 
               and personid = '713'
             GROUP BY personid, benefitsubclass, benefitplanid, enddate ) 

      (SELECT personid, positionid, MAX(effectivedate) AS effectivedate, 
       RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
              FROM pers_pos WHERE enddate > effectivedate AND current_timestamp BETWEEN createts AND endts
               and personid = '1182'
             GROUP BY personid, positionid ) 