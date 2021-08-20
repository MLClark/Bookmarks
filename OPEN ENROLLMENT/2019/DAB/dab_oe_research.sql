select * from person_bene_election where benefitsubclass in ('6H','6Z') and selectedoption = 'Y' 
and current_timestamp between createts and endts and deductionstartdate >= current_date;
select * from person_bene_election where personid = '3997' and benefitsubclass = '6Z';
