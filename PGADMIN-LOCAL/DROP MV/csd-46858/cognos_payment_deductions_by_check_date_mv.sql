------------------------------------------------------------------------------------------------------------------------------------------------
----- csd-46858 bug in public.cognos_payment_deductions_by_check_date_mv  - need to check createts and endts on person_identity table join -----
------------------------------------------------------------------------------------------------------------------------------------------------

-- Materialized View: public.cognos_payment_deductions_by_check_date_mv
/*
[Code: 0, SQL State: 2BP01]  ERROR: cannot drop materialized view cognos_payment_deductions_by_check_date_mv because other objects depend on it Detail: materialized view cognos_payment_deductions_by_month_mv depends on materialized view cognos_payment_deductions_by_check_date_mv
view cognos_payment_deductions_by_month depends on materialized view cognos_payment_deductions_by_month_mv
materialized view cognos_payment_deductions_by_quarter_mv depends on materialized view cognos_payment_deductions_by_month_mv
view cognos_payment_deductions_by_quarter depends on materialized view cognos_payment_deductions_by_quarter_mv
materialized view cognos_payment_deductions_by_year_mv depends on materialized view cognos_payment_deductions_by_quarter_mv
view cognos_payment_deductions_by_year depends on materialized view cognos_payment_deductions_by_year_mv
  Hint: Use DROP ... CASCADE to drop the dependent objects too.
*/

DROP VIEW public.cognos_payment_deductions_by_month;

DROP VIEW public.cognos_payment_deductions_by_quarter;

DROP VIEW public.cognos_payment_deductions_by_year;

DROP VIEW public.cognos_payment_deductions_by_check_date;

DROP MATERIALIZED VIEW public.cognos_payment_deductions_by_year_mv;

DROP MATERIALIZED VIEW public.cognos_payment_deductions_by_quarter_mv;

DROP MATERIALIZED VIEW public.cognos_payment_deductions_by_month_mv;

DROP MATERIALIZED VIEW public.cognos_payment_deductions_by_check_date_mv;

