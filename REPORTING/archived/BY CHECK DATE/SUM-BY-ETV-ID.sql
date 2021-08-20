--select personid, etv_id, sum(etv_taxable_wage) from cognos_payment_taxesus_by_check_date_mv group by 1,2 order by 1,2;
select x.personid, x.etv_id, sum(x.etv_taxable_wage) as box3_wage from 
(
 SELECT ppds.individual_key,
    ppds.check_date,
    ppds.check_number,
    ppds.payment_number::character(5) AS payment_number,
    ppds.etv_code,
        CASE
            WHEN cp.companyparametervalue::text = 'PSPAY'::text THEN ppds.etv_id
            WHEN cp.companyparametervalue::text = 'P20'::text THEN COALESCE(payc.paycode, ppds.etv_id)
            ELSE NULL::character varying
        END AS etv_id,
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
     LEFT JOIN ( SELECT taxmappaycodetoetvid.ttype_tax_code,
            taxmappaycodetoetvid.etv_id,
            taxmappaycodetoetvid.taxid,
            taxmappaycodetoetvid.ste_uniquetaxid,
            taxmappaycodetoetvid.new_paycode
           FROM payroll.taxmappaycodetoetvid
          WHERE taxmappaycodetoetvid.taxid <> 1) tmap ON tmap.etv_id::text = ppds.etv_id::text AND tmap.ttype_tax_code = ppds.ttype_tax_code
     LEFT JOIN payroll.pay_codes payc ON payc.paycode::text = tmap.new_paycode
     LEFT JOIN company_parameters cp ON 1 = 1 AND cp.companyparametername = 'PInt'::bpchar
  WHERE date_part('year'::text, ppds.check_date) >= (date_part('year'::text, 'now'::text::date) - 2::double precision) AND ((ppds.etv_id::bpchar = ANY (ARRAY['VAX'::bpchar, 'VAZ'::bpchar, 'VAY'::bpchar])) OR ppds.etv_id::text ~~ 'T%'::text)
    and ppds.etv_id in ('T05','T04','T03')
  and date_part('year',ppds.check_date) = '2020'
)x group by 1,2 order by 1,2