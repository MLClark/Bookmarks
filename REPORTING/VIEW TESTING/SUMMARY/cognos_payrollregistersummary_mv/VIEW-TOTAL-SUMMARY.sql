-- payroll.cognos_payrollregistersummary_mv AS 
select 
 'P20' AS companyparametervalue
,group_key
,dept
,sum(net_pay) as net_pay
,sum(gross_pay) as gross_pay
FROM public.cognos_payrollregistersummary_mv 
group by 1,2,3
order by dept,group_key
;



select * from cognos_payrollregistersummary_mv;