CREATE MATERIALIZED VIEW public.cognos_payment_deductions_by_check_date_mv AS 
(
         SELECT ppds.individual_key,
            ppds.check_date,
            ppds.check_number,
            ppds.payment_number::character(5) AS payment_number,
            ppds.etv_code,
            etv.etv_name,
            ppds.etv_id,
            ppds.etv_amount,
            ppds.etv_taxable_wage,
            ppds.etype_hours,
            ppds.etype_rate,
            ppds.ttype_tax_code,
            ppds.group_key AS payunitxid,
            ppds.last_updt_dt,
            ppds.ttypetaxpct,
            ppds.personid,
            ppds.paymentheaderid,
            ppds.arrears_taken,
            ppds.arrears_balance,
            pph.state_dn03_code,
            "left"(ppds.ttype_tax_code::text, 2) AS federalstateid,
            "right"(ppds.ttype_tax_code::text, 4) AS taxjurisdictionid,
            ppds.etv_amount_ytd,
            ppds.etv_amount_q1td,
            ppds.etv_amount_q2td,
            ppds.etv_amount_q3td,
            ppds.etv_amount_q4td
           FROM pspay_payment_detail ppds
             JOIN pspay_payment_header pph ON pph.paymentheaderid = ppds.paymentheaderid AND (pph.payrollfinal = 'Y'::bpchar OR pph.payrollfinal IS NULL)
             LEFT JOIN cognos_pspay_etv_names etv ON ppds.etv_id::text = etv.etv_id::text AND ppds.group_key = etv.group_key
          WHERE date_part('year'::text, ppds.check_date) >= (date_part('year'::text, 'now'::text::date) - 2::double precision) AND "left"(ppds.etv_id::text, 1) = 'V'::text AND (ppds.etv_id::bpchar <> ALL (ARRAY['VAY'::bpchar, 'VAX'::bpchar, 'VAZ'::bpchar]))
        UNION ALL
         SELECT ppds.individual_key,
            ppds.check_date,
            ppds.check_number,
            ppds.payment_number::character(5) AS payment_number,
            ppds.etv_code,
            etv.etv_name,
            ppds.etv_id,
            ppds.etv_amount,
            ppds.etv_taxable_wage,
            ppds.etype_hours,
            ppds.etype_rate,
            ppds.ttype_tax_code,
            ppds.group_key AS payunitxid,
            ppds.last_updt_dt,
            ppds.ttypetaxpct,
            ppds.personid,
            ppds.paymentheaderid,
            ppds.arrears_taken,
            ppds.arrears_balance,
            pph.state_dn03_code,
            "left"(ppds.ttype_tax_code::text, 2) AS federalstateid,
            "right"(ppds.ttype_tax_code::text, 4) AS taxjurisdictionid,
            ppds.etv_amount_ytd,
            ppds.etv_amount_q1td,
            ppds.etv_amount_q2td,
            ppds.etv_amount_q3td,
            ppds.etv_amount_q4td
           FROM pspay_payment_detail_archive ppds
           JOIN pspay_payment_header_archive pph ON pph.paymentheaderid = ppds.paymentheaderid AND (pph.payrollfinal = 'Y'::bpchar OR pph.payrollfinal IS NULL)
           LEFT JOIN cognos_pspay_etv_names etv ON ppds.etv_id::text = etv.etv_id::text AND ppds.group_key = etv.group_key
          WHERE date_part('year'::text, ppds.check_date) >= (date_part('year'::text, 'now'::text::date) - 2::double precision) AND "left"(ppds.etv_id::text, 1) = 'V'::text AND (ppds.etv_id::bpchar <> ALL (ARRAY['VAY'::bpchar, 'VAX'::bpchar, 'VAZ'::bpchar]))
) UNION
 SELECT pi.identity AS individual_key,
    ppds.check_date,
    pph.check_number,
    pph.sequencenumber::character(5) AS payment_number,
        CASE
            WHEN pc.paycodetypeid = ANY (ARRAY[6, 8]) THEN 'ER'::text
            ELSE 'EE'::text
        END AS etv_code,
    pc.paycodeshortdesc AS etv_name,
    pc.paycode AS etv_id,
    ppds.amount AS etv_amount,
    ppds.subject_wages AS etv_taxable_wage,
    ppds.units AS etype_hours,
    ppds.rate AS etype_rate,
    ''::bpchar AS ttype_tax_code,
    dx.companycode::text || pu.payunitxid::text AS payunitxid,
    COALESCE(ppds.updatets, ppds.createts) AS last_updt_dt,
    ''::bpchar AS ttypetaxpct,
    ppds.personid,
    ppds.paymentheaderid,
    NULL::numeric AS arrears_taken,
    NULL::numeric AS arrears_balance,
    ''::bpchar AS state_dn03_code,
    ''::text AS federalstateid,
    ''::text AS taxjurisdictionid,
    ppds.amount_ytd AS etv_amount_ytd,
    ppds.amount_q1td AS etv_amount_q1td,
    ppds.amount_q2td AS etv_amount_q2td,
    ppds.amount_q3td AS etv_amount_q3td,
    ppds.amount_q4td AS etv_amount_q4td
   FROM payroll.payment_detail ppds
     JOIN payroll.payment_header pph ON pph.paymentheaderid = ppds.paymentheaderid
     JOIN person_identity pi ON pi.personid = pph.personid AND pi.identitytype = 'PSPID'::bpchar 
      and current_timestamp between pi.createts and pi.endts  --<<<-- csd-46858
     JOIN pay_unit pu ON pph.payunitid = pu.payunitid
     JOIN dxcompanyname dx ON dx.companyid = pu.companyid
     JOIN payroll.pay_codes pc ON pc.paycode::text = ppds.paycode::text AND pc.uidisplay = 'Y'::bpchar AND pph.check_date >= pc.effectivedate AND pph.check_date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[6])) AND pc.paycode::text ~~ '%-ER'::text
  WHERE date_part('year'::text, ppds.check_date) >= (date_part('year'::text, 'now'::text::date) - 2::double precision)
WITH DATA;

ALTER TABLE public.cognos_payment_deductions_by_check_date_mv
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_check_date_mv TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_payment_deductions_by_check_date_mv TO read_write;
GRANT SELECT ON TABLE public.cognos_payment_deductions_by_check_date_mv TO read_only;

