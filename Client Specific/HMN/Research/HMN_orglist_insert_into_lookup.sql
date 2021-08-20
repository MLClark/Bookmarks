--CREATE SEQUENCE orglist_id_seq;

delete from edi.lookup;
INSERT
INTO
    edi.lookup
    (

        lookupid,
        key1,
        key2,
        key3,
        key4,
        key5,
        value1,
        value2,
        value3,
        value4,
        value5,
        value6,
        value7,
        value8,
        value9,
        value10,
        effectivedate,
        enddate,
        createts,
        endts,
        active
    ) 
  select distinct
 1 as lookupid
,list1.personid as key1
,null as key2
,null as key3
,null as key4
,null as key5
,list1.f5_emp_name as value1
,list1.positionid as value2
,min(list1.budget_org) as value3
,min(list1.budgetof) as value4
,min(list1.memberof) as value5
,min(list1.budget_org1) as value6
,min(list1.budgetof1) as value7
,null as value8
,null as value9
,null as value10
,current_date as effectivedate
,'2199-12-31'::date as enddate
,current_timestamp as createts
,'2199-12-30 19:00:00'::timestamp as endts
,0
from 
(



select distinct
 pi.personid 
,pn.lname||', '||pn.fname||' '||COALESCE(pn.mname,'') ::varchar(60) as f5_emp_name 
,oc_cc.orgcode budget_org
,oc_cc1.orgcode budget_org1
,pp.positionid 
,porb.organizationid budgetof
,porb1.organizationid budgetof1
,porm.organizationid memberof
 
from person_identity pi

join person_names pn
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'

join pers_pos pp 
  on pp.personid = pi.personid
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts
 
 /*
    get positions from prior year
    exclude logically deleted positions
 */
left join pos_org_rel porb
  ON porb.positionid = PP.positionid 
 AND porb.posorgreltype = 'Budget' 
 and porb.posorgrelevent  in ( 'NewPos','NewOrgRel ')
 and current_date > porb.effectivedate
 and porb.effectivedate <> '1950-01-01' 
 and date_part('year',porb.effectivedate)=date_part('year',current_date-interval '1 year')
 and porb.effectivedate - interval '1 day' <> porb.enddate
 and current_timestamp between porb.createts and porb.endts
 
left join pos_org_rel porb1
  ON porb1.positionid = PP.positionid 
 AND porb1.posorgreltype = 'Budget' 
 and porb1.posorgrelevent  in ( 'NewPos')
-- and current_date > porb1.effectivedate
 and date_part('year',porb1.effectivedate)<=date_part('year',current_date-interval '1 year')
 and porb1.effectivedate - interval '1 day' <> porb1.enddate 
 and porb1.effectivedate <> '1950-01-01' 
 and current_timestamp between porb1.createts and porb1.endts 
 
left join pos_org_rel porm
  ON porm.positionid = PP.positionid 
 AND porm.posorgreltype = 'Member' 
 and porm.posorgrelevent  in ( 'NewPos')
 and current_date > porm.effectivedate
 and date_part('year',porm.effectivedate)=date_part('year',current_date-interval '1 year')
 and porm.effectivedate - interval '1 day' <> porm.enddate
 and current_timestamp between porm.createts and porm.endts 
 
 /*
select * from pos_org_rel where positionid in ('401587') 
   and posorgreltype = 'Budget' 
   and posorgrelevent in ( 'NewPos','NewOrgRel ')
   --and current_date > effectivedate
   and date_part('year',effectivedate)<=date_part('year',current_date-interval '1 year')
   and effectivedate - interval '1 day' <> enddate
   and effectivedate <> '1950-01-01'
   and current_timestamp between createts and endts;   
  
   */
    
left join organization_code oc_cc
  ON oc_cc.organizationid = porb.organizationid
 AND oc_cc.organizationtype = 'CC'
 and current_date between oc_cc.effectivedate and oc_cc.enddate 
 and current_timestamp between oc_cc.createts and oc_cc.endts 
 
left join organization_code oc_cc1
  ON oc_cc1.organizationid = porb1.organizationid
 AND oc_cc1.organizationtype = 'CC'
 and current_date between oc_cc1.effectivedate and oc_cc1.enddate 
 and current_timestamp between oc_cc1.createts and oc_cc1.endts 
 
 /*
 select * from organization_code oc_mbr
 where oc_mbr.organizationid = '1404'
   and oc_mbr.organizationtype = 'CC'
   and current_date between oc_mbr.effectivedate and oc_mbr.enddate 
   and current_timestamp between oc_mbr.createts and oc_mbr.endts
 */
    
where pi.identitytype = 'SSN'
  and current_date between pi.createts and pi.endts
  --and oc_cc.orgcode is not null
  --and pi.personid = '66127'


) list1
group by 1,2,3,4,5,6,7,8,14,15,16,17,18,19,20
order by f5_emp_name ;
select * from edi.lookup;
