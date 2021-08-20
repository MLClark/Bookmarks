--DROP VIEW IF EXISTS payroll.cognos_proposedpayrollregisterearnings;
--CREATE OR REPLACE VIEW payroll.cognos_proposedpayrollregisterearnings AS 

---Add payroll.payment_type.paymenttypedesc to the view
 SELECT 
    st1.payscheduleperiodid,
    st1.personid,
    st1.paymentheaderid,
    st1.pspaypayrollid,
    st1.personearnsetuppid,
    st1.etv_id AS etv_id,
    st1.etvname AS etvname,
    SUM(COALESCE(st1.amount,     0::numeric)::numeric(18,2)) AS amount,
    SUM(COALESCE(st1.hours,      0::numeric)::numeric(18,6)) AS hours,
    SUM(COALESCE(st1.rate,       0::numeric)::numeric(18,6)) AS rate,
    SUM(COALESCE(st1.net_pay,    0::numeric)::numeric(18,2)) AS net_pay,
    SUM(COALESCE(st1.gross_pay,  0::numeric)::numeric(18,2)) AS gross_pay,
    COALESCE(st2.ytd_hrs,    0::numeric)::numeric(18,6) AS ytd_hrs,
    COALESCE(st2.ytd_amount, 0::numeric)::numeric(18,2) AS ytd_amount,
    COALESCE(st2.ytd_wage,   0::numeric)::numeric(18,2) AS ytd_wage,   
    st1.paymenttype,
    st2.sequencenumber AS sequencenumber,
    st1.paycodeaffiliationid,
    st1.paymenttypedesc
    
    FROM  

(( 

 SELECT
    ppp.payscheduleperiodid,
    ppp.personid,
    NULL::integer AS paymentheaderid,
    pp.pspaypayrollid,
    pes.personearnsetuppid,
    st.paycode AS etv_id,
    st.paycode::text || COALESCE('-'::text || pc.paycodeshortdesc::text, ''::text) AS etvname,
    SUM(st.amount) AS amount,
    SUM(st.units) AS hours,
    st.rate as rate,
    SUM(ppp.net_amount) AS net_pay,
    SUM(ppp.gross_amount) AS gross_pay,
    0 AS ytd_hrs,
    0 AS ytd_amount,
    0 AS ytd_wage,
    ppp.paymenttype,
    COALESCE(ppp.sequencenumber, '~'::character varying) AS sequencenumber,
    st.paycodeaffiliationid,
    pt.paymenttypedesc   
   FROM payroll.personperiodpayments ppp
   JOIN payroll.staged_transaction st ON ppp.payscheduleperiodid = st.payscheduleperiodid AND ppp.personid = st.personid AND ppp.paymenttype = st.paymenttype AND COALESCE(ppp.sequencenumber, '~'::character varying)::text = COALESCE(st.sequencenumber, '~'::character varying)::text
   JOIN payroll.payment_types pt ON pt.paymenttype = st.paymenttype
   JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND ppp.asofdate >= pc.effectivedate AND ppp.asofdate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[1, 2, 7]))
   JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
   JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
   JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
   LEFT JOIN person_earning_setup pes ON pes.personid = st.personid AND pes.etvid::text = st.paycode::text AND psp.periodpaydate >= pes.effectivedate AND psp.periodpaydate <= pes.enddate AND now() >= pes.createts AND now() <= pes.endts
  GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, pes.personearnsetuppid, st.paycode, st.rate, pc.paycodeshortdesc, ppp.paymenttype, (COALESCE(ppp.sequencenumber, '~'::character varying)), st.paycodeaffiliationid, pt.paymenttypedesc)  st1
  
 JOIN
   
