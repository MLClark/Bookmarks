select * from pers_pos where personid = '10003' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from position_desc where positionid = '32814';

select * from benefit_plan_desc;

(select personid, phonecontacttype, case when substring (phoneno from 4 for 1) = '-' then phoneno else substring (phoneno from 1 for 3) || '-' || substring (phoneno from 4 for 3) || '-' || substring (phoneno from 7 for 4) end as phoneno, RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
             from person_phone_contacts where phonecontacttype in ('Work','Mobile','Home') and current_date between effectivedate and enddate and current_timestamp between createts and endts and personid in ('2795','2810','2907','2790')
             group by personid, phonecontacttype, phoneno order by personid, rank
           
           ) ;
           
select personid, position('@' in url) from person_net_contacts where personid = '2759'

SELECT POSITION('Tutorial' IN 'PostgreSQL Tutorial')

select * from person_names where lname = 'Judy' and nametype = 'Legal';

select * from edi.edi_last_update;
insert into edi.edi_last_update (feedid,lastupdatets) values ('TASC_FSA_Census_File_Export','2020-01-01 00:00:00') ;