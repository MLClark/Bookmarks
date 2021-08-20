DROP VIEW public.cognos_payrollregistersummary_winter;

DROP MATERIALIZED VIEW public.cognos_payrollregistersummary_winter_mv;

CREATE MATERIALIZED VIEW public.cognos_payrollregistersummary_winter_mv AS 
 SELECT DISTINCT ph.personid,
    ((pn.fname::text || ' '::text) || COALESCE(pn.mname::text || ' '::text, ''::text)) || pn.lname::text AS employeename,
    (((pn.lname::text || ' '::text) || pn.fname::text) || ' '::text) || COALESCE(pn.mname, ''::character varying)::text AS employeenamelastfirst,
    ph.paymentheaderid,
    ph.individual_key AS employeeid,
    ph.check_date::character varying AS check_date,
    gk.groupkey AS group_key,
    ph.period_begin_date::character varying AS periodstartdate,
    ph.period_end_date::character varying AS periodenddate,
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
    ph.payment_number::text AS payment_number,
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
    ph.payrollfinal,
    ' ' as paymenttype,
    0 as processingorder,
    ' ' ::varchar(5) as sequencenumber ,
    case when pd.remoteemployee = 'Y' then pa.stateprovincecode else la.stateprovincecode end as workstate
   FROM pspay_payment_header ph
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar AND cp.companyparametervalue::text = 'PSPAY'::text
     JOIN paymentheaderclassifications phc ON phc.paymentheaderid = ph.paymentheaderid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN personpayperiodgetdates pgd ON pgd.payscheduleperiodid = ph.payscheduleperiodid AND ph.personid = pgd.personid
     JOIN person_names pn ON ph.personid = pn.personid AND now() >= pn.effectivedate AND now() <= pn.enddate AND now() >= pn.createts AND now() <= pn.endts AND pn.nametype = 'Legal'::bpchar
     JOIN pay_unit pu ON pgd.payunitid = pu.payunitid AND now() >= pu.createts AND now() <= pu.endts
     JOIN groupkey gk ON gk.payunitid = pu.payunitid
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
     LEFT JOIN person_locations pl ON pl.personid = ppos.personid AND pgd.person_default_perioddate >= pl.effectivedate AND pgd.person_default_perioddate <= pl.enddate AND now() >= pl.createts AND now() <= pl.endts
     LEFT JOIN location_address la ON la.locationid = pl.locationid AND pgd.person_default_perioddate >= la.effectivedate AND pgd.person_default_perioddate <= la.enddate AND now() >= la.createts AND now() <= la.endts
     LEFT JOIN person_address pa on pa.personid = ppos.personid AND pgd.person_default_perioddate >= pa.effectivedate AND pgd.person_default_perioddate <= pa.enddate AND now() >= pa.createts AND now() <= pa.endts and pa.addresstype = 'Res' 
     LEFT JOIN position_desc pd on pd.positionid = ppos.positionid AND pgd.person_default_perioddate >= pd.effectivedate AND pgd.person_default_perioddate <= pd.enddate AND now() >= pd.createts AND now() <= pd.endts  
     LEFT JOIN ( SELECT cp_1.countrycode,
            cp_1.patternmask,
            "position"(cp_1.patternmask::text, '-'::text) AS dash1,
            "position"("substring"(cp_1.patternmask::text, "position"(cp_1.patternmask::text, '-'::text) + 1), '-'::text) AS dash2,
            "position"("substring"("substring"(cp_1.patternmask::text, "position"(cp_1.patternmask::text, '-'::text) + 1), "position"(cp_1.patternmask::text, '-'::text) + 1), '-'::text) AS dash3
           FROM country_pattern cp_1
          WHERE cp_1.patterntype = 'identity'::bpchar) pm ON pm.countrycode = pi.countrycode
                   

WITH NO DATA;

CREATE OR REPLACE VIEW public.cognos_payrollregistersummary_winter
AS SELECT cognos_payrollregistersummary_winter_mv.personid,
    cognos_payrollregistersummary_winter_mv.employeename,
    cognos_payrollregistersummary_winter_mv.employeenamelastfirst,
    cognos_payrollregistersummary_winter_mv.paymentheaderid,
    cognos_payrollregistersummary_winter_mv.employeeid,
    cognos_payrollregistersummary_winter_mv.check_date,
    cognos_payrollregistersummary_winter_mv.group_key,
    cognos_payrollregistersummary_winter_mv.periodstartdate,
    cognos_payrollregistersummary_winter_mv.periodenddate,
    cognos_payrollregistersummary_winter_mv.checkno,
    cognos_payrollregistersummary_winter_mv.net_pay,
    cognos_payrollregistersummary_winter_mv.gross_pay,
    cognos_payrollregistersummary_winter_mv.ssn,
    cognos_payrollregistersummary_winter_mv.payscheduleperiodid,
    cognos_payrollregistersummary_winter_mv.payperiodstartdate,
    cognos_payrollregistersummary_winter_mv.payperiodenddate,
    cognos_payrollregistersummary_winter_mv.periodpaydate,
    cognos_payrollregistersummary_winter_mv.pspaypayrollid,
    cognos_payrollregistersummary_winter_mv.payment_number,
    cognos_payrollregistersummary_winter_mv.dept,
    cognos_payrollregistersummary_winter_mv.deptcode,
    cognos_payrollregistersummary_winter_mv.divcode,
    cognos_payrollregistersummary_winter_mv.divdesc,
    cognos_payrollregistersummary_winter_mv.emplstatusdesc,
    cognos_payrollregistersummary_winter_mv.currentrate,
    cognos_payrollregistersummary_winter_mv.payunitid,
    cognos_payrollregistersummary_winter_mv.has_disbursements,
    cognos_payrollregistersummary_winter_mv.is_directdeposit,
    cognos_payrollregistersummary_winter_mv.is_livecheck,
    cognos_payrollregistersummary_winter_mv.is_immediatecheck,
    cognos_payrollregistersummary_winter_mv.is_adjustment,
    cognos_payrollregistersummary_winter_mv.is_postpayment,
    cognos_payrollregistersummary_winter_mv.is_voided,
    cognos_payrollregistersummary_winter_mv.is_reissued,
    cognos_payrollregistersummary_winter_mv.payrollfinal,
    cognos_payrollregistersummary_winter_mv.paymenttype,
    cognos_payrollregistersummary_winter_mv.processingorder,
    cognos_payrollregistersummary_winter_mv.sequencenumber,
    cognos_payrollregistersummary_winter_mv.workstate
   FROM cognos_payrollregistersummary_winter_mv;


