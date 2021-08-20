select * from organization_code

select * from pers_pos where current_date between effectivedate and enddate and current_timestamp between createts and endts and personid in ('3663','3666');
select * from pos_org_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts and posorgreltype = 'Member' and positionid 
in (select positionid from pers_pos where current_date between effectivedate and enddate and current_timestamp between createts and endts and personid in ('3663','3666'));
select * from organization_code where current_date between effectivedate and enddate and current_timestamp between createts and endts and organizationtype = 'Dept' and organizationid
in (select organizationid from pos_org_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts and posorgreltype = 'Member' and positionid 
in (select positionid from pers_pos where current_date between effectivedate and enddate and current_timestamp between createts and endts and personid in ('3663','3666')));


left join pos_org_rel pord
  on pord.positionid = pd.positionid 
 and pord.posorgreltype = 'Member'
 and current_date between pord.effectivedate and pord.enddate 
 and current_timestamp between pord.createts and pord.endts
 
LEFT JOIN organization_code ocd 
  ON ocd.organizationid = pord.organizationid 
 AND ocd.organizationtype = 'Dept'
 and current_date between ocd.effectivedate and ocd.enddate 
 and current_timestamp between ocd.createts and ocd.endts 
 
 
 
 
(select personid, emplevent, emplstatus, emplclass, emplpermanency, benefitstatus, emplhiredate, empllasthiredate, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank  
             from person_employment where effectivedate <= enddate and current_timestamp between createts and endts 
              and personid in (select distinct personid from person_employment where emplevent in ('Hire', 'Rehire') and effectivedate < enddate and current_timestamp between createts and endts group by 1)
              and ((emplstatus in ('T','R')) or (emplevent in ('Hire', 'Rehire'))) --and personid in ('2664','3033','3038')
          );

select * from person_employment where personid  in ('3033','2664','3038') order by 1;
 (select distinct personid from person_employment where personid = '3663' and emplevent in ('Hire', 'Rehire') and effectivedate <= enddate and current_timestamp between createts and endts group by 1) ;

--insert into edi.edi_last_update (feedid,lastupdatets) values ( 'DAB_OneAmerica_401K_Export','2020-11-23 13:32:00');

select * from edi.edi_last_update  where feedid = 'DAB_OneAmerica_401K_Export';
update edi.edi_last_update set lastupdatets = '2021-07-11 09:17:43' where feedid = 'DAB_OneAmerica_401K_Export'; --2020-02-19 07:08:30
--2021-05-12 09:17:43

select * from person_employment order by personid;
left join  (select personid, emplevent, emplstatus, emplclass, emplpermanency, benefitstatus, emplhiredate, empllasthiredate, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank  
             from person_employment where effectivedate <  enddate and current_timestamp between createts and endts 
              and personid in (select distinct personid from person_employment where emplevent = 'Rehire' and effectivedate < enddate and current_timestamp between createts and endts group by 1)
              and emplstatus in ('T','R','D','V','X')
              ) rehired on rehired.personid = pi.personid and rehired.rank = 1

 (select personid, emplevent, emplstatus, emplclass, emplpermanency, benefitstatus, emplhiredate, empllasthiredate, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank  
             from person_employment where effectivedate <  enddate and current_timestamp between createts and endts 
              and personid in (select distinct personid from person_employment where emplevent = 'Rehire' and effectivedate < enddate and current_timestamp between createts and endts group by 1)
              and emplstatus in ('T','R','D','V','X')
              );

select * from person_employment where personid = '3007';
select * from company_parameters where companyparametername = 'PInt';
select * from pers
select * from pay_unit;
select * from person_financial_plan_election;

select * from pers_pos; 

select date_part('year',age(birthdate)) from person_vitals

select * from person_employment where emplhiredate <> empllasthiredate and personid 

select * from person_vitals 

select * from person_identity where personid = '3092';

select * from person_address where personid = '2700';
select * from person_names where lname like 'Del%';

select position('_' in 'PROGDIR_325 ' );
select char_length('PROGDIR_325 ' );

select substring('PROGDIR_325 ' from 1 for 8-1);
select substring('PROGDIR_325 ' from 1 for position('_' in 'PROGDIR_325 ' )-1);

select * from person_names where personid = '3080';

select * from person_names where personid in ('4236','2784','3080') and nametype = 'Legal' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select 
 personid
,name
,position(',' in name) as pos
,char_length(name) length
,substring(name from position(',' in name))||'*'||substring(name from 1 for position(',' in name)) ::char(30) as fullname30
,substring(name from position(',' in name))||'*'||substring(name from 1 for char_length(name - (position(',' in name) )))
from person_names where nametype = 'Legal' and current_date between effectivedate and enddate and current_timestamp between createts and endts
order by length desc


select
 i.personid
,i.pos
,i.len
,pn.name

,i.len - i.pos as lname

,(pn.fname||' '||coalesce(pn.mname,'')) as fullname
,substring(pn.name from position(',' in pn.name)) 
,substring(pn.name from position(',' in pn.name))||substring(pn.name from i.pos for 1)
,substring(pn.name from 1 for i.pos)
from 
(select 
 personid
,name
,position(',' in name) as pos
,char_length(name) as len
from person_names where nametype = 'Legal' and current_date between effectivedate and enddate and current_timestamp between createts and endts
order by len desc) i

join person_names pn 
  on pn.personid = i.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 order by len desc
 ;
 

