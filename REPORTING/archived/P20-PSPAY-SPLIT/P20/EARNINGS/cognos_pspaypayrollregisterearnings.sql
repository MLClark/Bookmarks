CREATE OR REPLACE VIEW payroll.cognos_pspaypayrollregisterearnings AS 
 SELECT cognos_pspaypayrollregisterearnings_mv.personid,
    cognos_pspaypayrollregisterearnings_mv.paymentheaderid,
    cognos_pspaypayrollregisterearnings_mv.pspaypayrollid,
    cognos_pspaypayrollregisterearnings_mv.personearnsetuppid,
    cognos_pspaypayrollregisterearnings_mv.etv_id,
    cognos_pspaypayrollregisterearnings_mv.etvname,
    cognos_pspaypayrollregisterearnings_mv.amount,
    cognos_pspaypayrollregisterearnings_mv.hours,
    cognos_pspaypayrollregisterearnings_mv.rate,
    cognos_pspaypayrollregisterearnings_mv.net_pay,
    cognos_pspaypayrollregisterearnings_mv.gross_pay,
    cognos_pspaypayrollregisterearnings_mv.ytd_hrs,
    cognos_pspaypayrollregisterearnings_mv.ytd_amount,
    cognos_pspaypayrollregisterearnings_mv.ytd_wage
   FROM payroll.cognos_pspaypayrollregisterearnings_mv;

ALTER TABLE payroll.cognos_pspaypayrollregisterearnings
  OWNER TO postgres;
GRANT ALL ON TABLE payroll.cognos_pspaypayrollregisterearnings TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_pspaypayrollregisterearnings TO read_write;
GRANT SELECT ON TABLE payroll.cognos_pspaypayrollregisterearnings TO read_only;
