select 
 ppar.personid
,substr(pi.identity,1,3) ::char(3) as co_code
,substr(pi.identity,4,6) ::char(6) as file_number
,pn.lname ::varchar(30) as lname
,pn.fname ::varchar(30) as fname
,ppar.personactivityreqpid
,ppd.edtcode
,ppar.ptoplanid
,ppar.effectivedate
,ppar.enddate
,ppar.activityrequestsource
,ppar.reasoncode
,ppar.activityrequestcomment
,ppar.ptoplanaccrualpid
,ppar.takehours
,ppar.accruehours
,ppar.bankhours
,ppar.vestingperiodholding
,ppar.appliedflag
,ppar.planyearstart
,ppar.planyearend
,ppar.createts
,ppar.endts
,ppar.updatets
,ppar.requestgroupid


from person_pto_activity_request ppar

join edi.edi_last_update elu on elu.feedid = 'DGH_PersonPTOPlans_Import'

join person_names pn
  on pn.personid = ppar.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 
join person_identity pi
  on pi.personid = ppar.personid
 and pi.identitytype = 'Badge'
 and current_timestamp between pi.createts and pi.endts
 
join pto_plan_desc ppd
  on ppd.ptoplanid = ppar.ptoplanid
 and current_date between ppd.effectivedate and ppd.enddate
 and current_timestamp between ppd.createts and ppd.endts

where activityrequestcomment = 'DGHTiimeImport' 
  and ppar.createts::date >= elu.lastupdatets::date
 order by co_code, file_number
 
 --select * from person_pto_plans where personid = '19703';
 --select * from pto_plan_desc;
 --select * from edi.edi_last_update;