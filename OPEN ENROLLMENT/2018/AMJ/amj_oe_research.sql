select * from benefit_plan_desc where benefitsubclass in ('6Z','6Y');


select * from person_benefit_action where eventname in ('OE')
and eventeffectivedate > '2018-01-01'
select * from edi.edi_last_update;
select * from person_bene_election pbe
join edi.edi_last_update elu on elu.feedID = 'Unum_VolLifeADD_Export'

where benefitsubclass in ('21','22','24','25','27','2Z') and effectivedate >= '2018-11-11 07:00:24' and benefitelection = 'E' and selectedoption = 'Y' 
and (pbe.effectivedate >= elu.lastupdatets::DATE or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )


select * from benefit_plan_desc 
select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2018-01-01 00:00:00' where feedid = 'AMJ_EBC_HSA_Eligibility_Export';
insert into edi.edi_last_update (feedid,lastupdatets) values ('AMJ_EBC_HSA_Eligibility_Export','2018-01-01 00:00:00');

'2018-11-11 07:00:24'
select * from benefit_plan_desc where benefitplanid in ('42','45','48','51','75','57');
select * from benefit_plan_desc where benefitsubclass in ('21','22','24','25','27','2Z');
select * from benefit_plan_desc where edtcode = 'LIFE';

SELECT date_trunc('year', current_date + interval '1 year');

select distinct personid from person_bene_election where benefitsubclass in ('21','22','24','25','27','2Z')
and effectivedate = date_trunc('year', current_date + interval '1 year') and current_timestamp between createts and endts 
and benefitelection = 'E' and selectedoption = 'Y' order by 1
;

(SELECT personid,coverageamount,createts,personbeneelectionevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('21') and benefitelection in ( 'E') and selectedoption = 'Y'
             and personid = '921'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent )

select * from person_bene_election where benefitsubclass in ('21','22','24','25','27','2Z') and personid = '1724'
and effectivedate = date_trunc('year', current_date + interval '1 year') and current_timestamp between createts and endts 
and benefitelection = 'E' and selectedoption = 'Y' order by 1 

(SELECT personid,coverageamount,createts,personbeneelectionevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('21') and benefitelection in ( 'E') and selectedoption = 'Y'
              and personid = '1855'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent )

select * from person_compensation where personid = '732'            
select * from person_employment where personid = '1855';

(SELECT personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_compensation 
            WHERE enddate > effectivedate  and personid = '732'
              AND current_timestamp BETWEEN createts AND endts and compamount <> 0
            GROUP BY personid, compamount, increaseamount, compevent, frequencycode )