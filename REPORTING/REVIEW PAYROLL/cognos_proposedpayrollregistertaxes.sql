-- View: payroll.cognos_proposedpayrollregistertaxes

-- DROP VIEW payroll.cognos_proposedpayrollregistertaxes;

--CREATE OR REPLACE VIEW payroll.cognos_proposedpayrollregistertaxes AS 
 SELECT st1.payscheduleperiodid,
    st1.personid,
    st1.paymentheaderid,
    st1.pspaypayrollid,
    st1.etv_id,
    st1.etvname,
    st1.taxiddesc,
    st1.taxid,
    sum(COALESCE(st1.amount, 0::numeric)::numeric(18,2)) AS amount,
    sum(COALESCE(st1.hours, 0::numeric)::numeric(18,6)) AS hours,
    sum(COALESCE(st1.wage, 0::numeric)::numeric(18,2)) AS wage,
    sum(COALESCE(st1.net_pay, 0::numeric)::numeric(18,2)) AS net_pay,
    sum(COALESCE(st1.gross_pay, 0::numeric)::numeric(18,2)) AS gross_pay,
    sum(COALESCE(st2.ytd_hrs, 0::numeric)::numeric(18,6)) AS ytd_hrs,
    sum(COALESCE(st2.ytd_amount, 0::numeric)::numeric(18,2)) AS ytd_amount,
    sum(COALESCE(st2.ytd_wage, 0::numeric)::numeric(18,2)) AS ytd_wage,
    st1.persontaxelectionpid,
    st1.isemployer,
    st1.paymenttype,
    st1.sequencenumber
   FROM ( SELECT ppp.payscheduleperiodid,
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
            0 AS ytd_hrs,
            0 AS ytd_amount,
            0 AS ytd_wage,
            pte.persontaxelectionpid,
                CASE
                    WHEN pc.paycodetypeid = 8 THEN 'T'::text
                    ELSE 'F'::text
                END AS isemployer,
            ppp.paymenttype,
            ppp.sequencenumber
           FROM payroll.personperiodpayments ppp
             JOIN payroll.staged_transaction st ON ppp.payscheduleperiodid = st.payscheduleperiodid AND ppp.personid = st.personid AND ppp.paymenttype = st.paymenttype AND COALESCE(st.sequencenumber, '~'::character varying)::text = COALESCE(ppp.sequencenumber, '~'::character varying)::text
             JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND ppp.periodpaydate >= pc.effectivedate AND ppp.periodpaydate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[4, 8]))
             JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
             JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
             JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
             JOIN tax t ON t.taxid = st.taxid
             LEFT JOIN person_tax_elections pte ON pte.personid = st.personid AND pte.taxid = t.taxid AND ppp.periodpaydate >= pte.effectivedate AND ppp.periodpaydate <= pte.enddate AND now() >= pte.createts AND now() <= pte.endts
             LEFT JOIN tax_related_plan trp ON trp.taxidee = t.taxid AND 'now'::text::date >= trp.effectivedate AND 'now'::text::date <= trp.enddate AND now() >= trp.createts AND now() <= trp.endts
             JOIN pay_unit pu ON pu.payunitid = psp.payunitid AND now() >= pu.createts AND now() <= pu.endts
          GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, st.paycode, pc.paycodeshortdesc, pc.paycodetypeid, ppp.paymenttype, st.taxid, t.taxiddesc, pu.employertaxid, trp.taxider, pte.persontaxelectionpid, ppp.sequencenumber) st1
     JOIN ( SELECT ppp.payscheduleperiodid,
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
            0 AS amount,
            0 AS hours,
            0 AS wage,
            0 AS rate,
            0 AS net_pay,
            0 AS gross_pay,
            sum(COALESCE(st.units_ytd, 0::numeric)::numeric(18,6)) AS ytd_hrs,
            sum(COALESCE(st.amount_ytd, 0::numeric)::numeric(18,2)) AS ytd_amount,
            sum(COALESCE(ppp.gross_amount, 0::numeric)::numeric(18,2)) AS ytd_wage,
            pte.persontaxelectionpid,
                CASE
                    WHEN pc.paycodetypeid = 8 THEN 'T'::text
                    ELSE 'F'::text
                END AS isemployer,
            ppp.paymenttype,
            ppp.sequencenumber
           FROM payroll.personperiodpayments ppp
             JOIN payroll.staged_transaction st ON ppp.payscheduleperiodid = st.payscheduleperiodid AND ppp.personid = st.personid AND ppp.paymenttype = st.paymenttype AND COALESCE(ppp.sequencenumber, '~'::character varying)::text = COALESCE(st.sequencenumber, '~'::character varying)::text
             JOIN ( SELECT staged_transaction.personid,
                    staged_transaction.payscheduleperiodid,
                    staged_transaction.asofdate,
                    staged_transaction.paycode,
                    staged_transaction.units_ytd,
                    staged_transaction.amount_ytd,
                    staged_transaction.subject_wages_ytd,
                    max(staged_transaction.paymentseq) AS paymentseq,
                    rank() OVER (PARTITION BY staged_transaction.personid, staged_transaction.paycode ORDER BY (max(staged_transaction.paymentseq)) DESC) AS rank
                   FROM payroll.staged_transaction
                  GROUP BY staged_transaction.personid, staged_transaction.payscheduleperiodid, staged_transaction.asofdate, staged_transaction.paycode, staged_transaction.units_ytd, staged_transaction.amount_ytd, staged_transaction.subject_wages_ytd) pst ON pst.payscheduleperiodid = st.payscheduleperiodid AND pst.personid = st.personid AND pst.asofdate = st.asofdate AND pst.paycode::text = st.paycode::text AND pst.paymentseq = st.paymentseq AND pst.rank = 1
             JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND ppp.periodpaydate >= pc.effectivedate AND ppp.periodpaydate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[4, 8]))
             JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
             JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
             JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
             JOIN tax t ON t.taxid = st.taxid
             LEFT JOIN person_tax_elections pte ON pte.personid = st.personid AND pte.taxid = t.taxid AND ppp.periodpaydate >= pte.effectivedate AND ppp.periodpaydate <= pte.enddate AND now() >= pte.createts AND now() <= pte.endts
             LEFT JOIN tax_related_plan trp ON trp.taxidee = t.taxid AND 'now'::text::date >= trp.effectivedate AND 'now'::text::date <= trp.enddate AND now() >= trp.createts AND now() <= trp.endts
             JOIN pay_unit pu ON pu.payunitid = psp.payunitid AND now() >= pu.createts AND now() <= pu.endts
          GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, st.paycode, pc.paycodeshortdesc, pc.paycodetypeid, ppp.paymenttype, st.taxid, t.taxiddesc, pu.employertaxid, trp.taxider, pte.persontaxelectionpid, ppp.sequencenumber) st2 ON st2.personid = st1.personid AND st2.etv_id::text = st1.etv_id::text AND st2.payscheduleperiodid = st2.payscheduleperiodid
  GROUP BY st1.payscheduleperiodid, st1.personid, st1.paymentheaderid, st1.pspaypayrollid, st1.etv_id, st1.etvname, st1.paymenttype, st2.sequencenumber, st1.taxiddesc, st1.taxid, st1.persontaxelectionpid, st1.isemployer, st1.sequencenumber
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
    payrollregistertaxes.sequencenumber
   FROM payroll.payrollregistertaxes
  WHERE (payrollregistertaxes.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid
                           FROM payroll.staged_transaction))))));
/*
ALTER TABLE payroll.cognos_proposedpayrollregistertaxes
  OWNER TO ehcmuser;
GRANT ALL ON TABLE payroll.cognos_proposedpayrollregistertaxes TO ehcmuser;
GRANT SELECT ON TABLE payroll.cognos_proposedpayrollregistertaxes TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_proposedpayrollregistertaxes TO read_write;
*/
