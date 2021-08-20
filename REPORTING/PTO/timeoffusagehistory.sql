-- View: public.timeoffusagehistory

-- DROP VIEW public.timeoffusagehistory;

--CREATE OR REPLACE VIEW public.timeoffusagehistory AS 
 SELECT p.personid,
    p.personactivityreqpid,
    p.ptoplanid,
    p.payyear,
    ppd.ptoplandesc,
    p.processdate,
        CASE
            WHEN p.processtype = 'Request'::text AND p.processdate < 'now'::text::date THEN 'Taken'::text
            ELSE p.processtype
        END AS processtype,
    p.ptohoursused,
    p.ptohoursaccrued,
    p.ptohoursbanked,
        CASE
            WHEN p.processdate < (pe.empllasthiredate + '1 day'::interval * ppd.ptovestingperiod::double precision) THEN (round(p.vestingperiodholding, 2) || ' Withheld Until: '::text) || (pe.empllasthiredate + '1 day'::interval * ppd.ptovestingperiod::double precision)::date
            ELSE 'Fully Vested'::text
        END AS vestingholdings,
    sum(p.ptohoursaccrued + p.ptohoursbanked - (p.ptohoursused + p.vestingperiodholding)) OVER (PARTITION BY p.personid, p.ptoplanid, p.planyearstart ORDER BY p.processdate) AS ptobalance,
    p.ptonote,
    p.planyearstart,
    p.planyearend
   FROM ( SELECT par.personid,
            min(par.personactivityreqpid) AS personactivityreqpid,
            par.ptoplanid,
            ( SELECT date_part('year'::text, par.planyearstart) AS date_part) AS payyear,
            par.planyearstart,
            par.effectivedate AS processdate,
            string_agg(par.activityrequestsource::text, ', '::text) AS processtype,
            sum(par.takehours) AS ptohoursused,
            sum(par.accruehours) AS ptohoursaccrued,
            sum(par.bankhours) AS ptohoursbanked,
            sum(par.vestingperiodholding) AS vestingperiodholding,
            string_agg(par.activityrequestcomment::text, ', '::text) AS ptonote,
            par.planyearend
           FROM person_pto_activity_request par
          WHERE now() >= par.createts AND now() <= par.endts AND 'now'::text::date >= par.effectivedate AND 'now'::text::date <= par.enddate OR par.createts = par.endts AND par.enddate >= par.effectivedate
          GROUP BY par.personid, par.ptoplanid, par.planyearstart, par.planyearend, par.effectivedate) p
     JOIN pto_plan_desc ppd ON p.ptoplanid = ppd.ptoplanid AND 'now'::text::date >= ppd.effectivedate AND 'now'::text::date <= ppd.enddate AND now() >= ppd.createts AND now() <= ppd.endts
     JOIN person_employment pe ON p.personid = pe.personid AND now() >= pe.effectivedate AND now() <= pe.enddate AND 'now'::text::date >= pe.createts AND 'now'::text::date <= pe.endts AND (@ (p.ptohoursused + (@ (p.ptohoursaccrued + (@ (p.ptohoursbanked + (@ p.vestingperiodholding))))))) <> 0::numeric;

/*
ALTER TABLE public.timeoffusagehistory
  OWNER TO postgres;
GRANT ALL ON TABLE public.timeoffusagehistory TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.timeoffusagehistory TO read_write;
GRANT SELECT ON TABLE public.timeoffusagehistory TO read_only;
*/
