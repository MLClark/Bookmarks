-- P20 version
-- 5 - kd001
-- 6 - kd002
SELECT gj.pspaypayrollid,
    g.payunitdesc,
    psp.periodstartdate,
    psp.periodenddate,
    psp.periodpaydate,
    psp.processfinaldate,
    m.categorydesc,
    COALESCE(mv.glmappedvaldesc, edd.etvdesc, payc.paycodedesc) AS amountdesc,
    r.personid,
    epi.lastname, 
    epi.firstname,
    r.payunitid,
    r.payscheduleperiodid,
    r.glacctnumtemplateid,
    r.amountid,
    r.totalperiodamount,
    r.totalperiodhours,
    r.taxid,
    r.taxstate,
    case when psa.percentage is not null then cast(psa.percentage * (r.amount/100) as float) else r.amount end as amount,
    r.hours,
    r.isbase,
    r.multiplier,
    r.rowrank,
    psa.memberorgcode,
    r.divorgcode,
    r.orgorgcode,
    --r.budgetorgcode,
    --psa.budgetorgcode,
    case when psa.budgetorgcode is null then r.budgetorgcode
         else psa.budgetorgcode end as budgetorgcode,
    r.matrixorgcode,
    r.locationcode,
    r.jobcode,
    r.jobcode2,
    r.jobcode3,
    r.jobcode4,
    r.jobcode5,
    r.jobcode6,
    r.glamtacctmapid,
    r.creditdebitind,
    r.doallocation,
    r.mappedvaluecode,
    r.separator,
--    r.acctnum,
    case when psa.budgetorgcode is null then r.acctnum
         else psa.budgetorgcode || right(r.acctnum,4) end as acctnum
   FROM gl_execute_job gj
     JOIN pspay_payroll pp ON gj.pspaypayrollid = pp.pspaypayrollid
     JOIN gl_period_detail_results r ON gj.payscheduleperiodlist @> ARRAY[r.payscheduleperiodid]
     LEFT JOIN edi.etl_personal_info epi ON r.personid = epi.personid
     LEFT JOIN person_salary_allocation psa on psa.personid = r.personid and current_date between psa.effectivedate and psa.enddate and current_timestamp between psa.createts and psa.endts
     JOIN gl_amt_acct_map m ON r.glamtacctmapid = m.glamtacctmapid AND 'now'::text::date >= m.effectivedate AND 'now'::text::date <= m.enddate AND now() >= m.createts AND now() <= m.endts
     JOIN groupkey g ON r.payunitid = g.payunitid
     JOIN pay_schedule_period psp ON r.payscheduleperiodid = psp.payscheduleperiodid
     LEFT JOIN pspaygroupearningdeductiondets_mv edd ON r.amountid = edd.etv_id::text AND g.groupkey::bpchar = edd.group_key
     left join payroll.pay_codes payc on r.amountid = payc.paycode::text and current_date between payc.effectivedate and payc.enddate and current_timestamp between payc.createts and payc.endts
    LEFT JOIN gl_mapped_values mv ON r.amountid = ('MAPPEDVALUECODE_'::text || mv.glmappedvalueid) AND gj.executestatus = 1
     where psp.periodpaydate = ?
     AND psp.payunitid = 5 order by payunitid;
     -- P20 version
-- 5 - kd001
-- 6 - kd002
SELECT gj.pspaypayrollid,
    g.payunitdesc,
    psp.periodstartdate,
    psp.periodenddate,
    psp.periodpaydate,
    psp.processfinaldate,
    m.categorydesc,
    COALESCE(mv.glmappedvaldesc, edd.etvdesc, payc.paycodedesc) AS amountdesc,
    r.personid,
    epi.lastname, 
    epi.firstname,
    r.payunitid,
    r.payscheduleperiodid,
    r.glacctnumtemplateid,
    r.amountid,
    r.totalperiodamount,
    r.totalperiodhours,
    r.taxid,
    r.taxstate,
    case when psa.percentage is not null then cast(psa.percentage * (r.amount/100) as float) else r.amount end as amount,
    r.hours,
    r.isbase,
    r.multiplier,
    r.rowrank,
    psa.memberorgcode,
    r.divorgcode,
    r.orgorgcode,
    --r.budgetorgcode,
    --psa.budgetorgcode,
    case when psa.budgetorgcode is null then r.budgetorgcode
         else psa.budgetorgcode end as budgetorgcode,
    r.matrixorgcode,
    r.locationcode,
    r.jobcode,
    r.jobcode2,
    r.jobcode3,
    r.jobcode4,
    r.jobcode5,
    r.jobcode6,
    r.glamtacctmapid,
    r.creditdebitind,
    r.doallocation,
    r.mappedvaluecode,
    r.separator,
--    r.acctnum,
    case when psa.budgetorgcode is null then r.acctnum
         else psa.budgetorgcode || right(r.acctnum,4) end as acctnum
   FROM gl_execute_job gj
     JOIN pspay_payroll pp ON gj.pspaypayrollid = pp.pspaypayrollid
     JOIN gl_period_detail_results r ON gj.payscheduleperiodlist @> ARRAY[r.payscheduleperiodid]
     LEFT JOIN edi.etl_personal_info epi ON r.personid = epi.personid
     LEFT JOIN person_salary_allocation psa on psa.personid = r.personid and current_date between psa.effectivedate and psa.enddate and current_timestamp between psa.createts and psa.endts
     JOIN gl_amt_acct_map m ON r.glamtacctmapid = m.glamtacctmapid AND 'now'::text::date >= m.effectivedate AND 'now'::text::date <= m.enddate AND now() >= m.createts AND now() <= m.endts
     JOIN groupkey g ON r.payunitid = g.payunitid
     JOIN pay_schedule_period psp ON r.payscheduleperiodid = psp.payscheduleperiodid
     LEFT JOIN pspaygroupearningdeductiondets_mv edd ON r.amountid = edd.etv_id::text AND g.groupkey::bpchar = edd.group_key
     left join payroll.pay_codes payc on r.amountid = payc.paycode::text and current_date between payc.effectivedate and payc.enddate and current_timestamp between payc.createts and payc.endts
    LEFT JOIN gl_mapped_values mv ON r.amountid = ('MAPPEDVALUECODE_'::text || mv.glmappedvalueid) AND gj.executestatus = 1
     where psp.periodpaydate = ?
     AND psp.payunitid = 6 order by payunitid;
     select * from pay_unit;
     

     
     
     
