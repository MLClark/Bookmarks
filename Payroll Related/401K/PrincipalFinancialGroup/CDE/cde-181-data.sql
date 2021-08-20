select 
 pi.personid
,'MEMBER REHIRE - RTYPE 181' ::varchar(40) as qsource
,'181' ::char(3) as recordtype
,' '   ::char(1) as filler_4
,'805911' ::char(6) as contract_number
,' ' ::char(1) as filler_11
,pi.identity ::char(9) as employee_id_number
,' ' ::char(1) as filler_21
,replace(pn.name,',',' ') ::char(24) as emp_name
,' ' ::char(1) as filler_31_bytes
,pi.identity ::char(9) as ssn 
,' ' ::char(1) as filler_86
,to_char(pe.empllasthiredate,'MM/DD/YYYY')::char(10) as rehire_date
,' ' ::char(1) as filler_144_bytes

from person_identity pi

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate 
 and current_timestamp between pv.createts and pv.endts
 
join person_deduction_setup pds
  on pds.personid = pi.personid
 and pds.etvid in  ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ')
 and current_date between pds.effectivedate and pds.enddate
 and current_timestamp between pds.createts and pds.endts 

 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplevent = 'Rehire'