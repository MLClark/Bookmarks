SELECT distinct
 pi.personid

,'PeopleStrategy'::varchar(50) as PartnerID
,'C98599_HSA'::varchar(25) as GroupID
, lc.locationcode
,CASE lc.locationcode
   WHEN 'COR'  THEN 'COR'
   WHEN 'ATL'  THEN 'ATL'
   WHEN 'BET'  THEN 'DC'
   WHEN 'HOU'  THEN 'HOU'
   WHEN 'CHI'  THEN 'CHI'
   WHEN 'DEN'  THEN 'DEN'
   WHEN 'PHI'  THEN 'PHI'
   WHEN 'SFR'  THEN 'SF'
   WHEN 'WAS'  THEN 'DC'
   WHEN 'CNS'  THEN 'REM'
   WHEN 'BGL'  THEN 'DEN'
   WHEN 'CHIS' THEN 'CHI'
   WHEN 'PHO'  THEN 'PHX'
   WHEN 'SDG'  THEN 'SD'
   WHEN 'REM'  THEN 'CCG'
   WHEN 'CCG'  THEN 'CCG'
   WHEN 'DAL'  THEN 'HOU'
   --ELSE lc.locationcode END ::varchar(50) AS DivisionCode
   ELSE ' ' END ::varchar(50) AS DivisionCode
,to_char(coalesce(pbehsa.effectivedate,pbehsacu.effectivedate),'YYYY-mm-dd')::char(10) as effectivedate
,'9999-12-30' ::char(10) AS EndDate
,replace(pi.identity,'-','')::char(9) AS SSN

,UPPER(pn.lname) ::varchar(50) AS LastName
,UPPER(pn.title) ::varchar(50) AS Suffix
,UPPER(pn.fname) ::varchar(50) AS FirstName
,UPPER(pn.mname) ::varchar(50) AS MI

,to_char(pv.birthdate,'YYYY-MM-DD') ::char(10) AS DOB
,to_char(PE.emplhiredate,'YYYY-MM-DD') ::char(10) AS DOH

,pa.streetaddress ::varchar(255) AS Addr1
,pa.streetaddress2 ::varchar(255) AS Addr2
,pa.city ::varchar(50) AS City
,pa.stateprovincecode ::char(2) AS State
,pa.postalcode ::varchar(10) AS Zip
,coalesce(ppcw.phoneno,ppcb.phoneno,ppcm.phoneno,ppch.phoneno) ::char(12) AS PrimaryPhone
,ppcw.phonecomment ::varchar(5) AS Extension 
,coalesce(ppch.phoneno,ppcm.phoneno) ::varchar(12) AS SecondaryPhone
,coalesce(pncw.url,pnch.url,pnco.url)::varchar(100) AS WorkEmail

from person_identity pi

left join person_names pn 
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts  and pn.endts
 and pn.nametype = 'Legal'
 
left join person_address pa 
  on pa.personid = pi.personid 
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join person_payroll pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

left join pay_unit pu 
  on pu.payunitid = pp.payunitid

join person_bene_election pbe 
  on pbe.personid = pi.personid  
 and pbe.benefitsubclass in ( '6Y','6Z' )
 and pbe.selectedoption = 'Y'  
 and pbe.effectivedate < pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

------------------------------     
----- lm = Employee Life -----
------------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('6Y') and benefitelection <> 'W' and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent ) as pbehsacu on pbehsacu.personid = pbe.personid and pbehsacu.rank = 1  
----------------------------
----- ls = Spouse Life -----
----------------------------
left join (SELECT personid,coverageamount,createts,personbeneelectionevent, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election WHERE effectivedate < enddate AND current_timestamp BETWEEN createts AND endts and benefitsubclass in ('6Z') and benefitelection <> 'W' and selectedoption = 'Y'
            GROUP BY personid,coverageamount,createts,personbeneelectionevent ) as pbehsa on pbehsa.personid = pbe.personid and pbehsa.rank = 1     

/*
left join person_bene_election pbehsacu
  on pbehsacu.personid = pbe.personid
 and pbehsacu.benefitsubclass = '6Y'
 and pbehsacu.benefitelection = 'E' 
 and pbehsacu.selectedoption = 'Y'
 and pbehsacu.effectivedate < pbehsacu.enddate
 and current_timestamp between pbehsacu.createts and pbehsacu.endts

left join person_bene_election pbehsa
  on pbehsa.personid = pbe.personid
 and pbehsa.benefitsubclass = '6Z'
 and pbehsa.benefitelection = 'E' 
 and pbehsa.selectedoption = 'Y'
 and pbehsa.effectivedate < pbehsa.enddate
 and current_timestamp between pbehsa.createts and pbehsa.endts 
*/ 
                             
left join person_vitals pv 
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_employment pe 
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts  

left join person_phone_contacts ppch 
 on ppch.personid = pi.personid
 and ppch.phonecontacttype = 'Home' 
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 

left join person_phone_contacts ppcw 
  on ppcw.personid = pi.personid
 and ppcw.phonecontacttype = 'Work'   
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 

left join person_phone_contacts ppcb 
  on ppcb.personid = pi.personid
 and ppcb.phonecontacttype = 'BUSN'      
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 

left join person_phone_contacts ppcm 
  on ppcm.personid = pi.personid
 and ppcm.phonecontacttype = 'Mobile'       
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
   
left join person_locations pl
  on pl.personid = pi.personid 
 and pl.personlocationtype = 'P'::bpchar 
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts
   
left join location_codes lc 
  on lc.locationid = pl.locationid 
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts
 
left join (select personid, url, enddate, max(effectivedate) as effectivedate, max(endts) as endts,  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
             from person_net_contacts where netcontacttype = 'WRK' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, url, enddate) pncw on pncw.personid = pe.personid and pncw.rank = 1 
            
left join (select personid, url, enddate, max(effectivedate) as effectivedate, max(endts) as endts,  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
             from person_net_contacts where netcontacttype = 'HomeEmail' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, url, enddate) pnch on pnch.personid = pe.personid and pnch.rank = 1             
 
left join (select personid, url, enddate, max(effectivedate) as effectivedate, max(endts) as endts,  RANK() OVER (PARTITION BY personid ORDER BY max(endts) DESC) AS RANK
             from person_net_contacts where netcontacttype = 'OtherEmail' and current_date between effectivedate and enddate and current_timestamp between createts and endts
            group by personid, url, enddate) pnco on pnco.personid = pe.personid and pnco.rank = 1    

join edi.edi_last_update elu on elu.feedID = 'AMJ_EBC_HSA_Eligibility_Export'
---- lastupdatets only used as a jumping off point. This file is a full file of active ee's with current hsa benefits  

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('R','T')  -- terms should not be on the file
  and pbe.benefitelection = 'E' 
  
  --and pe.personid = '906'
  --- use OE as parm for open enrollment processing
  --- use CO as parm for change only processing (default)
  and case when ? = 'OE' then pbe.effectivedate >= date_trunc('year', current_date + interval '1 year') 
           when ? = 'CO' then pbe.effectivedate < pbe.enddate 
                         and (pbe.effectivedate >= elu.lastupdatets::DATE or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
           end

ORDER BY personid