-- View: public.cognos_payment_deductions_by_check_date

-- DROP VIEW public.cognos_payment_deductions_by_check_date;

CREATE VIEW public.cognos_payment_deductions_by_check_date AS 
 SELECT cognos_payment_deductions_by_check_date_mv.individual_key,
    cognos_payment_deductions_by_check_date_mv.check_date,
    cognos_payment_deductions_by_check_date_mv.check_number,
    cognos_payment_deductions_by_check_date_mv.payment_number,
    cognos_payment_deductions_by_check_date_mv.etv_code,
    cognos_payment_deductions_by_check_date_mv.etv_name,
    cognos_payment_deductions_by_check_date_mv.etv_id,
    cognos_payment_deductions_by_check_date_mv.etv_amount,
    cognos_payment_deductions_by_check_date_mv.etv_taxable_wage,
    cognos_payment_deductions_by_check_date_mv.etype_hours,
    cognos_payment_deductions_by_check_date_mv.etype_rate,
    cognos_payment_deductions_by_check_date_mv.ttype_tax_code,
    cognos_payment_deductions_by_check_date_mv.payunitxid,
    cognos_payment_deductions_by_check_date_mv.last_updt_dt,
    cognos_payment_deductions_by_check_date_mv.ttypetaxpct,
    cognos_payment_deductions_by_check_date_mv.personid,
    cognos_payment_deductions_by_check_date_mv.paymentheaderid,
    cognos_payment_deductions_by_check_date_mv.arrears_taken,
    cognos_payment_deductions_by_check_date_mv.arrears_balance,
    cognos_payment_deductions_by_check_date_mv.state_dn03_code,
    cognos_payment_deductions_by_check_date_mv.federalstateid,
    cognos_payment_deductions_by_check_date_mv.taxjurisdictionid,
    cognos_payment_deductions_by_check_date_mv.etv_amount_ytd,
    cognos_payment_deductions_by_check_date_mv.etv_amount_q1td,
    cognos_payment_deductions_by_check_date_mv.etv_amount_q2td,
    cognos_payment_deductions_by_check_date_mv.etv_amount_q3td,
    cognos_payment_deductions_by_check_date_mv.etv_amount_q4td
   FROM cognos_payment_deductions_by_check_date_mv;

ALTER TABLE public.cognos_payment_deductions_by_check_date
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_check_date TO postgres;
GRANT SELECT ON TABLE public.cognos_payment_deductions_by_check_date TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_payment_deductions_by_check_date TO read_write;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_check_date TO skybotsu;

-- Materialized View: public.cognos_payment_deductions_by_month_mv

-- DROP MATERIALIZED VIEW public.cognos_payment_deductions_by_month_mv;

CREATE MATERIALIZED VIEW public.cognos_payment_deductions_by_month_mv AS 
 SELECT cognos_payment_deductions_by_check_date_mv.personid,
    cognos_payment_deductions_by_check_date_mv.payunitxid,
    date_part('year'::text, cognos_payment_deductions_by_check_date_mv.check_date) AS checkyr,
    date_part('month'::text, cognos_payment_deductions_by_check_date_mv.check_date) AS checkmth,
    cognos_payment_deductions_by_check_date_mv.etv_id,
    cognos_payment_deductions_by_check_date_mv.etv_name,
    cognos_payment_deductions_by_check_date_mv.state_dn03_code,
    sum(cognos_payment_deductions_by_check_date_mv.etv_amount) AS etv_amount
   FROM cognos_payment_deductions_by_check_date_mv
  GROUP BY cognos_payment_deductions_by_check_date_mv.personid, cognos_payment_deductions_by_check_date_mv.payunitxid, (date_part('year'::text, cognos_payment_deductions_by_check_date_mv.check_date)), (date_part('month'::text, cognos_payment_deductions_by_check_date_mv.check_date)), cognos_payment_deductions_by_check_date_mv.etv_id, cognos_payment_deductions_by_check_date_mv.etv_name, cognos_payment_deductions_by_check_date_mv.state_dn03_code
  ORDER BY cognos_payment_deductions_by_check_date_mv.personid, cognos_payment_deductions_by_check_date_mv.payunitxid, (date_part('year'::text, cognos_payment_deductions_by_check_date_mv.check_date)), (date_part('month'::text, cognos_payment_deductions_by_check_date_mv.check_date)), cognos_payment_deductions_by_check_date_mv.etv_id, cognos_payment_deductions_by_check_date_mv.etv_name
