--select *  from cognos_pspaypayrollregisterearnings_mv;
--select distinct etv_id from cognos_pspaypayrollregisterearnings_mv;

select 
 'pspay' as qsource
,v.paycode
,sum(v.amount) as amount
,sum(v.hours) as hours
,sum(v.rate) as rate
,sum(v.net_pay) as net_pay
,sum(v.gross_pay) as gross_pay
,sum(v.ytd_hrs) as ytd_hrs
,sum(v.ytd_wage) as ytd_wage


from  payroll.cognos_pspaypayrollregisterearnings_mv v 
group by 1,2
order by 2