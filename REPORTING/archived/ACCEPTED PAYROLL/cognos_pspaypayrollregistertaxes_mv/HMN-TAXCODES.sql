select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T01' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T01'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T02' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T02'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------
select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T03' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T03'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T04' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T04'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));
------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T05' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T05'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T06' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T06'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T07' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T07'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T08' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T08'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T09' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T09'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T10' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T10'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T11' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T11'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T12' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T12'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T13' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T13'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T14' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T14'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T17' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T17'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T19' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T19'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'T20' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'T20'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'TAX' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'TAX'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'TAY' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'TAY'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'TAZ' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'TAZ'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'TFB' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'TFB'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'TFC' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'TFC'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'TFD' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'TFD'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'TFE' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'TFE'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'TFF' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'TFF'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'TFI' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'TFI'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));

------------------------------------------------------------------------------

select sum(amount) from cognos_pspaypayrollregistertaxes_mv where etv_id = 'TFN' and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));


select sum(etv_amount) from pspay_payment_detail pd where etv_id = 'TFN'  AND NOT (pd.ttype_tax_code = ANY (ARRAY[' '::bpchar, '000000'::bpchar])) AND (pd.etv_amount_ytd <> 0::numeric OR pd.etv_taxable_wage_ytd <> 0::numeric OR pd.etv_amount <> 0::numeric OR pd.etv_taxable_wage <> 0::numeric)
and paymentheaderid in 
(select paymentheaderid from pspay_payment_header where payscheduleperiodid in 
(select payscheduleperiodid from pay_schedule_period where periodpaydate > '2021-01-01' and processfinaldate is not null ));