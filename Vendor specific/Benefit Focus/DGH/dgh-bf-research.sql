(select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, RANK() OVER (PARTITION BY personid ORDER BY max(effectivedate) DESC) AS RANK
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts and personid = '19902'
            group by personid, positionid, scheduledhours, schedulefrequency)

;


select * from person_address where personid = '18121';

select * from person_names where personid in ('18121');




select * from person_names where personid in (select personid from person_names where nametype = 'Legal'   group by 1 having count(*) > 1);
select * from person_address where personid in (select personid from person_address where addresstype = 'Res'   group by 1 having count(*) > 1);

select * from person_employment where emplstatus <> 'A';

select * from person_names where personid in ('17388','17736');


select * from edi.edi_last_update;

update edi.edi_last_update set lastupdatets = '2019/05/17 17:00:06' where feedid = 'DGH_Benefitfocus_Demographic_Export'; -----2019/04/26 17:00:06
insert into edi.edi_last_update (feedid,lastupdatets) values ('DGH_Benefitfocus_Demographic_Export','2019-01-01 00:00:00'); 
select * from pay_unit;
select * from location_codes;
select * from person_locations where personid = '18630';

SELECT * FROM PERSON_ADDRESS WHERE PERSONID = '17482' AND ADDRESSTYPE = 'Res';

pu.payunitxid 

/*
7B9 =     TECH – BEDFORD (MAC)
7BC =     TECH – FAIRFIELD (MAC)
7C7 =     TECH – HAYWARD CERAMICS (MAC)
7C8 =     TECH – HAYWARD METALS (MAC)
7C9 =     TECH – HUDSON (MAC)
7DD =     TECH – LATROBE (MAC)
7DE =     TECH – LATROBE UNION (MAC)
7E6 =     TECH – NEW BEDFORD (MAC)
AXE =     TECH – AUBURN (MAC)
E39 =     TECH – IT NA (MAC)

7VK =     TECH – CERTECH TWINSBURG (MAC)
7XK =     TECH – CERTECH WILKESBARRE (MAC)
7YZ =     TECH – CERTECH WOODRIDGE (MAC)
*/

select * from edi.lookup ;

select distinct
 lkup.value1  ::varchar(19) as client_id
,to_char(current_date,'yyyymmdd') ::char(8) as create_date
,to_char(current_timestamp,'hhmm')::char(4) as create_time
,'FF' ::char(2) as file_type
,0   as record_count
,'Y' ::char(1) as safeguard_usage
,'Y' ::char(1) as auto_approve_benefits
,'2' ::char(1) as log_id_method
,'""' ::char(1) as password_method
,'V8' ::char(2) as version

 from edi.lookup lkup
 join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid
  and current_date between lkups.effectivedate and lkups.enddate
where current_date between lkup.effectivedate and lkup.enddate
  and lkups.lookupname = 'BAC_Benefitfocus_Demographic_Export'
