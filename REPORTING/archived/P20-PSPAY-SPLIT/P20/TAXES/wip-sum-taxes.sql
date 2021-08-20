--CREATE MATERIALIZED VIEW payroll.cognos_pspaypayrollregistertaxes_mv AS 
select 
 'PSPAY' AS companyparametervalue
--,t.personid 
,t.etv_id

,sum(t.amount) as amount
,sum(t.hours) as hours
,sum(t.wage) as wage
,sum(t.net_pay) as net_pay
,sum(t.gross_pay) as gross_pay
,sum(t.ytd_hrs) as ytd_hrs
,sum(t.ytd_amount) as ytd_amount
,sum(t.ytd_wage) as ytd_wage


from 
(select  
 ph.personid
,ph.paymentheaderid
,pd.pd_paycode as etv_id
,pd.pc_paycode::text || COALESCE('-'::text || pd.paycodeshortdesc::text, ''::text) as etvname
,((pd.taxiddesc::text ||CASE WHEN COALESCE(cts.privateplan, 'N'::bpchar) = 'Y'::bpchar THEN ' - Private Plan'::text ELSE ''::text END))::character varying(128) AS taxiddesc
,pd.taxid
,pd.amount
,pd.units AS hours
,pd.subject_wages AS wage
,ph.net_pay
,ph.gross_pay
,pd.units_ytd AS ytd_hrs
,pd.amount_ytd AS ytd_amount
,pd.subject_wages_ytd AS ytd_wage
,CASE WHEN pd.pd_paycode = 'ER'::bpchar THEN 'Y'::bpchar ELSE 'N'::bpchar END AS isemployer

FROM payroll.payment_header ph
JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
JOIN runpayrollgetdates rpgd ON rpgd.payscheduleperiodid = psp.payscheduleperiodid
JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
JOIN pay_unit pu ON pu.payunitid = psp.payunitid AND now() >= pu.createts AND now() <= pu.endts
JOIN (SELECT pd.personid,pd.paymentheaderid,t.taxid,pd.paycode as pd_paycode,payc.paycode as pc_paycode,pd.units,pd.amount,pd.subject_wages,pd.units_ytd,pd.amount_ytd,pd.subject_wages_ytd, payc.paycodeshortdesc,t.taxiddesc
        FROM payroll.payment_detail pd
        JOIN payroll.pay_codes payc ON payc.paycode::text = pd.paycode::text 
        and current_date between payc.effectivedate and payc.enddate and current_timestamp between payc.createts and payc.endts
        JOIN tax t on t.taxid = pd.taxid
       WHERE (pd.amount_ytd <> 0::numeric OR pd.subject_wages_ytd <> 0::numeric OR pd.amount <> 0::numeric OR pd.subject_wages <> 0::numeric)) pd on pd.personid = ph.personid and pd.paymentheaderid = ph.paymentheaderid 

LEFT JOIN company_tax_setup cts ON (pu.employertaxid::character varying::text = ANY (cts.feinlist::text[])) AND now() >= cts.createts AND now() <= cts.endts AND rpgd.asofdate >= cts.effectivedate AND rpgd.asofdate <= cts.enddate AND cts.taxid = pd.taxid
     JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar and cp.companyparametervalue::text = 'P20'::text 
     --where pd.pd_paycode like 'ER_SUT%' and pd.personid = '105' and pd.paymentheaderid = '8509'
     ) t group by etv_id,  companyparametervalue order by etv_id
 
     ;

