select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '201-10-01 00:00:00' where feedid = 'DGH_AetnaDisabilityExport';

sele

select * from pers_pos where personid = '17510';
select * from position_desc where positionid in ('51770');
select * from salary_grade where grade in ('1');

(select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where  current_timestamp between createts and endts and personid = '19805' 
            group by personid, positionid, scheduledhours, schedulefrequency) ;
(select personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
             from person_compensation where  current_timestamp BETWEEN createts AND endts and personid = '19805' 
            group by personid, compamount, increaseamount, compevent, frequencycode, earningscode)
;

select * from person_compensation where personid = '19805';
select * from position_desc where positionid = '52222';            
            
(select positionid, grade, positiontitle, flsacode, enddate, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY positionid ORDER BY max(effectivedate) DESC) AS RANK
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts and positionid = '52222'
            group by positionid, grade, positiontitle, flsacode, enddate)  ;           


s

select personid, locationid, max(effectivedate) as effectivedate, rank() over (partition by personid order by max(createts)desc) as rank
  from person_locations where current_date between effectivedate and enddate and current_timestamp between createts and endts
 group by personid, locationid


select * from person_names where lname like 'Espin%';
select * from person_names where lname like 'Jones%';

select * from person_employment where personid = '19805';

select * from person_employment where personid in ('18186') and emplstatus in ('T', 'R', 'D') 

SELECT * from person_identity where personid in ('17388', '19751') and identitytype = 'SSN';
select * from person_vitals where personid = '17388';
select * from pers_pos where personid = '18197';

( select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
             from pers_pos where current_timestamp between createts and endts and current_date between effectivedate and enddate 
             and personid = '18942'
            group by personid, positionid, scheduledhours, schedulefrequency)
            ;

select * from benefit_plan_desc where current_timestamp between createts and endts;

select * from position_desc where positionid = '50275';
select benefitsubclass from person_bene_election group by 1;

select companyname from companyname
where companynamepid = 1

select * from pay_unit;
select * from location_codes;
select * from location_address;

-- union 06,07
-- non-union 00,05,10,15,15



 (SELECT personid, compamount, increaseamount, compevent, frequencycode, earningscode, max(createts) as createts, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                     RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate)desc) AS RANK
            FROM person_compensation 
            WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and compevent <> 'Hire' and personid = '17279'
            GROUP BY personid, compamount, increaseamount, compevent, frequencycode, earningscode)
            ;
            
  (SELECT personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                     RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_compensation WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and compevent <> 'Hire' 
            GROUP BY personid, compamount, increaseamount, compevent, frequencycode )          
            select * from person_compensation where personid = '17279';
            
            
            pc.earningscode in ('Regular','ExcHrly', 'RegHrly')
insert into edi.edi_last_update (feedid,lastupdatets) values ('DGH_AetnaDisabilityExport','2018-01-01 00:00:00');