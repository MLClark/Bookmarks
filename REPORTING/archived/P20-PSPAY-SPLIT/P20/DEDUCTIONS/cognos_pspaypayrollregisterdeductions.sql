CREATE OR REPLACE VIEW payroll.cognos_pspaypayrollregisterdeductions AS 
 SELECT cognos_pspaypayrollregisterdeductions_mv.personid,
    cognos_pspaypayrollregisterdeductions_mv.paymentheaderid,
    cognos_pspaypayrollregisterdeductions_mv.pspaypayrollid,
    cognos_pspaypayrollregisterdeductions_mv.persondedsetuppid,
    cognos_pspaypayrollregisterdeductions_mv.persongarnishmentsetuppid,
    cognos_pspaypayrollregisterdeductions_mv.etv_id,
    cognos_pspaypayrollregisterdeductions_mv.etvname,
    cognos_pspaypayrollregisterdeductions_mv.amount,
    cognos_pspaypayrollregisterdeductions_mv.hours,
    cognos_pspaypayrollregisterdeductions_mv.net_pay,
    cognos_pspaypayrollregisterdeductions_mv.gross_pay,
    cognos_pspaypayrollregisterdeductions_mv.ytd_amount,
    cognos_pspaypayrollregisterdeductions_mv.ytd_wage,
    cognos_pspaypayrollregisterdeductions_mv.isemployer
   FROM payroll.cognos_pspaypayrollregisterdeductions_mv;

ALTER TABLE payroll.cognos_pspaypayrollregisterdeductions  OWNER TO postgres;
GRANT ALL ON TABLE payroll.cognos_pspaypayrollregisterdeductions TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_pspaypayrollregisterdeductions TO read_write;
GRANT SELECT ON TABLE payroll.cognos_pspaypayrollregisterdeductions TO read_only;
