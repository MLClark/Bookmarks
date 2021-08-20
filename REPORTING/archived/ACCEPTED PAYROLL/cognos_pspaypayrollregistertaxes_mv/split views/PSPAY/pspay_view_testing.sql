select sum(amount) from public.cognos_pspaypayrollregistertaxes where personid = '62958' and paymentheaderid = '118907';

select personid, paymentheaderid, sum(etv_amount) from pspay_payment_detail where personid = '62958' and ttype_tax_code in (select ttype_tax_code from tax_lookup_aggregators group by 1) group by personid, paymentheaderid order by personid, paymentheaderid;


select personid, sum(etv_amount) from pspay_payment_detail where personid = '62958' and ttype_tax_code in (select ttype_tax_code  from tax_lookup_aggregators group by 1) group by personid order by personid;