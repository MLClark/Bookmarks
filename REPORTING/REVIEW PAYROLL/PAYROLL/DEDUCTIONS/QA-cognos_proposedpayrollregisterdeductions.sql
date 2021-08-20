-- View: payroll.cognos_proposedpayrollregisterdeductions

-- DROP VIEW payroll.cognos_proposedpayrollregisterdeductions;

--CREATE OR REPLACE VIEW payroll.cognos_proposedpayrollregisterdeductions AS 
 SELECT ppp.payscheduleperiodid,
    ppp.personid,
    NULL::integer AS paymentheaderid,
    pp.pspaypayrollid,
    pds.persondedsetuppid,
    pgs.persongarnishmentsetuppid,
    st.paycode AS etv_id,
    st.paycode::text || COALESCE(
        CASE
            WHEN gt.garntypedesc IS NOT NULL THEN '-'::text || gt.garntypedesc::text
            ELSE NULL::text
        END, '-'::text || pc.paycodeshortdesc::text, ''::text) AS etvname,
    sum(st.amount) AS amount,
    sum(st.units) AS hours,
    sum(st.rate) AS rate,
    sum(ppp.net_amount) AS net_pay,
    sum(ppp.gross_amount) AS gross_pay,
    sum(COALESCE(st.amount_ytd, 0::numeric)::numeric(18,2)) AS ytd_amount,
    sum(COALESCE(st.subject_wages_ytd, 0::numeric)::numeric(18,2)) AS ytd_wage,
        CASE
            WHEN pc.paycodetypeid = 6 THEN 'T'::text
            ELSE 'F'::text
        END AS isemployer,
    ppp.paymenttype,
    ppp.sequencenumber,
    st.paycodeaffiliationid,
        CASE
            WHEN max(st.benefitplanid) IS NOT NULL THEN true
            ELSE false
        END AS enroll_in_catchup
   FROM payroll.personperiodpayments ppp
     JOIN payroll.staged_transaction st ON ppp.payscheduleperiodid = st.payscheduleperiodid AND ppp.personid = st.personid AND ppp.paymenttype = st.paymenttype AND COALESCE(st.sequencenumber, '~'::character varying)::text = COALESCE(ppp.sequencenumber, '~'::character varying)::text
     LEFT JOIN payroll.pay_code_override pco ON pco.paycode::text = st.paycode::text AND pco.payunitid = ppp.payunitid AND now() >= pco.createts AND now() <= pco.endts
     JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND
        CASE
            WHEN pco.uidisplay IS NOT NULL THEN pco.uidisplay = 'Y'::bpchar
            ELSE pc.uidisplay = 'Y'::bpchar
        END AND ppp.asofdate >= pc.effectivedate AND ppp.asofdate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[3, 6]))
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     LEFT JOIN person_deduction_setup pds ON pds.personid = st.personid AND pds.etvid::text = st.paycode::text AND psp.periodpaydate >= pds.effectivedate AND psp.periodpaydate <= pds.enddate AND now() >= pds.createts AND now() <= pds.endts AND pds.paycodeaffiliationid = st.paycodeaffiliationid
     LEFT JOIN person_garnishment_setup pgs ON pgs.personid = st.personid AND pgs.etvid::text = st.paycode::text AND psp.periodpaydate >= pgs.effectivedate AND psp.periodpaydate <= pgs.enddate AND now() >= pgs.createts AND now() <= pgs.endts
     LEFT JOIN garnishment_type gt ON pgs.garnishmenttype = gt.garntype
  WHERE ppp.net_amount <> 0::numeric
  GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, st.paycode, pc.paycodedesc, pc.paycodeshortdesc, pc.paycodetypeid, ppp.paymenttype, st.taxid, pds.persondedsetuppid, pgs.persongarnishmentsetuppid, gt.garntypedesc, ppp.sequencenumber, st.paycodeaffiliationid
UNION
 SELECT payrollregisterdeductions.payscheduleperiodid,
    payrollregisterdeductions.personid,
    payrollregisterdeductions.paymentheaderid,
    payrollregisterdeductions.pspaypayrollid,
    payrollregisterdeductions.persondedsetuppid,
    payrollregisterdeductions.persongarnishmentsetuppid,
    payrollregisterdeductions.etv_id,
    payrollregisterdeductions.etvname,
    payrollregisterdeductions.amount,
    payrollregisterdeductions.hours,
    payrollregisterdeductions.rate,
    payrollregisterdeductions.net_pay,
    payrollregisterdeductions.gross_pay,
    payrollregisterdeductions.ytd_amount,
    payrollregisterdeductions.ytd_wage,
        CASE
            WHEN payrollregisterdeductions.isemployer THEN 'T'::text
            ELSE 'F'::text
        END AS isemployer,
    payrollregisterdeductions.paymenttype,
    payrollregisterdeductions.sequencenumber,
    payrollregisterdeductions.paycodeaffiliationid,
    payrollregisterdeductions.enroll_in_catchup
   FROM payroll.payrollregisterdeductions
  WHERE (payrollregisterdeductions.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid
                           FROM payroll.staged_transaction))))));
/*
ALTER TABLE payroll.cognos_proposedpayrollregisterdeductions
  OWNER TO ehcmuser;
GRANT ALL ON TABLE payroll.cognos_proposedpayrollregisterdeductions TO ehcmuser;
GRANT SELECT ON TABLE payroll.cognos_proposedpayrollregisterdeductions TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_proposedpayrollregisterdeductions TO read_write;

*/
