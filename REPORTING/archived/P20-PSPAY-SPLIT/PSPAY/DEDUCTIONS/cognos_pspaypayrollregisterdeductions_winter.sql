CREATE OR REPLACE VIEW public.cognos_pspaypayrollregisterdeductions_winter AS 
 SELECT cognos_pspaypayrollregisterdeductions_winter_mv.personid,
    cognos_pspaypayrollregisterdeductions_winter_mv.paymentheaderid,
    cognos_pspaypayrollregisterdeductions_winter_mv.pspaypayrollid,
    cognos_pspaypayrollregisterdeductions_winter_mv.persondedsetuppid,
    cognos_pspaypayrollregisterdeductions_winter_mv.persongarnishmentsetuppid,
    cognos_pspaypayrollregisterdeductions_winter_mv.etv_id,
    cognos_pspaypayrollregisterdeductions_winter_mv.etvname,
    cognos_pspaypayrollregisterdeductions_winter_mv.amount,
    cognos_pspaypayrollregisterdeductions_winter_mv.hours,
    cognos_pspaypayrollregisterdeductions_winter_mv.net_pay,
    cognos_pspaypayrollregisterdeductions_winter_mv.gross_pay,
    cognos_pspaypayrollregisterdeductions_winter_mv.ytd_amount,
    cognos_pspaypayrollregisterdeductions_winter_mv.ytd_wage,
    cognos_pspaypayrollregisterdeductions_winter_mv.isemployer
   FROM public.cognos_pspaypayrollregisterdeductions_winter_mv;

ALTER TABLE public.cognos_pspaypayrollregisterdeductions_winter
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_pspaypayrollregisterdeductions_winter TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_pspaypayrollregisterdeductions_winter TO read_write;
GRANT SELECT ON TABLE public.cognos_pspaypayrollregisterdeductions_winter TO read_only;
