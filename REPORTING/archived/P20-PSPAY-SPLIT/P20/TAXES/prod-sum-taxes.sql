--CREATE MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_mv AS 
select 
 'PSPAY' AS companyparametervalue
--,p.personid 
,p.etv_id
,sum(p.amount) as amount
,sum(p.hours) as hours
,sum(p.wage) as wage
,sum(p.net_pay) as net_pay
,sum(p.gross_pay) as gross_pay
,sum(p.ytd_hrs) as ytd_hrs
,sum(p.ytd_amount) as ytd_amount
,sum(p.ytd_wage) as ytd_wage


from public.cognos_pspaypayrollregistertaxes_mv p
--where etv_id = 'ER_SUTA'
 group by etv_id, companyparametervalue order by etv_id;
 