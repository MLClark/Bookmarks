 SELECT ppp.payscheduleperiodid,
     'STYTD' as qsource,
     ppp.personid,
     NULL::integer AS paymentheaderid,
     pp.pspaypayrollid,
     pes.personearnsetuppid,
     st.paycode AS etv_id,
     st.paycode::text || COALESCE('-'::text || pc.paycodeshortdesc::text, ''::text) AS etvname,
     0 as amount,
     0 AS hours,
     0 as rate,
     0 AS net_pay,
     0 AS gross_pay,
     sum(COALESCE(st.units_ytd, 0::numeric)::numeric(18,6)) AS ytd_hrs,
     sum(COALESCE(st.amount_ytd, 0::numeric)::numeric(18,2)) AS ytd_amount,
     sum(COALESCE(st.subject_wages_ytd, 0::numeric)::numeric(18,2)) AS ytd_wage,
     ppp.paymenttype,
     COALESCE(ppp.sequencenumber, '~'::character varying) AS "coalesce"
     
     FROM payroll.personperiodpayments ppp
     JOIN payroll.staged_transaction st ON ppp.payscheduleperiodid = st.payscheduleperiodid AND ppp.personid = st.personid AND ppp.paymenttype = st.paymenttype AND COALESCE(ppp.sequencenumber, '~'::character varying)::text = COALESCE(st.sequencenumber, '~'::character varying)::text
     
     join ( select personid, payscheduleperiodid, asofdate, paycode, units_ytd, amount_ytd, subject_wages_ytd , max(paymentseq) as paymentseq, rank() over (partition by personid, paycode order by max(paymentseq) desc) as rank
              from payroll.staged_transaction group by personid, payscheduleperiodid, asofdate, paycode, units_ytd, amount_ytd, subject_wages_ytd ) pst ON pst.payscheduleperiodid = st.payscheduleperiodid AND pst.personid = st.personid AND pst.asofdate = st.asofdate AND pst.paycode = st.paycode AND pst.paymentseq = st.paymentseq and pst.rank = 1

     JOIN payroll.payment_types pt ON pt.paymenttype = st.paymenttype
     JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND ppp.asofdate >= pc.effectivedate AND ppp.asofdate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[1, 2, 7]))
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     LEFT JOIN person_earning_setup pes ON pes.personid = st.personid AND pes.etvid::text = st.paycode::text AND psp.periodpaydate >= pes.effectivedate AND psp.periodpaydate <= pes.enddate AND now() >= pes.createts AND now() <= pes.endts
     where ppp.personid = '677' and st.paycode = 'E01'
  GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, pes.personearnsetuppid, st.paycode, st.rate, pc.paycodeshortdesc, ppp.paymenttype, (COALESCE(ppp.sequencenumber, '~'::character varying))