WITH DATA;

ALTER TABLE public.cognos_payment_deductions_by_month_mv
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_month_mv TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_payment_deductions_by_month_mv TO read_write;
GRANT SELECT ON TABLE public.cognos_payment_deductions_by_month_mv TO read_only;

-- View: public.cognos_payment_deductions_by_month

-- DROP VIEW public.cognos_payment_deductions_by_month;

CREATE VIEW public.cognos_payment_deductions_by_month AS 
 SELECT cognos_payment_deductions_by_month_mv.personid,
    cognos_payment_deductions_by_month_mv.payunitxid,
    cognos_payment_deductions_by_month_mv.checkyr,
    cognos_payment_deductions_by_month_mv.checkmth,
    cognos_payment_deductions_by_month_mv.etv_id,
    cognos_payment_deductions_by_month_mv.etv_name,
    cognos_payment_deductions_by_month_mv.state_dn03_code,
    cognos_payment_deductions_by_month_mv.etv_amount
   FROM cognos_payment_deductions_by_month_mv;

ALTER TABLE public.cognos_payment_deductions_by_month
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_month TO postgres;
GRANT SELECT ON TABLE public.cognos_payment_deductions_by_month TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_payment_deductions_by_month TO read_write;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_month TO skybotsu;

-- Materialized View: public.cognos_payment_deductions_by_quarter_mv

-- DROP MATERIALIZED VIEW public.cognos_payment_deductions_by_quarter_mv;

CREATE MATERIALIZED VIEW public.cognos_payment_deductions_by_quarter_mv AS 
 SELECT cognos_payment_deductions_by_month_mv.personid,
    cognos_payment_deductions_by_month_mv.payunitxid,
    cognos_payment_deductions_by_month_mv.checkyr,
        CASE
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 1::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 3::double precision THEN 1
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 4::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 6::double precision THEN 2
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 7::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 9::double precision THEN 3
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 10::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 12::double precision THEN 4
            ELSE NULL::integer
        END AS checkqtr,
    cognos_payment_deductions_by_month_mv.etv_id,
    cognos_payment_deductions_by_month_mv.etv_name,
    cognos_payment_deductions_by_month_mv.state_dn03_code,
    sum(cognos_payment_deductions_by_month_mv.etv_amount) AS etv_amount
   FROM cognos_payment_deductions_by_month_mv
  GROUP BY cognos_payment_deductions_by_month_mv.personid, cognos_payment_deductions_by_month_mv.payunitxid, cognos_payment_deductions_by_month_mv.checkyr, (
        CASE
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 1::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 3::double precision THEN 1
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 4::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 6::double precision THEN 2
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 7::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 9::double precision THEN 3
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 10::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 12::double precision THEN 4
            ELSE NULL::integer
        END), cognos_payment_deductions_by_month_mv.etv_id, cognos_payment_deductions_by_month_mv.etv_name, cognos_payment_deductions_by_month_mv.state_dn03_code
  ORDER BY cognos_payment_deductions_by_month_mv.personid, cognos_payment_deductions_by_month_mv.payunitxid, cognos_payment_deductions_by_month_mv.checkyr, (
        CASE
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 1::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 3::double precision THEN 1
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 4::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 6::double precision THEN 2
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 7::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 9::double precision THEN 3
            WHEN cognos_payment_deductions_by_month_mv.checkmth >= 10::double precision AND cognos_payment_deductions_by_month_mv.checkmth <= 12::double precision THEN 4
            ELSE NULL::integer
        END), cognos_payment_deductions_by_month_mv.etv_id, cognos_payment_deductions_by_month_mv.etv_name
WITH DATA;

