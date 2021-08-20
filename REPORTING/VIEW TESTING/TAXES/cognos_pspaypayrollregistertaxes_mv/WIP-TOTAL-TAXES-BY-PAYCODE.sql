--CREATE MATERIALIZED VIEW payroll.cognos_pspaypayrollregistertaxes_mv AS 
select 
 'payroll' AS companyparametervalue
--,t.personid 
,t.etv_id

,sum(t.amount) as amount
,coalesce(t.erfica_amount,t.erfli_amount,t.erfuta_amount,t.ermedi_amount,t.ersuta_amount,t.ersutasc_amount,t.fica_amount,t.fit_amount,t.fli_amount,t.medi_amount,t.sit_amount,city_amount,erpop_amount,medi2_amount,sdi_amount,CNTY_amount,ERSDI_amount,SUI_amount,EIT_amount,LST_amount,OLTS_amount,OLF_amount
          ,ERRRTA1_amount,ERRRTA2_amount,RRTA1_amount,RRTA2_amount) as pd_amount
,sum(t.hours) as hours
,sum(t.wage) as wage
,coalesce(t.erfica_wages,t.erfli_wages,t.erfuta_wages,t.ermedi_wages,t.ersuta_wages,t.ersutasc_wages,t.fica_wages,t.fit_wages,t.fli_wages,t.medi_wages,t.sit_wages,city_wages,erpop_wages,medi2_wages,sdi_wages,CNTY_wages,ERSDI_wages,SUI_wages,EIT_wages,LST_wages,OLTS_wages,OLF_wages
         ,ERRRTA1_wages,ERRRTA2_wages,RRTA1_wages,RRTA2_wages) as pd_wages
,sum(t.net_pay) as net_pay
,coalesce(t.erfica_net_pay,t.erfli_net_pay,t.erfuta_net_pay,t.ermedi_net_pay,t.ersuta_net_pay,t.ersutasc_net_pay,t.fica_net_pay,t.fit_net_pay,t.fli_net_pay,t.medi_net_pay,t.sit_net_pay,city_net_pay,erpop_net_pay,medi2_net_pay,sdi_net_pay,CNTY_net_pay,ERSDI_net_pay,SUI_net_pay,EIT_net_pay,LST_net_pay
          ,OLTS_net_pay,OLF_net_pay,ERRRTA1_net_pay,ERRRTA2_net_pay,RRTA1_net_pay,RRTA2_net_pay) as pd_net_pay
,sum(t.gross_pay) as gross_pay
,coalesce(t.erfica_gross_pay,t.erfli_gross_pay,t.erfuta_gross_pay,t.ermedi_gross_pay,t.ersuta_gross_pay,t.ersutasc_gross_pay,t.fica_gross_pay,t.fit_gross_pay,t.fli_gross_pay,t.medi_gross_pay,t.sit_gross_pay,city_gross_pay,erpop_gross_pay,medi2_gross_pay,sdi_gross_pay,CNTY_gross_pay,ERSDI_gross_pay,SUI_gross_pay
         ,EIT_gross_pay,LST_gross_pay,OLTS_gross_pay,OLF_gross_pay,ERRRTA1_gross_pay,ERRRTA2_gross_pay,RRTA1_gross_pay,RRTA2_gross_pay) as pd_gross_pay
,sum(t.ytd_hrs) as ytd_hrs
,sum(t.ytd_amount) as ytd_amount
,coalesce(erfica_amount_ytd,erfli_amount_ytd,erfuta_amount_ytd,ermedi_amount_ytd,ersuta_amount_ytd,ersutasc_amount_ytd,fica_amount_ytd,fit_amount_ytd,fli_amount_ytd,medi_amount_ytd,sit_amount_ytd,city_amount_ytd,erpop_amount_ytd,medi2_amount_ytd,sdi_amount_ytd,CNTY_amount_ytd,ERSDI_amount_ytd,SUI_amount_ytd
         ,EIT_amount_ytd,LST_amount_ytd,OLTS_amount_ytd,OLF_amount_ytd,ERRRTA1_amount_ytd,ERRRTA2_amount_ytd,RRTA1_amount_ytd,RRTA2_amount_ytd) as pd_ytd_amount
