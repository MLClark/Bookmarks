-- View: payroll.cognos_proposedpayrollregistersummary

-- DROP VIEW payroll.cognos_proposedpayrollregistersummary;

--CREATE OR REPLACE VIEW payroll.cognos_proposedpayrollregistersummary AS 
/*

Remove the following columns (a search was done of all prod reports to confirm these columns are not used)
is_immediatecheck
is_adjustment
is_postpayment
is_voided
is_reissued
Add payroll.payment_type.paymenttypedesc to the view
Add payroll.payment_type.processingorder to the view

*/
 SELECT DISTINCT ppp.personid,
    ((pn.fname::text || ' '::text) || COALESCE(pn.mname::text || ' '::text, ''::text)) || pn.lname::text AS employeename,
    (((pn.lname::text || ' '::text) || pn.fname::text) || ' '::text) || COALESCE(pn.mname, ''::character varying)::text AS employeenamelastfirst,
    NULL::integer AS paymentheaderid,
    pspid.identity AS employeeid,
    to_char(pgd.periodpaydate::timestamp with time zone, 'MM/DD/YYYY'::text) AS check_date,
    gk.groupkey AS group_key,
    to_char(pgd.periodstartdate::timestamp with time zone, 'MM/DD/YYYY'::text) AS periodstartdate,
    to_char(pgd.periodenddate::timestamp with time zone, 'MM/DD/YYYY'::text) AS periodenddate,
    NULL::text AS checkno,
    ppp.net_amount AS net_pay,
    ppp.gross_amount AS gross_pay,
        CASE
            WHEN pm.dash3 <> 0 THEN replace("substring"(pm.patternmask::text, 1, pm.dash1 + pm.dash2 + pm.dash3) || "substring"(pi.identity::text, pm.dash1 + pm.dash2 + pm.dash3 - 1, length(pi.identity::text) - pm.dash3), '?'::text, 'X'::text)
            WHEN pm.dash2 <> 0 THEN replace("substring"(pm.patternmask::text, 1, pm.dash1 + pm.dash2) || "substring"(pi.identity::text, pm.dash1 + pm.dash2 - 1, length(pi.identity::text) - pm.dash2), '?'::text, 'X'::text)
            WHEN pm.dash1 <> 0 THEN replace("substring"(pm.patternmask::text, 1, pm.dash1) || "substring"(pi.identity::text, pm.dash1 - 1, length(pi.identity::text) - pm.dash1), '?'::text, 'X'::text)
            ELSE lpad("substring"(pi.identity::text, length(pi.identity::text) - 3, length(pi.identity::text)), length(pi.identity::text), 'X'::text)
        END AS ssn,
    ppp.payscheduleperiodid,
    pgd.periodstartdate AS payperiodstartdate,
    pgd.periodenddate AS payperiodenddate,
    pgd.periodpaydate,
    pp.pspaypayrollid,
    NULL::text AS payment_number,
    oc.organizationdesc AS dept,
    oc.orgcode AS deptcode,
    oc_div.orgcode AS divcode,
    oc_div.organizationdesc AS divdesc,
    s.emplstatusdesc,
        CASE
            WHEN pc.frequencycode = 'H'::bpchar THEN pc.compamount
            ELSE
            CASE
                WHEN fcpay.annualfactor > 0::numeric THEN pc.compamount * fc.annualfactor / fcpay.annualfactor
                ELSE 0::numeric
            END
        END AS currentrate,
    pgd.payunitid,
        CASE
            WHEN pt.hasdisbursements OR ppp.net_amount = 0::numeric AND ppp.gross_amount <> 0::numeric THEN 'T'::text
            ELSE 'F'::text
        END AS has_disbursements,
        CASE
            WHEN (ppp.paymenttype = ANY (ARRAY[1, 6])) AND pd.personid IS NOT NULL THEN 'T'::text
            ELSE 'F'::text
        END AS is_directdeposit,
        CASE
            WHEN (ppp.paymenttype = ANY (ARRAY[1, 6])) AND pd.personid IS NULL THEN 'T'::text
            ELSE 'F'::text
        END AS is_livecheck,
    ppp.paymenttype,
    pt.processingorder,
    pt.paymenttypedesc,
    COALESCE(ppp.sequencenumber, '~'::character varying) AS sequencenumber,
    'F'::text AS isaccepted
   FROM payroll.personperiodpayments ppp
     JOIN payroll.payment_types pt ON pt.paymenttype = ppp.paymenttype
     LEFT JOIN person_direct_deposits pd ON pd.personid = ppp.personid AND ppp.asofdate >= pd.effectivedate AND ppp.asofdate <= pd.enddate AND now() >= pd.createts AND now() <= pd.endts
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = ppp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN runpayrollgetdates pgd ON pgd.payscheduleperiodid = ppp.payscheduleperiodid
     JOIN person_names pn ON pn.personid = ppp.personid AND pgd.asofdate >= pn.effectivedate AND pgd.asofdate <= pn.enddate AND now() >= pn.createts AND now() <= pn.endts AND pn.nametype = 'Legal'::bpchar
     JOIN pay_unit pu ON pgd.payunitid = pu.payunitid
     JOIN groupkey gk ON gk.payunitid = pu.payunitid
     LEFT JOIN pers_pos ppos ON pn.personid = ppos.personid AND pgd.asofdate >= ppos.effectivedate AND pgd.asofdate <= ppos.enddate AND now() >= ppos.createts AND now() <= ppos.endts AND ppos.persposrel = 'Occupies'::bpchar
     LEFT JOIN pos_org_rel por ON ppos.positionid = por.positionid AND pgd.asofdate >= por.effectivedate AND pgd.asofdate <= por.enddate AND now() >= por.createts AND now() <= por.endts AND por.posorgreltype = 'Member'::bpchar
     LEFT JOIN organization_code oc ON por.organizationid = oc.organizationid AND pgd.asofdate >= oc.effectivedate AND pgd.asofdate <= oc.enddate AND now() >= oc.createts AND now() <= oc.endts
     LEFT JOIN org_rel or1 ON por.organizationid = or1.organizationid AND pgd.asofdate >= or1.effectivedate AND pgd.asofdate <= or1.enddate AND now() >= or1.createts AND now() <= or1.endts AND or1.orgreltype = 'Management'::bpchar
     LEFT JOIN organization_code oc_div ON or1.memberoforgid = oc_div.organizationid AND pgd.asofdate >= oc_div.effectivedate AND pgd.asofdate <= oc_div.enddate AND now() >= oc_div.createts AND now() <= oc_div.endts
     LEFT JOIN person_compensation pc ON pc.personid = ppp.personid AND pgd.asofdate >= pc.effectivedate AND pgd.asofdate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.earningscode = ANY (ARRAY['Regular'::bpchar, 'RegHrly'::bpchar, 'ExcHrly'::bpchar]))
     LEFT JOIN frequency_codes fc ON pc.frequencycode = fc.frequencycode
     LEFT JOIN frequency_codes fcpos ON ppos.schedulefrequency = fcpos.frequencycode
     LEFT JOIN frequency_codes fcpay ON pu.frequencycode = fcpay.frequencycode
     JOIN person_employment pe ON pe.personid = ppp.personid AND pgd.asofdate >= pe.effectivedate AND pgd.asofdate <= pe.enddate AND now() >= pe.createts AND now() <= pe.endts
     JOIN employment_status s ON pe.emplstatus::text = s.emplstatus
     JOIN person_identity pspid ON pspid.personid = ppp.personid AND pspid.identitytype = 'PSPID'::bpchar AND now() >= pspid.createts AND now() <= pspid.endts
     LEFT JOIN person_identity pi ON pi.personid = ppp.personid AND pi.countrycode IS NOT NULL AND now() >= pi.createts AND now() <= pi.endts
     LEFT JOIN ( SELECT cp.countrycode,
            cp.patternmask,
            "position"(cp.patternmask::text, '-'::text) AS dash1,
            "position"("substring"(cp.patternmask::text, "position"(cp.patternmask::text, '-'::text) + 1), '-'::text) AS dash2,
            "position"("substring"("substring"(cp.patternmask::text, "position"(cp.patternmask::text, '-'::text) + 1), "position"(cp.patternmask::text, '-'::text) + 1), '-'::text) AS dash3
           FROM country_pattern cp
          WHERE cp.patterntype = 'identity'::bpchar) pm ON pm.countrycode = pi.countrycode
