select * from person_names where personid in 


------------- calculate ytd gross / net pay
Every payroll.staged_transaction st.paycode on has a paycodetypeid in payroll.pay_codes pc
paycodetypeid has gross_multiplier, net_multiplier or taxablewages_multiplier on payroll.pay_code_types t

*/
select paycode, paycodetypeid from payroll.pay_codes where paycode in (select paycode from payroll.staged_transaction where personid = '1075' and payscheduleperiodid = 1491);
select * from payroll.pay_code_types where paycodetypeid in 
(select paycodetypeid from payroll.pay_codes where paycode in (select paycode from payroll.staged_transaction where personid = '1075' and payscheduleperiodid = 1491));
select * from payroll.staged_transaction where personid = '1075' and payscheduleperiodid = 1491;

--CREATE OR REPLACE VIEW payroll.personperiodpayments AS 
 SELECT sn.personid,
    sn.payscheduleperiodid,
    COALESCE(x.paymenttype, ( SELECT payment_types.paymenttype
           FROM payroll.payment_types
          WHERE payment_types.paymenttypedesc::text = 'Normal'::text)) AS paymenttype,
    x.batchtaxdedscheduleid,
    x.batchtaxmethodid,
    COALESCE(x.gross_amount, 0.00) AS gross_amount,
    COALESCE(x.net_amount, 0.00) AS net_amount,
    COALESCE(x.wages_401k, 0.00) AS wages_401k,
    COALESCE(x.earnings, 0.00) AS earnings,
        CASE
            WHEN x.sequencenumber::text = '~'::text THEN NULL::character varying
            ELSE x.sequencenumber
        END AS sequencenumber,
        CASE
            WHEN x.paymenttype = ANY (ARRAY[2, 3, 4]) THEN ARRAY['-1'::integer]
            ELSE COALESCE(b.valid_schedules, sn.valid_schedules)
        END AS valid_schedules,
        CASE
            WHEN x.paymenttype = ANY (ARRAY[2, 3, 4]) THEN true
            ELSE false
        END AS isautoadjust,
        CASE
            WHEN x.batchtaxmethodid = 1 THEN 'FLAT'::text
            WHEN x.batchtaxmethodid = 2 THEN 'PREVIOUSAGGREGATION'::text
            WHEN x.batchtaxmethodid = 3 THEN 'BONUS'::text
            ELSE 'NONE'::text
        END AS withholdingtypesupplemental,
    sn.periodsperyear,
    false AS iscumulative,
    sn.periodpaydate,
    sn.periodnumber,
    sn.asofdate,
    sn.payunitid,
    sn.earningscode,
    COALESCE(x.processingorder, ( SELECT payment_types.processingorder
           FROM payroll.payment_types
          WHERE payment_types.paymenttypedesc::text = 'Normal'::text)) AS processingorder,
    sn.employer_id
   FROM payroll.person_payperiod_snapshot sn
     JOIN pay_schedule_period psp ON sn.payscheduleperiodid = psp.payscheduleperiodid
     LEFT JOIN ( SELECT sn_1.personid,
            sn_1.payscheduleperiodid,
            s.paymenttype,
            max(s.batchtaxdedscheduleid) AS batchtaxdedscheduleid,
            max(s.batchtaxmethodid) AS batchtaxmethodid,
            sum(s.amount * t.gross_multiplier::numeric) AS gross_amount,
            sum(s.amount * t.net_multiplier::numeric) AS net_amount,
            sum(s.amount * r.multiplier::numeric) AS wages_401k,
            sum(
                CASE
                    WHEN pc.paycodetypeid = ANY (ARRAY[1, 2, 5, 7]) THEN s.amount
                    ELSE 0::numeric
                END) AS earnings,
            COALESCE(s.sequencenumber, '~'::character varying) AS sequencenumber,
            pt.processingorder
           FROM payroll.person_payperiod_snapshot sn_1
             JOIN payroll.staged_transaction s ON s.payscheduleperiodid = sn_1.payscheduleperiodid AND s.personid = sn_1.personid
             JOIN payroll.payment_types pt ON pt.paymenttype = s.paymenttype
             JOIN payroll.pay_codes pc ON s.paycode::text = pc.paycode::text AND sn_1.periodpaydate >= pc.effectivedate AND sn_1.periodpaydate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts
             LEFT JOIN payroll.pay_code_relationships r ON s.paycode::text = r.paycode::text AND r.paycoderelationshiptype::text = '401kWg'::text AND sn_1.periodpaydate >= r.effectivedate AND sn_1.periodpaydate <= r.enddate AND now() >= r.createts AND now() <= r.endts
             JOIN payroll.pay_code_types t ON pc.paycodetypeid = t.paycodetypeid
          GROUP BY sn_1.personid, sn_1.payscheduleperiodid, s.paymenttype, (COALESCE(s.sequencenumber, '~'::character varying)), pt.processingorder) x ON sn.personid = x.personid AND sn.payscheduleperiodid = x.payscheduleperiodid
     LEFT JOIN payroll.batchtaxmethodscheduleoptions b ON sn.payunitid = b.payunitid AND x.batchtaxdedscheduleid = b.batchtaxdedscheduleid
  WHERE psp.payrolltypeid = 1 AND sn.payrollstatus = 'A'::bpchar OR x.paymenttype IS NOT NULL;








