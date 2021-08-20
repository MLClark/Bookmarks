select distinct
 pi.personid as group_personid
,lkup.value1 as client_tasc_id -- 1
,pie.identity  as indv_tasc_id --2 *File must contain Employee ID or Individual TASC ID to identify Participant Must match value found in Universal Benefit Account
,pie.identity  as employee_id --3 *If unable to provide the Individual TASC ID then Employee ID is required. Employee ID is required for new enrollees.
,pn.lname as lname --4
,pn.fname as fname --5
,pn.mname as mname --6
,null as nickname --7
,case when position('@' in coalesce(pncw.url,pnch.url,pnco.url)) <> 0 then  coalesce(pncw.url,pnch.url,pnco.url) else null end as email --8
,replace(pa.streetaddress,',','') ::varchar(50) as addr1 --9
,replace(pa.streetaddress2,',','') ::varchar(50) as addr2 --10
,pa.city ::varchar(30) as city --11
,pa.stateprovincecode ::char(2) as state --12
,pa.postalcode ::char(5) as zip -- 13
,substring(replace(pa.postalcode,'-','') from 6 for 4) ::char(4) as zip_plus4 --14
,pa.countrycode ::char(2) as country --15
,'Primary' ::char(8) as addresstype --16

,to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as dob --21
,to_char(pv.deathdate,'mm/dd/yyyy') ::char(10) as dod --22 
,case when pv.gendercode = 'M' then 'Male'
      when pv.gendercode = 'F' then 'Female' else 'Unknown' end ::char(10) as gender --23
,to_char(greatest(pe.emplhiredate,pe.empllasthiredate),'mm/dd/yyyy') ::char(10) as hire_date --24

,case when pp.schedulefrequency = 'W' then 'Weekly'
      when pp.schedulefrequency = 'B' then 'Bi Weekly'
      when pp.schedulefrequency = 'S' then 'Semi-Monthly'
      when pp.schedulefrequency = 'M' then 'Monthly'
      else null end ::char(15) as payroll_schedule_name
      
,'' as division
,'' as subdivision
,'' ::char(15) as class 


      
,case when pe.emplstatus in ('T') then to_char(greatest(pe.paythroughdate,pe.effectivedate),'mm/dd/yyyy') else null end ::char(10) as termdate --29
,case when pe.emplstatus in ('R') then to_char(greatest(pe.paythroughdate,pe.effectivedate),'mm/dd/yyyy') else null end ::char(10) as retired --30
,case when pe.emplstatus in ('L') then to_char(pe.effectivedate,'mm/dd/yyyy') else null end ::char(10) as loa_start_date --31
,case when pe.emplstatus in ('L') then to_char(pe.enddate,'mm/dd/yyyy') else null end ::char(10) as loa_end_date --32
,case when pe.emplstatus in ('L') and pe.emplevent in ('Leave') then true 
      when pe.emplstatus in ('L') and pe.emplevent in ('LOA w/o Pa') then false 
      else null end as loa_w_benefits 
,'Unlimited' ::char(10)  as health_plan_member_id --34
,null ::char(10) as hdhp_start_date --35
,null ::char(10) as hdhp_end_date --36


,pch.phoneno
,pch.phonecontacttype
,pch.rank as key_rank 
,elu.lastupdatets

from person_identity pi

join edi.edi_last_update elu on elu.feedid = 'TASC_FSA_Census_File_Export'

left join pers_pos pp 
  on pp.personid = pi.personid 
 and current_date between pp.effectivedate and pp.enddate 
 and current_timestamp between pp.createts and pp.endts
 
join person_identity pie 
  on pie.personid = pp.personid 
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_names pn
  on pn.personid = pp.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

left join person_net_contacts pncw
  on pncw.personid = pp.personid
 and pncw.netcontacttype = 'WRK'::bpchar
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate

left join person_net_contacts pnch
  on pnch.personid = pp.personid
 and pnch.netcontacttype = 'HomeEmail'::bpchar
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate

left join person_net_contacts pnco
  on pnco.personid = pp.personid
 and pnco.netcontacttype = 'OtherEmail'::bpchar
 and current_date between pnco.effectivedate and pnco.enddate
 and current_timestamp between pnco.createts and pnco.enddate 

left join person_address pa
  on pa.personid = pp.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join (select personid, phonecontacttype, case when substring (phoneno from 4 for 1) = '-' then phoneno else substring (phoneno from 1 for 3) || '-' || substring (phoneno from 4 for 3) || '-' || substring (phoneno from 7 for 4) end as phoneno, RANK() OVER (PARTITION BY personid ORDER BY max(createts) DESC) AS RANK
             from person_phone_contacts where phonecontacttype in ('Work','Mobile','Home') and current_date between effectivedate and enddate and current_timestamp between createts and endts 
             group by personid, phonecontacttype, phoneno order by personid, rank
           ) pch on pch.personid = pp.personid

left join (select personid, case when substring (phoneno from 4 for 1) = '-' then phoneno
             else substring (phoneno from 1 for 3) || '-' || substring (phoneno from 4 for 3) || '-' || substring (phoneno from 7 for 4) end as phoneno 
             from person_phone_contacts where phonecontacttype = 'Home' and current_date between effectivedate and enddate and current_timestamp between createts and endts
           ) ppch on ppch.personid = pp.personid   

left join (select personid, case when substring (phoneno from 4 for 1) = '-' then phoneno
             else substring (phoneno from 1 for 3) || '-' || substring (phoneno from 4 for 3) || '-' || substring (phoneno from 7 for 4) end as phoneno 
             from person_phone_contacts where phonecontacttype = 'Work' and current_date between effectivedate and enddate and current_timestamp between createts and endts
           ) ppcw on ppcw.personid = pp.personid             

left join (select personid, case when substring (phoneno from 4 for 1) = '-' then phoneno
             else substring (phoneno from 1 for 3) || '-' || substring (phoneno from 4 for 3) || '-' || substring (phoneno from 7 for 4) end as phoneno 
             from person_phone_contacts where phonecontacttype = 'Mobile' and current_date between effectivedate and enddate and current_timestamp between createts and endts
           ) ppcm on ppcm.personid = pp.personid         

left join person_vitals pv
  on pv.personid = pp.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_employment pe
  on pe.personid = pp.personid 
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

left join (select personid, compamount, increaseamount, compevent, frequencycode, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_compensation where (current_date between effectivedate and enddate or (effectivedate > current_date and enddate > effectivedate)) and current_timestamp between createts and endts
            group by personid, compamount, increaseamount, compevent, frequencycode ) as pc on pc.personid = pe.personid and pc.rank = 1   
 
left join ( select lkups.lookupname, lkups.lookupid,lkup.lookupid,lkup.key1,lkup.value1
         from edi.lookup lkup
         join edi.lookup_schema lkups
           on lkups.lookupid = lkup.lookupid
          and current_date between lkups.effectivedate and lkups.enddate
        where current_date between lkup.effectivedate and lkup.enddate
          and lkups.lookupname in ('TASC_FSA_Exports') 
      ) lkup on 1=1 and lkup.key1 = 'ClientTASCID'
  
where pi.identitytype = 'SSN' 
  and current_timestamp between pi.createts and pi.endts 
  and ((pe.emplstatus in ('R','T') and pe.effectivedate >= elu.lastupdatets) 
   or  (pe.emplstatus not in ('R','T')))
