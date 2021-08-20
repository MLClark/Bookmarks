--CREATE OR REPLACE VIEW public.cognos_ptorequests AS 
 SELECT pa.personid,
    pa.ptoplanid,
    ppd.ptoplandesc,
    ppd.edtcode,
    pa.createts::date AS activitydate,
    round(pa.takehours, 2) AS hrsrequested,
    pa.effectivedate AS timeoffstartdt,
    pa.effectivedate AS timeoffenddate,
        CASE
            WHEN pa.createts > now() AND pa.enddate >= pa.effectivedate THEN 'New Request'::text
            WHEN pa.effectivedate > pa.enddate THEN 'Cancellation'::text
            WHEN pa.endts < now() THEN 'Disapproved'::text
            WHEN pa.createts <= now() AND pa.effectivedate > 'now'::text::date THEN 'Approved'::text
            WHEN pa.createts <= now() AND pa.effectivedate <= 'now'::text::date THEN 'Taken'::text
            ELSE 'Unknown'::text
        END AS activity,
        CASE
            WHEN pa.createts > now() AND pa.enddate >= pa.effectivedate THEN 'Pending'::text
            WHEN pa.effectivedate > pa.enddate THEN 'Cancelled'::text
            WHEN pa.endts < now() THEN 'Cancelled'::text
            WHEN pa.createts <= now() THEN 'Approved'::text
            ELSE 'Cancelled'::text
        END AS workflowstatus,
    pa.activityrequestsource,
    pa.activityrequestcomment,
    wil.processcomment AS comments,
    date_part('year'::text, pa.planyearstart) AS payyear,
    pa.createts,
    pa.endts,
    wi.workflowinstanceid,
    wil.workflowinstancelogid
   FROM person_pto_activity_request pa
     LEFT JOIN person_pto_request_group prg ON pa.requestgroupid = prg.requestgroupid
     JOIN pto_plan_desc ppd ON pa.ptoplanid = ppd.ptoplanid AND pa.effectivedate >= ppd.effectivedate AND pa.effectivedate <= ppd.enddate AND now() >= ppd.createts AND now() <= ppd.endts
     LEFT JOIN workflow_instance wi ON wi.subject = pa.personid AND
        CASE
            WHEN pa.requestgroupid IS NOT NULL THEN wi.operationpid = prg.persptoreqgrouppid AND (wi.workflowdefinitionid IN ( SELECT wd.workflowdefinitionid
               FROM workflow_control wc
                 JOIN workflow_definition wd ON wd.workflowid = wc.workflowid AND now() >= wd.effectivedate AND now() <= wd.enddate AND now() >= wd.createts AND now() <= wd.endts
              WHERE wc.tablename = 'PERSON_PTO_REQUEST_GROUP'::bpchar AND 'now'::text::date >= wc.effectivedate AND 'now'::text::date <= wc.enddate AND now() >= wc.createts AND now() <= wc.endts AND wc.enabled = 'Y'::bpchar))
            ELSE wi.operationpid = pa.personactivityreqpid AND (wi.workflowdefinitionid IN ( SELECT wd.workflowdefinitionid
               FROM workflow_control wc
                 JOIN workflow_definition wd ON wd.workflowid = wc.workflowid AND now() >= wd.effectivedate AND now() <= wd.enddate AND now() >= wd.createts AND now() <= wd.endts
              WHERE wc.tablename = 'PERSON_PTO_ACTIVITY_REQUEST'::bpchar AND 'now'::text::date >= wc.effectivedate AND 'now'::text::date <= wc.enddate AND now() >= wc.createts AND now() <= wc.endts AND wc.enabled = 'Y'::bpchar))
        END
     LEFT JOIN workflow_instance_log wil ON wi.workflowinstanceid = wil.workflowinstanceid AND wil.workflowinstancelogid = (( SELECT max(wil2.workflowinstancelogid) AS max
           FROM workflow_instance_log wil2
          WHERE wil2.workflowinstanceid = wil.workflowinstanceid AND COALESCE(wil2.processcomment, ''::character varying)::text <> ''::text))
  WHERE pa.reasoncode::text = 'REQ'::text AND pa.takehours <> 0::numeric OR pa.activityrequestsource::text = 'Adjustment'::text;
/*
ALTER TABLE public.cognos_ptorequests
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_ptorequests TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_ptorequests TO read_write;
GRANT SELECT ON TABLE public.cognos_ptorequests TO read_only;
*/