( SELECT 
    ppp.payscheduleperiodid,
    ppp.personid,
    NULL::integer AS paymentheaderid,
    pp.pspaypayrollid,
    pes.personearnsetuppid,
    st.paycode AS etv_id,
    st.paycode::text || COALESCE('-'::text || pc.paycodeshortdesc::text, ''::text) AS etvname,
    0 AS amount,
    0 AS hours,
    0 AS rate,
    0 AS net_pay,
    0 AS gross_pay,
    COALESCE(st.units_ytd, 0::numeric)::numeric(18,6) AS ytd_hrs,
    COALESCE(st.amount_ytd, 0::numeric)::numeric(18,2) AS ytd_amount,
    COALESCE(ppp.gross_amount, 0::numeric)::numeric(18,2) AS ytd_wage,
    ppp.paymenttype,
    COALESCE(ppp.sequencenumber, '~'::character varying) AS sequencenumber,
    st.paycodeaffiliationid,
    pt.paymenttypedesc
 
  FROM payroll.personperiodpayments ppp
  JOIN payroll.staged_transaction st ON ppp.payscheduleperiodid = st.payscheduleperiodid AND ppp.personid = st.personid AND ppp.paymenttype = st.paymenttype AND COALESCE(ppp.sequencenumber, '~'::character varying)::text = COALESCE(st.sequencenumber, '~'::character varying)::text
   
  JOIN ( SELECT personid, payscheduleperiodid, asofdate, paycode, units_ytd, amount_ytd, subject_wages_ytd , max(paymentseq) as paymentseq, rank() OVER (PARTITION BY personid, paycode ORDER BY MAX(paymentseq) DESC) as rank
          FROM payroll.staged_transaction GROUP BY personid, payscheduleperiodid, asofdate, paycode, units_ytd, amount_ytd, subject_wages_ytd ) pst ON pst.payscheduleperiodid = st.payscheduleperiodid AND pst.personid = st.personid AND pst.asofdate = st.asofdate AND pst.paycode = st.paycode AND pst.paymentseq = st.paymentseq and pst.rank = 1

  JOIN payroll.payment_types pt ON pt.paymenttype = st.paymenttype
  JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND ppp.asofdate >= pc.effectivedate AND ppp.asofdate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[1, 2, 7]))
  JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
  JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
  JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
  LEFT JOIN person_earning_setup pes ON pes.personid = st.personid AND pes.etvid::text = st.paycode::text AND psp.periodpaydate >= pes.effectivedate AND psp.periodpaydate <= pes.enddate AND now() >= pes.createts AND now() <= pes.endts
  ) st2 on st2.personid = st1.personid and st2.etv_id = st1.etv_id and  st2.payscheduleperiodid = st2.payscheduleperiodid  )

GROUP BY st1.payscheduleperiodid, st1.personid, st1.paymentheaderid, st1.pspaypayrollid, st1.personearnsetuppid, st1.etv_id, st1.etvname, st1.paymenttype, st2.sequencenumber, st1.paycodeaffiliationid, st2.ytd_hrs, st2.ytd_amount, st2.ytd_wage, st1.paymenttypedesc
    
UNION

SELECT 
    p21.payscheduleperiodid,
    p21.personid,
    p21.paymentheaderid,
    p21.pspaypayrollid,
    p21.personearnsetuppid,
    p21.etv_id AS etv_id,
    p21.etvname AS etvname,
    SUM(COALESCE(p21.amount,0::numeric)::numeric(18,2)) AS amount,
    SUM(COALESCE(p21.hours,0::numeric)::numeric(18,6)) AS hours,
    SUM(COALESCE(p21.rate,0::numeric)::numeric(18,6)) AS rate,
    SUM(COALESCE(p21.net_pay,0::numeric)::numeric(18,2)) AS net_pay,
    SUM(COALESCE(p21.gross_pay,0::numeric)::numeric(18,2)) AS gross_pay,
    COALESCE(p22.ytd_hrs,0::numeric)::numeric(18,6) AS ytd_hrs,
    COALESCE(p22.ytd_amount,0::numeric)::numeric(18,2) AS ytd_amount,
    COALESCE(p22.ytd_wage,0::numeric)::numeric(18,2) AS ytd_wage,
    p21.paymenttype,
    p21.sequencenumber as sequencenumber,
    p21.paycodeaffiliationid,
    p21.paymenttypedesc
    
    
