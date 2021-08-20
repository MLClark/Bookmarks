CREATE OR REPLACE VIEW payroll.cognos_payrollregistersummary AS 
 SELECT cognos_payrollregistersummary_mv.personid,
    cognos_payrollregistersummary_mv.employeename,
    cognos_payrollregistersummary_mv.employeenamelastfirst,
    cognos_payrollregistersummary_mv.paymentheaderid,
    cognos_payrollregistersummary_mv.employeeid,
    cognos_payrollregistersummary_mv.check_date,
    cognos_payrollregistersummary_mv.group_key,
    cognos_payrollregistersummary_mv.periodstartdate,
    cognos_payrollregistersummary_mv.periodenddate,
    cognos_payrollregistersummary_mv.checkno,
    cognos_payrollregistersummary_mv.net_pay,
    cognos_payrollregistersummary_mv.gross_pay,
    cognos_payrollregistersummary_mv.ssn,
    cognos_payrollregistersummary_mv.payscheduleperiodid,
    cognos_payrollregistersummary_mv.payperiodstartdate,
    cognos_payrollregistersummary_mv.payperiodenddate,
    cognos_payrollregistersummary_mv.periodpaydate,
    cognos_payrollregistersummary_mv.pspaypayrollid,
    cognos_payrollregistersummary_mv.payment_number,
    cognos_payrollregistersummary_mv.dept,
    cognos_payrollregistersummary_mv.deptcode,
    cognos_payrollregistersummary_mv.divcode,
    cognos_payrollregistersummary_mv.divdesc,
    cognos_payrollregistersummary_mv.emplstatusdesc,
    cognos_payrollregistersummary_mv.currentrate,
    cognos_payrollregistersummary_mv.payunitid,
    cognos_payrollregistersummary_mv.has_disbursements,
    cognos_payrollregistersummary_mv.is_directdeposit,
    cognos_payrollregistersummary_mv.is_livecheck,
    cognos_payrollregistersummary_mv.is_immediatecheck,
    cognos_payrollregistersummary_mv.is_adjustment,
    cognos_payrollregistersummary_mv.is_postpayment,
    cognos_payrollregistersummary_mv.is_voided,
    cognos_payrollregistersummary_mv.is_reissued,
    cognos_payrollregistersummary_mv.payrollfinal
   FROM payroll.cognos_payrollregistersummary_mv;

ALTER TABLE payroll.cognos_payrollregistersummary
  OWNER TO postgres;
GRANT ALL ON TABLE payroll.cognos_payrollregistersummary TO postgres;
GRANT SELECT ON TABLE payroll.cognos_payrollregistersummary TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_payrollregistersummary TO read_write;
