select * from benefit_plan_desc ;
--select edtcode from benefit_plan_desc group by edtcode;

select distinct
	bpd.benefitplanid,
	bpd.benefitplancode,
	trim(upper(bpd.benefitsubclass)) as benefitsubclass,
--	bpd.benefitcalctype,
	'P'::char(1) as benefitcalctype,
	bo.benefitoptionid,
	current_timestamp as createts
from benefit_plan_desc bpd
join 	benefit_option bo on bo.benefitplanid = bpd.benefitplanid and bo.edtcode = bpd.edtcode
		and 'now'::text::date >= bo.effectivedate AND 'now'::text::date <= bo.enddate AND now() >= bo.createts AND now() <= bo.endts
where
	bpd.edtcode like '%401%'
	and 'now'::text::date >= bpd.effectivedate AND 'now'::text::date <= bpd.enddate AND now() >= bpd.createts AND now() <= bpd.endts
;


/*
2019-04-15
	AXU - There was a problem with benefitcalctype from the table being "B" and the eHCM defaulting to amount instead of %.
	If the eHCM gets fixed, this can be put back to handle amounts and percentages.
*/