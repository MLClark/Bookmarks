-- Grant access to existing tables
GRANT USAGE ON SCHEMA public TO readaccess;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readaccess;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres;



refresh materialized view public.cognos_payrollregistersummary_winter_mv;

select * from public.cognos_payrollregistersummary_winter_mv limit 100;
select * from public.cognos_payrollregistersummary_winter limit 100;