FROM  
    (SELECT p2.payscheduleperiodid,     
         p2.personid,
         p2.paymentheaderid,
         p2.pspaypayrollid,
         p2.personearnsetuppid,
         p2.etv_id,
         p2.etvname,
         p2.amount AS amount,
         p2.hours AS hours,
         p2.rate AS rate,
         p2.net_pay,
         p2.gross_pay,
         p2.ytd_hrs,
         p2.ytd_amount,
         p2.ytd_wage,
         p2.paymenttype,
         p2.sequencenumber AS sequencenumber,
         RANK() OVER (PARTITION BY p2.personid, p2.etv_id, pspaypayrollid ORDER BY MAX(p2.paymentheaderid) DESC) AS rank,
         p2.paycodeaffiliationid,
         NULL::text paymenttypedesc
        FROM payroll.payrollregisterearnings p2
       WHERE (p2.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid
                FROM pay_schedule_period
               WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT MIN(pay_schedule_period_1.periodpaydate) AS min
                        FROM pay_schedule_period pay_schedule_period_1
                       WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid FROM payroll.staged_transaction))))))
      GROUP BY p2.payscheduleperiodid, p2.personid, p2.paymentheaderid, p2.pspaypayrollid, p2.personearnsetuppid, p2.etv_id, p2.etvname,p2.amount, p2.hours, p2.rate, p2.net_pay, p2.gross_pay, p2.ytd_hrs, p2.ytd_amount, p2.ytd_wage, p2.paymenttype, p2.sequencenumber, p2.paycodeaffiliationid
     ) p21           

JOIN

 (SELECT p2.payscheduleperiodid,     
    p2.personid,
    p2.paymentheaderid,
    p2.pspaypayrollid,
    p2.personearnsetuppid,
    p2.etv_id,
    p2.etvname,
    0 as amount,
    0 as hours,
    0 as rate,
    0 as net_pay,
    0 as gross_pay,
    p2.ytd_hrs,
    p2.ytd_amount,
    p2.ytd_wage,
    p2.paymenttype,
    p2.sequencenumber AS sequencenumber,
    rank() over (partition by p2.personid, p2.etv_id, p2.paymentheaderid order by max(p2.paymentdetailid) desc) as rank,
    p2.paycodeaffiliationid,
    NULL::text paymenttypedesc
   FROM payroll.payrollregisterearnings p2
  WHERE (p2.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid FROM payroll.staged_transaction))))))   
 GROUP BY p2.payscheduleperiodid, p2.personid, p2.paymentheaderid, p2.pspaypayrollid, p2.personearnsetuppid, p2.etv_id, p2.etvname,p2.amount, p2.hours, p2.rate, p2.net_pay, p2.gross_pay, p2.ytd_hrs, p2.ytd_amount, p2.ytd_wage, p2.paymenttype, p2.sequencenumber, paymentdetailid, p2.paycodeaffiliationid
 ) p22 ON p22.personid = p21.personid AND p22.payscheduleperiodid = p21.payscheduleperiodid AND p22.paymentheaderid = p21.paymentheaderid AND p22.pspaypayrollid = p21.pspaypayrollid and p22.etv_id = p21.etv_id AND p22.rank = 1 
 

GROUP BY p21.personid, p21.payscheduleperiodid, p21.paymentheaderid, p21.pspaypayrollid, p21.personearnsetuppid, p21.etv_id, p21.etvname, p21.paymenttype, p21.sequencenumber, p22.ytd_hrs, p22.ytd_amount, p22.ytd_wage, p21.paycodeaffiliationid, p21.paymenttypedesc

--ALTER TABLE payroll.cognos_proposedpayrollregisterearnings   OWNER TO ehcmuser;

