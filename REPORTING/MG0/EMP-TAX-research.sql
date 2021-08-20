select n.etv_name, sum(etv_amount)Amt, ppd.etv_id, ppd.etv_code from pspay_payment_detail ppd join pspay_payment_header pph
on ppd.paymentheaderid=pph.paymentheaderid
and pph.period_end_date>='2019-06-02' and  pph.period_end_date<='2020-01-02' 
--and ppd.etv_id ilike 'T%' 
and ppd.etv_id in ('T01', 'T02', 'T03', 'T04', 'T05', 'T06', 'T07', 'T08', 'T09', 'T10', 'T11', 'T12', 'T13', 'T14', 'T17')
join cognos_pspay_etv_names n on n.etv_id = ppd.etv_id
group by ppd.etv_id, ppd.etv_code, n.etv_name
order by ppd.etv_code;

select * from cognos_pspay_etv_names where etv_id in ('T19','T01', 'T02', 'T03', 'T04', 'T05', 'T06', 'T07', 'T08', 'T09', 'T10', 'T11', 'T12', 'T13', 'T14', 'T17');

select * from cognos_payment_taxesus_by_check_date  ppd
join pspay_payment_header pph
on ppd.paymentheaderid=pph.paymentheaderid
and ppd.etv_id in ('T09','T10') 
and pph.period_end_date>='2019-06-02' and  pph.period_end_date<='2020-01-02' ;

select n.etv_name, sum(etv_amount)Amt, ppd.etv_id, ppd.etv_code from pspay_payment_detail ppd join pspay_payment_header pph
on ppd.paymentheaderid=pph.paymentheaderid
and pph.period_end_date>='2019-06-02' and  pph.period_end_date<='2020-01-02' 
and ppd.etv_id in ('T09','T10','T19') 
join cognos_pspay_etv_names n on n.etv_id = ppd.etv_id
group by ppd.etv_id, ppd.etv_code, n.etv_name
order by ppd.etv_code;


select * from pspay_payment_detail ppd join pspay_payment_header pph
on ppd.paymentheaderid=pph.paymentheaderid
--and ppd.etv_id in ('T01', 'T02', 'T03', 'T04', 'T05', 'T06', 'T07', 'T08', 'T09', 'T10', 'T11', 'T12', 'T13', 'T14', 'T17')
and ppd.ttype_tax_code in ('57FL00','039801') 
and pph.check_date >='2019-06-02' and  pph.check_date<='2020-01-02' ;