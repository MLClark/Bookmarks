select distinct
 pp.personid
,pd.positiontitle
,pn.name ::char(255) as Name
,pi.identity ::char(255) as SupervisorNumber
,case pe.emplstatus when 'A' then '0' else '1' end ::char(1) as Disabled
FROM pos_pos po
LEFT JOIN position_desc pd ON pd.positionid = po.positionid 
     AND current_date between pd.effectivedate and pd.enddate
     AND current_timestamp between pd.createts AND pd.endts
LEFT JOIN pers_pos pp  ON pp.positionid = po.positionid 
     AND pp.persposrel = 'Occupies'::bpchar 
LEFT JOIN person_names pn ON pn.personid = pp.personid
LEFT JOIN name_type ON name_type.nametype = pn.nametype  
LEFT JOIN person_identity pi on pi.personid = pp.personid
     and pi.identitytype = 'NetId' 
LEFT JOIN person_employment pe ON pe.personid = pp.personid 
      and current_date between pe.effectivedate and pe.enddate
      and current_timestamp between pe.createts and pe.endts         
WHERE po.posposrel = 'Manages'::bpchar
  --and pp.personid in ( '20489', '21827')   

;