,sum(t.ytd_wage) as ytd_wage
,coalesce(erfica_subject_wages_ytd,erfli_subject_wages_ytd,erfuta_subject_wages_ytd,ermedi_subject_wages_ytd,ersuta_subject_wages_ytd,ersutasc_subject_wages_ytd,fica_subject_wages_ytd,fit_subject_wages_ytd,fli_subject_wages_ytd,medi_subject_wages_ytd,sit_subject_wages_ytd,city_subject_wages_ytd
         ,erpop_subject_wages_ytd,medi2_subject_wages_ytd,sdi_subject_wages_ytd,CNTY_subject_wages_ytd,ERSDI_subject_wages_ytd,SUI_subject_wages_ytd,EIT_subject_wages_ytd,LST_subject_wages_ytd,OLTS_subject_wages_ytd,OLF_subject_wages_ytd,ERRRTA1_subject_wages_ytd,ERRRTA2_subject_wages_ytd
         ,RRTA1_subject_wages_ytd,RRTA2_subject_wages_ytd) as pd_wagesytd


from 
(select  
 ph.personid
,ph.paymentheaderid
,pd.pd_paycode as etv_id

,er_fica.paycode as erfica_paycode
,er_fica.amount as erfica_amount
,er_fica.wages as erfica_wages
,er_fica.amount_ytd as erfica_amount_ytd
,er_fica.subject_wages_ytd as erfica_subject_wages_ytd
,er_fica.net_pay as erfica_net_pay
,er_fica.gross_pay as erfica_gross_pay

,erfli.paycode as erfli_paycode
,erfli.amount as erfli_amount
,erfli.wages as erfli_wages
,erfli.amount_ytd as erfli_amount_ytd
,erfli.subject_wages_ytd as erfli_subject_wages_ytd
,erfli.net_pay as erfli_net_pay
,erfli.gross_pay as erfli_gross_pay

,erfuta.paycode as erfuta_paycode
,erfuta.amount as erfuta_amount
,erfuta.wages as erfuta_wages
,erfuta.amount_ytd as erfuta_amount_ytd
,erfuta.subject_wages_ytd as erfuta_subject_wages_ytd
,erfuta.net_pay as erfuta_net_pay
,erfuta.gross_pay as erfuta_gross_pay

,ermedi.paycode as ermedi_paycode
,ermedi.amount as ermedi_amount
,ermedi.wages as ermedi_wages
,ermedi.amount_ytd as ermedi_amount_ytd
,ermedi.subject_wages_ytd as ermedi_subject_wages_ytd
,ermedi.net_pay as ermedi_net_pay
,ermedi.gross_pay as ermedi_gross_pay

,ersuta.paycode as ersuta_paycode
,ersuta.amount as ersuta_amount
,ersuta.wages as ersuta_wages
,ersuta.amount_ytd as ersuta_amount_ytd
,ersuta.subject_wages_ytd as ersuta_subject_wages_ytd
,ersuta.net_pay as ersuta_net_pay
,ersuta.gross_pay as ersuta_gross_pay

,ersutasc.paycode as ersutasc_paycode
,ersutasc.amount as ersutasc_amount
,ersutasc.wages as ersutasc_wages
,ersutasc.amount_ytd as ersutasc_amount_ytd
,ersutasc.subject_wages_ytd as ersutasc_subject_wages_ytd
,ersutasc.net_pay as ersutasc_net_pay
,ersutasc.gross_pay as ersutasc_gross_pay

,fica.paycode as fica_paycode
,fica.amount as fica_amount
,fica.wages as fica_wages
,fica.amount_ytd as fica_amount_ytd
,fica.subject_wages_ytd as fica_subject_wages_ytd
,fica.net_pay as fica_net_pay
,fica.gross_pay as fica_gross_pay

,fit.paycode as fit_paycode
,fit.amount as fit_amount
,fit.wages as fit_wages
,fit.amount_ytd as fit_amount_ytd
,fit.subject_wages_ytd as fit_subject_wages_ytd
,fit.net_pay as fit_net_pay
,fit.gross_pay as fit_gross_pay

,fli.paycode as fli_paycode
,fli.amount as fli_amount
,fli.wages as fli_wages
,fli.amount_ytd as fli_amount_ytd
,fli.subject_wages_ytd as fli_subject_wages_ytd
,fli.net_pay as fli_net_pay
,fli.gross_pay as fli_gross_pay

,medi.paycode as medi_paycode
,medi.amount as medi_amount
,medi.wages as medi_wages
,medi.amount_ytd as medi_amount_ytd
,medi.subject_wages_ytd as medi_subject_wages_ytd
,medi.net_pay as medi_net_pay
,medi.gross_pay as medi_gross_pay

,sit.paycode as sit_paycode
,sit.amount as sit_amount
,sit.wages as sit_wages
,sit.amount_ytd as sit_amount_ytd
,sit.subject_wages_ytd as sit_subject_wages_ytd
,sit.net_pay as sit_net_pay
,sit.gross_pay as sit_gross_pay

,city.paycode as city_paycode
,city.amount as city_amount
,city.wages as city_wages
,city.amount_ytd as city_amount_ytd
,city.subject_wages_ytd as city_subject_wages_ytd
,city.net_pay as city_net_pay
,city.gross_pay as city_gross_pay

,erpop.paycode as erpop_paycode
,erpop.amount as erpop_amount
,erpop.wages as erpop_wages
,erpop.amount_ytd as erpop_amount_ytd
,erpop.subject_wages_ytd as erpop_subject_wages_ytd
,erpop.net_pay as erpop_net_pay
,erpop.gross_pay as erpop_gross_pay

,medi2.paycode as medi2_paycode
,medi2.amount as medi2_amount
,medi2.wages as medi2_wages
,medi2.amount_ytd as medi2_amount_ytd
,medi2.subject_wages_ytd as medi2_subject_wages_ytd
,medi2.net_pay as medi2_net_pay
,medi2.gross_pay as medi2_gross_pay

,sdi.paycode as sdi_paycode
,sdi.amount as sdi_amount
,sdi.wages as sdi_wages
,sdi.amount_ytd as sdi_amount_ytd
,sdi.subject_wages_ytd as sdi_subject_wages_ytd
,sdi.net_pay as sdi_net_pay
,sdi.gross_pay as sdi_gross_pay

,CNTY.paycode as CNTY_paycode
,CNTY.amount as CNTY_amount
,CNTY.wages as CNTY_wages
,CNTY.amount_ytd as CNTY_amount_ytd
,CNTY.subject_wages_ytd as CNTY_subject_wages_ytd
,CNTY.net_pay as CNTY_net_pay
,CNTY.gross_pay as CNTY_gross_pay

,ERSDI.paycode as ERSDI_paycode
,ERSDI.amount as ERSDI_amount
,ERSDI.wages as ERSDI_wages
,ERSDI.amount_ytd as ERSDI_amount_ytd
,ERSDI.subject_wages_ytd as ERSDI_subject_wages_ytd
,ERSDI.net_pay as ERSDI_net_pay
,ERSDI.gross_pay as ERSDI_gross_pay

,SUI.paycode as SUI_paycode
,SUI.amount as SUI_amount
,SUI.wages as SUI_wages
,SUI.amount_ytd as SUI_amount_ytd
,SUI.subject_wages_ytd as SUI_subject_wages_ytd
,SUI.net_pay as SUI_net_pay
,SUI.gross_pay as SUI_gross_pay

,EIT.paycode as EIT_paycode
,EIT.amount as EIT_amount
,EIT.wages as EIT_wages
,EIT.amount_ytd as EIT_amount_ytd
,EIT.subject_wages_ytd as EIT_subject_wages_ytd
,EIT.net_pay as EIT_net_pay
,EIT.gross_pay as EIT_gross_pay

,LST.paycode as LST_paycode
,LST.amount as LST_amount
,LST.wages as LST_wages
,LST.amount_ytd as LST_amount_ytd
,LST.subject_wages_ytd as LST_subject_wages_ytd
,LST.net_pay as LST_net_pay
,LST.gross_pay as LST_gross_pay

,OLF.paycode as OLF_paycode
,OLF.amount as OLF_amount
,OLF.wages as OLF_wages
,OLF.amount_ytd as OLF_amount_ytd
,OLF.subject_wages_ytd as OLF_subject_wages_ytd
,OLF.net_pay as OLF_net_pay
,OLF.gross_pay as OLF_gross_pay

,OLTS.paycode as OLTS_paycode
,OLTS.amount as OLTS_amount
,OLTS.wages as OLTS_wages
,OLTS.amount_ytd as OLTS_amount_ytd
,OLTS.subject_wages_ytd as OLTS_subject_wages_ytd
,OLTS.net_pay as OLTS_net_pay
,OLTS.gross_pay as OLTS_gross_pay

,ERRRTA1.paycode as ERRRTA1_paycode
,ERRRTA1.amount as ERRRTA1_amount
,ERRRTA1.wages as ERRRTA1_wages
,ERRRTA1.amount_ytd as ERRRTA1_amount_ytd
,ERRRTA1.subject_wages_ytd as ERRRTA1_subject_wages_ytd
,ERRRTA1.net_pay as ERRRTA1_net_pay
,ERRRTA1.gross_pay as ERRRTA1_gross_pay

,ERRRTA2.paycode as ERRRTA2_paycode
,ERRRTA2.amount as ERRRTA2_amount
,ERRRTA2.wages as ERRRTA2_wages
,ERRRTA2.amount_ytd as ERRRTA2_amount_ytd
,ERRRTA2.subject_wages_ytd as ERRRTA2_subject_wages_ytd
,ERRRTA2.net_pay as ERRRTA2_net_pay
,ERRRTA2.gross_pay as ERRRTA2_gross_pay

,RRTA1.paycode as RRTA1_paycode
,RRTA1.amount as RRTA1_amount
,RRTA1.wages as RRTA1_wages
,RRTA1.amount_ytd as RRTA1_amount_ytd
,RRTA1.subject_wages_ytd as RRTA1_subject_wages_ytd
,RRTA1.net_pay as RRTA1_net_pay
,RRTA1.gross_pay as RRTA1_gross_pay

,RRTA2.paycode as RRTA2_paycode
,RRTA2.amount as RRTA2_amount
,RRTA2.wages as RRTA2_wages
,RRTA2.amount_ytd as RRTA2_amount_ytd
,RRTA2.subject_wages_ytd as RRTA2_subject_wages_ytd
,RRTA2.net_pay as RRTA2_net_pay
,RRTA2.gross_pay as RRTA2_gross_pay

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

left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'ER_FICA' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode ) er_fica on er_fica.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'ER_FLI'  and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) erfli on erfli.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'ER_FUTA' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) erfuta on erfuta.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'ER_MEDI' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) ermedi on ermedi.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay 
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'ER_SUTA' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) ersuta on ersuta.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'ER_SUTA_SC' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) ersutasc on ersutasc.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay 
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'FICA'  and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) fica on fica.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'FIT' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) fit on fit.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'FLI' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) fli on fli.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay 
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'MEDI' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) medi on medi.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'SIT' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) sit on sit.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'CITY' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) city on city.paycode = pd.pd_paycode   
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'ER_POP' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) erpop on erpop.paycode = pd.pd_paycode  
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'MEDI2' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) medi2 on medi2.paycode = pd.pd_paycode
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'SDI' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) sdi on sdi.paycode = pd.pd_paycode                                        

