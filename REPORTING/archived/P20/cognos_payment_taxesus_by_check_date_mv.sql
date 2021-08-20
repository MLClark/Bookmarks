--CREATE MATERIALIZED VIEW public.cognos_payment_taxesus_by_check_date_mv AS 
SELECT ppds.individual_key,
    ppds.check_date,
    ppds.check_number,
    ppds.payment_number,
    ppds.etv_code,
     CASE WHEN cp.companyparametervalue = 'PSPAY' then ppds.etv_id
          WHEN cp.companyparametervalue = 'P20' then coalesce(payc.paycode ,ppds.etv_id)
          END as etv_id,     
    ppds.etv_amount,
    ppds.etv_taxable_wage,
    ppds.etype_hours,
    ppds.etype_rate,
    ppds.group_key AS payunitxid,
    ppds.last_updt_dt,
    ppds.ttypetaxpct,
    ppds.personid,
    ppds.paymentheaderid,
    ppds.arrears_taken,
    ppds.arrears_balance,
    pph.state_dn03_code,
    "left"(ppds.ttype_tax_code::text, 2) AS federalstateid,
    "right"(ppds.ttype_tax_code::text, 4) AS taxjurisdictionid,
    ppds.etv_taxable_wage_ytd,
    ppds.etv_amount_ytd,
    ppds.etv_amount_q1td,
    ppds.etv_amount_q2td,
    ppds.etv_amount_q3td,
    ppds.etv_amount_q4td,
    COALESCE(t.taxiddesc, pdd.etvname::text::character varying, ''::text::character varying) AS etvname,
    t.psdcode,
    btrim(sp.stateprovincecode::text) AS stateprovincecode,
    tla.ttype_tax_code,
    btrim(pucsui.identification::text) AS taxid,
    pucsui.rate AS taxrate,
    sp.stateprovincename
   FROM pspay_payment_detail ppds
     JOIN pspay_payment_header pph ON pph.paymentheaderid = ppds.paymentheaderid AND (pph.payrollfinal = 'Y'::bpchar OR pph.payrollfinal IS NULL)
     JOIN person_payroll pp ON pp.personid = ppds.personid AND 'now'::text::date >= pp.effectivedate AND 'now'::text::date <= pp.enddate AND now() >= pp.createts AND now() <= pp.endts
     JOIN pay_unit pu ON pp.payunitid = pu.payunitid AND pu.countrycode = 'US'::bpchar
     JOIN pay_schedule_period psp ON pph.payscheduleperiodid = psp.payscheduleperiodid
     LEFT JOIN pspaygroupearningdeductiondets pdd ON pph.group_key = pdd.group_key AND ppds.etv_id::text = pdd.etv_id::text
     LEFT JOIN runpayrollgetdates rpgd ON rpgd.payscheduleperiodid = psp.payscheduleperiodid
     LEFT JOIN person_tax_elections_aggregators_asof tla ON ppds.ttype_tax_code = tla.ttype_tax_code AND tla.etvid_lookups @> ARRAY[ppds.etv_id] AND tla.personid = pp.personid AND tla.asofdate = rpgd.asofdate
     LEFT JOIN tax t ON t.taxid = tla.taxid
     LEFT JOIN tax_entity te ON t.taxentity = te.taxentity
     LEFT JOIN state_province sp ON btrim(sp.taxstatecode::text) = btrim(te.taxstatecode::text)
     LEFT JOIN pay_unit_configuration pucsui ON pucsui.payunitid = psp.payunitid AND psp.periodpaydate >= pucsui.effectivedate AND psp.periodpaydate <= pucsui.enddate AND now() >= pucsui.createts AND now() <= pucsui.endts AND btrim(pucsui.stateprovincecode::text) = btrim(sp.stateprovincecode::text) AND pucsui.payunitconfigurationtypeid = (( SELECT pay_unit_configuration_type.payunitconfigurationtypeid
           FROM pay_unit_configuration_type
          WHERE pay_unit_configuration_type.payunitconfigurationtypename::text = 'SUI'::text)) AND ppds.ttype_tax_code ~~ '%AZ%'::text
     left JOIN (SELECT * FROM payroll.taxmappaycodetoetvid WHERE taxid <> 1) tmap ON tmap.etv_id = ppds.etv_id and tmap.ttype_tax_code = ppds.ttype_tax_code 
     left JOIN payroll.pay_codes payc ON payc.paycode = tmap.new_paycode 
     LEFT JOIN company_parameters cp on 1 = 1 and cp.companyparametername = 'PInt'
      where date_part('year'::text, ppds.check_date) >= (date_part('year'::text, 'now'::text::date) - 2::double precision) AND (((ppds.etv_id::bpchar = ANY (ARRAY['VAX'::bpchar, 'VAZ'::bpchar, 'VAY'::bpchar]))) 
       OR ppds.etv_id::text ~~ 'T%'::text)


