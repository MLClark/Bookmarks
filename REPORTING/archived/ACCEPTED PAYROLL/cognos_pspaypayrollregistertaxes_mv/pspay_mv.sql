--CREATE MATERIALIZED VIEW public.cognos_pspaypayrollregistertaxes_mv AS 
 SELECT 
    ph.personid,
    ph.paymentheaderid,
    pp.pspaypayrollid,
    pd.etv_id,
    pd.etv_id::text || COALESCE('-'::text || pdd.etvname::text, ''::text) AS etvname,

    /*    CASE
            WHEN cp.companyparametervalue::text = 'PSPAY'::text THEN pd.etv_id
            WHEN cp.companyparametervalue::text = 'P20'::text THEN payc.paycode
            ELSE NULL::character varying
        END AS etv_id, 
        
        CASE
            WHEN cp.companyparametervalue::text = 'PSPAY'::text THEN pd.etv_id::text || COALESCE('-'::text || pdd.etvname::text, ''::text)
            WHEN cp.companyparametervalue::text = 'P20'::text THEN payc.paycode::text || COALESCE('-'::text || payc.paycodeshortdesc::text, ''::text)
            ELSE NULL::text
        END AS etvname,
    */        
    ((t.taxiddesc::text ||
        CASE
            WHEN COALESCE(cts.privateplan, 'N'::bpchar) = 'Y'::bpchar THEN ' - Private Plan'::text
            ELSE ''::text
        END))::character varying(128) AS taxiddesc,
    tla.taxid,
    pd.etv_amount AS amount,
    pd.etype_hours AS hours,
    pd.etv_taxable_wage AS wage,
    ph.net_pay,
    ph.gross_pay,
    pd.etype_hours_ytd AS ytd_hrs,
    pd.etv_amount_ytd AS ytd_amount,
    pd.etv_taxable_wage_ytd AS ytd_wage,
   ----- pte.persontaxelectionpid, not used in reporting 
        CASE
            WHEN pd.etv_code = 'ER'::bpchar THEN 'Y'::bpchar
            ELSE 'N'::bpchar
        END AS isemployer
   FROM pspay_payment_header ph
     ---- removed pgdate join
     ---- JOIN persongetdates pgdate ON pgdate.personid = ph.personid AND pgdate.tablename = 'PERSON_EMPLOYMENT'::text
   
     JOIN pspay_payment_detail pd ON pd.paymentheaderid = ph.paymentheaderid AND pd.etv_id::text ~~ 'T%'::text AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
     JOIN pay_schedule_period psp ON psp.payscheduleperiodid = ph.payscheduleperiodid
     JOIN runpayrollgetdates rpgd ON rpgd.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll_pay_sch_periods ps ON ps.payscheduleperiodid = psp.payscheduleperiodid
     JOIN pspay_payroll pp ON ps.pspaypayrollid = pp.pspaypayrollid
     ---- Removed pgd join 
     ---- JOIN personpayperiodgetdates pgd ON pgd.payscheduleperiodid = ph.payscheduleperiodid AND ph.personid = pgd.personid
     
     JOIN pay_unit pu ON pu.payunitid = psp.payunitid and current_timestamp between pu.createts and pu.endts
     LEFT JOIN pspaygroupearningdeductiondets pdd ON ph.group_key = pdd.group_key AND pd.etv_id::text = pdd.etv_id::text AND pdd.etorv = 'T'::text   

     LEFT JOIN tax_lookup_aggregators tla ON pd.ttype_tax_code = tla.ttype_tax_code AND tla.etvid_lookups @> ARRAY[pd.etv_id]
     JOIN tax t ON t.taxid = tla.taxid 
     
     ---- Tried to remove pte join
     ---- pte is needed for T02/FIT to determine if ee's taxid is 1 or 2. I don't see we need pte for any other taxes.
     ---- JOIN person_tax_elections pte ON pte.taxid = t.taxid AND pte.personid = ph.personid AND GREATEST(pgdate.mineffectivedate, 'now'::text::date) >= pte.effectivedate AND GREATEST(pgdate.mineffectivedate, 'now'::text::date) <= pte.enddate AND now() >= pte.createts AND now() <= pte.endts
     
     LEFT JOIN person_tax_elections pte on pte.personid = pd.personid and current_date between pte.effectivedate and pte.enddate and current_timestamp between pte.createts and pte.endts and pte.taxid = tla.taxid


     ---- trp returns 1 er 600099 / ee 502235 taxid row same setup on all clients I reviewed - what does this data represent
     ---- LEFT JOIN tax_related_plan trp ON trp.taxidee = t.taxid AND rpgd.asofdate >= trp.effectivedate AND rpgd.asofdate <= trp.enddate AND now() >= trp.createts AND now() <= trp.endts     

     ---- LEFT JOIN company_tax_setup cts ON (pu.employertaxid::character varying::text = ANY (cts.feinlist::text[])) AND now() >= pu.createts AND now() <= pu.endts AND now() >= cts.createts AND now() <= cts.endts AND rpgd.asofdate >= cts.effectivedate AND rpgd.asofdate <= cts.enddate AND (cts.taxid = tla.taxid OR cts.taxid = trp.taxider)
     ---- moved pu current_timestamp conditions to pu join 
     ---- removed trp or condition - this causing cte join 
     LEFT JOIN company_tax_setup cts ON (pu.employertaxid::character varying::text = ANY (cts.feinlist::text[])) AND now() >= cts.createts AND now() <= cts.endts AND rpgd.asofdate >= cts.effectivedate AND rpgd.asofdate <= cts.enddate AND cts.taxid = tla.taxid 
     
     ---- Not needed for PSPAY
     --LEFT JOIN payroll.taxmappaycodetoetvid tmap ON tmap.etv_id::text = pd.etv_id::text AND tmap.ttype_tax_code = pd.ttype_tax_code and tmap.taxid = pte.taxid ---- changed to left join and joined on pte.taxid to prevent dupes 
     --LEFT JOIN payroll.pay_codes payc ON payc.paycode::text = tmap.new_paycode -- AND pte.taxid = tmap.taxid ---- changed to left join and moved pte.taxid to tmap join 
     
     LEFT JOIN company_parameters cp ON cp.companyparametername = 'PInt'::bpchar and  cp.companyparametervalue = 'PSPAY'
     where pd.etv_id <> 'T02'
     
     
