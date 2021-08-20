select * from organization_code where organizationtype = 'CC';
select * from pers_pos where personid = '62958' and current_date between effectivedate and enddate and current_timestamp between createts and endts;
select * from positionorgreldetail ;
select * from pos_pos;
select * from orglist;
select * from organization_type;
select 
 oc_cc.organizationid 
,ot.organizationtypedesc
,oc_cc.organizationdesc as organization
,oc_cc.orgcode as org_level3_code
,oc_cc.organizationxid as external_id

from organization_code oc_cc

join organization_type ot
  on ot.organizationtype = oc_cc.organizationtype
  
where oc_cc.organizationtype = 'CC'
 and current_date between oc_cc.effectivedate and oc_cc.enddate
 and current_timestamp between oc_cc.createts and oc_cc.endts
 and oc_cc.effectivedate - interval '1 day' <> oc_cc.enddate
 --and oc_cc.organizationid = '1473'
 ;