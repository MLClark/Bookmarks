select distinct
 pi.personid
,'ACTIVE EE' ::varchar(30) as qsource 
,pbe.effectivedate 
,pbe.createts

,'"'||pn.fname||' '||pn.lname||' '||COALESCE(pn.mname,'')||'"' ::varchar(60) AS full_name

,pi.identity as ssn
,'"'||pa.streetaddress||' '||COALESCE(pa.streetaddress2,'') ||'"' ::varchar(60)AS ADDR

,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip


,to_char(pv.birthdate,'mmddyyyy')::char(8) as dob
,pv.gendercode ::char(1) as gender
,coalesce(ppch.phoneno,' ') ::varchar(10) AS PrimaryPhone
,coalesce(pnch.url,pnc.url) ::varchar(100) AS WorkEmail


,to_char(pbe.effectivedate,'mmddyyyy')::char(8) as coverage_effective_date
,' ' ::char(1) as spouse_name
,' ' ::char(1) as spouse_ssn
,' ' ::char(1) as spouse_dob
,' ' ::char(1) as dep_name
,' ' ::char(1) as dep_ssn
,' ' ::char(1) as dep_dob
/*
,case when pbe.benefitsubclass = '6H' and pbe.benefitplanid in ('92','104') then 'HSA EE Hourly'
      when pbe.benefitsubclass = '6H' and pbe.benefitplanid = '95' then 'HSA Family Hourly'
      when pbe.benefitsubclass = '6Z' and pbe.benefitplanid in ('92','104') then 'HSA EE Hourly'
      when pbe.benefitsubclass = '6Z' and pbe.benefitplanid = '98' and bpd.benefitplancode = 'HSAFamSal' then 'HSA Family Salaried'
      when pbe.benefitsubclass = '6Z' and pbe.benefitplanid = '98' and bpd.benefitplancode = 'HSAEESal' then 'HSA EE Salaried'
      when pbe.benefitsubclass = '6Z' and pbe.benefitplanid = '101' then 'HSA Family Salaried'
      when pbe.benefitsubclass = '6Z' and pbe.benefitplanid = '107' then 'HSA Family Salaried'
      when pbe.benefitsubclass = '6Z' and pbe.benefitplanid = '119' then 'HSA EE Hourly'
      when pbe.benefitsubclass = '6Z' and pbe.benefitplanid = '122' then 'HSA Family Hourly' end ::varchar(30) as type_of_coverage
*/
,'HSA'   ::varchar(30) as type_of_coverage    
,to_char(pbe.coverageamount,'99999999d00') ::char(12) as annual_contrib
,to_char(cast(pbe.monthlyamount / 2 as dec(18,2)),'99999999d00') ::char(12)  as per_pay_period_contrib


from person_identity pi
--- select * from edi.edi_last_update
left join edi.edi_last_update elu on feedid = 'DAB_EBenefits_HSA_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts  

join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
        
left join person_phone_contacts ppcm
  on ppch.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile' 
 
left join person_phone_contacts ppcb
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'    
  
left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
    
left join person_net_contacts pnc 
  on pnc.personid = pi.personid 
 and pnc.netcontacttype = 'WRK'::bpchar 
 and current_date between pnc.effectivedate and pnc.enddate
 and current_timestamp between pnc.createts and pnc.enddate 
-- select * from person_net_contacts
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate  

join person_bene_election pbe
  on pbe.personid = pe.personid
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('6H','6Z')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection = 'E'
 and (pbe.effectivedate >= elu.lastupdatets::DATE 
  or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )  

left join person_bene_election pbe6h
  on pbe6h.personid = pe.personid
 and current_date between pbe6h.effectivedate and pbe6h.enddate
 and current_timestamp between pbe6h.createts and pbe6h.endts
 and pbe6h.benefitsubclass in ('6H')
 and pbe6h.selectedoption = 'Y'
 and pbe6h.benefitelection in ('E','T')
