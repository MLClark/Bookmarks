-- Grant access to existing tables
GRANT USAGE ON SCHEMA public TO readaccess;
GRANT SELECT ON ALL TABLES IN SCHEMA payroll TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA edi TO postgres;

refresh materialized view payroll.cognos_payrollregistersummary_mv;

select * from payroll.cognos_payrollregistersummary_mv limit 100;
select * from payroll.cognos_payrollregistersummary limit 100;