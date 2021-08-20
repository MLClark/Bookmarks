with bo as 
(

select 
 oc.organizationid       as org1id
,oc.organizationdesc     as org1desc
,oc.orgcode              as org1code
,oc.organizationtype     as org1type
,oc.effectivedate        as org1effdt
,oc.enddate              as org1enddt
,oc2.organizationid      as org2id
,oc2.organizationdesc    as org2desc
,oc2.orgcode             as org2code
,oc2.organizationtype    as org2type
,oc2.effectivedate       as org2effdt
,oc2.enddate             as org2enddt 
,oc3.organizationid      as org3id 
,oc3.organizationdesc    as org3desc
,oc3.orgcode             as org3code
,oc3.organizationtype    as org3type
,oc3.effectivedate       as org3effdt
,oc3.enddate             as org3enddt
,oc4.organizationid      as org4id 
,oc4.organizationdesc    as org4desc
,oc4.orgcode             as org4code
,oc4.organizationtype    as org4type
,oc4.effectivedate       as org4effdt
,oc4.enddate             as org4enddt

from organization_code oc
LEFT join org_rel orl on orl.organizationid = oc.organizationid 
 and current_date between orl.effectivedate and orl.enddate
 and current_timestamp between orl.createts and orl.endts
 
LEFT join organization_code oc2 on oc2.organizationid = orl.memberoforgid
 and current_date between oc2.effectivedate and oc2.enddate
 and current_timestamp between oc2.createts and oc2.endts
  
left join org_rel orl2 on orl2.organizationid = oc2.organizationid 
 and current_date between orl2.effectivedate and orl2.enddate
 and current_timestamp between orl2.createts and orl2.endts 
 
left join organization_code oc3 on oc3.organizationid = orl2.memberoforgid
 and current_date between oc3.effectivedate and oc3.enddate
 and current_timestamp between oc3.createts and oc3.endts 
  
left join org_rel orl3 on orl3.organizationid = oc3.organizationid 
 and current_date between orl3.effectivedate and orl3.enddate
 and current_timestamp between orl3.createts and orl3.endts 
 
left join organization_code oc4 on oc4.organizationid = orl3.memberoforgid
 and current_date between oc4.effectivedate and oc4.enddate
 and current_timestamp between oc4.createts and oc4.endts  
   
where current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts

)
 SELECT
        CASE
            WHEN bo.org2id IS NULL THEN bo.org1id
            WHEN bo.org3id IS NULL THEN bo.org2id
            WHEN bo.org4id IS NULL THEN bo.org3id
            ELSE bo.org4id
        END AS org1id,
        CASE
            WHEN bo.org2id IS NULL THEN bo.org1desc
            WHEN bo.org3id IS NULL THEN bo.org2desc
            WHEN bo.org4id IS NULL THEN bo.org3desc
            ELSE bo.org4desc
        END AS org1desc,
        CASE
            WHEN bo.org2id IS NULL THEN bo.org1code
            WHEN bo.org3id IS NULL THEN bo.org2code
            WHEN bo.org4id IS NULL THEN bo.org3code
            ELSE bo.org4code
        END AS org1code,
        CASE
            WHEN bo.org2id IS NULL THEN bo.org1type
            WHEN bo.org3id IS NULL THEN bo.org2type
            WHEN bo.org4id IS NULL THEN bo.org3type
            ELSE bo.org4type
        END AS org1type,
        CASE
            WHEN bo.org2id IS NULL THEN bo.org1effdt
            WHEN bo.org3id IS NULL THEN bo.org2effdt
            WHEN bo.org4id IS NULL THEN bo.org3effdt
            ELSE bo.org4effdt
        END AS org1effdt,
        CASE
            WHEN bo.org2id IS NULL THEN bo.org1enddt
            WHEN bo.org3id IS NULL THEN bo.org2enddt
            WHEN bo.org4id IS NULL THEN bo.org3enddt
            ELSE bo.org4enddt
        END AS org1enddt,
        CASE
            WHEN bo.org2id IS NULL THEN NULL::integer
            WHEN bo.org3id IS NULL THEN bo.org1id
            WHEN bo.org4id IS NULL THEN bo.org2id
            ELSE bo.org3id
        END AS org2id,
        CASE
            WHEN bo.org2id IS NULL THEN NULL::character varying
            WHEN bo.org3id IS NULL THEN bo.org1desc
            WHEN bo.org4id IS NULL THEN bo.org2desc
            ELSE bo.org3desc
        END AS org2desc,
        CASE
            WHEN bo.org2id IS NULL THEN NULL::bpchar
            WHEN bo.org3id IS NULL THEN bo.org1code
            WHEN bo.org4id IS NULL THEN bo.org2code
            ELSE bo.org3code
        END AS org2code,
        CASE
            WHEN bo.org2id IS NULL THEN NULL::bpchar
            WHEN bo.org3id IS NULL THEN bo.org1type
            WHEN bo.org4id IS NULL THEN bo.org2type
            ELSE bo.org3type
        END AS org2type,
        CASE
            WHEN bo.org2id IS NULL THEN NULL::date
            WHEN bo.org3id IS NULL THEN bo.org1effdt
            WHEN bo.org4id IS NULL THEN bo.org2effdt
            ELSE bo.org3effdt
        END AS org2effdt,
        CASE
            WHEN bo.org2id IS NULL THEN NULL::date
            WHEN bo.org3id IS NULL THEN bo.org1enddt
            WHEN bo.org4id IS NULL THEN bo.org2enddt
            ELSE bo.org3enddt
        END AS org2enddt,
        CASE
            WHEN bo.org3id IS NULL THEN NULL::integer
            WHEN bo.org4id IS NULL THEN bo.org1id
            ELSE bo.org2id
        END AS org3id,
        CASE
            WHEN bo.org3id IS NULL THEN NULL::character varying
            WHEN bo.org4id IS NULL THEN bo.org1desc
            ELSE bo.org2desc
        END AS org3desc,
        CASE
            WHEN bo.org3id IS NULL THEN NULL::bpchar
            WHEN bo.org4id IS NULL THEN bo.org1code
            ELSE bo.org2code
        END AS org3code,
        CASE
            WHEN bo.org3id IS NULL THEN NULL::bpchar
            WHEN bo.org4id IS NULL THEN bo.org1type
            ELSE bo.org2type
        END AS org3type,
        CASE
            WHEN bo.org3id IS NULL THEN NULL::date
            WHEN bo.org4id IS NULL THEN bo.org1effdt
            ELSE bo.org2effdt
        END AS org3effdt,
        CASE
            WHEN bo.org3id IS NULL THEN NULL::date
            WHEN bo.org4id IS NULL THEN bo.org1enddt
            ELSE bo.org2enddt
        END AS org3enddt,
        CASE
            WHEN bo.org4id IS NOT NULL THEN bo.org1id
            ELSE NULL::integer
        END AS org4id,
        CASE
            WHEN bo.org4id IS NOT NULL THEN bo.org1desc
            ELSE NULL::character varying
        END AS org4desc,
        CASE
            WHEN bo.org4id IS NOT NULL THEN bo.org1code
            ELSE NULL::bpchar
        END AS org4code,
        CASE
            WHEN bo.org4id IS NOT NULL THEN bo.org1type
            ELSE NULL::bpchar
        END AS org4type,
        CASE
            WHEN bo.org4id IS NOT NULL THEN bo.org1effdt
            ELSE NULL::date
        END AS org4effdt,
        CASE
            WHEN bo.org4id IS NOT NULL THEN bo.org1enddt
            ELSE NULL::date
        END AS org4enddt
from   bo