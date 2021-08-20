select * from person_bene_election where benefitsubclass in ('6Z','10') and effectivedate > current_date and benefitelection = 'E' and selectedoption = 'Y';

select * from person_bene_election where benefitsubclass in ('6Z','10') and personid = '1581'  and benefitelection = 'E' and selectedoption = 'Y';


select * from edi.edi_last_update;

select * from person_names where lname like 'Water%';

update edi.edi_last_update set lastupdatets = '2019-02-26 06:03:19' where feedid = 'CDE_Optum_HSA_Changes';


2019-02-26 06:03:19