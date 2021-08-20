--CREATE MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_mv AS 
select 
 'PSPAY' AS companyparametervalue
--,p.personid 
,pd.etv_id
,sum(pd.amount) as amount
,coalesce(er_fica.amount,erfli.wages,erfuta.amount,ermedi.amount,ersuta.amount,ersutasc.amount,fica.amount,fit.amount,fli.amount,medi.amount,sit.amount) as pdamount
,sum(pd.hours) as hours
,sum(pd.wage) as wage
,coalesce(er_fica.wages,erfli.wages,erfuta.wages,ermedi.wages,ersuta.wages,ersutasc.wages,fica.wages,fit.wages,fli.wages,medi.wages,sit.wages) as pdwages
,sum(pd.net_pay) as net_pay
,sum(pd.gross_pay) as gross_pay
,sum(pd.ytd_hrs) as ytd_hrs
,sum(pd.ytd_amount) as ytd_amount
,coalesce(er_fica.amount_ytd,erfli.amount_ytd,erfuta.amount_ytd,ermedi.amount_ytd,ersuta.amount_ytd,ersutasc.amount_ytd,fica.amount_ytd,fit.amount_ytd,fli.amount_ytd,medi.amount_ytd,sit.amount_ytd) as pdamountytd
,sum(pd.ytd_wage) as ytd_wage
,coalesce(er_fica.subject_wages_ytd,erfli.subject_wages_ytd,erfuta.subject_wages_ytd,ermedi.subject_wages_ytd,ersuta.subject_wages_ytd,ersutasc.subject_wages_ytd,fica.subject_wages_ytd,fit.subject_wages_ytd,fli.subject_wages_ytd,medi.subject_wages_ytd,sit.subject_wages_ytd) as pdsubjectwagesytd


from public.cognos_pspaypayrollregistertaxes_mv pd

left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd
             from payroll.payment_detail where paycode = 'ER_FICA' group by paycode) er_fica on er_fica.paycode = pd.etv_id
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd 
             from payroll.payment_detail where paycode = 'ER_FLI' group by paycode) erfli on erfli.paycode = pd.etv_id
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd
             from payroll.payment_detail where paycode = 'ER_FUTA' group by paycode) erfuta on erfuta.paycode = pd.etv_id
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd 
             from payroll.payment_detail where paycode = 'ER_MEDI' group by paycode) ermedi on ermedi.paycode = pd.etv_id
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd 
             from payroll.payment_detail where paycode = 'ER_SUTA' group by paycode) ersuta on ersuta.paycode = pd.etv_id
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd
             from payroll.payment_detail where paycode = 'ER_SUTA_SC' group by paycode) ersutasc on ersutasc.paycode = pd.etv_id
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd 
             from payroll.payment_detail where paycode = 'FICA' group by paycode) fica on fica.paycode = pd.etv_id
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd
             from payroll.payment_detail where paycode = 'FIT' group by paycode) fit on fit.paycode = pd.etv_id
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd
             from payroll.payment_detail where paycode = 'FLI' group by paycode) fli on fli.paycode = pd.etv_id
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd 
             from payroll.payment_detail where paycode = 'MEDI' group by paycode) medi on medi.paycode = pd.etv_id
left join (select paycode, sum(amount) as amount, sum(subject_wages) as wages, sum(amount_ytd) as amount_ytd, sum(subject_wages_ytd) as subject_wages_ytd
             from payroll.payment_detail where paycode = 'SIT' group by paycode) sit on sit.paycode = pd.etv_id
             
--where etv_id = 'ER_SUTA'
 group by etv_id
          ,er_fica.amount,erfli.wages,erfuta.amount,ermedi.amount,ersuta.amount,ersutasc.amount,fica.amount,fit.amount,fli.amount,medi.amount,sit.amount
          ,er_fica.wages,erfli.wages,erfuta.wages,ermedi.wages,ersuta.wages,ersutasc.wages,fica.wages,fit.wages,fli.wages,medi.wages,sit.wages
          ,er_fica.amount_ytd,erfli.amount_ytd,erfuta.amount_ytd,ermedi.amount_ytd,ersuta.amount_ytd,ersutasc.amount_ytd,fica.amount_ytd,fit.amount_ytd,fli.amount_ytd,medi.amount_ytd,sit.amount_ytd
          ,er_fica.subject_wages_ytd,erfli.subject_wages_ytd,erfuta.subject_wages_ytd,ermedi.subject_wages_ytd,ersuta.subject_wages_ytd,ersutasc.subject_wages_ytd,fica.subject_wages_ytd,fit.subject_wages_ytd,fli.subject_wages_ytd,medi.subject_wages_ytd,sit.subject_wages_ytd
          ,companyparametervalue order by etv_id;
 