select distinct

-- DEPARTMENT CODE = org1code
 case when SPLIT_PART(coalesce(ros.org1code),'-',1) = '1' then '00001'
      else SPLIT_PART(coalesce(ros.org1code),'-',1) end ::char(5) AS department

,ros.org1desc AS  member_description
,SPLIT_PART(coalesce(ros.org2code ),'-',1)::char(5) AS division_code
,rosdiv.org2desc AS division_desc

from pos_org_rel por

join position_desc pd
  on pd.positionid = por.positionid
 and current_date between pd.effectivedate and pd.enddate
 and current_timestamp between pd.createts and pd.endts 

join org_rel orl
  on orl.organizationid = por.organizationid
 and current_date between orl.effectivedate and orl.enddate
 and current_timestamp between orl.createts and orl.endts

join cognos_orgstructure ros
  on ros.org2id = orl.memberoforgid
 and ros.org1type = 'Dept'
 and ros.org1id = orl.organizationid

join cognos_orgstructure rosdiv
  on rosdiv.org2id = orl.memberoforgid
 and rosdiv.org2type = 'Div'
        
 
where current_date between por.effectivedate and por.enddate
  and current_timestamp between por.createts and por.endts
  
  
ORDER BY department