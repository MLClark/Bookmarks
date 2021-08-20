 -- View: payroll.cognos_proposedpayrollregistertaxes

-- DROP VIEW payroll.cognos_proposedpayrollregistertaxes;

--CREATE OR REPLACE VIEW payroll.cognos_proposedpayrollregistertaxes AS 
 
 SELECT ppp.payscheduleperiodid,
    ppp.personid,
    NULL::integer AS paymentheaderid,
    pp.pspaypayrollid,
    st.paycode AS etv_id,
    st.paycode::text || COALESCE('-'::text || pc.paycodeshortdesc::text, ''::text) AS etvname,
    t.taxiddesc::text ||
        CASE
            WHEN (( SELECT cts.privateplan
               FROM company_tax_setup cts
              WHERE (pu.employertaxid::character varying::text = ANY (cts.feinlist::text[])) AND now() >= cts.createts AND now() <= cts.endts AND 'now'::text::date >= cts.effectivedate AND 'now'::text::date <= cts.enddate AND (cts.taxid = st.taxid OR cts.taxid = trp.taxider))) = 'Y'::bpchar THEN ' - Private Plan'::text
            ELSE ''::text
        END AS taxiddesc,
    st.taxid,
    sum(st.amount) AS amount,
    sum(st.units) AS hours,
    sum(st.subject_wages) AS wage,
    sum(ppp.net_amount) AS net_pay,
    sum(ppp.gross_amount) AS gross_pay,
    COALESCE(st.units_ytd, 0.00::numeric) AS ytd_hrs,
    COALESCE(st.amount_ytd, 0.00::numeric) AS ytd_amount,
    COALESCE(st.subject_wages_ytd, 0.00::numeric) AS ytd_wage,
    pte.persontaxelectionpid,
        CASE
            WHEN pc.paycodetypeid = 8 THEN 'T'::text
            ELSE 'F'::text
        END AS isemployer,
    ppp.paymenttype,
    COALESCE(ppp.sequencenumber, '~'::character varying) AS sequencenumber,
    pt.paymenttypedesc
   FROM payroll.personperiodpayments ppp
     JOIN payroll.staged_transaction st ON ppp.payscheduleperiodid = st.payscheduleperiodid AND ppp.personid = st.personid AND ppp.paymenttype = st.paymenttype AND COALESCE(st.sequencenumber, '~'::character varying)::text = COALESCE(ppp.sequencenumber, '~'::character varying)::text
     JOIN payroll.payment_types pt ON pt.paymenttype = st.paymenttype
     LEFT JOIN payroll.pay_code_override pco ON pco.paycode::text = st.paycode::text AND pco.payunitid = ppp.payunitid AND now() >= pco.createts AND now() <= pco.endts
     JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND
        CASE
            WHEN pco.uidisplay IS NOT NULL THEN pco.uidisplay = 'Y'::bpchar
            ELSE pc.uidisplay = 'Y'::bpchar
        END AND ppp.periodpaydate >= pc.effectivedate AND ppp.periodpaydate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[4, 8]))
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN tax t ON t.taxid = st.taxid
     LEFT JOIN person_tax_elections pte ON pte.personid = st.personid AND pte.taxid = t.taxid AND ppp.periodpaydate >= pte.effectivedate AND ppp.periodpaydate <= pte.enddate AND now() >= pte.createts AND now() <= pte.endts
     LEFT JOIN tax_related_plan trp ON trp.taxidee = t.taxid AND 'now'::text::date >= trp.effectivedate AND 'now'::text::date <= trp.enddate AND now() >= trp.createts AND now() <= trp.endts
     JOIN pay_unit pu ON pu.payunitid = psp.payunitid AND now() >= pu.createts AND now() <= pu.endts
  WHERE ppp.net_amount <> 0::numeric
  GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, st.paycode, pc.paycodeshortdesc, pc.paycodetypeid, ppp.paymenttype, st.taxid, t.taxiddesc, pu.employertaxid, trp.taxider, pte.persontaxelectionpid, ppp.sequencenumber
  ,st.amount_ytd, st.subject_wages_ytd, st.units_ytd, pt.paymenttypedesc
UNION
 SELECT payrollregistertaxes.payscheduleperiodid,
    payrollregistertaxes.personid,
    payrollregistertaxes.paymentheaderid,
    payrollregistertaxes.pspaypayrollid,
    payrollregistertaxes.etv_id,
    payrollregistertaxes.etvname,
    payrollregistertaxes.taxiddesc,
    payrollregistertaxes.taxid,
    payrollregistertaxes.amount,
    payrollregistertaxes.hours,
    payrollregistertaxes.wage,
    payrollregistertaxes.net_pay,
    payrollregistertaxes.gross_pay,
    payrollregistertaxes.ytd_hrs,
    payrollregistertaxes.ytd_amount,
    payrollregistertaxes.ytd_wage,
    payrollregistertaxes.persontaxelectionpid,
        CASE
            WHEN payrollregistertaxes.isemployer THEN 'T'::text
            ELSE 'F'::text
        END AS isemployer,
    payrollregistertaxes.paymenttype,
    payrollregistertaxes.sequencenumber,
    NULL::text as paymenttypedesc
   FROM payroll.payrollregistertaxes
  WHERE (payrollregistertaxes.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid
                           FROM payroll.staged_transaction))))));
                           
/*
ALTER TABLE payroll.cognos_proposedpayrollregistertaxes
  OWNER TO skybotsu;
*/                         