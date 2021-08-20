select * from person_bene_election where benefitsubclass in ('20','21','11','30','31','14','25','2Z')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and effectivedate < enddate and effectivedate >= current_date;

select distinct personid from person_bene_election where benefitsubclass in ('20','21','11','30','31','14','25','2Z')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year');
select * from person_bene_election where benefitsubclass in ('20','21','11','30','31','14','25','2Z')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year');


(select personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount, max(effectivedate) as effectivedate, max(enddate) as enddate,RANK() OVER (PARTITIon BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass = '20' and benefitelection = 'E' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate and effectivedate >= current_date
            group by personid, benefitelection, benefitcoverageid, benefitsubclass, benefitplanid, personbeneelectionpid, coverageamount)
            ;

select * from person_bene_election where personid = '2186' and benefitsubclass = '11';
select * from dependent_enrollment where personid = '2328' and benefitsubclass = '11';
select * from edi.edi_last_update;
insert into edi.edi_last_update (lastupdatets,feedid) values ('2019-01-01 00:00:00','APM_Metlife_DentalVisionLife_Export');

select * from person_bene_election where benefitsubclass = '30' and personid = '1449';
(SELECT personid, benefitsubclass, benefitelection, benefitcoverageid, coverageamount, personbeneelectionpid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITIon BY personid ORDER BY MAX(effectivedate) desc) AS RANK
            FROM person_bene_election left join edi.edi_last_update elu on elu.feedid = 'APM_Metlife_DentalVisionLife_Export'
           WHERE effectivedate < enddate  and current_timestamp BETWEEN createts and endts and benefitsubclass in ('31') and benefitelection in ( 'E')  and selectedoption = 'Y' and personid = '1449'
             and effectivedate <= elu.lastupdatets GROUP BY personid, benefitsubclass, benefitelection, benefitcoverageid, coverageamount, personbeneelectionpid);

(select distinct pbe.personid from person_bene_election pbe

join (select pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount, max(pbe.effectivedate) as effectivedate, max(pbe.enddate) as enddate,RANK() over (partition by pbe.personid order by max(pbe.effectivedate) desc) AS RANK
             from person_bene_election pbe 
             join person_employment pe on pe.personid = pbe.personid and current_date between pe.effectivedate and pe.enddate and current_timestamp between pe.createts and pe.endts and pe.emplstatus not in ('T','R')
            where pbe.benefitsubclass = '11' and pbe.benefitelection in ('T','W') and pbe.selectedoption = 'Y' and current_timestamp between pbe.createts and pbe.endts and pbe.effectivedate < pbe.enddate and pbe.effectivedate >= '2019-09-01'
              and pbe.personid in (select distinct(personid) from person_bene_election where benefitsubclass in ('11')  and selectedoption = 'Y' and benefitelection = 'E' and current_timestamp between createts and endts and current_date between effectivedate and enddate and date_part('year',deductionstartdate) = date_part('year',current_date - interval '1 year'))
            group by pbe.personid, pbe.benefitelection, pbe.benefitcoverageid, pbe.benefitsubclass, pbe.benefitplanid, pbe.personbeneelectionpid, pbe.coverageamount)   pbednt on pbednt.personid = pbe.personid and pbednt.RANK = 1           

where pbe.benefitelection = 'E' and pbe.selectedoption = 'Y'  and current_date between pbe.effectivedate and pbe.enddate and current_timestamp between pbe.createts and pbe.endts  and pbe.benefitsubclass in ('11'))             