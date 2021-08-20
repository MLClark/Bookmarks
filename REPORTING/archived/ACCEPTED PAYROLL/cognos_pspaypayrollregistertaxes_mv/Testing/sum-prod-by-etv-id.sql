--CREATE MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_mv AS 
select 
 'PSPAY' AS companyparametervalue
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
where p.paymentheaderid in (select paymentheaderid from pspay_payment_header where check_date = '2021-04-30')
 group by etv_id, companyparametervalue order by etv_id;
 
select * from person_names where personid = '66163';

select 428.54 - 278.97;

select * from pspay_payment_detail where personid = '68401' and check_date = '2021-04-30' and etv_id = 'T07';


select * from pspay_payment_detail where check_date = '2021-04-30' and etv_id = 'E70';
select * from cognos_pspaypayrollregistertaxes_mv where paymentheaderid 
in (select paymentheaderid from pspay_payment_detail where check_date = '2021-04-30' and etv_id = 'E70') and etv_id = 'E70';