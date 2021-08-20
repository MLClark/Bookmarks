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
    0 AS amount,
    0 AS hours,
    sum(st.subject_wages) AS wage,
    sum(ppp.net_amount) AS net_pay,
    0 AS gross_pay,
    sum(COALESCE(pst.units_ytd, 0::numeric)::numeric(18,6)) AS ytd_hrs,
    sum(COALESCE(pst.amount_ytd, 0::numeric)::numeric(18,2)) AS ytd_amount,
    sum(COALESCE(pst.subject_wages_ytd, 0::numeric)::numeric(18,2)) AS ytd_wage,
    pte.persontaxelectionpid,
        CASE
            WHEN pc.paycodetypeid = 8 THEN 'T'::text
            ELSE 'F'::text
        END AS isemployer,
    ppp.paymenttype,
    ppp.sequencenumber
   FROM payroll.personperiodpayments ppp
     JOIN payroll.staged_transaction st ON ppp.payscheduleperiodid = st.payscheduleperiodid AND ppp.personid = st.personid AND ppp.paymenttype = st.paymenttype AND COALESCE(st.sequencenumber, '~'::character varying)::text = COALESCE(ppp.sequencenumber, '~'::character varying)::text
     
     
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
                  GROUP BY staged_transaction.personid, staged_transaction.payscheduleperiodid, staged_transaction.asofdate, staged_transaction.paycode, staged_transaction.units_ytd, staged_transaction.amount_ytd, staged_transaction.subject_wages_ytd) pst 
               ON pst.payscheduleperiodid = st.payscheduleperiodid AND pst.personid = st.personid AND pst.asofdate = st.asofdate AND pst.paycode::text = st.paycode::text AND pst.paymentseq = st.paymentseq AND pst.rank = 1
                    
     JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND 'now'::text::date >= pc.effectivedate AND 'now'::text::date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[4, 8]))
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN tax t ON t.taxid = st.taxid
     LEFT JOIN person_tax_elections pte ON pte.personid = st.personid AND pte.taxid = t.taxid AND 'now'::text::date >= pte.effectivedate AND 'now'::text::date <= pte.enddate AND now() >= pte.createts AND now() <= pte.endts
     LEFT JOIN tax_related_plan trp ON trp.taxidee = t.taxid AND 'now'::text::date >= trp.effectivedate AND 'now'::text::date <= trp.enddate AND now() >= trp.createts AND now() <= trp.endts
     JOIN pay_unit pu ON pu.payunitid = psp.payunitid AND now() >= pu.createts AND now() <= pu.endts
  WHERE ppp.net_amount <> 0::numeric
  GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, st.paycode, pc.paycodeshortdesc, pc.paycodetypeid, ppp.paymenttype, st.taxid, t.taxiddesc, pu.employertaxid, trp.taxider, pte.persontaxelectionpid, ppp.sequencenumber
  
  order by personid, etv_id
;

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
    sum(COALESCE(st.units_ytd, 0::numeric)::numeric(18,6)) AS ytd_hrs,
    sum(COALESCE(st.amount_ytd, 0::numeric)::numeric(18,2)) AS ytd_amount,
    sum(COALESCE(st.subject_wages_ytd, 0::numeric)::numeric(18,2)) AS ytd_wage,
    pte.persontaxelectionpid,
        CASE
            WHEN pc.paycodetypeid = 8 THEN 'T'::text
            ELSE 'F'::text
        END AS isemployer,
    ppp.paymenttype,
    ppp.sequencenumber
   FROM payroll.personperiodpayments ppp
     JOIN payroll.staged_transaction st ON ppp.payscheduleperiodid = st.payscheduleperiodid AND ppp.personid = st.personid AND ppp.paymenttype = st.paymenttype AND COALESCE(st.sequencenumber, '~'::character varying)::text = COALESCE(ppp.sequencenumber, '~'::character varying)::text
     JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND 'now'::text::date >= pc.effectivedate AND 'now'::text::date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[4, 8]))
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN tax t ON t.taxid = st.taxid
     LEFT JOIN person_tax_elections pte ON pte.personid = st.personid AND pte.taxid = t.taxid AND 'now'::text::date >= pte.effectivedate AND 'now'::text::date <= pte.enddate AND now() >= pte.createts AND now() <= pte.endts
     LEFT JOIN tax_related_plan trp ON trp.taxidee = t.taxid AND 'now'::text::date >= trp.effectivedate AND 'now'::text::date <= trp.enddate AND now() >= trp.createts AND now() <= trp.endts
     JOIN pay_unit pu ON pu.payunitid = psp.payunitid AND now() >= pu.createts AND now() <= pu.endts
  WHERE ppp.net_amount <> 0::numeric
  GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, st.paycode, pc.paycodeshortdesc, pc.paycodetypeid, ppp.paymenttype, st.taxid, t.taxiddesc, pu.employertaxid, trp.taxider, pte.persontaxelectionpid, ppp.sequencenumber