ALTER TABLE public.cognos_payment_deductions_by_quarter_mv
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_quarter_mv TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_payment_deductions_by_quarter_mv TO read_write;
GRANT SELECT ON TABLE public.cognos_payment_deductions_by_quarter_mv TO read_only;


-- View: public.cognos_payment_deductions_by_quarter

-- DROP VIEW public.cognos_payment_deductions_by_quarter;

CREATE VIEW public.cognos_payment_deductions_by_quarter AS 
 SELECT cognos_payment_deductions_by_quarter_mv.personid,
    cognos_payment_deductions_by_quarter_mv.payunitxid,
    cognos_payment_deductions_by_quarter_mv.checkyr,
    cognos_payment_deductions_by_quarter_mv.checkqtr,
    cognos_payment_deductions_by_quarter_mv.etv_id,
    cognos_payment_deductions_by_quarter_mv.etv_name,
    cognos_payment_deductions_by_quarter_mv.state_dn03_code,
    cognos_payment_deductions_by_quarter_mv.etv_amount
   FROM cognos_payment_deductions_by_quarter_mv;

ALTER TABLE public.cognos_payment_deductions_by_quarter
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_quarter TO postgres;
GRANT SELECT ON TABLE public.cognos_payment_deductions_by_quarter TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_payment_deductions_by_quarter TO read_write;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_quarter TO skybotsu;


-- Materialized View: public.cognos_payment_deductions_by_year_mv

-- DROP MATERIALIZED VIEW public.cognos_payment_deductions_by_year_mv;

CREATE MATERIALIZED VIEW public.cognos_payment_deductions_by_year_mv AS 
 SELECT cognos_payment_deductions_by_quarter_mv.personid,
    cognos_payment_deductions_by_quarter_mv.payunitxid,
    cognos_payment_deductions_by_quarter_mv.checkyr,
    cognos_payment_deductions_by_quarter_mv.etv_id,
    cognos_payment_deductions_by_quarter_mv.etv_name,
    cognos_payment_deductions_by_quarter_mv.state_dn03_code,
    sum(cognos_payment_deductions_by_quarter_mv.etv_amount) AS etv_amount
   FROM cognos_payment_deductions_by_quarter_mv
  GROUP BY cognos_payment_deductions_by_quarter_mv.personid, cognos_payment_deductions_by_quarter_mv.payunitxid, cognos_payment_deductions_by_quarter_mv.checkyr, cognos_payment_deductions_by_quarter_mv.etv_id, cognos_payment_deductions_by_quarter_mv.etv_name, cognos_payment_deductions_by_quarter_mv.state_dn03_code
  ORDER BY cognos_payment_deductions_by_quarter_mv.personid, cognos_payment_deductions_by_quarter_mv.payunitxid, cognos_payment_deductions_by_quarter_mv.checkyr, cognos_payment_deductions_by_quarter_mv.etv_id, cognos_payment_deductions_by_quarter_mv.etv_name
WITH DATA;

ALTER TABLE public.cognos_payment_deductions_by_year_mv
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_year_mv TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_payment_deductions_by_year_mv TO read_write;
GRANT SELECT ON TABLE public.cognos_payment_deductions_by_year_mv TO read_only;

-- View: public.cognos_payment_deductions_by_year

-- DROP VIEW public.cognos_payment_deductions_by_year;

CREATE VIEW public.cognos_payment_deductions_by_year AS 
 SELECT cognos_payment_deductions_by_year_mv.personid,
    cognos_payment_deductions_by_year_mv.payunitxid,
    cognos_payment_deductions_by_year_mv.checkyr,
    cognos_payment_deductions_by_year_mv.etv_id,
    cognos_payment_deductions_by_year_mv.etv_name,
    cognos_payment_deductions_by_year_mv.state_dn03_code,
    cognos_payment_deductions_by_year_mv.etv_amount
   FROM cognos_payment_deductions_by_year_mv;

ALTER TABLE public.cognos_payment_deductions_by_year
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_year TO postgres;
GRANT SELECT ON TABLE public.cognos_payment_deductions_by_year TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_payment_deductions_by_year TO read_write;
GRANT ALL ON TABLE public.cognos_payment_deductions_by_year TO skybotsu;
