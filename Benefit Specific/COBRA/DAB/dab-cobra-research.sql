update edi.edi_last_update set lastupdatets = '2018-11-07 00:00:00' where feedid = 'DAB_EBenefits_Cobra_Export';

select * from person_bene_election where personid = '2737'and benefitsubclass in ('10','11','12','14','1H','1V');
select * from person_dependent_relationship where personid = '2737';



((select * from person_bene_election where benefitsubclass in ('10','11','12','14','1H','1V') and date_part('year',eventdate)='2018'and benefitelection = 'E' and selectedoption = 'Y' and eventdate >= '2018-10-01' and personid not in 
(select distinct personid from person_bene_election where benefitsubclass in ('10','11','12','14','1H','1V') and date_part('year',eventdate)=date_part('year',current_date) and benefitelection = 'E' and selectedoption = 'Y' and effectivedate <= '2018-10-01')))
;





select * from person_address where personid = '2788' and current_date between effectivedate and enddate and current_timestamp between createts and endts and addresstype = 'Res';



select * from person_address where city like '%,%';

SELECT * from person_employment where empleventdetcode = 'Death';
SELECT * from person_employment where personid = '2667';

select * from person_bene_election where personid = '2755' and benefitsubclass in ('10','11','12','14','1H','1V');

(SELECT personid,benefitcoverageid,benefitsubclass,MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election pc1
             LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'DAB_EBenefits_Cobra_Export'
            WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('10','11','12','14','1H','1V') 
              and benefitelection in ( 'E') and selectedoption = 'Y' and benefitcoverageid > '1' and personid = '2755'
            GROUP BY personid,benefitcoverageid,benefitsubclass )
            ;

(select distinct effcovdate.personid 
        from (select pbe.personid,pbe.benefitsubclass, min(pbe.createts) as createts, min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
                from person_bene_election pbe
               where pbe.benefitsubclass in ('10','11','12','14','1H','1V')
                 and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' and personid = '2755'
                 and current_timestamp between createts and endts
                 and effectivedate < enddate
                 and benefitcoverageid > '1'
                 
               group by 1,2) effcovdate
       left join edi.edi_last_update elu on elu.feedid = 'DAB_EBenefits_Cobra_Export'
         
      where effcovdate.min_effectivedate < elu.lastupdatets) 

select * from person_bene_election 
select * from edi.edi_last_update;
select * from person_names where personid = '2663';
insert into edi.edi_last_update (feedid,lastupdatets) values ('DAB_EBenefits_Cobra_Export','2018-11-01 00:00:00');

select * from person_benefit_action where personid = '2914';
select * from person_bene_election where personid = '2845' and benefitsubclass in ('10','11','12','14','1H','1V');

select * from person_employment where personid = '2885';


select * from person_benefit_action where eventname = 'TER' and eventeffectivedate >= '2018-01-01' and personid in 
(select personid from person_bene_election where benefitsubclass in  ('10','11','12','14','1H','1V')and benefitcoverageid > '1'
  and benefitelection = 'E' and selectedoption = 'Y'and effectivedate < enddate and current_timestamp between createts and endts);



(select * from person_bene_election where benefitsubclass in ('10','11','12','14','1H','1V') and date_part('year',eventdate)=date_part('year',current_date) and benefitelection = 'E' and selectedoption = 'Y' and eventdate < '2018-10-01'
AND PERSONID = '2897');    

((select * from person_bene_election where benefitsubclass in ('10','11','12','14','1H','1V') and date_part('year',eventdate)='2018'and benefitelection = 'E' and selectedoption = 'Y' and eventdate >= '2018-10-01' and personid not in 
(select distinct personid from person_bene_election where benefitsubclass in ('10','11','12','14','1H','1V') and date_part('year',eventdate)=date_part('year',current_date) and benefitelection = 'E' and selectedoption = 'Y' and eventdate < '2018-10-01')))

select * from person_bene_election where personid = '2897' and benefitsubclass in  ('10','11','12','14','1H','1V')
and effectivedate < enddate and current_timestamp between createts and endts
 and selectedoption = 'Y';
select * from person_names where lname like 'Bapt%';

(select effcovdate.personid,effcovdate.benefitsubclass,effcovdate.min_effectivedate,effcovdate.createts
        from (select pbe.personid,pbe.benefitsubclass, min(pbe.createts) as createts, min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
                from person_bene_election pbe
               where pbe.benefitsubclass in ('10','11','12','14','1H','1V')
                 and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' and pbe.personid = '2755'
               group by 1,2) effcovdate
       left join edi.edi_last_update elu on elu.feedid = 'DAB_EBenefits_Cobra_Export'
         
      where effcovdate.min_effectivedate = effcovdate.max_effectivedate
        and effcovdate.min_effectivedate >= elu.lastupdatets
         or effcovdate.createts >= elu.lastupdatets) 
         ;
         
         
 select * from comp_plan_benefit_plan where cobraplan = 'Y';
select * from benefit_coverage_desc where benefitcoverageid = '16';

select * from benefit_plan_desc where benefitsubclass in ('10','11','12','14');

select * from benefit_plan_desc where benefitsubclass in ('10','11','12','14','1H','1V');

select * from person_bene_election where personid = '2755' and benefitsubclass in ('11','1H');


(select distinct personid from person_bene_election where current_timestamp between createts and endts and personid = '2663'
                         and benefitsubclass in ('10','11','12','14','1H','1V') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)
                         

select * from person_dependent_relationship where personid = '2771';
select * from dependent_enrollment where personid = '2835';
select * from person_names where personid in (select dependentid from person_dependent_relationship where personid = '2835' group by 1);

select pe.* from person_employment pe
  join edi.edi_last_update elu on elu.feedid = 'DAB_EBenefits_Cobra_Export'
  JOIN person_bene_election pbe 
  on pbe.personid = pe.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection <> 'W'
 and pbe.benefitsubclass in ('10','11','12','14')
 and pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts AND pbe.endts
  -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','12','14') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
                         
where emplevent in 
(select emplevent from employment_event_detail where benefitstatus in ('I','T') group by 1)
and pe.effectivedate >= elu.lastupdatets

;
select * from employment_event_detail where benefitstatus in ('I','T') ;
select * from person_bene_election where personid = '2693' and benefitsubclass in ('10','11','12','14');
select * from person_benefit_action where personid = '2693' ;
select * from system_event;
