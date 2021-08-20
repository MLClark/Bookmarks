select 
to_char(ppd.check_date,'mmddyyyy') ::char(8) as "Payroll Date",
pis.identity::char(9) as "SSN",
--ppd.individual_key as "Alternate or Employee ID", 
ee.employeeid as "Alternate or Employee ID", 
epi.firstname as "First Name",
epi.lastname as "Last Name", 
pel.etv_description,
ppd.etv_id,
case ppd.etv_id when 'VEH' then 'HSA' when 'VBB' then 'DCA' when 'VBA' then 'HRA' end as "Deduction Code",
ppd.etv_amount as "Payroll Deduction Amount"
from (select ?::date as lastcheckdate) dt
CROSS JOIN edi.etl_personal_info epi
JOIN EDI.ediemployee ee on ee.personid = epi.personid
join pspay_payment_detail ppd on ppd.individual_key = epi.trankey and ppd.check_date = ?::DATE
join pspay_etv_list pel on pel.etv_id = ppd.etv_id
LEFT JOIN person_identity pis ON pis.personid = epi.personid AND pis.identitytype = 'SSN' AND now() between pis.createts and pis.endts

where ppd.etv_code = 'EE' and ppd.etv_id in (select etv_id from pspay_deduction_accumulators where etv_id in ('VEH','VBB', 'VBA') group by 1)
order by ppd.individual_key
;
