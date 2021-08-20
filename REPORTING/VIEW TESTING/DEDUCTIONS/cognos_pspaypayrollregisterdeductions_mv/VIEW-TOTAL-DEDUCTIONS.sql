select 

'view' as qsource
,etv_id 
,sum(v.amount) as amount
,sum(v.hours) as hours
,sum(v.net_pay) as net_pay
,sum(v.gross_pay) as gross_pay
,sum(v.ytd_amount) as ytd_amount
,sum(v.ytd_wage) as ytd_wage

from cognos_pspaypayrollregisterdeductions_mv v
group by 1,2 
order by 2
