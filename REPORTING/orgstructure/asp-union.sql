-- Materialized View: public.cognos_orgstructure_mv

-- DROP MATERIALIZED VIEW public.cognos_orgstructure_mv;

--CREATE MATERIALIZED VIEW public.cognos_orgstructure_mv AS 


select 
 oc.organizationid       as org1id
,oc.organizationdesc     as org1desc
,oc.orgcode              as org1code
,oc.organizationtype     as org1type
,oc.effectivedate        as org1effdt
,oc.enddate              as org1enddt
--,orl.memberoforgid       as org1mbrof
,oc2.organizationid      as org2id
,oc2.organizationdesc    as org2desc
,oc2.orgcode             as org2code
,oc2.organizationtype    as org2type
,oc2.effectivedate       as org2effdt
,oc2.enddate             as org2enddt 
--,orl2.memberoforgid      as org2mbrof
,oc3.organizationid      as org3id 
,oc3.organizationdesc    as org3desc
,oc3.orgcode             as org3code
,oc3.organizationtype    as org3type
,oc3.effectivedate       as org3effdt
,oc3.enddate             as org3enddt
--,orl3.memberoforgid      as org3mbrof
,oc4.organizationid      as org4id 
,oc4.organizationdesc    as org4desc
,oc4.orgcode             as org4code
,oc4.organizationtype    as org4type
,oc4.effectivedate       as org4effdt
,oc4.enddate             as org4enddt

from organization_code oc
join org_rel orl on orl.organizationid = oc.organizationid 
 and current_date between orl.effectivedate and orl.enddate
 and current_timestamp between orl.createts and orl.endts
 
join organization_code oc2 on oc2.organizationid = orl.memberoforgid
 and current_date between oc2.effectivedate and oc2.enddate
 and current_timestamp between oc2.createts and oc2.endts
 and oc2.organizationid in (select organizationid from company_organization_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1)
  
left join org_rel orl2 on orl2.organizationid = oc2.organizationid 
 and current_date between orl2.effectivedate and orl2.enddate
 and current_timestamp between orl2.createts and orl2.endts 
 
left join organization_code oc3 on oc3.organizationid = orl2.memberoforgid
 and current_date between oc3.effectivedate and oc3.enddate
 and current_timestamp between oc3.createts and oc3.endts 
 and oc3.organizationid in (select organizationid from company_organization_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1)
  
left join org_rel orl3 on orl3.organizationid = oc3.organizationid 
 and current_date between orl3.effectivedate and orl3.enddate
 and current_timestamp between orl3.createts and orl3.endts 
 
left join organization_code oc4 on oc4.organizationid = orl3.memberoforgid
 and current_date between oc4.effectivedate and oc4.enddate
 and current_timestamp between oc4.createts and oc4.endts  
 and oc4.organizationid in (select organizationid from company_organization_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1)    
   
where oc.organizationid in (select organizationid from company_organization_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1)   
  and current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts
  
  union

select 
 oc.organizationid       as org1id
,oc.organizationdesc     as org1desc
,oc.orgcode              as org1code
,oc.organizationtype     as org1type
,oc.effectivedate        as org1effdt
,oc.enddate              as org1enddt
,null                    as org2id
,null                    as org2desc
,null                    as org2code
,null                    as org2type
,null                    as org2effdt
,null                    as org2enddt 
--,orl2.memberoforgid      as org2mbrof
,null                    as org3id 
,null                    as org3desc
,null                    as org3code
,null                    as org3type
,null                    as org3effdt
,null                    as org3enddt
--,orl3.memberoforgid      as org3mbrof
,null                    as org4id 
,null                    as org4desc
,null                    as org4code
,null                    as org4type
,null                    as org4effdt
,null                    as org4enddt
from organization_code oc
join company_organization_rel cor on cor.organizationid = oc.organizationid and current_date between cor.effectivedate and cor.enddate and current_timestamp between cor.createts and cor.endts

where oc.organizationid in (select organizationid from company_organization_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1)   
  and current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts
  and oc.organizationtype = 'CC'
  
union  
  
select 
 oc.organizationid       as org1id
