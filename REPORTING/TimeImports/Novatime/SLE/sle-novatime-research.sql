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

select * from pay_schedule_period where date_part('year',periodpaydate)='2019' and date_part('month',periodpaydate)>='07';

select * from pay_schedule_period where processfinaldate is not null;


select * from batch_header where check_date = '2019-07-15';

select * from cognos_pspay_etv_names ;
select * from cognos_pspay_etv_names_mv;



select * from person_identity where identitytype = 'EmpNo';
select * from person_identity where personid = '104';


select * from batch_detail  where etv_id = 'E01';

select * from person_identity where personid = '173';

select * from batch_detail where personid = '203';

select * from person_identity where identity = '105';

select * from person_names where personid = '1012';

select * from batch_header where createts::date = current_date ;
select * from batch_detail  where createts::date = current_date;

delete from batch_detail  where createts::date = current_date;
delete from batch_header where createts::date = current_date;
select * from person_identity where identitytype = 'USGID';

select pi.identity, pn.name, bd.personid, bd.amount, bd.hours, bd.etv_id
  from batch_detail bd 
  join person_identity pi 
    on pi.personid = bd.personid
   and pi.identitytype = 'USGID'
  join person_names pn
    on pn.personid = bd.personid
   and pn.nametype = 'Legal'
   and current_date between pn.effectivedate and pn.enddate
   and current_timestamp between pn.createts and pn.endts
 where bd.batchheaderid = 27
 order by 1
