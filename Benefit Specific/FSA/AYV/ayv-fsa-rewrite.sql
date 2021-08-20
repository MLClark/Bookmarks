select distinct
 pi.personid
,left(pip.identity,5)
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity 
      else left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn

,pn.fname ::varchar(100) as fname
,pn.lname ::varchar(100) as lname
,pn.mname ::char(1) as mname
       
,pu.frequencycode ::char(1) as payroll_freq
,to_char(current_date,'mm/dd/yyyy') ::char(10) as payroll_file_date
,to_char(pbe.effectivedate,'mm/dd/yyyy') ::char(10) as edoc
,case when pbe.benefitsubclass = '60' then 'Health FSA'
      when pbe.benefitsubclass = '61' then 'Dep FSA'
      when pbe.benefitsubclass = '10' then 'Medical'
      when pbe.benefitsubclass = '11' then 'Dental'
      else ' ' end ::varchar(20) as ded_code
,pu.frequencycode ::char(1) as ded_freq   
,case when pbe.benefitsubclass = '60' then cast(ppdvba.etv_amount as dec(18,2))
      when pbe.benefitsubclass = '61' then cast(ppdvbb.etv_amount as dec(18,2))
      when pbe.benefitsubclass = '10' then cast(ppdvbc.etv_amount as dec(18,2))
      when pbe.benefitsubclass = '11' then cast(ppdvbd.etv_amount as dec(18,2))
      end as ded_amount 

,pu.frequencycode ::char(1) as er_contrib_freq
,0 as er_contrib_amt
,case when pbe.benefitsubclass  = '60' then cast(pbe.coverageamount as dec(18,2))  
      when pbe.benefitsubclass  = '61' then cast(pbe.coverageamount as dec(18,2))      
      else 0 end as annual_election   
,' ' ::char(1) as dept_div
,to_char(pv.birthdate,'mm/dd/yyyy') ::char(10) as dob      
,to_char(pe.empllasthiredate,'mm/dd/yyyy') ::char(10) as doh          
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as term_date
,case when pe.emplstatus = 'T' then to_char(pe.paythroughdate,'mm/dd/yyyy') else ' ' end ::char(10) as paythru_date
,case when pe.emplstatus = 'T' then to_char(pbe.effectivedate,'mm/dd/yyyy') else ' ' end ::char(10) as expir_date 
,'"'||pd.positiontitle||'"' ::varchar(100) as job_title

,pp.scheduledhours
,pc.frequencycode
,case when pc.frequencycode = 'H' then cast(pc.compamount  * pp.scheduledhours * 24 as dec(18,2))
      else cast(pc.compamount as dec(18,2)) end as salary
,' ' ::char(1) as ownership_pct
,pa.streetaddress ::varchar(50) as addr1
,pa.streetaddress2 ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::varchar(11) as zip
,coalesce(pncw.url,pnch.url,pnco.url) ::varchar(200) as email
,'"Strategic Link Consulting"' ::varchar(50) as company_code

from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts  

left join person_compensation pc
  on pc.personid = pi.personid
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts  

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
 
join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('60','61','11','10')
 and pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts

join person_bene_election pbemed
  on pbemed.personid = pbe.personid
 and pbemed.benefitsubclass in ('10')
 and pbemed.selectedoption = 'Y'
 and pbemed.benefitelection in ('E')
 and current_date between pbemed.effectivedate and pbemed.enddate
 and current_timestamp between pbemed.createts and pbemed.endts  

join person_bene_election pbednt
  on pbednt.personid = pbe.personid
 and pbednt.benefitsubclass in ('11')
 and pbednt.selectedoption = 'Y'
 and pbednt.benefitelection in ('E')
 and current_date between pbednt.effectivedate and pbednt.enddate
 and current_timestamp between pbednt.createts and pbednt.endts   

left join person_bene_election pbedfsa
  on pbedfsa.personid = pbe.personid
 and (pbedfsa.personid = pbemed.personid or pbedfsa.personid = pbednt.personid)  
 and pbedfsa.benefitsubclass in ('61')
 and pbedfsa.selectedoption = 'Y'
 and pbedfsa.benefitelection in ('E')
 and current_date between pbedfsa.effectivedate and pbedfsa.enddate
 and current_timestamp between pbedfsa.createts and pbedfsa.endts 

join person_bene_election pbefsa
  on pbefsa.personid = pbe.personid
 and (pbefsa.personid = pbemed.personid or pbefsa.personid = pbednt.personid)
 and pbefsa.benefitsubclass in ('60')
 and pbefsa.selectedoption = 'Y'
 and pbefsa.benefitelection in ('E')
 and current_date between pbefsa.effectivedate and pbefsa.enddate
 and current_timestamp between pbefsa.createts and pbefsa.endts

left join pspay_payment_detail ppdvba
  on ppdvba.personid = pbe.personid
 and ppdvba.check_date = ?::date ---2018-05-24
 and ppdvba.etv_id in ('VBA')

left join pspay_payment_detail ppdvbb
  on ppdvbb.personid = pbe.personid
 and ppdvbb.check_date = ?::date ---2018-05-24
 and ppdvbb.etv_id in ('VBB')
 
left join pspay_payment_detail ppdvbc
  on ppdvbc.personid = pbe.personid
 and ppdvbc.check_date = ?::date ---2018-05-24
 and ppdvbc.etv_id in ('VBC')

left join pspay_payment_detail ppdvbd
  on ppdvbd.personid = pbe.personid
 and ppdvbd.check_date = ?::date ---2018-05-24
 and ppdvbd.etv_id in ('VBD')   

left join pers_pos pp
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts

join position_desc pd
  on pd.positionid = pp.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts  

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
