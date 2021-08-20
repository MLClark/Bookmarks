
--We need to look at legislationid = 2 (this links to the federal_tax_legislation table) 
-- and pull the fein list from cares_erclt100_feinlist and caresercgt100_feinlist. 
--  A client will only have values in one of those 2 fields.



 SELECT 
    ccd.original_er_social_sec_wages,
    ccd.adjusted_er_social_sec_wages,
    ccd.ee_health_expense_credit,
    ccd.er_health_expense_credit,
    ccd.er_ret_credit
   FROM covid_ee_ret_credit_detail ccd
     JOIN pspay_payment_header ph ON ph.paymentheaderid = ccd.paymentheaderid AND ph.check_date = ccd.check_date

  WHERE (ph.paymentheaderid IN 
        (SELECT ph_1.paymentheaderid 
           FROM covid_credit_detail ccd_1
           JOIN pspay_payment_header ph_1 ON ccd_1.paymentheaderid = ph_1.paymentheaderid
          WHERE (ph_1.employer_id IN
               ( SELECT unnest(company_tax_setup_federal.feinlist) AS unnest  
                   FROM company_tax_setup_federal
                   join federal_tax_legislation ftl
                     on ftl.id = company_tax_setup_federal.legislationid
                  WHERE 'now'::text::date >= company_tax_setup_federal.effectivedate 
                    AND 'now'::text::date <= company_tax_setup_federal.enddate 
                    AND 'now'::text::date >= company_tax_setup_federal.createts 
                    AND 'now'::text::date <= company_tax_setup_federal.endts 
                    --AND company_tax_setup_federal.legislationid = 2 
                    AND company_tax_setup_federal.taxid = 1
                  )))
                  )


select * from federal_tax_legislation;
select * from company_tax_setup_federal;

select unnest(feinlist) as unnest from company_tax_setup_federal where current_date between effectivedate and enddate and current_timestamp between createts and endts and legislationid = 1;



( SELECT unnest(company_tax_setup_federal.cares_erclt100_feinlist) AS unnest
                   FROM company_tax_setup_federal
                  WHERE 'now'::text::date >= company_tax_setup_federal.effectivedate AND 'now'::text::date <= company_tax_setup_federal.enddate AND now() >= company_tax_setup_federal.createts AND now() <= company_tax_setup_federal.endts AND company_tax_setup_federal.legislationid = 2 AND company_tax_setup_federal.taxid = 1
                  union
  SELECT unnest(company_tax_setup_federal.cares_ercgt100_feinlist) AS unnest
                   FROM company_tax_setup_federal
                  WHERE 'now'::text::date >= company_tax_setup_federal.effectivedate AND 'now'::text::date <= company_tax_setup_federal.enddate AND now() >= company_tax_setup_federal.createts AND now() <= company_tax_setup_federal.endts AND company_tax_setup_federal.legislationid = 2 AND company_tax_setup_federal.taxid = 1                  
)


CSD-29271
-- data available in AJG and DFG on QA
select * from 

select * from cognos_covid_credit_detail;
select * from pay_unit;

select * from person_names where lname like 'Beavon%';

select * from cognos_covid_credit_detail where personid = '3593';


select * from covid_credit_detail where personid = '3200';
select * from cognos_w2_data where boxnumber like 'b%';
select * from w2viewsummarytotals;

case when [Logical].[Covid Credit Detail].[periodpaydate] is not null then ( to_char(minimum([Logical].[Covid Credit Detail].[periodpaydate]),'yyyy-mm-dd') ) end

select * from pspay_payment_detail where etv_id in ('EDH','EDI') and personid = '13617';
select * from payunit;

select * from covid_credit_detail where paymentheaderid in (select  paymentheaderid from pspay_payment_detail where etv_id in ('EDH','EDI') and personid = '13617');

select * from pspay_payment_header where paymentheaderid in (select  paymentheaderid from pspay_payment_detail where etv_id in ('EDH','EDI') and personid = '13617');


select * from covid_credit_detail where paymentheaderid in ('53349','53369','53371');
select * from pspay_payment_header where paymentheaderid in ('53349','53369','53371');
select unnest(feinlist) from company_tax_setup_federal where current_date between effectivedate and enddate and current_timestamp between createts and endts and legislationid = 1 and taxid = 1;

select * from company_tax_setup_federal;

select * from company_tax_setup
select * from company_tax_setup_federal
select * from pspay_payment_header where paymentheaderid = 53288
select * from pay_schedule_period;

select * from covid_credit_detail where paymentheaderid not in (select 

select taxid, legislationid, unnest(feinlist) from company_tax_setup_federal where current_date between effectivedate and enddate
and current_timestamp between createts and endts;


select taxid, legislationid, feinlist from company_tax_setup_federal where current_date between effectivedate and enddate
and current_timestamp between createts and endts;

where paymentheaderid in 
        (select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
                (select payscheduleperiodid from pspay_payroll_pay_sch_periods where pspaypayrollid in 
                        (select pspaypayrollid from pspay_payroll ppay join edi.edi_last_update elu 
                             on elu.feedid = 'DGH_JH_401K_Export' and elu.lastupdatets <= ppay.statusdate
                             where ppay.pspaypayrollstatusid = 4 )))


select * from covid_credit_detail 



select * from companytaxsetupfederalasof cts, json_array_elements(feinlist) as fein fl where asofdate = current_date
select fl from companytaxsetupfederalasof cts, json_array_elements(feinlist) fl where asofdate = current_date

If we use Period Pay Date (instead of check date) as the first column (and selection criteria), but include "Immediate check: MM/DD/YY" that shows the date the check was posted... that is the best of both worlds.


-- basis for view

create or replace view cognos_covid_credit_detail AS
select ph.employer_id, ccd.* from covid_credit_detail ccd
join pspay_payment_header ph on ccd.paymentheaderid = ph.paymentheaderid
where employer_id in (select unnest(feinlist) from company_tax_setup_federal where current_date between effectivedate and enddate
and current_timestamp between createts and endts and legislationid = 1 and taxid = 1);


select * from person_names where lname like 'Crut%';
-- looking for payment types

select pph.paymentheaderid, pph.personid, pph.check_date, pph.check_number, pph.payment_number
, pph.period_begin_date, pph.period_end_date, pph.payscheduleperiodid, pph.last_updt_dt, pph.processingtype, pph.paymenttype, pph.payrollfinal
,psp.*

 from pspay_payment_header pph 
 join pay_schedule_period psp on pph.payscheduleperiodid = psp.payscheduleperiodid
 where paymentheaderid in (select ph.paymentheaderid from covid_credit_detail ccd
join pspay_payment_header ph on ccd.paymentheaderid = ph.paymentheaderid
where employer_id in (select unnest(feinlist) from company_tax_setup_federal where current_date between effectivedate and enddate
and current_timestamp between createts and endts and legislationid = 1 and taxid = 1))
;

-- data available in AJG and DFG on QA
select * from covid_credit_detail;
select * from pspay_payment_detail where personid = '10278' and check_date >= '2020-04-01';