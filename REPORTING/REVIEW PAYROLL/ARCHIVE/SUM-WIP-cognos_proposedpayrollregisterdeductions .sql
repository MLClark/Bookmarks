-- View: payroll.cognos_proposedpayrollregisterdeductions

-- DROP VIEW payroll.cognos_proposedpayrollregisterdeductions;
--select * from payroll.cognos_proposedpayrollregisterdeductions where personid = '1213' and paymentheaderid is null and etv_id = 'VB2';
--CREATE OR REPLACE VIEW payroll.cognos_proposedpayrollregisterdeductions AS 
 ---- this version eliminates dupes on ytd hours and wages.
 -- View: payroll.cognos_proposedpayrollregisterdeductions

-- DROP VIEW payroll.cognos_proposedpayrollregisterdeductions;

--CREATE OR REPLACE VIEW payroll.cognos_proposedpayrollregisterdeductions AS 
select x.etv_id as etv_id
    ,sum(amount) as amount
    ,sum(ytd_amount) as amount_ytd
    from 
    (

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
    COALESCE(st1.rate, 0::numeric) AS rate,
    COALESCE(st2.net_pay, 0::numeric) AS net_pay,
    COALESCE(st2.gross_pay, 0::numeric) AS gross_pay,
    COALESCE(st2.ytd_amount, 0::numeric) AS ytd_amount,
    COALESCE(st2.ytd_wage, 0::numeric) AS ytd_wage,
    st1.isemployer,
    st1.paymenttype,
    st1.sequencenumber,
    st1.paycodeaffiliationid,
    st1.enroll_in_catchup
   FROM
   
( SELECT ppp.payscheduleperiodid,
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
    sum(pst.amount) AS amount,
    sum(pst.units) AS hours,
    pst.rate AS rate,
    0 AS net_pay,
    0 AS gross_pay,
    0 AS ytd_amount,
    0 AS ytd_wage,
        CASE
            WHEN pc.paycodetypeid = 6 THEN 'T'::text
            ELSE 'F'::text
        END AS isemployer,
    ppp.paymenttype,
    COALESCE(ppp.sequencenumber, '~'::character varying) AS sequencenumber,
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
                 sum(staged_transaction.units) as units,
                 sum(staged_transaction.amount) as amount,
                 staged_transaction.rate as rate,
                 max(staged_transaction.paymentseq) AS paymentseq,
                 rank() OVER (PARTITION BY staged_transaction.personid, staged_transaction.paycode ORDER BY (max(staged_transaction.paymentseq)) DESC) AS rank
            FROM payroll.staged_transaction 
           GROUP BY staged_transaction.personid, staged_transaction.sequencenumber, staged_transaction.payscheduleperiodid, staged_transaction.asofdate, staged_transaction.paycode, staged_transaction.rate) pst 
     ON pst.payscheduleperiodid = st.payscheduleperiodid AND pst.personid = st.personid AND pst.asofdate = st.asofdate AND pst.paycode::text = st.paycode::text AND pst.paymentseq = st.paymentseq AND pst.rank = 1

     JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND 'now'::text::date >= pc.effectivedate AND 'now'::text::date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[3, 6]))
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     LEFT JOIN person_deduction_setup pds ON pds.personid = st.personid AND pds.etvid::text = st.paycode::text AND psp.periodpaydate >= pds.effectivedate AND psp.periodpaydate <= pds.enddate AND now() >= pds.createts AND now() <= pds.endts
     LEFT JOIN person_garnishment_setup pgs ON pgs.personid = st.personid AND pgs.etvid::text = st.paycode::text AND psp.periodpaydate >= pgs.effectivedate AND psp.periodpaydate <= pgs.enddate AND now() >= pgs.createts AND now() <= pgs.endts
     LEFT JOIN garnishment_type gt ON pgs.garnishmenttype = gt.garntype
  WHERE ppp.net_amount <> 0::numeric 
  GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, st.paycode, pc.paycodedesc, pc.paycodeshortdesc, pc.paycodetypeid, ppp.paymenttype, st.taxid, pds.persondedsetuppid, pgs.persongarnishmentsetuppid, gt.garntypedesc, ppp.sequencenumber, st.paycodeaffiliationid, pst.rate
  ) st1
  
