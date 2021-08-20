select * from cognos_pspaypayrollregistertaxes_mv where personid = '67846'
and paymentheaderid in (select paymentheaderid from pspay_payment_header where personid = '67846' and check_date between '2020-01-01' and '2020-12-31')
and etv_id not in ('T02','T13','T01','TFB','TFC')
;
select * from pspay_payment_detail where etv_id like 'T%' and etv_id not in ('T02','T13','T01','TFB','TFC','TAX','TAZ') and personid = '67846' and check_date between '2020-01-01' and '2020-12-31'
;


;
select * from tax where taxid in (1,2);
select * from tax_lookup_aggregators where taxid in (1,2);
select * from payroll.payment_details where personid = '123' and check_date = '2021-01-22' and paymentheaderid = 18586;

select * from person_names where personid = '123';


select * from cognos_pspaypayrollregistertaxes_mv where personid = '67697'
and paymentheaderid in (select paymentheaderid from pspay_payment_header where personid = '67697' and check_date between '2020-01-01' and '2020-12-31')
and etv_id not in ('T02','T13','T01','TFB','TFC');

select * from pspay_payment_detail where etv_id like 'T%' and etv_id not in ('T02','T13','T01','TFB','TFC','TAX','TAZ') and personid = '67697' and check_date between '2020-01-01' and '2020-12-31'

/*
Issue with revised view missing T09 for personid 67846 with taxid 600311. Should have a tax amount of 11.13

has to do with this join doesn't match taxid or ttype_tax_code
JOIN payroll.taxmappaycodetoetvid tmap ON tmap.etv_id = pd.etv_id
--and pte.taxid::numeric = tmap.taxid::numeric
– and tmap.ttype_tax_code = pd.ttype_tax_code
*/