select * from person_names where lname like 'Mazza%';
select * from dxpersonpositiondet where personid = '66625';
select * from person_phone_contacts where current_date between effectivedate and enddate and current_timestamp between createts and endts and phonecontacttype = 'Work';
select * from person_names where personid = '62997';
select * from person_phone_contacts where personid = '63551' and current_date between effectivedate and enddate and current_timestamp between createts and endts and phonecontacttype = 'Work';

21778925004267


left join (select personid, phoneno, phonecontacttype, effectivedate, enddate, createts, endts, rank() over (partition by personid order by createts desc) as rank
             from person_phone_contacts where current_date between effectivedate and enddate and current_timestamp between createts and endts  
              and phonecontacttype = 'Work') ppcw on ppcw.personid = pi.personid and ppcw.rank = 1      

SELECT * FROM PERSON_ADDRESS WHERE PERSONID = '66362';              
SELECT * FROM PERSON_ADDRESS WHERE PERSONID = '67630';      