,oc.organizationdesc     as org1desc
,oc.orgcode              as org1code
,oc.organizationtype     as org1type
,oc.effectivedate        as org1effdt
,oc.enddate              as org1enddt
,null                    as org2id
,null                    as org2desc
,null                    as org2code
,null                    as org2type
,null                    as org2effdt
,null                    as org2enddt 
--,orl2.memberoforgid      as org2mbrof
,null                    as org3id 
,null                    as org3desc
,null                    as org3code
,null                    as org3type
,null                    as org3effdt
,null                    as org3enddt
--,orl3.memberoforgid      as org3mbrof
,null                    as org4id 
,null                    as org4desc
,null                    as org4code
,null                    as org4type
,null                    as org4effdt
,null                    as org4enddt
from organization_code oc
join company_organization_rel cor on cor.organizationid = oc.organizationid and current_date between cor.effectivedate and cor.enddate and current_timestamp between cor.createts and cor.endts

where oc.organizationid not in (select organizationid from org_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1)   
  and current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts
  and oc.organizationtype = 'Dept'
  
  union
  
select 
 oc.organizationid       as org1id
,oc.organizationdesc     as org1desc
,oc.orgcode              as org1code
,oc.organizationtype     as org1type
,oc.effectivedate        as org1effdt
,oc.enddate              as org1enddt
--,orl.memberoforgid       as org1mbrof
,oc2.organizationid      as org2id
,oc2.organizationdesc    as org2desc
,oc2.orgcode             as org2code
,oc2.organizationtype    as org2type
,oc2.effectivedate       as org2effdt
,oc2.enddate             as org2enddt 
--,orl2.memberoforgid      as org2mbrof
,oc3.organizationid      as org3id 
,oc3.organizationdesc    as org3desc
,oc3.orgcode             as org3code
,oc3.organizationtype    as org3type
,oc3.effectivedate       as org3effdt
,oc3.enddate             as org3enddt
--,orl3.memberoforgid      as org3mbrof
,oc4.organizationid      as org4id 
,oc4.organizationdesc    as org4desc
,oc4.orgcode             as org4code
,oc4.organizationtype    as org4type
,oc4.effectivedate       as org4effdt
,oc4.enddate             as org4enddt

from organization_code oc
join org_rel orl on orl.organizationid = oc.organizationid 
 and current_date between orl.effectivedate and orl.enddate
 and current_timestamp between orl.createts and orl.endts
 
join organization_code oc2 on oc2.organizationid = orl.memberoforgid
 and current_date between oc2.effectivedate and oc2.enddate
 and current_timestamp between oc2.createts and oc2.endts
 and oc2.organizationid in (select organizationid from company_organization_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1)
  
left join org_rel orl2 on orl2.organizationid = oc2.organizationid 
 and current_date between orl2.effectivedate and orl2.enddate
 and current_timestamp between orl2.createts and orl2.endts 
 
left join organization_code oc3 on oc3.organizationid = orl2.memberoforgid
 and current_date between oc3.effectivedate and oc3.enddate
 and current_timestamp between oc3.createts and oc3.endts 
 and oc3.organizationid in (select organizationid from company_organization_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1)
  
left join org_rel orl3 on orl3.organizationid = oc3.organizationid 
 and current_date between orl3.effectivedate and orl3.enddate
 and current_timestamp between orl3.createts and orl3.endts 
 
left join organization_code oc4 on oc4.organizationid = orl3.memberoforgid
 and current_date between oc4.effectivedate and oc4.enddate
 and current_timestamp between oc4.createts and oc4.endts  
 and oc4.organizationid in (select organizationid from company_organization_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1)    
   
where oc.organizationtype = 'BU' 
  and current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts  
  
  UNION
  
select 
 oc.organizationid       as org1id
,oc.organizationdesc     as org1desc
,oc.orgcode              as org1code
,oc.organizationtype     as org1type
,oc.effectivedate        as org1effdt
,oc.enddate              as org1enddt
,null                    as org2id
,null                    as org2desc
,null                    as org2code
,null                    as org2type
,null                    as org2effdt
,null                    as org2enddt 
--,orl2.memberoforgid      as org2mbrof
,null                    as org3id 
,null                    as org3desc
,null                    as org3code
,null                    as org3type
,null                    as org3effdt
,null                    as org3enddt
--,orl3.memberoforgid      as org3mbrof
,null                    as org4id 
,null                    as org4desc
,null                    as org4code
,null                    as org4type
,null                    as org4effdt
,null                    as org4enddt
from organization_code oc
join company_organization_rel cor on cor.organizationid = oc.organizationid and current_date between cor.effectivedate and cor.enddate and current_timestamp between cor.createts and cor.endts

where oc.organizationid not in (select organizationid from org_rel where current_date between effectivedate and enddate and current_timestamp between createts and endts group by 1)   
  and current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts
  and oc.organizationtype = 'Div' and oc.orgcode <> 'A'   
