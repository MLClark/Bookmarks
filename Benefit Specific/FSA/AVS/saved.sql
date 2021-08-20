select distinct
 pi.personid
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn
,pn.fname ::varchar(100) as fname
,pn.lname ::varchar(100) as lname
,pn.mname ::char(1) as mname
,pu.frequencycode ::char(1) as payroll_freq
,to_char(current_date,'mm/dd/yyyy') ::char(10) as payroll_file_date
,to_char(pbefsa.effectivedate,'mm/dd/yyyy') ::char(10) as effective_doc
,case when pbefsa.benefitsubclass    = '60' then 'Health FSA'
      else ' ' end ::varchar(20) as ded_code
,pu.frequencycode ::char(1) as ded_freq   
,case when pbefsa.benefitsubclass    = '60' then cast(ppd.etv_amount as dec(18,2))
      end as ded_amount
,pu.frequencycode ::char(1) as employer_contrib_freq
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
,pa.streetaddress ::varchar(50) as addr1
,pa.streetaddress2 ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(11) as zip
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(200) as email
,'"Strategic Link Consulting"' ::varchar(50) as company_code
,pbe.coverageamount as election_amt
,to_char(dfpd.first_check_date,'mm/dd/yyyy') ::char(10) as fstpay_ded_dte
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as termdate
,case when pe.emplstatus = 'T' then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as final_pay_dte
---- note I can't always provide the final pay amount on a change / only weekly feed. If the ee termed the same week they
---- paid then I can provide the amount - no guarantee that this amount will coincide with a final pay deduction
,case when pe.emplstatus = 'T' then ppd.etv_amount else null end as final_payroll_ded_amt
,'None' ::char(4) as er_contrib_level
,'0' ::char(1) as er_contrib_amt

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
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

left join person_bene_election pbefsa
  on pbefsa.personid = pbe.personid
 and pbefsa.benefitsubclass in ('60')
 and pbefsa.selectedoption = 'Y'
 and pbefsa.benefitelection in ('E')
 and current_date between pbefsa.effectivedate and pbefsa.enddate
 and current_timestamp between pbefsa.createts and pbefsa.endts

left join pspay_payment_detail ppd
  on ppd.personid = pbe.personid
 and ppd.etv_id = 'VBA'
 and ppd.check_date = ?::date
 
left join (
select ppd.personid, min(ppd.check_date) first_check_date
  from pspay_payment_detail ppd
  join person_bene_election pbe
    on pbe.personid = ppd.personid
   and pbe.benefitsubclass = '60'
   and pbe.selectedoption = 'Y'
   and pbe.benefitelection = 'E'
 where etv_id = 'VBA' 
   and check_date >= pbe.effectivedate
   group by 1) as dfpd on dfpd.personid = pbefsa.personid
   
       
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
 
left join person_payroll ppy
  on ppy.personid = pi.personid
 and current_date between ppy.effectivedate and ppy.enddate
 and current_timestamp between ppy.createts and ppy.endts
  
left join pay_unit pu 
  on pu.payunitid = ppy.payunitid
 and current_date between ppy.effectivedate and ppy.enddate
 and current_timestamp between ppy.createts and ppy.endts
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  
union

select distinct
 pi.personid
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn
,pn.fname ::varchar(100) as fname
,pn.lname ::varchar(100) as lname
,pn.mname ::char(1) as mname
,pu.frequencycode ::char(1) as payroll_freq
,to_char(current_date,'mm/dd/yyyy') ::char(10) as payroll_file_date
,to_char(pbefsad.effectivedate,'mm/dd/yyyy') ::char(10) as effective_doc
,case when pbefsad.benefitsubclass   = '61' then 'Dep FSA'
      else ' ' end ::varchar(20) as ded_code
,pu.frequencycode::char(1) as ded_freq   
,case when pbefsad.benefitsubclass   = '61' then cast(ppd.etv_amount  as dec(18,2))
      end as ded_amount
,pu.frequencycode ::char(1) as employer_contrib_freq
,case when pbefsad.benefitsubclass   = '61' then cast(poc.employercost as dec(18,2))
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
,pa.streetaddress ::varchar(50) as addr1
,pa.streetaddress2 ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(11) as zip
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(200) as email
,'"Strategic Link Consulting"' ::varchar(50) as company_code
,pbe.coverageamount as election_amt
,to_char(dfpd.first_check_date,'mm/dd/yyyy') ::char(10) as fstpay_ded_dte
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as termdate
,case when pe.emplstatus = 'T' then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as final_pay_dte
---- note I can't always provide the final pay amount on a change / only weekly feed. If the ee termed the same week they
---- paid then I can provide the amount - no guarantee that this amount will coincide with a final pay deduction
,case when pe.emplstatus = 'T' then ppd.etv_amount else null end as final_payroll_ded_amt
,'None' ::char(4) as er_contrib_level
,'0' ::char(1) as er_contrib_amt

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
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

left join benefit
left join person_bene_election pbefsad
  on pbefsad.personid = pbe.personid
 and pbefsad.benefitsubclass in ('61')
 and pbefsad.selectedoption = 'Y'
 and pbefsad.benefitelection in ('E')
 and current_date between pbefsad.effectivedate and pbefsad.enddate
 and current_timestamp between pbefsad.createts and pbefsad.endts   
 
left join pspay_payment_detail ppd
  on ppd.personid = pbe.personid
 and ppd.etv_id = 'VBB'
 and ppd.check_date = ?::date
 
left join (
select ppd.personid, min(ppd.check_date) first_check_date
  from pspay_payment_detail ppd
  join person_bene_election pbe
    on pbe.personid = ppd.personid
   and pbe.benefitsubclass = '61'
   and pbe.selectedoption = 'Y'
   and pbe.benefitelection = 'E'
 where etv_id = 'VBB' 
   and check_date >= pbe.effectivedate
   group by 1) as dfpd on dfpd.personid = pbefsad.personid
  
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
  
left join person_payroll ppy
  on ppy.personid = pi.personid
 and current_date between ppy.effectivedate and ppy.enddate
 and current_timestamp between ppy.createts and ppy.endts
  
left join pay_unit pu 
  on pu.payunitid = ppy.payunitid
 and current_date between ppy.effectivedate and ppy.enddate
 and current_timestamp between ppy.createts and ppy.endts
   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts

  order by 1