----------------- calculate ytd gross / net pay end











select * from payroll.payment_detail 
where paycode = 'E01' and  check_date >= '2020-01-01' and payscheduleperiodid = 606 
and personid not in (select personid from payroll.payrollregisterearnings where payscheduleperiodid = 606
and etv_id = 'E01' )
;
select * from person_names where lname like 'Bor%';

select * from payroll.payment_detail where personid = '568' and payscheduleperiodid = '782' and paycode = 'VA5'
select * from payroll.staged_transaction where personid = '677';
select * from payroll.staged_transaction where paycode = 'E01' and payscheduleperiodid = '616';
select amount_ytd  from payroll.staged_transaction where paycode = 'E01' and payscheduleperiodid = '616';
select 723940.35 - 60400.74;
select sum(amount_ytd) from payroll.staged_transaction where payscheduleperiodid = '616' and paycode = 'E01';
select * from payroll.cognos_proposedpayrollregisterearnings  where etv_id = 'E01' and payscheduleperiodid in (select payscheduleperiodid from pay_schedule_period where date_part('year',periodpaydate)='2020');
select * from payroll.cognos_proposedpayrollregisterearnings  where etv_id = 'E01' and payscheduleperiodid in (select payscheduleperiodid from pay_schedule_period where date_part('year',periodpaydate)='2020');

select * from payroll.proposedpayrollregistersummary;
select * from payroll.cognos_proposedpayrollregistersummary ;

select * from payroll.payrollregisterearnings;
select * from payroll.personperiodpayments;
select * from pay_schedule_period where payscheduleperiodid = '604';
select * from payroll.personperiodpayments;

select payscheduleperiodid from payroll.personperiodpayments group by 1; 
select payscheduleperiodid 
select * from pay_schedule_period where date_part('year',periodpaydate)='2020';
select * from payroll.payrollregisterearnings where etv_id = 'E01'  

select * from payroll.staged_transaction where subject_wages_ytd <> 0;
select * from payroll.payment_detail where check_date >= '2020-01-01' and paycode = 'E01';
select * from payroll.payrollregisterearnings where ytd_wage <> 0;
select * from payroll.personperiodpayments where personid = '677' and etv_id = 'E01';

