-- Materialized View: payroll.cognos_payrollregisterearnings_mv
DROP VIEW payroll.cognos_payrollregisterearnings;
DROP MATERIALIZED VIEW payroll.cognos_payrollregisterearnings_mv;

CREATE MATERIALIZED VIEW payroll.cognos_payrollregisterearnings_mv AS 
 SELECT ph.personid,
    ph.paymentheaderid,
    pp.pspaypayrollid,
    pes.personearnsetuppid,
    pd.paycode AS etv_id,
    pd.paycode::text || COALESCE('-'::text || pc.paycodeshortdesc::text, ''::text) AS etvname,
    pd.amount,
    pd.units AS hours,
    pd.rate,
    ph.net_pay,
    ph.gross_pay,
    pd.units_ytd AS ytd_hrs,
    pd.amount_ytd AS ytd_amount,
    pd.subject_wages_ytd AS ytd_wage
   FROM payroll.payment_header ph
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar AND cp.companyparametervalue::text = 'P20'::text
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN payroll.payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND (pd.amount_ytd <> 0::numeric OR pd.units_ytd <> 0::numeric OR pd.amount <> 0::numeric OR pd.units <> 0::numeric) AND ((pd.paycode::text IN ( SELECT DISTINCT person_earning_setup.etvid AS paycode
           FROM person_earning_setup
          WHERE 'now'::text::date >= person_earning_setup.effectivedate AND 'now'::text::date <= person_earning_setup.enddate AND now() >= person_earning_setup.createts AND now() <= person_earning_setup.endts)) OR (pd.paycode::text IN ( SELECT DISTINCT pay_codes.paycode
           FROM payroll.pay_codes
          WHERE (pay_codes.paycodetypeid = ANY (ARRAY[1, 2, 7, 10])) AND 'now'::text::date >= pay_codes.effectivedate AND 'now'::text::date <= pay_codes.enddate AND now() >= pay_codes.createts AND now() <= pay_codes.endts)))
     JOIN payroll.pay_codes pc ON pc.paycode::text = pd.paycode::text AND ph.check_date >= pc.effectivedate AND ph.check_date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[1, 2, 7, 10]))
     JOIN pay_unit pu ON pu.payunitid = ph.payunitid AND now() >= pu.createts AND now() <= pu.endts
     LEFT JOIN person_earning_setup pes ON ph.personid = pes.personid AND pes.etvid::text = pd.paycode::text AND psp.periodpaydate >= pes.effectivedate AND psp.periodpaydate <= pes.enddate AND now() >= pes.createts AND now() <= pes.endts
WITH DATA;

ALTER TABLE payroll.cognos_payrollregisterearnings_mv
  OWNER TO ehcmuser;
GRANT ALL ON TABLE payroll.cognos_payrollregisterearnings_mv TO ehcmuser;
GRANT SELECT ON TABLE payroll.cognos_payrollregisterearnings_mv TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_payrollregisterearnings_mv TO read_write;

-- Index: payroll.ix_cognos_payrollregisterearnings_mv

-- DROP INDEX payroll.ix_cognos_payrollregisterearnings_mv;

CREATE INDEX ix_cognos_payrollregisterearnings_mv
  ON payroll.cognos_payrollregisterearnings_mv
  USING btree
  (paymentheaderid);

-- Index: payroll.ix_cognos_payrollregisterearnings_payrollid

-- DROP INDEX payroll.ix_cognos_payrollregisterearnings_payrollid;

CREATE INDEX ix_cognos_payrollregisterearnings_payrollid
  ON payroll.cognos_payrollregisterearnings_mv
  USING btree
  (pspaypayrollid);

-- View: payroll.cognos_payrollregisterearnings

-- DROP VIEW payroll.cognos_payrollregisterearnings;

CREATE OR REPLACE VIEW payroll.cognos_payrollregisterearnings AS 
 SELECT cognos_payrollregisterearnings_mv.personid,
    cognos_payrollregisterearnings_mv.paymentheaderid,
    cognos_payrollregisterearnings_mv.pspaypayrollid,
    cognos_payrollregisterearnings_mv.personearnsetuppid,
    cognos_payrollregisterearnings_mv.etv_id,
    cognos_payrollregisterearnings_mv.etvname,
    cognos_payrollregisterearnings_mv.amount,
    cognos_payrollregisterearnings_mv.hours,
    cognos_payrollregisterearnings_mv.rate,
    cognos_payrollregisterearnings_mv.net_pay,
    cognos_payrollregisterearnings_mv.gross_pay,
    cognos_payrollregisterearnings_mv.ytd_hrs,
    cognos_payrollregisterearnings_mv.ytd_amount,
    cognos_payrollregisterearnings_mv.ytd_wage
   FROM payroll.cognos_payrollregisterearnings_mv;

ALTER TABLE payroll.cognos_payrollregisterearnings
  OWNER TO ehcmuser;
GRANT ALL ON TABLE payroll.cognos_payrollregisterearnings TO ehcmuser;
GRANT SELECT ON TABLE payroll.cognos_payrollregisterearnings TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_payrollregisterearnings TO read_write;
