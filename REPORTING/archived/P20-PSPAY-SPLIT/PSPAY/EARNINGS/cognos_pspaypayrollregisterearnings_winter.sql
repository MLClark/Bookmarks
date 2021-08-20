CREATE OR REPLACE VIEW public.cognos_pspaypayrollregisterearnings_winter AS 
 SELECT cognos_pspaypayrollregisterearnings_winter_mv.personid,
    cognos_pspaypayrollregisterearnings_winter_mv.paymentheaderid,
    cognos_pspaypayrollregisterearnings_winter_mv.pspaypayrollid,
    cognos_pspaypayrollregisterearnings_winter_mv.personearnsetuppid,
    cognos_pspaypayrollregisterearnings_winter_mv.etv_id,
    cognos_pspaypayrollregisterearnings_winter_mv.etvname,
    cognos_pspaypayrollregisterearnings_winter_mv.amount,
    cognos_pspaypayrollregisterearnings_winter_mv.hours,
    cognos_pspaypayrollregisterearnings_winter_mv.rate,
    cognos_pspaypayrollregisterearnings_winter_mv.net_pay,
    cognos_pspaypayrollregisterearnings_winter_mv.gross_pay,
    cognos_pspaypayrollregisterearnings_winter_mv.ytd_hrs,
    cognos_pspaypayrollregisterearnings_winter_mv.ytd_amount,
    cognos_pspaypayrollregisterearnings_winter_mv.ytd_wage
   FROM cognos_pspaypayrollregisterearnings_winter_mv;

ALTER TABLE public.cognos_pspaypayrollregisterearnings_winter
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_pspaypayrollregisterearnings_winter TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_pspaypayrollregisterearnings_winter TO read_write;
GRANT SELECT ON TABLE public.cognos_pspaypayrollregisterearnings_winter TO read_only;