-- and (pbe6h.effectivedate >= elu.lastupdatets::DATE 
--  or (pbe6h.createts > elu.lastupdatets and pbe6h.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
 
left join person_bene_election pbe6z
  on pbe6z.personid = pe.personid
 and current_date between pbe6z.effectivedate and pbe6z.enddate
 and current_timestamp between pbe6z.createts and pbe6z.endts
 and pbe6z.benefitsubclass in ('6Z')
 and pbe6z.selectedoption = 'Y'
 and pbe6z.benefitelection in ('E','T') 
 --and (pbe6z.effectivedate >= elu.lastupdatets::DATE 
  --or (pbe6z.createts > elu.lastupdatets and pbe6z.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) )  
 
left JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts   

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('L','A')
 -- and pe.personid = '2720'


UNION

select distinct
 pi.personid
,'TERMED EE' ::varchar(30) as qsource 

,pe.effectivedate 
,pe.createts

,'"'||pn.fname||' '||pn.lname||' '||COALESCE(pn.mname,'')||'"' ::varchar(60) AS full_name

,pi.identity as ssn
,'"'||pa.streetaddress||' '||COALESCE(pa.streetaddress2,' ') ||'"' ::varchar(60) AS ADDR

,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip


,to_char(pv.birthdate,'mmddyyyy')::char(8) as dob
,pv.gendercode ::char(1) as gender


,coalesce(ppcw.phoneno,ppcb.phoneno,ppcm.phoneno,ppch.phoneno,'no phones loaded') ::varchar(10) AS PrimaryPhone
,coalesce(pnch.url,pnc.url) ::varchar(100) AS WorkEmail


,to_char(pbe.effectivedate,'mmddyyyy')::char(8) as coverage_effective_date
,' ' ::char(1) as spouse_name
,' ' ::char(1) as spouse_ssn
,' ' ::char(1) as spouse_dob
,' ' ::char(1) as dep_name
,' ' ::char(1) as dep_ssn
,' ' ::char(1) as dep_dob
,'HSA'   ::varchar(30) as type_of_coverage    
,to_char(pbe.coverageamount,'99999999d00') ::char(12) as annual_contrib
,to_char(cast(pbe.monthlyamount / 2 as dec(18,2)),'99999999d00') ::char(12) as per_pay_period_contrib


from person_identity pi

LEFT join edi.edi_last_update elu on feedid = 'DAB_EBenefits_HSA_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe
  on pbe.personid = pe.personid
 and current_timestamp between pbe.createts and pbe.endts
 and pbe.benefitsubclass in ('6H','6Z')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E','T')
 and (pbe.effectivedate >= elu.lastupdatets::DATE 
   or (pbe.createts > elu.lastupdatets and pbe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 
 
left join person_bene_election pbe6h
  on pbe6h.personid = pe.personid
 and current_timestamp between pbe6h.createts and pbe6h.endts
 and pbe6h.benefitsubclass in ('6H')
 and pbe6h.selectedoption = 'Y'
 and pbe6h.benefitelection in ('E','T')
 
left join person_bene_election pbe6z
  on pbe6z.personid = pe.personid
 and current_timestamp between pbe6z.createts and pbe6z.endts
 and pbe6z.benefitsubclass in ('6Z')
 and pbe6z.selectedoption = 'Y'
 and pbe6z.benefitelection in ('E','T') 
 
join person_names pn
  on pn.personid = pe.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_address pa
  on pa.personid = pe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 
 
join person_vitals pv
  on pv.personid = pe.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
  
left join person_phone_contacts ppch 
  on ppch.personid = pi.personid
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts 
 and ppch.phonecontacttype = 'Home'
left join person_phone_contacts ppcw
  on ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts  
 and ppcw.phonecontacttype = 'Work'   
left join person_phone_contacts ppcb
  on ppcb.personid = pi.personid
 and current_date between ppcb.effectivedate and ppcb.enddate
 and current_timestamp between ppcb.createts and ppcb.endts 
 and ppcb.phonecontacttype = 'BUSN'      
left join person_phone_contacts ppcm
  on ppch.personid = pi.personid
 and current_date between ppcm.effectivedate and ppcm.enddate
 and current_timestamp between ppcm.createts and ppcm.endts 
 and ppcm.phonecontacttype = 'Mobile'         
  
left join person_net_contacts pnc 
  on pnc.personid = pi.personid 
 and pnc.netcontacttype = 'WRK'::bpchar 
 and current_date between pnc.effectivedate and pnc.enddate
 and current_timestamp between pnc.createts and pnc.enddate 
-- select * from person_net_contacts
left join person_net_contacts pnch 
  on pnch.personid = pi.personid 
 and pnch.netcontacttype = 'HomeEmail'::bpchar 
 and current_date between pnch.effectivedate and pnch.enddate
 and current_timestamp between pnch.createts and pnch.enddate  


JOIN benefit_plan_desc bpd  
  on bpd.benefitsubclass = pbe.benefitsubclass
 and bpd.benefitplanid = pbe.benefitplanid
 --AND current_date between bpd.effectivedate and bpd.enddate
 AND current_timestamp between bpd.createts and bpd.endts   
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'T'
  and (pe.effectivedate >= elu.lastupdatets::DATE 
   or (pe.createts > elu.lastupdatets and pe.effectivedate < coalesce(elu.lastupdatets, '2017-01-01')) ) 


ORDER BY 1      