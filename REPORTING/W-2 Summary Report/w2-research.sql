--select * from cognos_pspay_etv_names where etv_id like 'T%' and etv_name is not null and group_key = 'AZW30'; --- BOX
select * from cognos_tax_liability;
select * from tax_form_header where taxformhdrid = '1183';
select * from tax_form_detail where taxformhdrid = '1183' and box like 'b%';
select * from w2viewsummarytotals;
select * from tax_form_box_desc;




select * from cognos_w2_data where trankey = 'AZW20000009078' and boxnumber like 'e%';
select * from cognos_w2_data limit 10;

select * from pay_unit;

select * from cognos_w2_data where taxformyear = '2018' 

SELECT
    TRIM(BOTH FROM "cognos_tax_liability"."employertaxid") AS "Employer_Tax_Id", 
    TRIM(BOTH FROM "cognos_tax_liability"."groupkey") AS "Group_Key", 
    TRIM(BOTH FROM "cognos_tax_liability"."stateprovincecode") as "State_Code",
    "cognos_tax_liability"."payunitid" AS "Pay_Unit_Id"
FROM
    "public"."cognos_tax_liability" "cognos_tax_liability" 
WHERE "cognos_tax_liability"."employertaxid" is not null
GROUP BY 
    TRIM(BOTH FROM "cognos_tax_liability"."employertaxid"), 
    TRIM(BOTH FROM "cognos_tax_liability"."groupkey"), 
    TRIM(BOTH FROM "cognos_tax_liability"."stateprovincecode"),
    "cognos_tax_liability"."payunitid" 
    
    
    select * from w2viewsummarytotals;
    select * from information_schema.columns ;
    
select 
 payunitid
,alphavalue
,dollarsvalue
,box
from cognos_w2_data where taxformyear = '2018' and payunitid = '7';
select * from cognos_tax_liability where payunitdesc like 'AZW30%';
select * from statetaxidmap where stateprovincecode in ('CA');
select * from taxadd where taxid in (select taxid from statetaxidmap where stateprovincecode in ('CA') group by 1);
select * from taxentitiesadd where taxentity in (select taxentity from statetaxidmap where stateprovincecode in ('CA') group by 1);
select * from taxentitieslist where taxentity in (select taxentity from statetaxidmap where stateprovincecode in ('CA') group by 1);
select * from taxtaxentities where taxentity in (select taxentity from statetaxidmap where stateprovincecode in ('CA') group by 1);



select	batchtaxmethodid,
		batchtaxmethodcode,
		upper(trim(batchtaxmethoddesc))::varchar(50) as batchtaxmethoddesc
from	batch_tax_method




select * from cognos_w2_data;
select * from w2viewsummarytotals;

select * from tax_form_header ;
select * from tax_form_detail ;