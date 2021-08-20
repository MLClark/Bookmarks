-- Materialized View: payroll.cognos_payrollregisterdeductions_mv

/*
ERROR:  cannot drop materialized view payroll.cognos_payrollregisterdeductions_mv because other objects depend on it
DETAIL:  view payroll.cognos_payrollregisterdeductions depends on materialized view payroll.cognos_payrollregisterdeductions_mv
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
SQL state: 2BP01
*/

DROP VIEW payroll.cognos_payrollregisterdeductions;
DROP MATERIALIZED VIEW payroll.cognos_payrollregisterdeductions_mv;

CREATE MATERIALIZED VIEW payroll.cognos_payrollregisterdeductions_mv AS 
 SELECT ph.personid,
    ph.paymentheaderid,
    pp.pspaypayrollid,
    pgs.persongarnishmentsetuppid,
    pd.paycode AS etv_id,
    pd.paycode::text || COALESCE('-'::text ||
        CASE
            WHEN gt.garntypedesc IS NOT NULL THEN gt.garntypedesc
            ELSE NULL::character varying
        END::text, '-'::text || pc.paycodeshortdesc::text, ''::text) AS etvname,
    pd.amount,
    pd.units AS hours,
    ph.net_pay,
    ph.gross_pay,
    pd.amount_ytd AS ytd_amount,
    pd.subject_wages_ytd AS ytd_wage,
        CASE
            WHEN pc.paycodetypeid = 6 THEN 'Y'::bpchar
            ELSE 'N'::bpchar
        END AS isemployer
   FROM payroll.payment_header ph
     JOIN payroll.payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND (pd.amount_ytd <> 0::numeric OR pd.units_ytd <> 0::numeric OR pd.amount <> 0::numeric OR pd.units <> 0::numeric)
     JOIN company_parameters ON company_parameters.companyparametername = 'PInt'::bpchar AND company_parameters.companyparametervalue::text = 'P20'::text
     JOIN payroll.pay_codes pc ON pc.paycode::text = pd.paycode::text AND ph.check_date >= pc.effectivedate AND ph.check_date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[3, 6]))
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     LEFT JOIN person_garnishment_setup pgs ON ph.personid = pgs.personid AND pgs.etvid::text = pd.paycode::text AND psp.periodpaydate >= pgs.effectivedate AND psp.periodpaydate <= pgs.enddate AND now() >= pgs.createts AND now() <= pgs.endts
     LEFT JOIN garnishment_type gt ON pgs.garnishmenttype = gt.garntype
WITH DATA;

ALTER TABLE payroll.cognos_payrollregisterdeductions_mv
  OWNER TO ehcmuser;
GRANT ALL ON TABLE payroll.cognos_payrollregisterdeductions_mv TO ehcmuser;
GRANT SELECT ON TABLE payroll.cognos_payrollregisterdeductions_mv TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_payrollregisterdeductions_mv TO read_write;

CREATE OR REPLACE VIEW payroll.cognos_payrollregisterdeductions AS 
 SELECT cognos_payrollregisterdeductions_mv.personid,
    cognos_payrollregisterdeductions_mv.paymentheaderid,
    cognos_payrollregisterdeductions_mv.pspaypayrollid,
    cognos_payrollregisterdeductions_mv.persongarnishmentsetuppid,
    cognos_payrollregisterdeductions_mv.etv_id,
    cognos_payrollregisterdeductions_mv.etvname,
    cognos_payrollregisterdeductions_mv.amount,
    cognos_payrollregisterdeductions_mv.hours,
    cognos_payrollregisterdeductions_mv.net_pay,
    cognos_payrollregisterdeductions_mv.gross_pay,
    cognos_payrollregisterdeductions_mv.ytd_amount,
    cognos_payrollregisterdeductions_mv.ytd_wage,
    cognos_payrollregisterdeductions_mv.isemployer
   FROM payroll.cognos_payrollregisterdeductions_mv;

ALTER TABLE payroll.cognos_payrollregisterdeductions
  OWNER TO ehcmuser;
GRANT ALL ON TABLE payroll.cognos_payrollregisterdeductions TO ehcmuser;
GRANT SELECT ON TABLE payroll.cognos_payrollregisterdeductions TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_payrollregisterdeductions TO read_write;
