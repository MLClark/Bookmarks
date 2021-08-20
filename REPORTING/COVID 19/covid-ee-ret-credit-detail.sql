select * from person_names where lname like 'Agui%';
select * from covid_ee_ret_credit_detail ;
select * from pspay_payment_detail where paymentheaderid = '54629' and check_date = '2020-07-05';
select * from person_employment where personid = '20174';
--select * from covidcreditadjustments  ;

select 
 ph.personid
,ph.group_key
,ph.paymentheaderid
,pn.name
,ph.check_date
,pe.emplclass
,ccd.original_er_social_sec_wages
,ccd.adjusted_er_social_sec_wages

from covid_ee_ret_credit_detail ccd
join pspay_payment_header ph
  on ph.paymentheaderid = ccd.paymentheaderid
 and ph.check_date = ccd.check_date
join person_names pn
  on pn.nametype = 'Legal' 
 and pn.personid = ph.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
join person_employment pe
  on pe.personid = ph.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
;
select * from cognos_covid_credit_detail where personid in (select personid from cognos_covid_employee_retention_credit group by 1);

select * from cognos_covid_credit_detail where personid = '10106';
select * from covid_ee_ret_credit_detail where paymentheaderid = '54404';


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
           FROM covid_credit_detail ccd_1
             JOIN pspay_payment_header ph_1 ON ccd_1.paymentheaderid = ph_1.paymentheaderid
          WHERE (ph_1.employer_id IN ( SELECT unnest(company_tax_setup_federal.feinlist) AS unnest
                   FROM company_tax_setup_federal
                  WHERE 'now'::text::date >= company_tax_setup_federal.effectivedate AND 'now'::text::date <= company_tax_setup_federal.enddate AND now() >= company_tax_setup_federal.createts AND now() <= company_tax_setup_federal.endts AND company_tax_setup_federal.legislationid = 1 AND company_tax_setup_federal.taxid = 1))))
                  and ph.personid = '10106'
  ORDER BY ph.check_date, ph.paymentheaderid;