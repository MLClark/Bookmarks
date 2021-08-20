--CREATE MATERIALIZED VIEW payroll.cognos_payrollregistersummary_mv AS 
 SELECT DISTINCT ph.personid,
    ((((pn.fname::text || ' '::text) || COALESCE(pn.mname::text || ' '::text, ''::text)) || pn.lname::text) || ' '::text) || COALESCE(pn.title::text || ' '::text, ''::text) AS employeename,
    (((((pn.lname::text || ' '::text) || pn.fname::text) || ' '::text) || COALESCE(pn.mname, ''::character varying)::text) || ' '::text) || COALESCE(pn.title::text || ' '::text, ''::text) AS employeenamelastfirst,
    ph.paymentheaderid,
    pip.identity AS employeeid,
    ph.check_date::character varying AS check_date,
    pu.payunitdesc AS group_key,
    psp.periodstartdate,
    psp.periodenddate,
    ph.check_number AS checkno,
    ph.net_pay,
    ph.gross_pay,
        CASE
            WHEN pm.dash3 <> 0 THEN replace("substring"(pm.patternmask::text, 1, pm.dash1 + pm.dash2 + pm.dash3) || "substring"(pi.identity::text, pm.dash1 + pm.dash2 + pm.dash3 - 1, length(pi.identity::text) - pm.dash3), '?'::text, 'X'::text)
            WHEN pm.dash2 <> 0 THEN replace("substring"(pm.patternmask::text, 1, pm.dash1 + pm.dash2) || "substring"(pi.identity::text, pm.dash1 + pm.dash2 - 1, length(pi.identity::text) - pm.dash2), '?'::text, 'X'::text)
            WHEN pm.dash1 <> 0 THEN replace("substring"(pm.patternmask::text, 1, pm.dash1) || "substring"(pi.identity::text, pm.dash1 - 1, length(pi.identity::text) - pm.dash1), '?'::text, 'X'::text)
            ELSE lpad("substring"(pi.identity::text, length(pi.identity::text) - 3, length(pi.identity::text)), length(pi.identity::text), 'X'::text)
        END AS ssn,
    pgd.payscheduleperiodid,
    pgd.periodstartdate AS payperiodstartdate,
    pgd.periodenddate AS payperiodenddate,
    pgd.periodpaydate,
    pp.pspaypayrollid,
    ph.sequencenumber AS payment_number,
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
    phc.has_disbursements,
    phc.is_directdeposit,
    phc.is_livecheck,
    phc.is_immediatecheck,
    phc.is_adjustment,
    phc.is_postpayment,
    phc.is_voided,
    phc.is_reissued,
        CASE
            WHEN pp.pspaypayrollstatusid = 4 THEN 'Y'::text
            ELSE 'N'::text
        END AS payrollfinal
   FROM payroll.payment_header ph
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar AND cp.companyparametervalue::text = 'P20'::text
     JOIN paymentheaderclassifications phc ON phc.paymentheaderid = ph.paymentheaderid
     LEFT JOIN person_identity pip ON pip.personid = ph.personid AND now() >= pip.createts AND now() <= pip.endts AND pip.identitytype = 'PSPID'::bpchar
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN personpayperiodgetdates pgd ON pgd.payscheduleperiodid = ph.payscheduleperiodid AND ph.personid = pgd.personid
     JOIN person_names pn ON ph.personid = pn.personid AND now() >= pn.effectivedate AND now() <= pn.enddate AND now() >= pn.createts AND now() <= pn.endts AND pn.nametype = 'Legal'::bpchar
     JOIN pay_unit pu ON pgd.payunitid = pu.payunitid AND now() >= pu.createts AND now() <= pu.endts
     LEFT JOIN pers_pos ppos ON pn.personid = ppos.personid AND pgd.person_default_perioddate >= ppos.effectivedate AND pgd.person_default_perioddate <= ppos.enddate AND now() >= ppos.createts AND now() <= ppos.endts AND ppos.persposrel = 'Occupies'::bpchar
     LEFT JOIN pos_org_rel por ON ppos.positionid = por.positionid AND pgd.person_default_perioddate >= por.effectivedate AND pgd.person_default_perioddate <= por.enddate AND now() >= por.createts AND now() <= por.endts AND por.posorgreltype = 'Member'::bpchar
     LEFT JOIN organization_code oc ON por.organizationid = oc.organizationid AND pgd.person_default_perioddate >= oc.effectivedate AND pgd.person_default_perioddate <= oc.enddate AND now() >= oc.createts AND now() <= oc.endts
     LEFT JOIN org_rel or1 ON por.organizationid = or1.organizationid AND pgd.person_default_perioddate >= or1.effectivedate AND pgd.person_default_perioddate <= or1.enddate AND now() >= or1.createts AND now() <= or1.endts AND or1.orgreltype = 'Management'::bpchar
     LEFT JOIN organization_code oc_div ON or1.memberoforgid = oc_div.organizationid AND pgd.person_default_perioddate >= oc_div.effectivedate AND pgd.person_default_perioddate <= oc_div.enddate AND now() >= oc_div.createts AND now() <= oc_div.endts
     LEFT JOIN person_compensation pc ON ph.personid = pc.personid AND pgd.person_default_perioddate >= pc.effectivedate AND pgd.person_default_perioddate <= pc.enddate AND now() >= pc.createts AND now() <= pc.endts AND (pc.earningscode = ANY (ARRAY['Regular'::bpchar, 'RegHrly'::bpchar, 'ExcHrly'::bpchar]))
     LEFT JOIN frequency_codes fc ON pc.frequencycode = fc.frequencycode
     LEFT JOIN frequency_codes fcpos ON ppos.schedulefrequency = fcpos.frequencycode
     LEFT JOIN frequency_codes fcpay ON pu.frequencycode = fcpay.frequencycode
     JOIN person_employment pe ON pe.personid = ph.personid AND pgd.person_default_perioddate >= pe.effectivedate AND pgd.person_default_perioddate <= pe.enddate AND now() >= pe.createts AND now() <= pe.endts
     JOIN employment_status s ON pe.emplstatus::text = s.emplstatus
     LEFT JOIN person_identity pi ON pi.personid = ph.personid AND pi.countrycode IS NOT NULL AND now() >= pi.createts AND now() <= pi.endts
     LEFT JOIN ( SELECT cp_1.countrycode,
            cp_1.patternmask,
            "position"(cp_1.patternmask::text, '-'::text) AS dash1,
            "position"("substring"(cp_1.patternmask::text, "position"(cp_1.patternmask::text, '-'::text) + 1), '-'::text) AS dash2,
            "position"("substring"("substring"(cp_1.patternmask::text, "position"(cp_1.patternmask::text, '-'::text) + 1), "position"(cp_1.patternmask::text, '-'::text) + 1), '-'::text) AS dash3
           FROM country_pattern cp_1
          WHERE cp_1.patterntype = 'identity'::bpchar) pm ON pm.countrycode = pi.countrycode

    
--WITH DATA;