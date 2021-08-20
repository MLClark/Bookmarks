select * from person_identity where identitytype = 'AgtNo';

select * from person_names where personid in (select personid from person_identity where identitytype = 'AgtNo');

select * from person_employment where current_date between effectivedate and enddate and current_timestamp between createts and endts;


,ltrim(case when position('x' in lower(ppcw.phoneno)) > 1 then substring(ppcw.phoneno from (position('x' in lower(ppcw.phoneno)) + 1) for 5)		
		  when position('X. ' in upper(ppcw.phoneno)) > 1 then substring(ppcw.phoneno from (position('X. ' in upper(ppcw.phoneno)) + 3) for 5)
		  when position('X' in upper(ppcw.phoneno)) > 1 then ltrim(substring(ppcw.phoneno from (position('X' in upper(ppcw.phoneno)) + 1) for 5))
		  else '    ' end)::char(4) as Extension
	
select position('_' in 'PROGDIR_325 ' );
select char_length('PROGDIR_325 ' );

select substring('PROGDIR_325 ' from 1 for 8-1);
select substring('PROGDIR_325 ' from 1 for position('_' in 'PROGDIR_325 ' )-1);		  
		  
select personid
,url
,position('@' in url) -1
,char_length(url)
,case when position('@' in url) -1 > 0 then substring(url from 1 for position('@' in url) - 1) end
,case when position('@' in pnca.url) -1 > 0 then substring(pnca.url from 1 for position('@' in pnca.url) - 1) end as user_email_id

 from person_net_contacts  where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
 and url is not null;		  
 
 select * from person_names where personid = '69006';
 select * from person_net_contacts where personid = '64301' and netcontacttype = 'WRK' and current_timestamp between createts and endts
 and current_date between effectivedate and enddate
 
(select personid, url, enddate, max(effectivedate) as effectivedate, max(createts) as createts, rank() over (partition by personid order by max(createts), max(effectivedate) desc) AS rank
             from person_net_contacts where personid in ('63871', '63709','64301') and netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, url, enddate)  
 ;
            
 (select personid, url, enddate, max(effectivedate) as effectivedate, max(createts) as createts, rank() over (partition by personid order by max(createts), max(effectivedate) desc) AS rank
             from person_net_contacts where personid in ('63871', '63709','64301') and netcontacttype = 'WRK' and effectivedate < enddate and current_timestamp between createts and endts
            group by personid, url, enddate)         
            ;
            
select * from person_names where lname like 'Harrel%';      
select * from person_identity where personid = '68919' ;  
select * from person_identity where personid = '68923' ;     
select * from person_user_field_vals where ufid = (select ufid from user_field_desc where ufname = 'AgentType'
	       		and current_date between effectivedate and enddate
			     and current_timestamp between createts and endts)  ;
			     
select * from person_locations where personid = '62958';		     
