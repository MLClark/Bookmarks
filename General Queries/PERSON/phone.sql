/*
Dependent 
Home      
Mobile    
Work      
C-WK      
*/
select * from person_phone_contacts;
select phonecontacttype from person_phone_contacts group by 1;

select 
 pi.personid
,ppcH.phoneno ::char(15) as homephone
,ppcW.phoneno ::char(15) as workphone
,substring(ppcW.phoneno,11,5) ::char(5) as workphone_ext
,regexp_replace(coalesce(ppcw.phoneno,ppcb.phoneno,ppcm.phoneno,ppch.phoneno,'no phones'), '[^0-9]', '', 'g')
,coalesce(ppcw.phoneno,ppcb.phoneno,ppcm.phoneno,ppch.phoneno,'no phones') ::varchar(10) AS PrimaryPhone
from person_identity PI 

join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and ppch.phonecontacttype = 'Home'  
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.effectivedate - interval '1 day' <> ppch.enddate
 
join person_phone_contacts ppcw 
  on ppcw.personid = pi.personid
 and ppcw.phonecontacttype = 'Work'     
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 
 and ppcw.effectivedate - interval '1 day' <> ppcw.enddate
 
join person_phone_contacts ppcb 
  on ppcb.personid = pi.personid
 and ppcb.phonecontacttype = 'BUSN'    
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.effectivedate - interval '1 day' <> ppcb.enddate
    
join person_phone_contacts ppcm 
  on ppcm.personid = pi.personid
 and ppcm.phonecontacttype = 'Mobile'     
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.effectivedate - interval '1 day' <> ppcm.enddate
 
 ;
--select regexp_replace('(12s3)-456-6356(a+sdk', '[^0-9]', '', 'g');