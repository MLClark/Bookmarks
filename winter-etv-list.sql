select * from pspay_group_earnings;
select * from pspay_group_deductions where etv_id like 'VB%';
select * from cognos_pspay_etv_names where etv_id like 'T%';
select * from cognos_pspay_etv_names_mv  where  etv_id like ('%EC%');
select * from pspay_benefit_mapping;
select * from employerbenecontribution_2018;
select * from edccearnings;
select * from payroll.pay_codes;

select * from edccearnings where group_key = 'HMN00' order by etv_id;


select * from pspsay

 SELECT DISTINCT pspay_group_deductions.group_key,
    pspay_group_deductions.etv_id,
    pspay_group_deductions.deduction_name AS etv_name
   FROM pspay_group_deductions
  WHERE pspay_group_deductions.group_key <> '$$$$$'::bpchar AND now() >= pspay_group_deductions.createts AND now() <= pspay_group_deductions.endts
UNION
 SELECT DISTINCT pspay_group_earnings.group_key,
    pspay_group_earnings.etv_id,
    pspay_group_earnings.earning_name AS etv_name
   FROM pspay_group_earnings
  WHERE pspay_group_earnings.group_key <> '$$$$$'::bpchar AND now() >= pspay_group_earnings.createts AND now() <= pspay_group_earnings.endts
  ORDER BY 1, 2
;


select isc.table_name, isc.column_name
from information_schema.columns isc,
information_schema.tables ist
where ist.table_name = isc.table_name
--and table_type = 'BASE TABLE'
and isc.table_schema = 'public'
and column_name = 'etv_id';

select * from personbenoptioncostl where personid = '2742' and costsby = 'A';


 SELECT pl.personid,
    pl.benefitsubclass AS bensubclass,
    pb.employercost AS er_perperiodcost,
    pb.employeerate,
    'V'::text || "right"(pms.eeperpayamtcode::text, 2) AS etv_id,
    pd.paymentheaderid,
    pd.etv_amount,
    pd.group_key,
    pd.check_date,
    pu.employertaxid
   FROM person_bene_election pl
     JOIN personbenoptioncostl pb ON pl.personid = pb.personid AND pl.personbeneelectionpid = pb.personbeneelectionpid AND pb.costsby = 'P'::text
     JOIN pspay_benefit_mapping pms ON pl.benefitsubclass = pms.benefitsubclass AND pms.benefitplanid IS NULL AND (pl.taxable = pms.taxable OR pms.taxable IS NULL)
     JOIN pspay_payment_detail pd ON pd.personid = pl.personid AND pd.etv_id::text = ('V'::text || "right"(pms.eeperpayamtcode::text, 2))
     JOIN pspay_payment_header ph ON pd.paymentheaderid = ph.paymentheaderid AND ph.record_stat = 'A'::bpchar
     JOIN runpayrollgetdates pgd ON ph.payscheduleperiodid = pgd.payscheduleperiodid AND pgd.asofdate >= pl.effectivedate AND pgd.asofdate <= pl.enddate
     JOIN pay_schedule_period psp ON ph.payscheduleperiodid = psp.payscheduleperiodid AND psp.processfinaldate IS NOT NULL
     JOIN groupkey g ON pd.group_key = g.groupkey::bpchar
     JOIN pay_unit pu ON g.payunitid = pu.payunitid