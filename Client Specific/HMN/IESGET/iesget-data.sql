select 
 pi.personid
,pi.identity as empno
,pd.positiontitle ::varchar(64) as position_title
,pn.lname 
,pn.fname 
,pl.floormailstop as mailstop
,case when lc.locationcode = 'HO' then 'HO'
	 when puf.ufvalue <> '' and puf.ufvalue <> 'None' then 'FA' else 'FN' end as IES_location_code
,ltrim(case when position('x' in lower(ppcw.phoneno)) > 1 then substring(ppcw.phoneno from (position('x' in lower(ppcw.phoneno)) + 1) for 5)		
		  when position('X. ' in upper(ppcw.phoneno)) > 1 then substring(ppcw.phoneno from (position('X. ' in upper(ppcw.phoneno)) + 3) for 5)
		  when position('X' in upper(ppcw.phoneno)) > 1 then ltrim(substring(ppcw.phoneno from (position('X' in upper(ppcw.phoneno)) + 1) for 5))
		  else '    ' end)::char(4) as Extension
,pe.emplstatus ::char(1) as emplstatus	
,pia.identity as agent_number	  
,case when pe.emplhiredate <> pe.emplservicedate then to_char(pe.emplservicedate,'yyyymmdd') 
      else to_char(pe.emplhiredate,'yyyymmdd')::char(8) end as adj_hire_date
,case when pe.emplstatus in ('R','T') then to_char(pe.effectivedate,'yyyymmdd') 
      else ''  end ::char(8) as termdate
,case when position('@' in coalesce(pnca.url,pncb.url)) -1 > 0 then substring(coalesce(pnca.url,pncb.url) from 1 for position('@' in coalesce(pnca.url,pncb.url)) - 1) end as user_email_id
      

from person_identity pi

left join person_identity pia
  on pia.personid = pi.personid
 and pia.identitytype = 'AgtNo'
 and current_timestamp between pia.createts and pia.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate 
 and current_timestamp between pe.createts and pe.endts  

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

left join (select personid, phoneno, phonecontacttype, effectivedate, enddate, createts, endts, rank() over (partition by personid order by effectivedate , createts ) as rank
             from person_phone_contacts where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts  
              and phonecontacttype = 'Work') ppcw on ppcw.personid = pi.personid and ppcw.rank = 1  
              
left join (select personid, positionid, scheduledhours, schedulefrequency, max(effectivedate) as effectivedate, rank() over (partition by personid order by max(effectivedate) desc) AS rank
             from pers_pos where effectivedate < enddate and current_timestamp between createts and endts
            group by personid, positionid, scheduledhours, schedulefrequency) pp on pp.personid = pi.personid and pp.rank = 1

left join (select positionid, grade, positiontitle, flsacode, max(effectivedate) as effectivedate, rank() over (partition by positionid order by max(effectivedate) desc) AS rank
             from position_desc where effectivedate < enddate and current_timestamp between createts and endts 
            group by positionid, grade, positiontitle, flsacode) pd on pd.positionid = pp.positionid and pd.rank = 1  

left join  (select personid, url, enddate, max(effectivedate) as effectivedate, max(createts) as createts, rank() over (partition by personid order by max(createts), max(effectivedate) desc) AS rank
             from person_net_contacts where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, url, enddate) pnca on pnca.personid = pi.personid and pnca.rank = 1  

left join  (select personid, url, enddate, max(effectivedate) as effectivedate, max(createts) as createts, rank() over (partition by personid order by max(createts), max(effectivedate) desc) AS rank
             from person_net_contacts where netcontacttype = 'WRK' and effectivedate < enddate and current_timestamp between createts and endts
            group by personid, url, enddate) pncb on pncb.personid = pi.personid and pncb.rank = 1                
                        

left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate 
 and current_timestamp between pl.createts and pl.endts
 
left join person_user_field_vals puf 
  on puf.personid = pi.personid
 and current_date between puf.effectivedate and puf.enddate
 and current_timestamp between puf.createts and puf.endts
 and puf.ufid = (select ufid from user_field_desc where ufname = 'AgentType'
	       		and current_date between effectivedate and enddate
			     and current_timestamp between createts and endts)  	     

left join location_codes lc 
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts			                 
                        
where pi.identitytype = 'EmpNo'
  and current_timestamp between pi.createts and pi.endts
--  and pi.personid in ('63871', '63709' ) 
  
  order by pi.identity