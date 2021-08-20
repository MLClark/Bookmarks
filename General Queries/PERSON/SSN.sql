select 
 pi.identity
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity else
      left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as pi_ssn_w_dashes
,replace(pi.identity,'-','')         			AS SSN_without_Dashes
from person_identity pi
where current_timestamp between pi.createts and pi.endts
 and pi.identitytype = 'SSN';
