select 
 pi.personid
,'MEMBER CONTACT INFO - RTYPE 240' ::varchar(40) as qsource
,'240' ::char(3) as recordtype
,' '   ::char(1) as filler_4
,'805911' ::char(6) as contract_number
,' ' ::char(1) as filler_11
,pi.identity ::char(9) as employee_id_number
,' ' ::char(1) as filler_21
,pncw.url ::char(75) as work_email
,' ' ::char(1) as home_email_75_bytes
,ppcw.phoneno ::char(17) as work_phone
,' ' ::char(7) as work_ext
,ppch.phoneno ::char(17) as home_phone
,' ' ::char(7) as home_ext
,ppcm.phoneno ::char(18) as cell_phone
,' ' ::char(1) as filler_238


from person_identity pi

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
 
LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts 
 
left JOIN person_phone_contacts ppch 
  ON ppch.personid = pi.personid
 AND current_date between ppch.effectivedate and ppch.enddate
 AND current_timestamp between ppch.createts and ppch.endts 
 AND ppch.phonecontacttype = 'Home'
left JOIN person_phone_contacts ppcw 
  ON ppcw.personid = pi.personid
 AND current_date between ppcw.effectivedate and ppcw.enddate
 AND current_timestamp between ppcw.createts and ppcw.endts 
 AND ppcw.phonecontacttype = 'Work'   
left JOIN person_phone_contacts ppcb 
  ON ppcb.personid = pi.personid
 AND current_date between ppcb.effectivedate and ppcb.enddate
 AND current_timestamp between ppcb.createts and ppcb.endts 
 AND ppcb.phonecontacttype = 'BUSN'      
left JOIN person_phone_contacts ppcm 
  ON ppcm.personid = pi.personid
 AND current_date between ppcm.effectivedate and ppcm.enddate
 AND current_timestamp between ppcm.createts and ppcm.endts 
 AND ppcm.phonecontacttype = 'Mobile'  
 
join (select personid, max(effectivedate) as effectivedate, rank() over(partition by personid order by max(effectivedate) desc) as rank
        from person_deduction_setup where etvid in  ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ') 
         and current_date between effectivedate and enddate
         and current_timestamp between createts and endts group by personid) pds on pds.personid = pi.personid

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus in ('A','L') or (pe.emplstatus in ('T','R') and current_date - interval '60 days' <= pe.effectivedate))