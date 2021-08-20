select x.etv_id as etv_id
    --,x.personid as personid
    --,x.paymentheaderid
    ,sum(amount) as amount
    ,sum(hours) as hours
    ,sum(rate) as rate
    ,sum(net_pay) as net_pay
    ,sum(gross_pay) as gross_pay
    
    ,sum(ytd_amount) as ytd_amount
    ,sum(ytd_wage) as ytd_wage
    from 
    (

 SELECT ppp.payscheduleperiodid,
    ppp.personid,
    NULL::integer AS paymentheaderid,
    pp.pspaypayrollid,
    pes.personearnsetuppid,
    st.paycode AS etv_id,
    st.paycode::text || COALESCE('-'::text || pc.paycodeshortdesc::text, ''::text) AS etvname,
    sum(st.amount) AS amount,
    sum(st.units) AS hours,
    st.rate,
    sum(ppp.net_amount) AS net_pay,
    sum(ppp.gross_amount) AS gross_pay,
    COALESCE(st.units_ytd, 0::numeric)::numeric(18,6) AS ytd_hrs,
    COALESCE(st.amount_ytd, 0::numeric)::numeric(18,2) AS ytd_amount,
    COALESCE(st.subject_wages_ytd, 0::numeric)::numeric(18,2) AS ytd_wage,
    ppp.paymenttype,
    COALESCE(ppp.sequencenumber, '~'::character varying) AS sequencenumber,
    st.paycodeaffiliationid
   FROM payroll.personperiodpayments ppp
     JOIN payroll.staged_transaction st ON ppp.payscheduleperiodid = st.payscheduleperiodid AND ppp.personid = st.personid AND ppp.paymenttype = st.paymenttype AND COALESCE(ppp.sequencenumber, '~'::character varying)::text = COALESCE(st.sequencenumber, '~'::character varying)::text
     JOIN payroll.payment_types pt ON pt.paymenttype = st.paymenttype
     LEFT JOIN payroll.pay_code_override pco ON pco.paycode::text = st.paycode::text AND pco.payunitid = ppp.payunitid AND now() >= pco.createts AND now() <= pco.endts
     JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND
        CASE
            WHEN pco.uidisplay IS NOT NULL THEN pco.uidisplay = 'Y'::bpchar
            ELSE pc.uidisplay = 'Y'::bpchar
        END AND ppp.asofdate >= pc.effectivedate AND ppp.asofdate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[1, 2, 7]))
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     LEFT JOIN person_earning_setup pes ON pes.personid = st.personid AND pes.etvid::text = st.paycode::text AND psp.periodpaydate >= pes.effectivedate AND psp.periodpaydate <= pes.enddate AND now() >= pes.createts AND now() <= pes.endts AND pes.paycodeaffiliationid = st.paycodeaffiliationid
  GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, pes.personearnsetuppid, st.paycode, st.rate, pc.paycodeshortdesc, ppp.paymenttype, (COALESCE(ppp.sequencenumber, '~'::character varying)), st.paycodeaffiliationid, st.units_ytd, st.amount_ytd, st.subject_wages_ytd
UNION
 SELECT p2.payscheduleperiodid,
    p2.personid,
    p2.paymentheaderid,
    p2.pspaypayrollid,
    p2.personearnsetuppid,
    p2.etv_id,
    p2.etvname,
    p2.amount,
    p2.hours,
    p2.rate,
    p2.net_pay,
    p2.gross_pay,
    p2.ytd_hrs,
    p2.ytd_amount,
    p2.ytd_wage,
    p2.paymenttype,
    p2.sequencenumber,
    p2.paycodeaffiliationid
   FROM payroll.payrollregisterearnings p2
  WHERE (p2.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid
                           FROM payroll.staged_transaction))))))
 )x --where x.etv_id = 'V39-ER' and personid = '1267'
group by 1--,2,3    
order by 1,2                               
