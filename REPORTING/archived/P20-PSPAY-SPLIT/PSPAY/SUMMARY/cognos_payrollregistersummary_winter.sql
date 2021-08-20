CREATE OR REPLACE VIEW public.cognos_payrollregistersummary_winter AS 
 SELECT cognos_payrollregistersummary_winter_mv.personid,
    cognos_payrollregistersummary_winter_mv.employeename,
    cognos_payrollregistersummary_winter_mv.employeenamelastfirst,
    cognos_payrollregistersummary_winter_mv.paymentheaderid,
    cognos_payrollregistersummary_winter_mv.employeeid,
    cognos_payrollregistersummary_winter_mv.check_date,
    cognos_payrollregistersummary_winter_mv.group_key,
    cognos_payrollregistersummary_winter_mv.periodstartdate,
    cognos_payrollregistersummary_winter_mv.periodenddate,
    cognos_payrollregistersummary_winter_mv.checkno,
    cognos_payrollregistersummary_winter_mv.net_pay,
    cognos_payrollregistersummary_winter_mv.gross_pay,
    cognos_payrollregistersummary_winter_mv.ssn,
    cognos_payrollregistersummary_winter_mv.payscheduleperiodid,
    cognos_payrollregistersummary_winter_mv.payperiodstartdate,
    cognos_payrollregistersummary_winter_mv.payperiodenddate,
    cognos_payrollregistersummary_winter_mv.periodpaydate,
    cognos_payrollregistersummary_winter_mv.pspaypayrollid,
    cognos_payrollregistersummary_winter_mv.payment_number,
    cognos_payrollregistersummary_winter_mv.dept,
    cognos_payrollregistersummary_winter_mv.deptcode,
    cognos_payrollregistersummary_winter_mv.divcode,
    cognos_payrollregistersummary_winter_mv.divdesc,
    cognos_payrollregistersummary_winter_mv.emplstatusdesc,
    cognos_payrollregistersummary_winter_mv.currentrate,
    cognos_payrollregistersummary_winter_mv.payunitid,
    cognos_payrollregistersummary_winter_mv.has_disbursements,
    cognos_payrollregistersummary_winter_mv.is_directdeposit,
    cognos_payrollregistersummary_winter_mv.is_livecheck,
    cognos_payrollregistersummary_winter_mv.is_immediatecheck,
    cognos_payrollregistersummary_winter_mv.is_adjustment,
    cognos_payrollregistersummary_winter_mv.is_postpayment,
    cognos_payrollregistersummary_winter_mv.is_voided,
    cognos_payrollregistersummary_winter_mv.is_reissued,
    cognos_payrollregistersummary_winter_mv.payrollfinal
   FROM cognos_payrollregistersummary_winter_mv;

ALTER TABLE public.cognos_payrollregistersummary_winter
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_payrollregistersummary_winter TO postgres;
GRANT SELECT ON TABLE public.cognos_payrollregistersummary_winter TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_payrollregistersummary_winter TO read_write;
