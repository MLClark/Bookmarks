 SELECT st1.payscheduleperiodid,
    st1.personid,
    st1.paymentheaderid,
    st1.pspaypayrollid,
    st1.persondedsetuppid,
    st1.persongarnishmentsetuppid,
    st1.etv_id,
    st1.etvname,
    sum(COALESCE(st1.amount, 0::numeric)::numeric(18,2)) AS amount,
    sum(COALESCE(st1.hours, 0::numeric)::numeric(18,6)) AS hours,
    sum(COALESCE(st1.rate, 0::numeric)::numeric(18,6)) AS rate,
    COALESCE(st2.net_pay, 0::numeric) AS net_pay,
    COALESCE(st2.gross_pay, 0::numeric) AS gross_pay,
    COALESCE(st2.ytd_amount, 0::numeric) AS ytd_amount,
    COALESCE(st2.ytd_wage, 0::numeric) AS ytd_wage,
    st1.isemployer,
    st1.paymenttype,
    st1.sequencenumber,
    st1.paycodeaffiliationid,
    st1.enroll_in_catchup
   FROM ( SELECT ppp.payscheduleperiodid,
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
            0 AS net_pay,
            0 AS gross_pay,
            0 AS ytd_amount,
            0 AS ytd_wage,
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
             JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND 'now'::text::date >= pc.effectivedate AND 'now'::text::date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[3, 6]))
             JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
             JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
             JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
             LEFT JOIN person_deduction_setup pds ON pds.personid = st.personid AND pds.etvid::text = st.paycode::text AND psp.periodpaydate >= pds.effectivedate AND psp.periodpaydate <= pds.enddate AND now() >= pds.createts AND now() <= pds.endts
             LEFT JOIN person_garnishment_setup pgs ON pgs.personid = st.personid AND pgs.etvid::text = st.paycode::text AND psp.periodpaydate >= pgs.effectivedate AND psp.periodpaydate <= pgs.enddate AND now() >= pgs.createts AND now() <= pgs.endts
             LEFT JOIN garnishment_type gt ON pgs.garnishmenttype = gt.garntype
          GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, st.paycode, pc.paycodedesc, pc.paycodeshortdesc, pc.paycodetypeid, ppp.paymenttype, st.taxid, pds.persondedsetuppid, pgs.persongarnishmentsetuppid, gt.garntypedesc, ppp.sequencenumber, st.amount, st.paycodeaffiliationid, st.benefitplanid) st1
     LEFT JOIN ( SELECT ppp.payscheduleperiodid,
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
            0 AS amount,
            0 AS hours,
            0 AS rate,
            ppp.net_amount AS net_pay,
            ppp.gross_amount AS gross_pay,
            pst.amount_ytd AS ytd_amount,
            sum(ppp.gross_amount) AS ytd_wage,
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
             JOIN ( SELECT staged_transaction.personid,
                    staged_transaction.sequencenumber,
                    staged_transaction.payscheduleperiodid,
                    staged_transaction.asofdate,
                    staged_transaction.paycode,
                    staged_transaction.units_ytd,
                    staged_transaction.amount_ytd,
                    max(staged_transaction.paymentseq) AS paymentseq,
                    rank() OVER (PARTITION BY staged_transaction.personid, staged_transaction.paycode ORDER BY (max(staged_transaction.paymentseq)) DESC) AS rank
                   FROM payroll.staged_transaction
                  GROUP BY staged_transaction.personid, staged_transaction.sequencenumber, staged_transaction.payscheduleperiodid, staged_transaction.asofdate, staged_transaction.paycode, staged_transaction.units_ytd, staged_transaction.amount_ytd, staged_transaction.subject_wages_ytd) pst ON pst.payscheduleperiodid = st.payscheduleperiodid AND pst.personid = st.personid AND pst.asofdate = st.asofdate AND pst.paycode::text = st.paycode::text AND pst.paymentseq = st.paymentseq AND pst.rank = 1
             JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND 'now'::text::date >= pc.effectivedate AND 'now'::text::date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[3, 6]))
             JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
             JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
             JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
             LEFT JOIN person_deduction_setup pds ON pds.personid = st.personid AND pds.etvid::text = st.paycode::text AND psp.periodpaydate >= pds.effectivedate AND psp.periodpaydate <= pds.enddate AND now() >= pds.createts AND now() <= pds.endts
             LEFT JOIN person_garnishment_setup pgs ON pgs.personid = st.personid AND pgs.etvid::text = st.paycode::text AND psp.periodpaydate >= pgs.effectivedate AND psp.periodpaydate <= pgs.enddate AND now() >= pgs.createts AND now() <= pgs.endts
             LEFT JOIN garnishment_type gt ON pgs.garnishmenttype = gt.garntype
             
          GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, st.paycode, pc.paycodedesc, pc.paycodeshortdesc, pc.paycodetypeid, ppp.paymenttype, st.taxid, pds.persondedsetuppid, pgs.persongarnishmentsetuppid, gt.garntypedesc, ppp.sequencenumber, st.amount, st.units, st.rate, ppp.net_amount, ppp.gross_amount, pst.amount_ytd, st.paycodeaffiliationid, st.benefitplanid) st2 ON st2.personid = st1.personid AND st2.etv_id::text = st1.etv_id::text AND st1.payscheduleperiodid = st2.payscheduleperiodid

  GROUP BY st1.payscheduleperiodid, st1.personid, st1.paymentheaderid, st1.pspaypayrollid, st1.persondedsetuppid, st1.etv_id, st1.etvname, st1.paymenttype, st1.sequencenumber, st1.persongarnishmentsetuppid, st1.isemployer, st2.net_pay, st2.gross_pay, st2.ytd_amount, st2.ytd_wage, st1.paycodeaffiliationid, st1.enroll_in_catchup
