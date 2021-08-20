CREATE OR REPLACE VIEW public.cognos_pspaypayrollregistertaxes_winter AS 
 SELECT cognos_pspaypayrollregistertaxes_winter_mv.personid,
    cognos_pspaypayrollregistertaxes_winter_mv.paymentheaderid,
    cognos_pspaypayrollregistertaxes_winter_mv.pspaypayrollid,
    cognos_pspaypayrollregistertaxes_winter_mv.etv_id,
    cognos_pspaypayrollregistertaxes_winter_mv.etvname,
    cognos_pspaypayrollregistertaxes_winter_mv.taxiddesc,
    cognos_pspaypayrollregistertaxes_winter_mv.taxid,
    cognos_pspaypayrollregistertaxes_winter_mv.amount,
    cognos_pspaypayrollregistertaxes_winter_mv.hours,
    cognos_pspaypayrollregistertaxes_winter_mv.wage,
    cognos_pspaypayrollregistertaxes_winter_mv.net_pay,
    cognos_pspaypayrollregistertaxes_winter_mv.gross_pay,
    cognos_pspaypayrollregistertaxes_winter_mv.ytd_hrs,
    cognos_pspaypayrollregistertaxes_winter_mv.ytd_amount,
    cognos_pspaypayrollregistertaxes_winter_mv.ytd_wage,
    cognos_pspaypayrollregistertaxes_winter_mv.isemployer
   FROM cognos_pspaypayrollregistertaxes_winter_mv;
