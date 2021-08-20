select * from benefit_plan_desc where current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from person_compensation where personid in ('5277');
(select personid, compamount, frequencycode, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts) desc) as rank
             from person_compensation where current_timestamp between createts and endts and effectivedate < enddate and compamount <> 0 
             and personid = '5277'
            group by personid, compamount, frequencycode) ;
select * from pers_pos where personid in ('5277');
select * from person_compensation where personid = '5502';            

(select personid, compamount, frequencycode, max(createts) as createts, max(effectivedate) as effectivedate, max(enddate) as enddate,rank() over (partition by personid order by max(createts) desc) as rank
             from person_compensation where  createts < endts and effectivedate < enddate and compamount <> 0 and personid = '5502'
            group by personid, compamount, frequencycode);
            
select * from edi.edi_last_update;            
update edi.edi_last_update set lastupdatets = '2018-11-01 00:00:00' where feedid = 'AUR_Mutual_Of_Omaha_Carrier_Export';


select * from person_names where lname like 'Bond%';
select * from person_bene_election where personid = '5328' and benefitsubclass in ('30','31');
select * from person_employment where personid = '5328';