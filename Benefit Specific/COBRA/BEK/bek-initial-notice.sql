select distinct
 pi.personid
,'"MS Clinical Services, LLC dba MedSource"' ::varchar(100) as company_code
,' ' ::char(1) as dept_div
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(11) as ssn
,pn.fname ::varchar(50) as fname
,pn.lname ::varchar(50) as lname
,pn.mname ::char(1) as mname
,'"'||pa.streetaddress||'"'::varchar(50) as addr1
,'"'||pa.streetaddress2||'"' ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(5) as zip
,to_char(pv.birthdate,'mm/dd/yyyy')::char(10) as dob
,to_char(pe.effectivedate,'mm/dd/yyyy')::char(10) as doh
,to_char(pbeedt.effectivedate,'mm/dd/yyyy')::char(10) as edoc
,to_char(current_date,'mm/dd/yyyy')::char(10) as file_date
,rtrim(ltrim(pncw.url)) ::varchar(100) as email 

 
from person_identity pi
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_bene_election pbe 
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('10','11','14','60')
 and pbe.selectedoption = 'Y' 
  
left join 

(SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
        RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
        FROM person_bene_election pc1
        LEFT JOIN edi.edi_last_update elu ON elu.feedid = 'BEK_ProBenefits_Initial_Notice_Export'
        WHERE enddate > effectivedate 
          AND current_timestamp BETWEEN createts AND endts
          and benefitsubclass in ('10','11','14','60')
          and benefitelection = 'E'
          and selectedoption = 'Y'
        GROUP BY personid ) as pbeedt on pbeedt.personid = pe.personid and pbeedt.rank = 1   
          
join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

LEFT JOIN person_net_contacts pncw 
  ON pncw.personid = pi.personid 
 AND pncw.netcontacttype = 'WRK'::bpchar 
 AND current_date between pncw.effectivedate and pncw.enddate
 AND current_timestamp between pncw.createts and pncw.endts 

LEFT JOIN person_net_contacts pnch
  ON pnch.personid = pi.personid 
 AND pnch.netcontacttype = 'HomeEmail'::bpchar 
 AND current_date between pnch.effectivedate and pnch.enddate
 AND current_timestamp between pnch.createts and pnch.endts 

LEFT JOIN person_net_contacts pnco
  ON pnco.personid = pi.personid 
 AND pnco.netcontacttype = 'Other'::bpchar 
 AND current_date between pnco.effectivedate and pnco.enddate
 AND current_timestamp between pnco.createts and pnco.endts   
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus in ('A')
  and pbe.benefitelection in ('E') 

  order by 1