

--CREATE MATERIALIZED VIEW public.cognos_orgstructure_mv AS 
 SELECT distinct
        CASE
            WHEN of.org2id IS NULL THEN of.org1id
            WHEN of.org3id IS NULL THEN of.org2id
            WHEN of.org4id IS NULL THEN of.org3id
            ELSE of.org4id
        END AS org1id,
        CASE
            WHEN of.org2id IS NULL THEN of.org1desc
            WHEN of.org3id IS NULL THEN of.org2desc
            WHEN of.org4id IS NULL THEN of.org3desc
            ELSE of.org4desc
        END AS org1desc,
        CASE
            WHEN of.org2id IS NULL THEN of.org1code
            WHEN of.org3id IS NULL THEN of.org2code
            WHEN of.org4id IS NULL THEN of.org3code
            ELSE of.org4code
        END AS org1code,
        CASE
            WHEN of.org2id IS NULL THEN of.org1type
            WHEN of.org3id IS NULL THEN of.org2type
            WHEN of.org4id IS NULL THEN of.org3type
            ELSE of.org4type
        END AS org1type,
        CASE
            WHEN of.org2id IS NULL THEN of.org1effdt
            WHEN of.org3id IS NULL THEN of.org2effdt
            WHEN of.org4id IS NULL THEN of.org3effdt
            ELSE of.org4effdt
        END AS org1effdt,
        CASE
            WHEN of.org2id IS NULL THEN of.org1enddt
            WHEN of.org3id IS NULL THEN of.org2enddt
            WHEN of.org4id IS NULL THEN of.org3enddt
            ELSE of.org4enddt
        END AS org1enddt,
        CASE
            WHEN of.org2id IS NULL THEN NULL::integer
            WHEN of.org3id IS NULL THEN of.org1id
            WHEN of.org4id IS NULL THEN of.org2id
            ELSE of.org3id
        END AS org2id,
        CASE
            WHEN of.org2id IS NULL THEN NULL::character varying
            WHEN of.org3id IS NULL THEN of.org1desc
            WHEN of.org4id IS NULL THEN of.org2desc
            ELSE of.org3desc
        END AS org2desc,
        CASE
            WHEN of.org2id IS NULL THEN NULL::bpchar
            WHEN of.org3id IS NULL THEN of.org1code
            WHEN of.org4id IS NULL THEN of.org2code
            ELSE of.org3code
        END AS org2code,
        CASE
            WHEN of.org2id IS NULL THEN NULL::bpchar
            WHEN of.org3id IS NULL THEN of.org1type
            WHEN of.org4id IS NULL THEN of.org2type
            ELSE of.org3type
        END AS org2type,
        CASE
            WHEN of.org2id IS NULL THEN NULL::date
            WHEN of.org3id IS NULL THEN of.org1effdt
            WHEN of.org4id IS NULL THEN of.org2effdt
            ELSE of.org3effdt
        END AS org2effdt,
        CASE
            WHEN of.org2id IS NULL THEN NULL::date
            WHEN of.org3id IS NULL THEN of.org1enddt
            WHEN of.org4id IS NULL THEN of.org2enddt
            ELSE of.org3enddt
        END AS org2enddt,
        CASE
            WHEN of.org3id IS NULL THEN NULL::integer
            WHEN of.org4id IS NULL THEN of.org1id
            ELSE of.org2id
        END AS org3id,
        CASE
            WHEN of.org3id IS NULL THEN NULL::character varying
            WHEN of.org4id IS NULL THEN of.org1desc
            ELSE of.org2desc
        END AS org3desc,
        CASE
            WHEN of.org3id IS NULL THEN NULL::bpchar
            WHEN of.org4id IS NULL THEN of.org1code
            ELSE of.org2code
        END AS org3code,
        CASE
            WHEN of.org3id IS NULL THEN NULL::bpchar
            WHEN of.org4id IS NULL THEN of.org1type
            ELSE of.org2type
        END AS org3type,
        CASE
            WHEN of.org3id IS NULL THEN NULL::date
            WHEN of.org4id IS NULL THEN of.org1effdt
            ELSE of.org2effdt
        END AS org3effdt,
        CASE
            WHEN of.org3id IS NULL THEN NULL::date
            WHEN of.org4id IS NULL THEN of.org1enddt
            ELSE of.org2enddt
        END AS org3enddt,
        CASE
            WHEN of.org4id IS NOT NULL THEN of.org1id
            ELSE NULL::integer
        END AS org4id,
        CASE
            WHEN of.org4id IS NOT NULL THEN of.org1desc
            ELSE NULL::character varying
        END AS org4desc,
        CASE
            WHEN of.org4id IS NOT NULL THEN of.org1code
            ELSE NULL::bpchar
        END AS org4code,
        CASE
            WHEN of.org4id IS NOT NULL THEN of.org1type
            ELSE NULL::bpchar
        END AS org4type,
        CASE
            WHEN of.org4id IS NOT NULL THEN of.org1effdt
            ELSE NULL::date
        END AS org4effdt,
        CASE
            WHEN of.org4id IS NOT NULL THEN of.org1enddt
            ELSE NULL::date
        END AS org4enddt
   FROM ( SELECT distinct cor.companyid,
            oc.organizationid AS org1id,
            oc.organizationdesc AS org1desc,
            oc.organizationtype AS org1type,
            oc.orgcode AS org1code,
            oc.organizationevent AS org1event,
            oc.effectivedate AS org1effdt,
            oc.enddate AS org1enddt,
            orel.orgrelevent AS org1relevent,
            orel.orgreltype AS org1reltype,
            oc2.organizationid AS org2id,
            oc2.organizationdesc AS org2desc,
            oc2.organizationtype AS org2type,
            oc2.orgcode AS org2code,
            oc2.organizationevent AS org2event,
            oc2.effectivedate AS org2effdt,
            oc2.enddate AS org2enddt,
            orel2.orgrelevent AS org2relevent,
            orel2.orgreltype AS org2reltype,
            oc3.organizationid AS org3id,
            oc3.organizationdesc AS org3desc,
            oc3.organizationtype AS org3type,
            oc3.orgcode AS org3code,
            oc3.organizationevent AS org3event,
            oc3.effectivedate AS org3effdt,
            oc3.enddate AS org3enddt,
            orel3.orgrelevent AS org3relevent,
            orel3.orgreltype AS org3reltype,
            oc4.organizationid AS org4id,
            oc4.organizationdesc AS org4desc,
            oc4.organizationtype AS org4type,
            oc4.orgcode AS org4code,
            oc4.organizationevent AS org4event,
            oc4.effectivedate AS org4effdt,
            oc4.enddate AS org4enddt
           FROM company_organization_rel cor
             LEFT JOIN organization_code oc ON cor.organizationid = oc.organizationid AND now() >= oc.createts AND now() <= oc.endts AND 'now'::text::date >= oc.effectivedate AND 'now'::text::date <= oc.enddate
             LEFT JOIN org_rel orel ON oc.organizationid = orel.memberoforgid AND now() >= orel.createts AND now() <= orel.endts AND 'now'::text::date >= orel.effectivedate AND 'now'::text::date <= orel.enddate
             LEFT JOIN organization_code oc2 ON oc2.organizationid = orel.organizationid AND now() >= oc2.createts AND now() <= oc2.endts AND 'now'::text::date >= oc2.effectivedate AND 'now'::text::date <= oc2.enddate
             LEFT JOIN org_rel orel2 ON oc2.organizationid = orel2.memberoforgid AND now() >= orel2.createts AND now() <= orel2.endts AND 'now'::text::date >= orel2.effectivedate AND 'now'::text::date <= orel2.enddate
             LEFT JOIN organization_code oc3 ON oc3.organizationid = orel2.organizationid AND now() >= oc3.createts AND now() <= oc3.endts AND 'now'::text::date >= oc3.effectivedate AND 'now'::text::date <= oc3.enddate
             LEFT JOIN org_rel orel3 ON oc3.organizationid = orel3.memberoforgid AND now() >= orel3.createts AND now() <= orel3.endts AND 'now'::text::date >= orel3.effectivedate AND 'now'::text::date <= orel3.enddate
             LEFT JOIN organization_code oc4 ON oc4.organizationid = orel3.organizationid AND now() >= oc4.createts AND now() <= oc4.endts AND 'now'::text::date >= oc4.effectivedate AND 'now'::text::date <= oc4.enddate
          WHERE now() >= cor.createts AND now() <= cor.endts AND 'now'::text::date >= cor.effectivedate AND 'now'::text::date <= cor.enddate
          order by 4) of
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
