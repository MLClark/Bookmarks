-- Materialized View: payroll.cognos_payrollregistertaxes_mv
DROP VIEW payroll.cognos_payrollregistertaxes;
DROP MATERIALIZED VIEW payroll.cognos_payrollregistertaxes_mv;
CREATE MATERIALIZED VIEW payroll.cognos_payrollregistertaxes_mv AS 
 SELECT ph.personid,
    ph.paymentheaderid,
    pp.pspaypayrollid,
    pd.pd_paycode AS etv_id,
    pd.pc_paycode::text || COALESCE('-'::text || pd.paycodeshortdesc::text, ''::text) AS etvname,
    ((pd.taxiddesc::text ||
        CASE
            WHEN COALESCE(cts.privateplan, 'N'::bpchar) = 'Y'::bpchar THEN ' - Private Plan'::text
            ELSE ''::text
        END))::character varying(128) AS taxiddesc,
    pd.taxid,
    pd.amount,
    pd.units AS hours,
    pd.subject_wages AS wage,
    ph.net_pay,
    ph.gross_pay,
    pd.units_ytd AS ytd_hrs,
    pd.amount_ytd AS ytd_amount,
    pd.subject_wages_ytd AS ytd_wage,
        CASE
            WHEN pd.pd_paycode::bpchar = 'ER'::bpchar THEN 'Y'::bpchar
            ELSE 'N'::bpchar
        END AS isemployer
   FROM payroll.payment_header ph
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN runpayrollgetdates rpgd ON rpgd.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     JOIN pay_unit pu ON pu.payunitid = psp.payunitid AND now() >= pu.createts AND now() <= pu.endts
     JOIN ( SELECT pd_1.personid,
            pd_1.paymentheaderid,
            t.taxid,
            pd_1.paycode AS pd_paycode,
            payc.paycode AS pc_paycode,
            pd_1.units,
            pd_1.amount,
            pd_1.subject_wages,
            pd_1.units_ytd,
            pd_1.amount_ytd,
            pd_1.subject_wages_ytd,
            payc.paycodeshortdesc,
            t.taxiddesc
           FROM payroll.payment_detail pd_1
             JOIN payroll.pay_codes payc ON payc.paycode::text = pd_1.paycode::text AND 'now'::text::date >= payc.effectivedate AND 'now'::text::date <= payc.enddate AND now() >= payc.createts AND now() <= payc.endts AND (payc.paycodetypeid = ANY (ARRAY[4, 8, 9]))
             JOIN tax t ON t.taxid = pd_1.taxid
          WHERE pd_1.amount_ytd <> 0::numeric OR pd_1.subject_wages_ytd <> 0::numeric OR pd_1.amount <> 0::numeric OR pd_1.subject_wages <> 0::numeric) pd ON pd.personid = ph.personid AND pd.paymentheaderid = ph.paymentheaderid
     LEFT JOIN company_tax_setup cts ON (pu.employertaxid::character varying::text = ANY (cts.feinlist::text[])) AND now() >= cts.createts AND now() <= cts.endts AND rpgd.asofdate >= cts.effectivedate AND rpgd.asofdate <= cts.enddate AND cts.taxid = pd.taxid
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar AND cp.companyparametervalue::text = 'P20'::text
WITH DATA;

ALTER TABLE payroll.cognos_payrollregistertaxes_mv
  OWNER TO ehcmuser;
GRANT ALL ON TABLE payroll.cognos_payrollregistertaxes_mv TO ehcmuser;
GRANT SELECT ON TABLE payroll.cognos_payrollregistertaxes_mv TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_payrollregistertaxes_mv TO read_write;


-- DROP VIEW payroll.cognos_payrollregistertaxes;

CREATE OR REPLACE VIEW payroll.cognos_payrollregistertaxes AS 
 SELECT cognos_payrollregistertaxes_mv.personid,
    cognos_payrollregistertaxes_mv.paymentheaderid,
    cognos_payrollregistertaxes_mv.pspaypayrollid,
    cognos_payrollregistertaxes_mv.etv_id,
    cognos_payrollregistertaxes_mv.etvname,
    cognos_payrollregistertaxes_mv.taxiddesc,
    cognos_payrollregistertaxes_mv.taxid,
    cognos_payrollregistertaxes_mv.amount,
    cognos_payrollregistertaxes_mv.hours,
    cognos_payrollregistertaxes_mv.wage,
    cognos_payrollregistertaxes_mv.net_pay,
    cognos_payrollregistertaxes_mv.gross_pay,
    cognos_payrollregistertaxes_mv.ytd_hrs,
    cognos_payrollregistertaxes_mv.ytd_amount,
    cognos_payrollregistertaxes_mv.ytd_wage,
    cognos_payrollregistertaxes_mv.isemployer
   FROM payroll.cognos_payrollregistertaxes_mv;

ALTER TABLE payroll.cognos_payrollregistertaxes
  OWNER TO ehcmuser;
GRANT ALL ON TABLE payroll.cognos_payrollregistertaxes TO ehcmuser;
GRANT SELECT ON TABLE payroll.cognos_payrollregistertaxes TO read_only;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE payroll.cognos_payrollregistertaxes TO read_write;

