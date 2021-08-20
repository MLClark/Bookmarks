select * from person_names where lname like 'Patel%';
select * from person_employment where personid = '9805';
select * from person_bene_election where personid = '9805' and benefitsubclass in ('10','11','14','20')
and current_date between effectivedate and enddate and current_timestamp between createts and endts;
 (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','20') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate
                         and personid = '9805') 
select * from edi.edi_last_update;                         
update edi.edi_last_update set lastupdatets ='2018-09-01 00:00:00' where feedid = 'AJG_Cobra_Initial_Notice';