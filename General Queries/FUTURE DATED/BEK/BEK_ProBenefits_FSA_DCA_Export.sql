select distinct
 pi.personid
,'FSA' ::varchar(30) as sourceseq
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn
,pn.fname ::varchar(100) as fname
,pn.lname ::varchar(100) as lname
,pn.mname ::char(1) as mname
,'S' ::char(1) as payroll_freq
,to_char(current_date,'mm/dd/yyyy') ::char(10) as payroll_file_date
,to_char(pbefsa.effectivedate,'mm/dd/yyyy') ::char(10) as effective_doc
,case when pbefsa.benefitsubclass    = '60' and pbefsa.benefitplanid = '36' then 'Health FSA'
      when pbefsa.benefitsubclass    = '60' and pbefsa.benefitplanid = '33' then 'Health FSA - Limited'
      else ' ' end ::varchar(20) as ded_code
,'S' ::char(1) as ded_freq   
,case when pbefsa.benefitsubclass    = '60' then cast(ppd.etv_amount as dec(18,2))
      end as ded_amount
,'B' ::char(1) as employer_contrib_freq
,case when pbefsa.benefitsubclass    = '60' then cast(poc.employercost as dec(18,2))
      end as employer_contrib
,case when pbefsa.benefitsubclass  = '60' then cast(pbefsa.coverageamount as dec(18,2))    
      end as annual_election 
