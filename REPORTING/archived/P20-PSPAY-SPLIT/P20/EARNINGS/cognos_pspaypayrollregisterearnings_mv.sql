--CREATE MATERIALIZED VIEW payroll.cognos_pspaypayrollregisterearnings_mv AS 
 SELECT ph.personid,
    ph.paymentheaderid,
    pp.pspaypayrollid,
    pes.personearnsetuppid,
    pd.paycode,
    pd.paycode::text || COALESCE('-'::text || pdd.etvname::text, ''::text) AS etvname,
    pd.amount AS amount,
    pd.units AS hours,
    pd.rate AS rate,
    ph.net_pay,
    ph.gross_pay,
    pd.units_ytd AS ytd_hrs,
    pd.amount_ytd AS ytd_amount,
    pd.subject_wages_ytd AS ytd_wage
   FROM payroll.payment_header ph
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar and cp.companyparametervalue::text = 'P20'::text
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid

     JOIN payroll.payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND (pd.amount_ytd <> 0::numeric OR pd.units_ytd <> 0::numeric OR pd.amount <> 0::numeric OR pd.units <> 0::numeric) --AND pd.etv_code = 'EE'::bpchar not sure how to apply this 
      AND ((pd.paycode in (select distinct etvid as paycode from  person_earning_setup where current_date between effectivedate and enddate and current_timestamp between createts and endts))
       or  (pd.paycode in (select distinct paycode from payroll.pay_codes where paycodetypeid in (1,2) and current_date between effectivedate and enddate and current_timestamp between createts and endts)))
    
     JOIN pay_unit pu ON pu.payunitid = ph.payunitid AND current_timestamp between pu.createts and pu.endts  ----- added current_timestamp 
     
     LEFT JOIN pspaygroupearningdeductiondets pdd ON pu.payunitdesc = pdd.group_key AND pd.paycode::text = pdd.etv_id::text AND pdd.etorv = 'E'::text
     LEFT JOIN person_earning_setup pes ON ph.personid = pes.personid AND pes.etvid::text = pd.paycode::text AND psp.periodpaydate >= pes.effectivedate AND psp.periodpaydate <= pes.enddate AND now() >= pes.createts AND now() <= pes.endts
/*     
     

WITH DATA;

ALTER TABLE payroll.cognos_pspaypayrollregisterearnings_mv   OWNER TO postgres;
GRANT ALL ON TABLE payroll.cognos_pspaypayrollregisterearnings_mv TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_pspaypayrollregisterearnings_mv TO read_write;
GRANT SELECT ON TABLE payroll.cognos_pspaypayrollregisterearnings_mv TO read_only;


CREATE INDEX ix_cognos_pspaypayrollregisterearnings_mv
  ON payroll.cognos_pspaypayrollregisterearnings_mv
  USING btree
  (paymentheaderid);


CREATE INDEX ix_cognos_pspaypayrollregisterearnings_payrollid
  ON payroll.cognos_pspaypayrollregisterearnings_mv
  USING btree
  (pspaypayrollid);
*/