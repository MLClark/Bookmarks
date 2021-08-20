-- REFRESH MATERIALIZED VIEW view_name;
REFRESH MATERIALIZED VIEW pspaygroupearningdeductiondets_mv;

REFRESH MATERIALIZED VIEW cognos_pspaypayroll_persontaxelectionsbyyear_mv;

REFRESH MATERIALIZED VIEW payroll.cognos_payrollregisterdeductions_mv;

GRANT ALL ON SCHEMA payroll TO mclark;
GRANT ALL ON SCHEMA payroll TO mclark;
GRANT USAGE ON SCHEMA payroll TO mclark;


REFRESH MATERIALIZED VIEW cognos_pspaypayroll_persontaxelectionsbyyear_mv;

REFRESH MATERIALIZED VIEW pspaygroupearningdeductiondets_mv;

select * from public.pspaygroupearningdeductiondets;
[Code: 0, SQL State: 55000]  ERROR: materialized view "pspaygroupearningdeductiondets_mv" has not been populated
  Hint: Use the REFRESH MATERIALIZED VIEW command.