JOIN ( SELECT ppp.payscheduleperiodid,
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
    COALESCE(st.amount_ytd, 0.00) AS ytd_amount,
    COALESCE(st.subject_wages_ytd, 0.00) AS ytd_wage,
        CASE
            WHEN pc.paycodetypeid = 6 THEN 'T'::text
            ELSE 'F'::text
        END AS isemployer,
    ppp.paymenttype,
    COALESCE(ppp.sequencenumber, '~'::character varying) AS sequencenumber,
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
            FROM payroll.staged_transaction WHERE staged_transaction.amount_ytd <> 0::numeric --- making this change for SRE need to test on all clients
           GROUP BY staged_transaction.personid, staged_transaction.sequencenumber, staged_transaction.payscheduleperiodid, staged_transaction.asofdate, staged_transaction.paycode, staged_transaction.units_ytd, staged_transaction.amount_ytd, staged_transaction.subject_wages_ytd) pst 
     ON pst.payscheduleperiodid = st.payscheduleperiodid AND pst.personid = st.personid AND pst.asofdate = st.asofdate AND pst.paycode::text = st.paycode::text AND pst.paymentseq = st.paymentseq AND pst.rank = 1
   JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND 'now'::text::date >= pc.effectivedate AND 'now'::text::date <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[3, 6]))
   JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
   JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
   JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
   LEFT JOIN person_deduction_setup pds ON pds.personid = st.personid AND pds.etvid::text = st.paycode::text AND psp.periodpaydate >= pds.effectivedate AND psp.periodpaydate <= pds.enddate AND now() >= pds.createts AND now() <= pds.endts
   LEFT JOIN person_garnishment_setup pgs ON pgs.personid = st.personid AND pgs.etvid::text = st.paycode::text AND psp.periodpaydate >= pgs.effectivedate AND psp.periodpaydate <= pgs.enddate AND now() >= pgs.createts AND now() <= pgs.endts
   LEFT JOIN garnishment_type gt ON pgs.garnishmenttype = gt.garntype
  WHERE ppp.net_amount <> 0::numeric 
  GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, st.paycode, pc.paycodedesc, pc.paycodeshortdesc, pc.paycodetypeid, ppp.paymenttype, st.taxid, pds.persondedsetuppid, pgs.persongarnishmentsetuppid, gt.garntypedesc, ppp.sequencenumber, st.amount, st.units, st.rate, ppp.net_amount, ppp.gross_amount, st.subject_wages_ytd, st.amount_ytd, st.paycodeaffiliationid
  ) st2
  ON st2.personid = st1.personid AND st2.etv_id::text = st1.etv_id::text AND st1.payscheduleperiodid = st2.payscheduleperiodid
  GROUP BY st1.payscheduleperiodid, st1.personid, st1.paymentheaderid, st1.pspaypayrollid, st1.persondedsetuppid, st1.etv_id, st1.etvname, st1.paymenttype, st1.sequencenumber, st1.persongarnishmentsetuppid, st1.isemployer, st2.net_pay, st2.gross_pay, st2.ytd_amount, st1.paycodeaffiliationid, st2.ytd_wage, st1.enroll_in_catchup, st1.rate
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
                           FROM payroll.staged_transaction))))))
                                                      order by 2,1,3,6
                           
)x group by 1


/*
ALTER TABLE payroll.cognos_proposedpayrollregisterdeductions
  OWNER TO postgres;
GRANT ALL ON TABLE payroll.cognos_proposedpayrollregisterdeductions TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_proposedpayrollregisterdeductions TO read_write;
GRANT SELECT ON TABLE payroll.cognos_proposedpayrollregisterdeductions TO read_only;

*/