left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'EIT' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) EIT on EIT.paycode = pd.pd_paycode                                        
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'LST' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) LST on LST.paycode = pd.pd_paycode                                        

left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'CNTY' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) CNTY on CNTY.paycode = pd.pd_paycode                                        
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'ER_SDI' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) ERSDI on ERSDI.paycode = pd.pd_paycode                                        
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'SUI' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) SUI on SUI.paycode = pd.pd_paycode                                        
  
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'OLF' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) OLF on OLF.paycode = pd.pd_paycode                                        
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'OLTS' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) OLTS on OLTS.paycode = pd.pd_paycode                                        

left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'ER_RRTA1' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) ERRRTA1 on ERRRTA1.paycode = pd.pd_paycode                                        
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'ER_RRTA2' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) ERRRTA2 on ERRRTA2.paycode = pd.pd_paycode                                        


left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'RRTA1' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) RRTA1 on RRTA1.paycode = pd.pd_paycode                                        
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd, sum(h.net_pay) as net_pay, sum(h.gross_pay) as gross_pay
             from payroll.payment_detail d join payroll.payment_header h on h.personid = d.personid and h.paymentheaderid = d.paymentheaderid where paycode = 'RRTA2' and (d.amount_ytd <> 0::numeric OR d.subject_wages_ytd <> 0::numeric OR d.amount <> 0::numeric OR d.subject_wages <> 0::numeric) group by paycode) RRTA2 on RRTA2.paycode = pd.pd_paycode                                        

     ) t group by etv_id, pd_amount, pd_wages, pd_net_pay, pd_gross_pay, pd_ytd_amount, pd_wagesytd
