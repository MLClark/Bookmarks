-- View: public.cognos_covid_employee_retention_credit

-- DROP VIEW public.cognos_covid_employee_retention_credit;

--CREATE OR REPLACE VIEW public.cognos_covid_employee_retention_credit AS 
 SELECT ph.personid,
    ph.employer_id,
    ph.group_key,
    ph.paymentheaderid,
    pn.name,
    psp.periodpaydate,
    pe.emplclass,
    ccd.original_er_social_sec_wages,
    ccd.adjusted_er_social_sec_wages,
    ccd.ee_health_expense_credit,
    ccd.er_health_expense_credit,
    ccd.er_ret_credit
   FROM covid_ee_ret_credit_detail ccd
     JOIN pspay_payment_header ph ON ph.paymentheaderid = ccd.paymentheaderid AND ph.check_date = ccd.check_date
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN person_names pn ON pn.nametype = 'Legal'::bpchar AND pn.personid = ph.personid AND 'now'::text::date >= pn.effectivedate AND 'now'::text::date <= pn.enddate AND now() >= pn.createts AND now() <= pn.endts
     JOIN person_employment pe ON pe.personid = ph.personid AND 'now'::text::date >= pe.effectivedate AND 'now'::text::date <= pe.enddate AND now() >= pe.createts AND now() <= pe.endts
  WHERE (ph.paymentheaderid IN ( SELECT ph_1.paymentheaderid
           FROM covid_ee_ret_credit_detail ccd_1
             JOIN pspay_payment_header ph_1 ON ccd_1.paymentheaderid = ph_1.paymentheaderid
          WHERE (ph_1.employer_id IN ( SELECT unnest(company_tax_setup_federal.cares_erclt100_feinlist) AS unnest
                   FROM company_tax_setup_federal
                  WHERE 'now'::text::date >= company_tax_setup_federal.effectivedate AND 'now'::text::date <= company_tax_setup_federal.enddate AND now() >= company_tax_setup_federal.createts AND now() <= company_tax_setup_federal.endts AND company_tax_setup_federal.legislationid = 2 AND company_tax_setup_federal.taxid = 1
                UNION
                 SELECT unnest(company_tax_setup_federal.cares_ercgt100_feinlist) AS unnest
                   FROM company_tax_setup_federal
                  WHERE 'now'::text::date >= company_tax_setup_federal.effectivedate AND 'now'::text::date <= company_tax_setup_federal.enddate AND now() >= company_tax_setup_federal.createts AND now() <= company_tax_setup_federal.endts AND company_tax_setup_federal.legislationid = 2 AND company_tax_setup_federal.taxid = 1))))
  ORDER BY ph.check_date, ph.paymentheaderid;
/*
ALTER TABLE public.cognos_covid_employee_retention_credit
  OWNER TO skybotsu;
GRANT ALL ON TABLE public.cognos_covid_employee_retention_credit TO skybotsu;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_covid_employee_retention_credit TO read_write;
GRANT SELECT ON TABLE public.cognos_covid_employee_retention_credit TO read_only;
*/
