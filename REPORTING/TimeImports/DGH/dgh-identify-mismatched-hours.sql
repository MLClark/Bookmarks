SELECT distinct
 pi.personid

,pib.identity ::char(9) as badgeid
,pn.fname ::varchar(50) as fname
,pn.lname ::varchar(50) as lname
,pn.mname ::char(1) as mname
,ppp.ptoplanid as ptoplanid
,ppd.edtcode ::varchar(10) as etdcode

,to_char(current_date,'yyyy-mm-dd')::date as effectivedate
,bd.etv_id
,ppar.takehours
,cast(0 as dec(25,23)) as accruehours
,cast(0 as dec(25,23)) as bankhours
,cast(0 as dec(25,23)) as vestingperiodholding
,cast(null as int) as ptoplanaccrualpid
,cast(null as timestamp) as updatets 
,cast(null as int) as requestgroupid
,'Y' as appliedflag	
,to_char(pasof.planyearstart,'yyyy-mm-dd')::date as planyearstart
,to_char(pasof.planyearend,'yyyy-mm-dd')::date as planyearend
,current_timestamp as createts
,cast ('2199-12-30 00:00:00' as timestamp) as endts

,case when ppd.edtcode = 'PTOSick'  then 1
      when ppd.edtcode = 'VACPLAN'  then 2
      when ppd.edtcode = 'Bervmnt'  then 3
      when ppd.edtcode = 'JuryDuty' then 4
      when ppd.edtcode = 'FamDay'   then 5
      when ppd.edtcode = 'ComSvc'   then 6 end as key_rank

from person_identity pi

left join person_identity pib
  on pib.personid = pi.personid
 and current_timestamp between pib.createts and pib.endts
 and pib.identitytype = 'Badge'
 
left JOIN person_names pn
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'
 
join person_pto_activity_request ppar
  on ppar.personid = pi.personid 
 and ppar.activityrequestcomment = 'DGHTiimeImport' 
 
join person_pto_plans ppp
  on ppp.personid = pi.personid
 and current_date between ppp.effectivedate and ppp.enddate
 and current_timestamp between ppp.createts and ppp.endts

join pto_plan_desc ppd
  on ppd.ptoplanid = ppp.ptoplanid
 and current_date between ppd.effectivedate and ppd.enddate
 and current_timestamp between ppd.createts and ppd.endts
 
join personptoplanyearasof pasof
  on pasof.personid = ppp.personid
 and pasof.ptoplanid = ppp.ptoplanid
 and pasof.asofdate = current_date        
 
join batch_detail bd    
  on bd.personid = ppar.personid
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pib.identity is not null 
  and bd.etv_id in ('E16','E17','E18','E19','ECO','ECP')
  and pi.personid = '19102'
order by badgeid,key_rank