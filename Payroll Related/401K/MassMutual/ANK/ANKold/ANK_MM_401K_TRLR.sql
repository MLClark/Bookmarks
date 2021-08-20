-- ANK Demographic Trailer
select
 'DMTR' ::char(4) as recordType4
,'0001' ::char(4) as recordVersionNbr4
,'061654' ::char(6) as masterContactNbr6
,count(pi.personid) as totDetail12

from person_identity pi
join edi.edi_last_update elu on elu.feedid = 'ANK_MM_401k_Demo_HDR_Export'

left join person_names pn
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

left join person_address pa
  on pa.personid = pi.personid
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 and pa.addresstype = 'Res' 

left join person_phone_contacts ppcw ON ppcw.personid = pi.personid
 and current_date between ppcw.effectivedate and ppcw.enddate
 and current_timestamp between ppcw.createts and ppcw.endts 
 and ppcw.phonecontacttype = 'Work'  
 
left join person_net_contacts pncw ON pncw.personid = pi.personid 
 and pncw.netcontacttype = 'WRK'::bpchar 
 and current_date between pncw.effectivedate and pncw.enddate
 and current_timestamp between pncw.createts and pncw.enddate  
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts  

left join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts 
 
left join person_language_preference plp
  on plp.personid = pi.personid
   
left join person_maritalstatus pm
  on pm.personid = pi.personid
 and current_date between pm.effectivedate and pm.enddate
 and current_timestamp between pm.createts and pm.endts
 
left join pers_pos ppos
  on ppos.personid = pi.personid
 and current_date between ppos.effectivedate and ppos.enddate
 and current_timestamp between ppos.createts and ppos.endts
 
join position_job posj
  on posj.positionid = ppos.positionid
 and current_date between posj.effectivedate and posj.enddate
 and current_timestamp between posj.createts and posj.endts

left join job_desc jd
  on jd.jobid = posj.jobid
 and current_date between jd.effectivedate and jd.enddate
 and current_timestamp between jd.createts and jd.endts
 
left join person_compensation pc
  on pc.personid = pi.personid 
 and current_date between pc.effectivedate and pc.enddate
 and current_timestamp between pc.createts and pc.endts 
     
where current_date between pi.createts and pi.endts 
and pi.personid = '86349'
and pi.identitytype = 'SSN'

group by 1,2,3