select 
 'PSPAY' AS companyparametervalue
,t.etv_id
,paymentheaderid 
,sum(t.amount) as amount
,sum(t.hours) as hours
,sum(t.wage) as wage
,sum(t.net_pay) as net_pay
,sum(t.gross_pay) as gross_pay
,sum(t.ytd_hrs) as ytd_hrs
,sum(t.ytd_amount) as ytd_amount
,sum(t.ytd_wage) as ytd_wage


from cognos_pspaypayrollregistertaxes_winter_mv t where t.etv_id = 'T01' group by 1,2,3