,' ' ::char(1) as dept_div
,to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as dob      
,to_char(pe.empllasthiredate,'mm/dd/yyyy') ::char(10) as doh
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date
,case when pe.emplstatus = 'T' then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as paythru_date
,case when pe.emplstatus = 'T' then 
 to_char(pbefsa.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as expir_date 
,pp.positionid
,'"'||pd.positiontitle||'"' ::varchar(100) as job_title
,cast(pc.compamount as dec(18,2)) as salary
,' ' ::char(1) as ownership_pct
,'"'||pa.streetaddress||'"' ::varchar(50) as addr1
,'"'||pa.streetaddress2||'"' ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(11) as zip
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(200) as email
,'"MS Clinical Services, LLC dba MedSource"' ::varchar(50) as company_code

from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 AND (CURRENT_DATE between pbe.effectivedate AND pbe.enddate 
  or (pbe.effectivedate > current_date and pbe.enddate > pbe.effectivedate AND extract(year from pbe.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbe.createts AND pbe.endts

left join person_bene_election pbefsa
  on pbefsa.personid = pbe.personid
 and pbefsa.benefitsubclass in ('60')
 and pbefsa.selectedoption = 'Y'
 and pbefsa.benefitelection in ('E')
 AND (CURRENT_DATE between pbefsa.effectivedate AND pbefsa.enddate 
  or (pbefsa.effectivedate > current_date and pbefsa.enddate > pbefsa.effectivedate AND extract(year from pbefsa.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbefsa.createts AND pbefsa.endts

left join pspay_payment_detail ppd
  on ppd.personid = pbe.personid
 and ppd.etv_id = 'VBA'
 and ppd.check_date = ?::date
 
LEFT JOIN personbenoptioncostl poc 
  ON poc.personid = pbe.personid
 AND poc.personbeneelectionpid = pbe.personbeneelectionpid
 AND poc.costsby = 'P'   
 AND poc.employeerate > 0  
 
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

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  
union

select distinct
 pi.personid
,'Dep FSA' ::varchar(30) as sourceseq
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn
,pn.fname ::varchar(100) as fname
,pn.lname ::varchar(100) as lname
,pn.mname ::char(1) as mname
,'S' ::char(1) as payroll_freq
,to_char(current_date,'mm/dd/yyyy') ::char(10) as payroll_file_date
,to_char(pbefsad.effectivedate,'mm/dd/yyyy') ::char(10) as effective_doc
,case when pbefsad.benefitsubclass   = '61' then 'Dep FSA'
      else ' ' end ::varchar(20) as ded_code
,'S' ::char(1) as ded_freq   
,case when pbefsad.benefitsubclass   = '61' then cast(coalesce(ppd.etv_amount,pbefsad.monthlyamount  / 2 ) as dec(18,2))
      end as ded_amount
,'B' ::char(1) as employer_contrib_freq
,case when pbefsad.benefitsubclass   = '61' then cast(coalesce(poc.employercost,pbefsad.monthlyemployeramount  / 2 ) as dec(18,2))
      end as employer_contrib
,case when pbefsad.benefitsubclass = '61' then cast(pbefsad.coverageamount as dec(18,2))     
      end as annual_election 
,' ' ::char(1) as dept_div
,to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as dob      
,to_char(pe.empllasthiredate,'mm/dd/yyyy') ::char(10) as doh
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date
,case when pe.emplstatus = 'T' then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as paythru_date
,case when pe.emplstatus = 'T' then 
 to_char(pbefsad.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as expir_date 
,pp.positionid
,'"'||pd.positiontitle||'"' ::varchar(100) as job_title
,cast(pc.compamount as dec(18,2)) as salary
,' ' ::char(1) as ownership_pct
,'"'||pa.streetaddress||'"' ::varchar(50) as addr1
,'"'||pa.streetaddress2||'"' ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(11) as zip
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(200) as email
,'"MS Clinical Services, LLC dba MedSource"' ::varchar(50) as company_code

from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('61')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 AND (CURRENT_DATE between pbe.effectivedate AND pbe.enddate 
  or (pbe.effectivedate > current_date and pbe.enddate > pbe.effectivedate AND extract(year from pbe.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbe.createts AND pbe.endts

left join person_bene_election pbefsad
  on pbefsad.personid = pbe.personid
 and pbefsad.benefitsubclass in ('61')
 and pbefsad.selectedoption = 'Y'
 and pbefsad.benefitelection in ('E')
 AND (CURRENT_DATE between pbefsad.effectivedate AND pbefsad.enddate 
  or (pbefsad.effectivedate > current_date and pbefsad.enddate > pbefsad.effectivedate AND extract(year from pbefsad.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbefsad.createts AND pbefsad.endts  

left join pspay_payment_detail ppd
  on ppd.personid = pbe.personid
 and ppd.etv_id = 'VBB'
 and ppd.check_date = ?::date
 
LEFT JOIN personbenoptioncostl poc 
  ON poc.personid = pbe.personid
 AND poc.personbeneelectionpid = pbe.personbeneelectionpid
 AND poc.costsby = 'P'   
 AND poc.employeerate > 0  
 
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

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  
union

select distinct
 pi.personid
,'Med' ::varchar(30) as sourceseq
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn
,pn.fname ::varchar(100) as fname
,pn.lname ::varchar(100) as lname
,pn.mname ::char(1) as mname
,'S' ::char(1) as payroll_freq
,to_char(current_date,'mm/dd/yyyy') ::char(10) as payroll_file_date
,to_char(pbemed.effectivedate,'mm/dd/yyyy') ::char(10) as effective_doc
,case when pbemed.benefitsubclass    = '10' then 'Medical'
      else ' ' end ::varchar(20) as ded_code
,'S' ::char(1) as ded_freq   
,case when pbemed.benefitsubclass    = '10' then cast(coalesce(ppd.etv_amount,pbemed.monthlyamount  / 2 ) as dec(18,2))
      end as ded_amount
,'B' ::char(1) as employer_contrib_freq
,case when pbemed.benefitsubclass    = '10' then cast(coalesce(poc.employercost,pbemed.monthlyemployeramount  / 2 ) as dec(18,2))
      end as employer_contrib
,0 as annual_election 
,' ' ::char(1) as dept_div
,to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as dob      
,to_char(pe.empllasthiredate,'mm/dd/yyyy') ::char(10) as doh
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date
,case when pe.emplstatus = 'T' then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as paythru_date
,case when pe.emplstatus = 'T' then 
 to_char(pbemed.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as expir_date 
,pp.positionid
,'"'||pd.positiontitle||'"' ::varchar(100) as job_title
,cast(pc.compamount as dec(18,2)) as salary
,' ' ::char(1) as ownership_pct
,'"'||pa.streetaddress||'"' ::varchar(50) as addr1
,'"'||pa.streetaddress2||'"' ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(11) as zip
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(200) as email
,'"MS Clinical Services, LLC dba MedSource"' ::varchar(50) as company_code

from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('10')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 AND (CURRENT_DATE between pbe.effectivedate AND pbe.enddate 
  or (pbe.effectivedate > current_date and pbe.enddate > pbe.effectivedate AND extract(year from pbe.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbe.createts AND pbe.endts

left join person_bene_election pbemed
  on pbemed.personid = pbe.personid
 and pbemed.benefitsubclass in ('10')
 and pbemed.selectedoption = 'Y'
 and pbemed.benefitelection in ('E')
 AND (CURRENT_DATE between pbemed.effectivedate AND pbemed.enddate 
  or (pbemed.effectivedate > current_date and pbemed.enddate > pbemed.effectivedate AND extract(year from pbemed.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbemed.createts AND pbemed.endts 
 
left join pspay_payment_detail ppd
  on ppd.personid = pbe.personid
 and ppd.etv_id = 'VBC'
 and ppd.check_date = ?::date
 
LEFT JOIN personbenoptioncostl poc 
  ON poc.personid = pbe.personid
 AND poc.personbeneelectionpid = pbe.personbeneelectionpid
 AND poc.costsby = 'P'   
 AND poc.employeerate > 0   

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

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  
union

select distinct
 pi.personid
,'Dnt' ::varchar(30) as sourceseq
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn
,pn.fname ::varchar(100) as fname
,pn.lname ::varchar(100) as lname
,pn.mname ::char(1) as mname
,'S' ::char(1) as payroll_freq
,to_char(current_date,'mm/dd/yyyy') ::char(10) as payroll_file_date
,to_char(pbednt.effectivedate,'mm/dd/yyyy') ::char(10) as effective_doc
,case when pbednt.benefitsubclass    = '11' then 'Dental'
      else ' ' end ::varchar(20) as ded_code
,'S' ::char(1) as ded_freq   
,case when pbednt.benefitsubclass    = '11' then cast(coalesce(ppd.etv_amount,pbednt.monthlyamount  / 2) as dec(18,2))
      end as ded_amount
,'B' ::char(1) as employer_contrib_freq
,case when pbednt.benefitsubclass    = '11' then cast(coalesce(poc.employercost,pbednt.monthlyemployeramount / 2) as dec(18,2))
      end as employer_contrib
,0 as annual_election 
,' ' ::char(1) as dept_div
,to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as dob      
,to_char(pe.empllasthiredate,'mm/dd/yyyy') ::char(10) as doh
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date
,case when pe.emplstatus = 'T' then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as paythru_date
,case when pe.emplstatus = 'T' then 
 to_char(pbednt.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as expir_date 
,pp.positionid
,'"'||pd.positiontitle||'"' ::varchar(100) as job_title
,cast(pc.compamount as dec(18,2)) as salary
,' ' ::char(1) as ownership_pct
,'"'||pa.streetaddress||'"' ::varchar(50) as addr1
,'"'||pa.streetaddress2||'"' ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(11) as zip
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(200) as email
,'"MS Clinical Services, LLC dba MedSource"' ::varchar(50) as company_code

from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('11')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 AND (CURRENT_DATE between pbe.effectivedate AND pbe.enddate 
  or (pbe.effectivedate > current_date and pbe.enddate > pbe.effectivedate AND extract(year from pbe.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbe.createts AND pbe.endts

left join person_bene_election pbednt
  on pbednt.personid = pbe.personid
 and pbednt.benefitsubclass in ('11')
 and pbednt.selectedoption = 'Y'
 and pbednt.benefitelection in ('E')
 AND (CURRENT_DATE between pbednt.effectivedate AND pbednt.enddate 
  or (pbednt.effectivedate > current_date and pbednt.enddate > pbednt.effectivedate AND extract(year from pbednt.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbednt.createts AND pbednt.endts 

left join pspay_payment_detail ppd
  on ppd.personid = pbe.personid
 and ppd.etv_id = 'VBD'
 and ppd.check_date = ?::date
 
LEFT JOIN personbenoptioncostl poc 
  ON poc.personid = pbe.personid
 AND poc.personbeneelectionpid = pbe.personbeneelectionpid
 AND poc.costsby = 'P'   
 AND poc.employeerate > 0 
 
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

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  
UNION


select distinct
 pi.personid
,'Vsn' ::varchar(30) as sourceseq
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn
,pn.fname ::varchar(100) as fname
,pn.lname ::varchar(100) as lname
,pn.mname ::char(1) as mname
,'S' ::char(1) as payroll_freq
,to_char(current_date,'mm/dd/yyyy') ::char(10) as payroll_file_date
,to_char(pbevsn.effectivedate,'mm/dd/yyyy') ::char(10) as effective_doc
,case when pbevsn.benefitsubclass    = '14' then 'Vision'
      else ' ' end ::varchar(20) as ded_code
,'S' ::char(1) as ded_freq   
,case when pbevsn.benefitsubclass    = '14' then cast(coalesce(ppd.etv_amount,pbevsn.monthlyamount  / 2) as dec(18,2))
      end as ded_amount
,'B' ::char(1) as employer_contrib_freq
,case when pbevsn.benefitsubclass    = '14' then cast(coalesce(poc.employercost,pbevsn.monthlyemployeramount / 2) as dec(18,2))
      end as employer_contrib
,0 as annual_election 
,' ' ::char(1) as dept_div
,to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as dob      
,to_char(pe.empllasthiredate,'mm/dd/yyyy') ::char(10) as doh
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date
,case when pe.emplstatus = 'T' then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as paythru_date
,case when pe.emplstatus = 'T' then 
 to_char(pbevsn.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as expir_date 
,pp.positionid
,'"'||pd.positiontitle||'"' ::varchar(100) as job_title
,cast(pc.compamount as dec(18,2)) as salary
,' ' ::char(1) as ownership_pct
,'"'||pa.streetaddress||'"' ::varchar(50) as addr1
,'"'||pa.streetaddress2||'"' ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(11) as zip
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(200) as email
,'"MS Clinical Services, LLC dba MedSource"' ::varchar(50) as company_code

from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('14')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 AND (CURRENT_DATE between pbe.effectivedate AND pbe.enddate 
  or (pbe.effectivedate > current_date and pbe.enddate > pbe.effectivedate AND extract(year from pbe.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbe.createts AND pbe.endts

left join person_bene_election pbevsn
  on pbevsn.personid = pbe.personid
 and pbevsn.benefitsubclass in ('14')
 and pbevsn.selectedoption = 'Y'
 and pbevsn.benefitelection in ('E')
 AND (CURRENT_DATE between pbevsn.effectivedate AND pbevsn.enddate 
  or (pbevsn.effectivedate > current_date and pbevsn.enddate > pbevsn.effectivedate AND extract(year from pbevsn.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbevsn.createts AND pbevsn.endts 

left join pspay_payment_detail ppd
  on ppd.personid = pbe.personid
 and ppd.etv_id = 'VBE'
 and ppd.check_date = ?::date
 
LEFT JOIN personbenoptioncostl poc 
  ON poc.personid = pbe.personid
 AND poc.personbeneelectionpid = pbe.personbeneelectionpid
 AND poc.costsby = 'P'   
 AND poc.employeerate > 0 
 
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

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  
UNION


select distinct
 pi.personid
,'HSA' ::varchar(30) as sourceseq
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn
,pn.fname ::varchar(100) as fname
,pn.lname ::varchar(100) as lname
,pn.mname ::char(1) as mname
,'S' ::char(1) as payroll_freq
,to_char(current_date,'mm/dd/yyyy') ::char(10) as payroll_file_date
,to_char(pbehsa.effectivedate,'mm/dd/yyyy') ::char(10) as effective_doc
,case when pbehsa.benefitsubclass    = '6Z' then 'HSA'
      else ' ' end ::varchar(20) as ded_code
,'S' ::char(1) as ded_freq   
,case when pbehsa.benefitsubclass    = '6Z' then cast(coalesce(ppd.etv_amount,pbehsa.monthlyamount  / 2) as dec(18,2))
      end as ded_amount
,'B' ::char(1) as employer_contrib_freq
,case when pbehsa.benefitsubclass    = '6Z' then cast(coalesce(poc.employercost,pbehsa.monthlyemployeramount / 2) as dec(18,2))
      end as employer_contrib
,case when pbehsa.benefitsubclass  = '6Z' then cast(pbehsa.coverageamount as dec(18,2))    
      end as annual_election 
,' ' ::char(1) as dept_div
,to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as dob      
,to_char(pe.empllasthiredate,'mm/dd/yyyy') ::char(10) as doh
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date
,case when pe.emplstatus = 'T' then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as paythru_date
,case when pe.emplstatus = 'T' then 
 to_char(pbehsa.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as expir_date 
,pp.positionid
,'"'||pd.positiontitle||'"' ::varchar(100) as job_title
,cast(pc.compamount as dec(18,2)) as salary
,' ' ::char(1) as ownership_pct
,'"'||pa.streetaddress||'"' ::varchar(50) as addr1
,'"'||pa.streetaddress2||'"' ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(11) as zip
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(200) as email
,'"MS Clinical Services, LLC dba MedSource"' ::varchar(50) as company_code

from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('6Z')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 AND (CURRENT_DATE between pbe.effectivedate AND pbe.enddate 
  or (pbe.effectivedate > current_date and pbe.enddate > pbe.effectivedate AND extract(year from pbe.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbe.createts AND pbe.endts

left join person_bene_election pbehsa
  on pbehsa.personid = pbe.personid
 and pbehsa.benefitsubclass in ('6Z')
 and pbehsa.selectedoption = 'Y'
 and pbehsa.benefitelection in ('E')
 AND (CURRENT_DATE between pbehsa.effectivedate AND pbehsa.enddate 
  or (pbehsa.effectivedate > current_date and pbehsa.enddate > pbehsa.effectivedate AND extract(year from pbehsa.effectivedate) = extract(year from CURRENT_DATE)))
 AND CURRENT_TIMESTAMP between pbehsa.createts AND pbehsa.endts

left join pspay_payment_detail ppd
  on ppd.personid = pbe.personid
 and ppd.etv_id IN ('VEH','VEI')
 and ppd.check_date = ?::date
 
LEFT JOIN personbenoptioncostl poc 
  ON poc.personid = pbe.personid
 AND poc.personbeneelectionpid = pbe.personbeneelectionpid
 AND poc.costsby = 'P'   
 AND poc.employeerate > 0 
 
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

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts

    
  order by personid, ssn, sourceseq