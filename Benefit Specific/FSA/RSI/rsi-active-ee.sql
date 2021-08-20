select distinct
 pi.personid
,'0' ::char(1) as sort_seq
,'ACTIVE EE' ::varchar(30) as qsource  
,replace(pu.employertaxid,'-','')::varchar(20) as client_federal_id 
,pi.identity ::varchar(20) as participant_id
,'1'::char(1) as participant_id_type
,pn.fname::varchar(30) as fname
,pn.mname::char(1) as mname
,ltrim(pn.lname)::varchar(30) as lname
,pa.streetaddress ::varchar(30) as addr1
,pa.streetaddress2 ::varchar(30) as addr2
,pa.city ::varchar(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(16) as zip
,coalesce(pncw.url,pnch.url) ::varchar(50) AS email
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,coalesce(ppch.phoneno,ppcw.phoneno,ppcm.phoneno,ppcb.phoneno) ::varchar(16) AS phone 
,case when pu.frequencycode in ('S','BM') then 'B' else pu.frequencycode end ::char(1) as payroll_mode
,to_char(coalesce(pbefsa.effectivedate,pbedfsa.effectivedate),'mm/dd/yyyy')::char(10) as effectivedate
,replace(ro.org2desc,',','')::varchar(30) as location
,case when pbefsa.benefitsubclass  = '60' then '2'
      when pbedfsa.benefitsubclass = '61' then '1' end ::char(1) as plan_type_id
,to_char(coalesce(pbefsa.effectivedate,pbedfsa.effectivedate),'mm/dd/yyyy'
      ELSE to_char(pbe.effectivedate,'mm/dd/yyyy') 
      END 				AS "Enrollment Effective Date"      
 
from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
  
join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitelection <> 'W'
 and pbe.selectedoption = 'Y'
 and pbe.benefitsubclass in ('60','61')
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
 
left join person_bene_election pbefsa
  on pbefsa.personid = pbe.personid 
 and pbefsa.benefitelection <> 'W'
 and pbefsa.selectedoption = 'Y'
 and pbefsa.benefitsubclass in ('60')
 and current_date between pbefsa.effectivedate and pbefsa.enddate
 and current_timestamp between pbefsa.createts and pbefsa.endts  
 and pbefsa.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('60') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  

left join person_bene_election pbedfsa
  on pbedfsa.personid = pbe.personid 
 and pbedfsa.benefitelection <> 'W'
 and pbedfsa.selectedoption = 'Y'
 and pbedfsa.benefitsubclass in ('61')
 and current_date between pbedfsa.effectivedate and pbedfsa.enddate
 and current_timestamp between pbedfsa.createts and pbedfsa.endts 
 and pbedfsa.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate) 
  
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

left join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
 
left join person_phone_contacts ppch 
  on ppch.personid = pe.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
        
left join person_phone_contacts ppcm
  on ppch.personid = pe.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile' 
 
left join person_phone_contacts ppcb
  on ppcb.personid = pe.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'    
  
left join person_phone_contacts ppcw
  on ppcw.personid = pe.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
    
left join person_net_contacts pncw 
  on pncw.personid = pe.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate 

left join person_net_contacts pnch 
  on pnch.personid = pe.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate   
 
left join person_payroll ppay
  on ppay.personid = pe.personid
 and current_date between ppay.effectivedate and ppay.enddate
 and current_timestamp between ppay.createts and ppay.endts
 
left join pay_unit pu on pu.payunitid = ppay.payunitid 

left join pers_pos pp
  on pp.personid = pe.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
LEFT JOIN pos_org_rel por
  on por.positionid = pp.positionid
 AND current_date between por.effectivedate AND por.enddate
 AND current_timestamp between por.createts AND por.endts
 AND por.posorgreltype = 'Member'

LEFT JOIN cognos_orgstructure ro
  ON ro.org1id = por.organizationid  

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'