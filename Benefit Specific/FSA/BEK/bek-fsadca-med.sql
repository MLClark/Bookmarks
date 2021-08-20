
select distinct
 pi.personid
,'Med future dated' ::varchar(30) as sourceseq
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn
,pn.fname ::varchar(100) as fname
,pn.lname ::varchar(100) as lname
,pn.mname ::char(1) as mname
,'S' ::char(1) as payroll_freq
,to_char(current_date,'mm/dd/yyyy') ::char(10) as payroll_file_date
,to_char(pbe.effectivedate,'mm/dd/yyyy') ::char(10) as effective_doc
,case when pbe.benefitsubclass    = '10' then 'Medical'
      else ' ' end ::varchar(20) as ded_code
,'S' ::char(1) as ded_freq   
,case when pbe.benefitsubclass    = '10' then cast(coalesce(ppd.etv_amount,pbe.monthlyamount  / 2 ) as dec(18,2))
      end as ded_amount
,'B' ::char(1) as employer_contrib_freq
,case when pbe.benefitsubclass    = '10' then cast(coalesce(poc.employercost,pbe.monthlyemployeramount  / 2 ) as dec(18,2))
      end as employer_contrib
,0 as annual_election 
,' ' ::char(1) as dept_div
,to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as dob      
,to_char(pe.empllasthiredate,'mm/dd/yyyy') ::char(10) as doh
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date
,case when pe.emplstatus = 'T' then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as paythru_date
,case when pe.emplstatus = 'T' then 
 to_char(pbe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as expir_date 
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

left join edi.edi_last_update elu on elu.feedid = 'BEK_ProBenefits_FSA_DCA_Export'
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('10')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 ---- future dated logic from ba3
 AND (pbe.effectivedate > current_date and pbe.enddate > pbe.effectivedate AND extract(year from pbe.effectivedate) = extract(year from CURRENT_DATE))
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts and effectivedate > elu.lastupdatets 
                         and benefitsubclass in ('10') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)    

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
  