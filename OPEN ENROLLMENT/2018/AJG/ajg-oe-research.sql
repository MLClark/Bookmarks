select * from person_bene_election where benefitsubclass in ('13','1W') and selectedoption = 'Y' and benefitelection = 'E' and effectivedate = '2019-01-01' and personid = '13256';
select * from person_benefit_action where eventname = 'OE' and eventeffectivedate = '2019-01-01' and benefitsubclass in ('13','1W');

select distinct personid from person_bene_election where benefitsubclass in ('30','31') and selectedoption = 'Y' and benefitelection = 'E' and effectivedate = '2019-01-01';
select distinct personid from person_bene_election where benefitsubclass in ('13','1W') and selectedoption = 'Y' and benefitelection = 'E' and effectivedate = '2019-01-01';

select * from person_names where personid = '10549';
select * from person_employment where personid = '10549';
select * from person_bene_election where benefitsubclass in ('30','31') and selectedoption = 'Y' and benefitelection = 'E'  and personid = '10549';
'2019-01-01'