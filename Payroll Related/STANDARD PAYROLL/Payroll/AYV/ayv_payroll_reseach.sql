select * from batch_detail where BATCHheaderid in ('51','58');
select * from batch_header where batchheaderid in ('51','58');
select * from pay_schedule_period where periodenddate = '2018-03-10' and payunitid in ('8');
select * from pspay_benefit_mapping ;
select * from person_bene_election 
where current_timestamp between createts and endts
  and current_date between effectivedate and enddate
  and personid = '6138'
  ;
select * from personbenoptioncostl where personid = '6130';  
select * from person_identity where current_timestamp between createts and endts and identitytype = 'EmpNo' and personid = '6130';
select * from pspay_benefit_mapping ;
select * from person_compensation where personid = '6384';
select * from person_names where personid = '6384';