select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2019-01-01 00:00:00' where feedid = 'APM_Metlife_DentalVisionLife_Export';
select * from person_bene_election where benefitsubclass in ('20','21','11','30','31','14','25','2Z') ;



(SELECT personid, benefitsubclass, benefitelection, benefitcoverageid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_bene_election LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'APM_Metlife_DentalVisionLife_Export' and personid = '1456'
           WHERE effectivedate < enddate  AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('11') and benefitelection in ( 'E','T')  and selectedoption = 'Y' 
             and effectivedate <= elu.lastupdatets GROUP BY personid, benefitsubclass, benefitelection, benefitcoverageid, coverageamount)
             ;

select * from person_employment where effectivedate >= '2018-09-01';
select * from person_dependent_relationship where personid = '1450';


sele

select * from dependent_enrollment where personid = '940' and benefitsubclass in ('11','14','25','2Z') ;
select * from person_names where personid = '1615';
select * from person_vitals where personid = '1615';
select * from person_bene_election where personid = '831' and benefitsubclass = '2Z';
(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITIon BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '2Z' and benefitelection = 'E' and selectedoption = 'Y' and (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  and personid = '831'
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount) ;

select * from person_bene_election where benefitsubclass = '25' and selectedoption = 'Y' and benefitelection = 'E';

select * from person_bene_election where personid = '1384' and benefitsubclass = '25' and benefitelection = 'E' and selectedoption = 'Y' and enddate > current_date and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from pers_pos;
select * from person_compensation;
left join person_bene_election pbedblife
  on pbedblife.personid = pbe.personid
 and pbedblife.benefitsubclass in ('25') 
 and pbedblife.benefitelection = 'E'
 and pbedblife.selectedoption = 'Y' 
 and pbedblife.enddate > current_date
 and current_date between pbedblife.effectivedate and pbedblife.enddate
 and current_timestamp between pbedblife.createts and pbedblife.endts 
 
 select * from person_names where personid = '1573';
select * from person_employment where personid = '1573';
select * from person_bene_election where personid = '1870' and benefitsubclass = '11';
(SELECT personid, benefitsubclass, benefitelection, benefitcoverageid, coverageamount, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITIon BY personid ORDER BY MAX(effectivedate) ASC) AS RANK
            FROM person_bene_election left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'
           WHERE effectivedate < enddate  and current_timestamp BETWEEN createts and endts and benefitsubclass in ('11') and benefitelection in ( 'E','T')  and selectedoption = 'Y' and personid = '1573'
             and effectivedate <= elu.lastupdatets GROUP BY personid, benefitsubclass, benefitelection, benefitcoverageid, coverageamount);


select * from person_bene_election where personid = '861' and current_date between effectivedate and enddate and current_timestamp between createts and endts 
and selectedoption = 'Y' and benefitsubclass = '11';
select * from person_bene_election where personid = '861' and benefitsubclass = '11';
select * from person_bene_election where personid = '1347' and benefitsubclass = '20';
select * from person_bene_election where personid = '1347' and benefitsubclass = '21';
select * from person_bene_election where personid = '1347' and benefitsubclass = '31';
select * from person_bene_election where personid = '1347' and benefitsubclass = '30';
select * from person_bene_election where personid = '1347' and benefitsubclass = '21';
select * from person_bene_election where personid = '1347' and benefitsubclass = '2Z';
select * from person_bene_election where personid = '793' and benefitsubclass = '25';
select * from person_bene_election where personid = '1347' and benefitsubclass = '21';
select * from person_bene_election where personid = '1347' and benefitsubclass = '2Z';
select * from person_bene_election where personid = '793' and benefitsubclass = '25';
select * from person_bene_election where personid = '1347' and benefitsubclass = '14';


select * from person_identity where personid = '1353';
select * from person_names where lname like 'Este%';

select * from person_employment where personid = '861';
select * from person_bene_election where personid = '1347' and benefitsubclass = '30';
select * from person_bene_election where personid = '1337' and benefitsubclass = '11';

select * from person_compensation where personid = '1383';
select * from person_bene_election where personid = '1732' and benefitsubclass = '14';


select * from person_bene_election where personid = '1383' and benefitsubclass = '21';
select * from person_bene_election where personid = '1530' and benefitsubclass = '25';
select * from person_bene_election where personid = '940' and benefitsubclass = '2Z';

SELECT * FROM PERSON_BENE_ELECTION 
WHERE benefitsubclass in ('14') AND PERSONID = '1426'
and selectedoption = 'Y' and benefitelection = 'E' 
and current_date between effectivedate and enddate 
and current_timestamp between createts and endts;

SELECT * FROM PERSON_BENE_ELECTION 
WHERE benefitsubclass in ('14') AND PERSONID = '1426'
and selectedoption = 'Y' and benefitelection = 'E' 
and effectivedate < enddate 
and current_timestamp between createts and endts;

select * from person_bene_election where personid = '1488' and benefitsubclass = '20'
 and selectedoption = 'Y' and current_date between effectivedate and enddate
and current_timestamp between createts and endts and enddate > current_date;
select * from person_employment where personid = '1426';
select * from edi.edi_last_update;
insert into edi.edi_last_update (feedid,lastupdatets) values ('APM_Metlife_DentalVisionLife_Export','2018-10-01 00:00:00');




select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from person_names where personid = '1337';
select * from benefit_coverage_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and benefitsubclass = '11' and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and benefitsubclass = '20' and benefitelection = 'E' and selectedoption = 'Y';
select benefitsubclass from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and benefitelection = 'E' and selectedoption = 'Y' group by 1;
select * from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and benefitsubclass = '2Z' and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and benefitsubclass = '30' and benefitelection = 'E' and selectedoption = 'Y';
select * from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts 
and benefitsubclass = '21' and benefitelection = 'E' and selectedoption = 'Y';