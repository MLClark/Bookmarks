select * from pers_pos where personid = '1026';
select * from person_employment where personid = '1026';
select * from person_employment where emplstatus = 'R';
SELEct * from person_compensation where personid = '1062' and earningscode <> 'BenBase'
--and current_date between effectivedate and enddate
and current_timestamp between createts and endts;
select * from pers_pos where personid = '2246'
and current_date between effectivedate and enddate
and current_timestamp between createts and endts;
insert into edi.edi_last_update (feedid, lastupdatets) values ('BAC_Benefitfocus_Demographic_Export','2018-01-01 00:00:00');

update edi.edi_last_update set lastupdatets = '2018-01-01 00:00:00' where feedid = 'BAC_Benefitfocus_Demographic_Export';

(SELECT personid, compamount, frequencycode, increaseamount, compevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
            FROM person_compensation pc1
            LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BAC_Benefitfocus_Demographic_Export'
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate <= elu.lastupdatets::DATE
              and personid = '1062'
            GROUP BY personid, compamount, frequencycode, increaseamount, compevent );
            
(select personid, schedulefrequency, positionid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,
            RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
   from pers_pos              
   LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BAC_Benefitfocus_Demographic_Export'
    AND current_timestamp BETWEEN createts AND endts
    and effectivedate <= elu.lastupdatets::DATE
  GROUP BY personid, schedulefrequency, positionid );
  
select * from pers_pos where personid = '2176';  
select * from position_desc where positionid = '4230';