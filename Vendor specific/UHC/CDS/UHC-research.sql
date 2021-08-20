select * from person_employment where personid = '123' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from pers_pos where personid = '123';
select * from position_desc where positionid = '194';
select positiontitle from position_desc group by 1;

select 
 emplhiredate as orig_hire_date
,to_char(emplhiredate + interval '1 month' + interval '1 day','yyyy-mm-dd') as doh_1
,to_char(emplhiredate + interval '3 month' + interval '1 day','yyyy-mm-dd') as doh_3
,to_char(emplhiredate + interval '6 month' + interval '1 day','yyyy-mm-dd') as doh_6
from person_employment where personid = '1443'

select * from person_names where lname like 'Bra%';
select * from person_dependent_relationship;
select * from dependent;
select * from person_maritalstatus where personid in (select personid from person_maritalstatus where maritalstatus = 'D') a
select * from person_maritalstatus where personid = '135';
select * from person_dependent_relationship where personid in (select personid from person_maritalstatus where maritalstatus = 'D');
select * from person_names where personid = '5883';
select * from comp_plan_plan_year where compplanplanyeartype = 'Bene' and planyearend >= current_date;
select * from person_bene_election where personid  in ('200','201') and benefitsubclass = '23';


select * from edi.edi_last_update;
update edi.edi_last_update set lastupdatets = '2021-01-22 16:03:46' where feedid = 'CDS_UHC_Life_ADD_Export';
insert into edi.edi_last_update (feedid,lastupdatets) values ('CDS_UHC_Life_ADD_Export','2021-01-10 00:00:00');
select * from person_employment where personid = '123';
(select ppe.personid, ppe.benefitelection, ppe.benefitcoverageid, ppe.benefitsubclass, ppe.benefitplanid, ppe.coverageamount, ppe.eventdate, max(ppe.effectivedate) as effectivedate, max(ppe.enddate) as enddate,RANK() OVER (PARTITION BY ppe.personid ORDER BY MAX(ppe.effectivedate) DESC) AS RANK
             from person_bene_election ppe
            
            where ppe.benefitsubclass = '23' and ppe.benefitelection = 'E' and ppe.selectedoption = 'Y' and ppe.effectivedate < ppe.enddate and current_timestamp between ppe.createts and ppe.endts -- and ppe.eventdate >= cppy.planyearstart
            
             and personid not in (select personid from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts and emplstatus in ('R','T') and effectivedate >= '2020-10-01')
            group by ppe.personid, ppe.benefitelection, ppe.benefitcoverageid, ppe.benefitsubclass, ppe.benefitplanid, ppe.coverageamount, ppe.eventdate)