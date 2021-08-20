SELECT distinct
  pi.personid
,'59 ELIGIBLE NOT ENROLLED' ::varchar(50) as qsource
,'PeopleStrategy'::varchar(50) as PartnerID
,'C98599_HSA'::varchar(25) as GroupID
,lc.locationcode
,lu.value1 ::varchar(50) AS DivisionCode
,to_char(pe.effectivedate,'yyyy-mm-dd')::char(10) as effectivedate
,'9999-12-30' ::char(10) AS EndDate
,pi.identity AS SSN

,UPPER(pn.lname) ::varchar(50) AS LastName
,UPPER(pn.title) ::varchar(50) AS Suffix
,UPPER(pn.fname) ::varchar(50) AS FirstName
,UPPER(pn.mname) ::varchar(50) AS MI

,to_char(pv.birthdate,'yyyy-mm-dd') ::char(10) AS DOB
,to_char(pe.emplhiredate,'yyyy-mm-dd') ::char(10) AS DOH

,coalesce(pa.streetaddress,pab.streetaddress) ::varchar(255) AS Addr1
,coalesce(pa.streetaddress2,pab.streetaddress) ::varchar(255) AS Addr2
,coalesce(pa.city,pab.city) ::varchar(50) AS City
,coalesce(pa.stateprovincecode,pab.stateprovincecode) ::char(2) AS State
,coalesce(pa.postalcode,pab.postalcode) ::varchar(10) AS Zip
,coalesce(ppcw.phoneno,ppcb.phoneno,ppcm.phoneno,ppch.phoneno) ::char(12) AS PrimaryPhone
,ppcw.phonecomment ::varchar(5) AS Extension 
,coalesce(ppch.phoneno,ppcm.phoneno) ::varchar(12) AS SecondaryPhone
,coalesce(pncw.url,pnch.url,pnco.url)::varchar(100) AS WorkEmail

from person_identity pi 

left join edi.edi_last_update elu on elu.feedid = 'AMJ_EBC_HSA_Eligibility_Export'

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
left join person_address pa 
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

left join person_address pab 
  on pab.personid = pe.personid
 and pab.addresstype = 'BUSN'
 and current_date between pab.effectivedate and pab.enddate
 and current_timestamp between pab.createts and pab.endts
 
left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_payroll pp
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
            
left join pay_unit pu on pu.payunitid = pp.payunitid  
 
left join person_locations pl
  on pl.personid = pe.personid 
 and pl.personlocationtype = 'P'::bpchar 
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts
 
left join location_codes lc 
  on lc.locationid = pl.locationid 
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts

left join ( select lkup.lookupid,lkup.key1,lkup.value1 
              from edi.lookup lkup
              join edi.lookup_schema lkups on lkups.lookupid = lkup.lookupid and current_date between lkups.effectivedate and lkups.enddate 
             where current_date between lkup.effectivedate and lkup.enddate  and lkups.lookupname = 'AMJ HSA/FSA Eligibility Feed'
          ) lu on 1 = 1  and lc.locationcode = lu.key1  

left join person_phone_contacts ppch 
  on ppch.personid = pe.personid
 and ppch.phonecontacttype = 'Home'
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts
 
left join person_phone_contacts ppcw
  on ppcw.personid = pe.personid
 and ppcw.phonecontacttype = 'Work'
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts

left join person_phone_contacts ppcm
  on ppcm.personid = pe.personid
 and ppcm.phonecontacttype = 'Mobile'
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts

left join person_phone_contacts ppcb
  on ppcb.personid = pe.personid
 and ppcb.phonecontacttype = 'BUSN'
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts
 
left join person_net_contacts pnch
  on pnch.personid = pe.personid
 and pnch.netcontacttype = 'HomeEmail'
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.endts
 
left join person_net_contacts pncw
  on pncw.personid = pe.personid
 and pncw.netcontacttype = 'WRK'
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.endts

left join person_net_contacts pnco
  on pnco.personid = pe.personid
 and pnco.netcontacttype = 'OtherEmail'
 and current_date between pnco.effectivedate and pnco.enddate
 and current_timestamp between pnco.createts and pnco.endts
             
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus in ('A','L')
  and pe.emplpermanency = 'P'
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets::date, '2017-01-01')) ))
   
   -- exclude ee's currently enrolled in any HSA or FSA program
     
  and pe.personid not in (select distinct personid from person_bene_election where current_date between effectivedate and enddate and current_timestamp between createts and endts 
                             and benefitelection = 'E' and selectedoption = 'Y' and benefitsubclass in ('6Z','6Y'))
 