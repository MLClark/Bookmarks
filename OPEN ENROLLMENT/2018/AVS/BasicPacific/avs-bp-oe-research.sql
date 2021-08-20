select * from person_names where lname like 'DAWSON%';
select * from person_bene_election where personid = '6046' and benefitsubclass in ('60','61')
and benefitelection = 'E' and effectivedate = '2019-01-01';