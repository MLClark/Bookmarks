-- Grant access to existing tables
GRANT USAGE ON SCHEMA public TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA payroll TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA edi TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres;

refresh materialized view payroll.cognos_payrollregistersummary_mv;
refresh materialized view public.cognos_payrollregistersummary_winter_mv;


select * from public.cognos_payrollregistersummary_winter ; select * from payroll.cognos_payrollregistersummary limit 100;

select * from public.cognos_payrollregistersummary_winter union select * from payroll.cognos_payrollregistersummary limit 100;