( select personid, payscheduleperiodid, asofdate, paycode, units_ytd, amount_ytd, subject_wages_ytd , max(paymentseq) as paymentseq, rank() over (partition by personid, paycode order by max(paymentseq) desc) as rank
             from payroll.staged_transaction where personid = '677' and paycode = 'E01'
            group by personid, payscheduleperiodid, asofdate, paycode, units_ytd, amount_ytd, subject_wages_ytd ) ;
 SELECT ppp.payscheduleperiodid,
    'Q1' as qsource,
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
    sum(COALESCE(st.units_ytd, 0::numeric)::numeric(18,6)) AS ytd_hrs,
    sum(COALESCE(st.amount_ytd, 0::numeric)::numeric(18,2)) AS ytd_amount,
    sum(COALESCE(st.subject_wages_ytd, 0::numeric)::numeric(18,2)) AS ytd_wage,
    ppp.paymenttype,
    COALESCE(ppp.sequencenumber, '~'::character varying) AS "coalesce"
   FROM payroll.personperiodpayments ppp
     JOIN payroll.staged_transaction st ON ppp.payscheduleperiodid = st.payscheduleperiodid AND ppp.personid = st.personid AND ppp.paymenttype = st.paymenttype AND COALESCE(ppp.sequencenumber, '~'::character varying)::text = COALESCE(st.sequencenumber, '~'::character varying)::text
     JOIN payroll.payment_types pt ON pt.paymenttype = st.paymenttype
     JOIN payroll.pay_codes pc ON pc.paycode::text = st.paycode::text AND pc.uidisplay = 'Y'::bpchar AND ppp.asofdate >= pc.effectivedate AND ppp.asofdate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.paycodetypeid = ANY (ARRAY[1, 2, 7]))
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = st.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     LEFT JOIN person_earning_setup pes ON pes.personid = st.personid AND pes.etvid::text = st.paycode::text AND psp.periodpaydate >= pes.effectivedate AND psp.periodpaydate <= pes.enddate AND now() >= pes.createts AND now() <= pes.endts
     where ppp.personid = '677' and st.paycode = 'E01'
  GROUP BY ppp.payscheduleperiodid, ppp.personid, pp.pspaypayrollid, pes.personearnsetuppid, st.paycode, st.rate, pc.paycodeshortdesc, ppp.paymenttype, (COALESCE(ppp.sequencenumber, '~'::character varying))
  ;
  
  select * from person_names where personid = '677';
  
  
  select * from  payroll.payrollregisterearnings
  
  where payscheduleperiodid in ( SELECT pay_schedule_period.payscheduleperiodid
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT distinct staged_transaction.payscheduleperiodid  FROM payroll.staged_transaction))))) and personid = '677' and etv_id = 'E01';
                  
( SELECT *
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT distinct staged_transaction.payscheduleperiodid  FROM payroll.staged_transaction))))) ;                 

 SELECT p2.payscheduleperiodid,     'Q2' as qsource,
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
    p2.sequencenumber AS "coalesce"

    
   FROM payroll.payrollregisterearnings p2
  WHERE (p2.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid
                           FROM payroll.staged_transaction)))))) and p2.personid = '677' and p2.etv_id = 'E01';               
                           
                            
select * from payroll.payrollregisterearnings p2 where personid = '677' and etv_id = 'E01' and  (p2.payscheduleperiodid IN ( SELECT pay_schedule_period.payscheduleperiodid
           FROM pay_schedule_period
          WHERE date_part('year'::text, pay_schedule_period.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period_1.periodpaydate) AS min
                   FROM pay_schedule_period pay_schedule_period_1
                  WHERE (pay_schedule_period_1.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid
                           FROM payroll.staged_transaction))))))                        ;
                           
select * from  pay_schedule_period where date_part('year',periodpaydate) >= '2016' and payscheduleperiodid in ( SELECT staged_transaction.payscheduleperiodid FROM payroll.staged_transaction)      ;     
select * from payroll.payrollregisterearnings where personid = '677' and etv_id = 'E01' and payscheduleperiodid = '616'; 


