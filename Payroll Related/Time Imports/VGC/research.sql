select * from Person_pto_activity_request where createts::date = current_date;
delete  from Person_pto_activity_request where createts::date = current_date;
select * from person_names where lname like 'Par%';



insert into person_pto_activity_request (personid, personactivityreqpid, ptoplanid, effectivedate, enddate, activityrequestsource, reasoncode, activityrequestcomment, ptoplanaccrualpid, takehours, accruehours, bankhours, vestingperiodholding, appliedflag, planyearstart, planyearend, createts, endts) 
select ,388,,'06/06/2021','2199-12-31 +0','Import','I','Vista_TimeImport',null, 00000008.00,'0.0','0.0','0.0','Y','','', current_timestamp, '2199-12-30 00:00:00-05'


activityreqpid

SELECT
pto.personid
,pto.ptoplanid
,pi.identity
,pn.fname || ' ' || pn.lname as fullname
from person_pto_plans pto
left join person_identity pi on pi.personid = pto.personid and pi.identitytype = 'EmpNo' and current_timestamp between pi.createts and pi.endts
left join person_names pn on pn.personid = pi.personid and current_date between pn.effectivedate and pn.enddate and current_timestamp between pn.createts and pn.endts
where current_date between pto.effectivedate and pto.enddate and current_timestamp between pto.createts and pto.endts
and pto.personid in ('416', '405');

select * from person_pto_plans where personid in ('416', '405');