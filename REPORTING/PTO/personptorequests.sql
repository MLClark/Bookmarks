-- View: public.personptorequests

-- DROP VIEW public.personptorequests;

--CREATE OR REPLACE VIEW public.personptorequests AS 
 SELECT ppr.personid,
        CASE
            WHEN ppr.createts >= 'now'::text::date THEN 'Type=NoLink'::text
            WHEN ppr.effectivedate <= 'now'::text::date THEN 'Type=NoLink'::text
            ELSE ''::text
        END AS delete__xlink,
    ' '::character(6) AS delete_,
        CASE
            WHEN ppr.effectivedate > 'now'::text::date THEN 'Type=NoLink'::text
            ELSE ''::text
        END AS update__xlink,
    ' '::character(7) AS update_,
    ppr.ptoplanid,
    ppr.effectivedate,
    ppr.takehours AS ptohours,
    ppr.personactivityreqpid,
        CASE
            WHEN ppr.effectivedate > ppr.enddate OR ppr.endts < now() THEN 'Cancelled'::text
            WHEN ppr.effectivedate <= 'now'::text::date AND ppr.takehours <= 0::numeric THEN 'Refunded'::text
            WHEN ppr.activityrequestsource::text = 'Adjustment'::text THEN 'Adjusted'::text
            WHEN ppr.effectivedate <= 'now'::text::date AND now() >= ppr.createts AND now() <= ppr.endts THEN 'Taken'::text
            WHEN pl.currentstep = 999 THEN
            CASE
                WHEN ppr.createts < now() THEN 'Approved'::text
                WHEN ppr.endts < now() THEN 'Disapproved by '::text || pl.disapprovernames
                ELSE 'Unknown Status'::text
            END
            WHEN pl.currentstep <> 999 THEN 'Pending Approval by '::text || pl.approvernames
            WHEN ppr.createts < now() THEN 'Approved'::text
            ELSE 'Unknown Status'::text
        END AS workflowstatus,
    COALESCE(ppr.activityrequestcomment, pl.processcomment::character varying, ''::character varying) AS processcomment
   FROM person_pto_activity_request ppr
     LEFT JOIN person_pto_request_group pg ON ppr.requestgroupid = pg.requestgroupid
     LEFT JOIN ( SELECT wi.subject,
            wi.currentstep,
            wi.currentsteppersonid,
            wi.operationpid,
            wc.tablename,
            string_agg((pn.fname::text || ' '::text) || pn.lname::text, ', or '::text) AS approvernames,
            (max(pn1.fname::text) || ' '::text) || max(pn1.lname::text) AS disapprovernames,
            max(wil.processcomment::text) AS processcomment
           FROM workflow_instance wi
             LEFT JOIN workflow_instance_log wil ON wi.workflowinstanceid = wil.workflowinstanceid AND wil.workflowinstancelogid = (( SELECT max(wl2.workflowinstancelogid) AS max
                   FROM workflow_instance_log wl2
                  WHERE wl2.workflowinstanceid = wil.workflowinstanceid))
             JOIN workflow_definition wd ON wi.workflowdefinitionid = wd.workflowdefinitionid
             JOIN workflow_control wc ON wd.workflowid = wc.workflowid AND wc.enabled = 'Y'::bpchar AND 'now'::text::date >= wc.effectivedate AND 'now'::text::date <= wc.enddate AND now() >= wc.createts AND now() <= wc.endts AND (wc.tablename = ANY (ARRAY['PERSON_PTO_ACTIVITY_REQUEST'::bpchar, 'PERSON_PTO_REQUEST_GROUP'::bpchar]))
             LEFT JOIN person_names pn ON string_to_array(wi.currentsteppersonid::text, ', '::text) @> ARRAY[pn.personid::text] AND pn.nametype = 'Legal'::bpchar AND 'now'::text::date >= pn.effectivedate AND 'now'::text::date <= pn.enddate AND now() >= pn.createts AND now() <= pn.endts
             LEFT JOIN person_names pn1 ON wil.currentpersonid = pn1.personid AND pn1.nametype = 'Legal'::bpchar AND 'now'::text::date >= pn1.effectivedate AND 'now'::text::date <= pn1.enddate AND now() >= pn1.createts AND now() <= pn1.endts
          GROUP BY wi.subject, wi.currentstep, wi.currentsteppersonid, wi.operationpid, wc.tablename) pl ON pl.subject = ppr.personid AND pl.operationpid =
        CASE
            WHEN pl.tablename = 'PERSON_PTO_REQUEST_GROUP'::bpchar THEN pg.persptoreqgrouppid
            ELSE ppr.personactivityreqpid
        END
  WHERE now() < ppr.endts AND ('now'::text::date <= ppr.effectivedate OR 'now'::text::date >= ppr.planyearstart AND 'now'::text::date <= ppr.planyearend AND ppr.createts = ppr.endts) AND ppr.effectivedate <= ppr.enddate AND ppr.reasoncode::text = 'REQ'::text;
/*
ALTER TABLE public.personptorequests
  OWNER TO postgres;
GRANT ALL ON TABLE public.personptorequests TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.personptorequests TO read_write;
GRANT SELECT ON TABLE public.personptorequests TO read_only;
*/