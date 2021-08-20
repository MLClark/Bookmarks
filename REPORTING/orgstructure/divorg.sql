with suborg as 
(

select distinct
 oc.organizationid      
,oc.organizationdesc     
,oc.orgcode             
,oc.organizationtype     
,oc.effectivedate       
,oc.enddate         
,orl.memberoforgid             

from org_rel orl
 
join organization_code oc on oc.organizationid = orl.memberoforgid
 and current_date between oc.effectivedate and oc.enddate
 and current_timestamp between oc.createts and oc.endts
 and oc.organizationtype in ('Div') 
  or oc.organizationid   in (select organizationid from organization_code where current_date between effectivedate and enddate and current_timestamp between createts and endts and organizationtype in ('Div') and organizationid not in 
                            (select distinct memberoforgid from org_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts and orgreltype = 'Management'))

where current_date between orl.effectivedate and orl.enddate
  and current_timestamp between orl.createts and orl.endts
  and orl.orgreltype = 'Management'
  and orl.organizationid is not null 
  and oc.orgcode not in ('A') --- exclude default organization 
  
union

select distinct
 oc.organizationid      
,oc.organizationdesc     
,oc.orgcode             
,oc.organizationtype     
,oc.effectivedate       
,oc.enddate          
,orl.memberoforgid         

from org_rel orl
 
join organization_code oc on oc.organizationid = orl.memberoforgid
 and current_date between oc.effectivedate and oc.enddate
 and current_timestamp between oc.createts and oc.endts
 and oc.organizationtype in ('BU') 
  or oc.organizationid   in (select organizationid from organization_code where current_date between effectivedate and enddate and current_timestamp between createts and endts and organizationtype in ('BU') and organizationid not in 
                            (select distinct memberoforgid from org_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts and orgreltype = 'Management'))

where current_date between orl.effectivedate and orl.enddate
  and current_timestamp between orl.createts and orl.endts
  and orl.orgreltype = 'Management'
  and orl.organizationid is not null 
  and oc.orgcode not in ('A') --- exclude default organization 

union  

select distinct
 oc.organizationid      
,oc.organizationdesc     
,oc.orgcode             
,oc.organizationtype     
,oc.effectivedate       
,oc.enddate     
,orel.memberoforgid         

from organization_code oc  

left join org_rel orel 
  on orel.organizationid = oc.organizationid
 and current_date between orel.effectivedate and orel.enddate
 and current_timestamp between orel.createts and orel.endts
 
where current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts
  and oc.organizationtype in ('Dept') 
  
union

select distinct
 oc.organizationid      
,oc.organizationdesc     
,oc.orgcode             
,oc.organizationtype     
,oc.effectivedate       
,oc.enddate     
,orel.memberoforgid         

from organization_code oc  

left join org_rel orel 
  on orel.organizationid = oc.organizationid
 and current_date between orel.effectivedate and orel.enddate
 and current_timestamp between orel.createts and orel.endts

where current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts
  and oc.organizationtype in ('CC') 
   
order by organizationtype, organizationid
)
select * 

from suborg