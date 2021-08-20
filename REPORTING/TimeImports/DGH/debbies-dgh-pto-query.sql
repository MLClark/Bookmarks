WITH  ptoetvmap (edtcode, etv_id) AS (VALUES ('PTOSick', 'E16'), ('VACPLAN','E15'), ('Bervmnt','E18'), ('JuryDuty','E19'), ('ComSvc','ECP'), ('FamDay','ECO') ) 
select ppar.personid, ppd.edtcode, ppar.takehours,bd.hours, pn.name, ppar.ptoplanid, ppar.effectivedate, ppar.enddate, ppar.activityrequestsource, ppar.reasoncode, ppar.activityrequestcomment, ppar.createts
, ppd.ptoplandesc, ppd.ptoplanid
, pem.etv_id, pem.edtcode
, bd.batchdetailid, bd.batchheaderid, bd.etv_id,  bd.effectivedate, bd.createts
from person_pto_activity_request ppar
join person_pto_plans ppp
  on ppp.personid = ppar.personid
and ppp.ptoplanid = ppar.ptoplanid
and current_date between ppp.effectivedate and ppp.enddate
and current_timestamp between ppp.createts and ppp.endts
join pto_plan_desc ppd
  on ppd.ptoplanid = ppp.ptoplanid
and current_date between ppd.effectivedate and ppd.enddate
and current_timestamp between ppd.createts and ppd.endts

join person_names pn on pn.personid = ppp.personid and pn.nametype = 'Legal' and current_date between pn.effectivedate and pn.enddate and current_timestamp between pn.createts and pn.endts    
join ptoetvmap pem on pem.edtcode = ppd.edtcode 
join batch_detail bd on ppar.personid = bd.personid   and bd.etv_id = pem.etv_id and bd.createts::DATE = ppar.createts::date and ppar.takehours = bd.hours::integer --and bd.etv_id in ('E15', 'E16','E18','E19', 'ECO','ECP')
join batch_header bh on bh.batchheaderid = bd.batchheaderid and bh.effectivedate < bh.enddate and current_timestamp between bh.createts and bh.endts --and bh.batchname = 'DGH_TimeImport' or bh.batchname like '%.csv' 
where ppar.activityrequestcomment = 'DGHTiimeImport'
and ppar.takehours <> bd.hours
and bd.hours <> bd.hours::integer
and ppar.personid = '19633'
order by ppar.personid, ppar.effectivedate
;
select * from person_pto_activity_request where personid = '19633' and activityrequestcomment = 'DGHTiimeImport';
select * from batch_header where batchheaderid in ('417','342','732','769','533','633','908');
select * from batch_detail where personid in ('19633') and etv_id in ('E16');




