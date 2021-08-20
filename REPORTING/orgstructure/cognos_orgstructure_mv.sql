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

/*
WITH DATA;

ALTER TABLE public.cognos_orgstructure_mv
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_orgstructure_mv TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_orgstructure_mv TO read_write;
GRANT SELECT ON TABLE public.cognos_orgstructure_mv TO read_only;

-- Index: public.ix_cognos_orgstructure_mv

-- DROP INDEX public.ix_cognos_orgstructure_mv;

CREATE UNIQUE INDEX ix_cognos_orgstructure_mv
  ON public.cognos_orgstructure_mv
  USING btree
  (org1id, org2id, org3id, org4id);
  
*/
