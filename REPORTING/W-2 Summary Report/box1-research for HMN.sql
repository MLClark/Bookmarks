select * from pspay_payment_detail where personid in ('62958') and date_part('year',check_date) = '2020' and etv_id like 'T%';


select * from tax_form_detail where box::text like  '2         %' and  taxformhdrid in (select taxformhdrid from tax_form_header where  personid in ('64355') and taxformyear = '2020');
select * from tax_form_header where  personid in ('64355');

select * from year_end_tax_form_detail where box::text like  '1         %' ;

select * from person_identity where identity = 'HMN00000001592';

 SELECT pte.personid,
    pte.exempt,
    pte.exemptions,
    pte.taxid,
    t.taxcode,
    te.taxlocality,
    te.taxstatecode,
    spc.stateprovincecode,
    pte.effectivedate,
    pte.enddate
   FROM person_tax_elections pte
     JOIN tax t ON t.taxid = pte.taxid AND t.taxcode <> 'XXXXXXXX'::bpchar
     JOIN tax_entity te USING (taxentity)
     JOIN state_province spc ON spc.stateprovincegnis = te.taxstatecode::integer
  WHERE now() >= pte.createts AND now() <= pte.endts
  and pte.personid = '64355'

;
select personid, sum(etv_taxable_wage) taxable_wage  from pspay_payment_detail where  date_part('year',check_date) = '2020' and etv_id = 'T02' and etv_amount = 0
and personid in ('64355','65500','65920','66152','68419','68574','68620','68624','68693','68714','68738','68744','68745','68768','68772','68773')
group by personid
;

select * from pspay_payment_detail where  date_part('year',check_date) = '2020' and etv_id = 'T02' and etv_amount = 0
and personid in ('64355','65500','65920','66152','68419','68574','68620','68624','68693','68714','68738','68744','68745','68768','68772','68773')
;

(
select distinct
 personid
,trankey 
,taxformyear
,boxnumber
,box
,subbox
,alphavalue 
,dollarsvalue as box1_wages
from cognos_w2_data 
where taxformyear = '2020'
  and boxnumber = '1         ' 
  and personid in ('64355','65500','65920','66152','68419','68574','68620','68624','68693','68714','68738','68744','68745','68768','68772','68773')
);
--[Data].[payroll_taxesus_by_year].[etv_taxable_wage]

--Select * From public.cognos_payment_taxesus_by_year cognos_payment_taxesus_by_year

select personid, sum(etv_taxable_wage) From public.cognos_payment_taxesus_by_year
 where etv_id = 'T02' and checkyr = '2020' 
 and personid in ('64355','65500','65920','66152','68419','68574','68620','68624','68693','68714','68738','68744','68745','68768','68772','68773')
 group by personid;

Select * From public.cognos_payment_taxesus_by_year where etv_id = 'T02' and checkyr = '2020' and personid in ('64355','65500','65920','66152','68419','68574','68620','68624','68693','68714','68738','68744','68745','68768','68772','68773')
;
select * from person_names where personid in ('64355','65500','65920','66152','68419','68574','68620','68624','68693','68714','68738','68744','68745','68768','68772','68773')
and nametype = 'Legal' and current_date between effectivedate and enddate and current_timestamp between createts and endts;

select * from pspay_etv_list where etv_id like 'T%';
select * from payroll.pay_codes;
