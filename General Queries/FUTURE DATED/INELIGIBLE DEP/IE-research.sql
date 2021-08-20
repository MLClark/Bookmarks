select distinct
 pi.personid
 
from person_identity pi

where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts;
  
select * from person_maritalstatus  where maritalstatusevent = 'DIV';
select * from person_maritalstatus where maritalstatus = 'D';
select * from person_names where personid = '7105';