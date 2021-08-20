select
	trim(pi.identity)::char(9) as ssno,
	trim(pi1.identity)::varchar(20) as trankey,
	trim(ppd.etv_id)::char(3) as etv_id,

	case when ppd.etv_id = 'VEK' then '1'
         else '0'
	end::char(1) as etv_code,

	to_char(ppd.etv_amount, '99999999D99') as etv_amount,
	to_char(ppd.check_date, 'YYYYMMDD')::char(8) as check_date,
	date_part('year', CURRENT_DATE)::char(4) as check_year
from
	person_identity pi
	join person_identity pi1 on pi.personid = pi1.personid
		and pi1.identitytype = 'PSPID'::bpchar AND now() >= pi1.createts AND now() <= pi1.endts
	join pspay_payment_detail ppd on ppd.individual_key = pi1.identity
		and ppd.etv_id in ('VEH','VEK','VEI','VEJ')
		and ppd.check_date = ?
where  pi.identitytype = 'SSN'::bpchar AND now() >= pi.createts AND now() <= pi.endts

order by trankey

--- 2018-06-29