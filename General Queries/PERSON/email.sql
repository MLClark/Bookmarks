select distinct 
 pi.personid
,rtrim(ltrim(pncw.url)) ::varchar(100) as work_email  
,rtrim(ltrim(pnch.url)) ::varchar(100) as home_email   
,coalesce(pncw.url,pnch.url,pnco.url) as email
from person_identity pi

LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts 

LEFT JOIN person_net_contacts pnch
  ON pnch.personid = pi.personid 
 AND pnch.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnch.effectivedate and pnch.enddate
 AND current_timestamp between pnch.createts and pnch.endts 

LEFT JOIN person_net_contacts pnco
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'Other'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.endts  
  
 -- select netcontacttype from person_net_contacts group by 1;
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 