UNION ALL

 SELECT ppds.individual_key,
    ppds.check_date,
    ppds.check_number,
    ppds.payment_number,
    ppds.etv_code,
    ppds.etv_id,
    ppds.etv_amount,
    ppds.etv_taxable_wage,
    ppds.etype_hours,
    ppds.etype_rate,
    ppds.group_key AS payunitxid,
    ppds.last_updt_dt,
    ppds.ttypetaxpct,
    ppds.personid,
    ppds.paymentheaderid,
    ppds.arrears_taken,
    ppds.arrears_balance,
    pph.state_dn03_code,
    "left"(ppds.ttype_tax_code::text, 2) AS federalstateid,
    "right"(ppds.ttype_tax_code::text, 4) AS taxjurisdictionid,
    ppds.etv_taxable_wage_ytd,
    ppds.etv_amount_ytd,
    ppds.etv_amount_q1td,
    ppds.etv_amount_q2td,
    ppds.etv_amount_q3td,
    ppds.etv_amount_q4td,
    COALESCE(t.taxiddesc, pdd.etvname::text::character varying, ''::text::character varying) AS etvname,
    t.psdcode,
    btrim(sp.stateprovincecode::text) AS stateprovincecode,
    tla.ttype_tax_code,
    btrim(pucsui.identification::text) AS taxid,
    pucsui.rate AS taxrate,
    sp.stateprovincename
   FROM pspay_payment_detail_archive ppds
     JOIN pspay_payment_header_archive pph ON pph.paymentheaderid = ppds.paymentheaderid AND (pph.payrollfinal = 'Y'::bpchar OR pph.payrollfinal IS NULL)
     JOIN person_payroll pp ON pp.personid = ppds.personid AND 'now'::text::date >= pp.effectivedate AND 'now'::text::date <= pp.enddate AND now() >= pp.createts AND now() <= pp.endts
     JOIN pay_unit pu ON pp.payunitid = pu.payunitid AND pu.countrycode = 'US'::bpchar
     JOIN pay_schedule_period psp ON pph.payscheduleperiodid = psp.payscheduleperiodid
     LEFT JOIN pspaygroupearningdeductiondets pdd ON pph.group_key = pdd.group_key AND ppds.etv_id::text = pdd.etv_id::text
     LEFT JOIN runpayrollgetdates rpgd ON rpgd.payscheduleperiodid = psp.payscheduleperiodid
     LEFT JOIN person_tax_elections_aggregators_asof tla ON ppds.ttype_tax_code = tla.ttype_tax_code AND tla.etvid_lookups @> ARRAY[ppds.etv_id] AND tla.personid = pp.personid AND tla.asofdate = rpgd.asofdate
     LEFT JOIN tax t ON t.taxid = tla.taxid
     LEFT JOIN tax_entity te ON t.taxentity = te.taxentity
     LEFT JOIN state_province sp ON btrim(sp.taxstatecode::text) = btrim(te.taxstatecode::text)
     LEFT JOIN pay_unit_configuration pucsui ON pucsui.payunitid = psp.payunitid AND psp.periodpaydate >= pucsui.effectivedate AND psp.periodpaydate <= pucsui.enddate AND now() >= pucsui.createts AND now() <= pucsui.endts AND btrim(pucsui.stateprovincecode::text) = btrim(sp.stateprovincecode::text) AND pucsui.payunitconfigurationtypeid = (( SELECT pay_unit_configuration_type.payunitconfigurationtypeid
           FROM pay_unit_configuration_type
          WHERE pay_unit_configuration_type.payunitconfigurationtypename::text = 'SUI'::text)) AND ppds.ttype_tax_code ~~ '%AZ%'::text
  WHERE date_part('year'::text, ppds.check_date) >= (date_part('year'::text, 'now'::text::date) - 2::double precision) AND ((ppds.etv_id::bpchar = ANY (ARRAY['VAX'::bpchar, 'VAZ'::bpchar, 'VAY'::bpchar])) OR ppds.etv_id::text ~~ 'T%'::text)

/*
WITH DATA;

ALTER TABLE public.cognos_payment_taxesus_by_check_date_mv
  OWNER TO postgres;
GRANT ALL ON TABLE public.cognos_payment_taxesus_by_check_date_mv TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.cognos_payment_taxesus_by_check_date_mv TO read_write;
GRANT SELECT ON TABLE public.cognos_payment_taxesus_by_check_date_mv TO read_only;
*/
