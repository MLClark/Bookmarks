select epi.employeeid, epi.employeessn, epi.firstname, epi.lastname, epi.middlename 
, epi.suffix 
, epi.emailaddress 
, '' as deptcategory 
, epi.birthdate 
, epi.gendercode 
, epi.streetaddress1 
, epi.streetaddress2 
, epi.city 
, epi.statecode 
, epi.zipcode 
, epi.homephone 
, epi.workphone 
, '' as mailingstreet1 
, '' as mailingstreet2 
, '' as mailingcity 
, '' as mailingstate 
, '' as mailingzip 
, pbe.effectivedate 
, '2017-12-31' as pyenddate 
 
, coverageamount      
,CASE WHEN benefitsubclass = '60' then 'Medical FSA' 
     else 'Dependent FSA' end as fsatype 
 
from edi.etl_personal_info epi 
 join person_bene_election pbe on epi.personid = pbe.personid  
                               and current_date between pbe.effectivedate and pbe.enddate  
                               and current_timestamp between pbe.createts and pbe.endts 
                               AND pbe.benefitsubclass in ('61', '60') 
                               AND benefitelection <> 'E' 
                               and coverageamount > 0 
order by lastname                               ;