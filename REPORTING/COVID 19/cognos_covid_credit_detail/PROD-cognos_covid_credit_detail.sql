-- View: public.cognos_covid_credit_detail

-- DROP VIEW public.cognos_covid_credit_detail;

CREATE OR REPLACE VIEW public.cognos_covid_credit_detail AS 
 SELECT pph.personid,
    pph.employer_id,
    pph.paymentheaderid,
    psp.periodpaydate,
        CASE
            WHEN pph.processingtype = 'ImmCheck'::bpchar THEN ((pph.processingtype::text || ': '::text) || to_char(pph.check_date, 'mm/dd/yyyy'::text))::bpchar
            ELSE pph.processingtype
        END AS type_of_check,
    pn.name,
    ccd.etv_id,
    ccd.sick_category,
    ccd.credit_type,
    ppd.etype_hours,
    ppd.etv_amount,
    ccd.earn_rate AS rate,
    ccd.ftptindicator AS fulltime_parttime,
    ccd.maxcredithours AS maximum_hours_allowed,
    ccd.sick_hours AS current_hours_toward_max,
    ccd.adjusted_ee_social_sec_wages AS ee_ss_wages_sick_fmla,
    ccd.er_medicare_credit AS er_med_tax_sick_fmla,
    ccd.ee_health_expense_credit AS ee_qual_health_care,
    ccd.er_health_expense_credit AS er_qual_health_care
   FROM pspay_payment_header pph
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = pph.payscheduleperiodid
     JOIN person_names pn ON pn.personid = pph.personid AND pn.nametype = 'Legal'::bpchar AND 'now'::text::date >= pn.effectivedate AND 'now'::text::date <= pn.enddate AND now() >= pn.createts AND now() <= pn.endts
     JOIN pspay_payment_detail ppd ON ppd.personid = pph.personid AND ppd.paymentheaderid = pph.paymentheaderid AND ppd.payment_number = pph.payment_number
     JOIN covid_credit_detail ccd ON ccd.paymentheaderid = ppd.paymentheaderid AND ccd.etv_id::text = ppd.etv_id::text
  WHERE (pph.paymentheaderid IN ( SELECT ph.paymentheaderid
           FROM covid_credit_detail ccd_1
             JOIN pspay_payment_header ph ON ccd_1.paymentheaderid = ph.paymentheaderid
          WHERE (ph.employer_id IN ( SELECT unnest(company_tax_setup_federal.feinlist) AS unnest
                   FROM company_tax_setup_federal
                  WHERE 'now'::text::date >= company_tax_setup_federal.effectivedate AND 'now'::text::date <= company_tax_setup_federal.enddate AND now() >= company_tax_setup_federal.createts AND now() <= company_tax_setup_federal.endts AND company_tax_setup_federal.legislationid = 1 AND company_tax_setup_federal.taxid = 1))))
  ORDER BY pph.check_date, ppd.etv_id, pph.paymentheaderid;

ALTER TABLE public.cognos_covid_credit_detail
  OWNER TO skybotsu;
GRANT ALL ON TABLE public.cognos_covid_credit_detail TO skybotsu;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_covid_credit_detail TO read_write;
GRANT SELECT ON TABLE public.cognos_covid_credit_detail TO read_only;
