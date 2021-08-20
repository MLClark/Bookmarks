select * from benefit_plan_desc where benefitsubclass in ('20','30','31','21','2Z','23','25');
select * from person_employment where personid = '5113';
select * from person_bene_election where benefitsubclass = '23' and selectedoption = 'Y' and benefitelection = 'Y'
and current_date between effectivedate and enddate and current_timestamp between createts and endts;