UNION
 SELECT payrollregistersummary.personid,
    payrollregistersummary.employeename,
    payrollregistersummary.employeenamelastfirst,
    payrollregistersummary.paymentheaderid,
    payrollregistersummary.employeeid,
    payrollregistersummary.check_date,
    payrollregistersummary.group_key,
    payrollregistersummary.periodstartdate,
    payrollregistersummary.periodenddate,
    payrollregistersummary.checkno,
    payrollregistersummary.net_pay,
    payrollregistersummary.gross_pay,
    payrollregistersummary.ssn,
    payrollregistersummary.payscheduleperiodid,
    payrollregistersummary.payperiodstartdate,
    payrollregistersummary.payperiodenddate,
    payrollregistersummary.periodpaydate,
    payrollregistersummary.pspaypayrollid,
    payrollregistersummary.payment_number,
    payrollregistersummary.dept,
    payrollregistersummary.deptcode,
    payrollregistersummary.divcode,
    payrollregistersummary.divdesc,
    payrollregistersummary.emplstatusdesc,
    payrollregistersummary.currentrate,
    payrollregistersummary.payunitid,
        CASE
            WHEN payrollregistersummary.has_disbursements THEN 'T'::text
            ELSE 'F'::text
        END AS has_disbursements,
        CASE
            WHEN payrollregistersummary.is_directdeposit THEN 'T'::text
            ELSE 'F'::text
        END AS is_directdeposit,
        CASE
            WHEN payrollregistersummary.is_livecheck THEN 'T'::text
            ELSE 'F'::text
        END AS is_livecheck,

    payrollregistersummary.paymenttype,
    payrollregistersummary.processingorder,
    payrollregistersummary.paymenttypedesc,
    payrollregistersummary.sequencenumber,
        CASE
            WHEN payrollregistersummary.isaccepted THEN 'T'::text
            ELSE 'F'::text
        END AS isaccepted
   FROM payroll.payrollregistersummary
  WHERE date_part('year'::text, payrollregistersummary.periodpaydate) >= date_part('year'::text, ( SELECT min(pay_schedule_period.periodpaydate) AS min
           FROM pay_schedule_period
          WHERE (pay_schedule_period.payscheduleperiodid IN ( SELECT staged_transaction.payscheduleperiodid
                   FROM payroll.staged_transaction))));
/*
ALTER TABLE payroll.cognos_proposedpayrollregistersummary
  OWNER TO postgres;
GRANT ALL ON TABLE payroll.cognos_proposedpayrollregistersummary TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_proposedpayrollregistersummary TO read_write;
GRANT SELECT ON TABLE payroll.cognos_proposedpayrollregistersummary TO read_only;
*/
