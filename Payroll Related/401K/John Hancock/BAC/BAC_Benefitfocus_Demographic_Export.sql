select
 pi.personid
,pi.identity ::char(9) as ssn 
,pn.fname ::varchar(50) as fname
,pn.mname ::char(1) as mname
,pn.lname ::varchar(50) as lname
,pn.title ::varchar(10) as suffix

,case when ppd.etv_id = 'VB1' then 'TRADITIONAL401K'
      end ::varchar(100) as bentype
,pel.etv_description ::varchar(100) as planname


from person_identity pi

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
left join person_bene_election pbe
  on pbe.personid = pi.personid
 and pbe.benefitelection = 'E'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 
join benefit_plan_desc bpd
  on bpd.benefitsubclass = pbe.benefitsubclass
 and current_date between bpd.effectivedate and bpd.enddate
 and current_timestamp between bpd.createts and bpd.endts 
 
 
join pspay_payment_detail ppd
  on ppd.personid = pi.personid 
 and ppd.check_date = '2018-01-12'
 and ppd.etv_id in ( 'VB1' )
 
 
join pspay_payment_detail ppdvb1 
  on ppdvb1.personid = pi.personid 
 and ppdvb1.check_date = ppd.check_date
 and ppdvb1.etv_id = 'VB1' 

left join pspay_etv_list pel
  on pel.etv_id = ppdvb1.etv_id 
   
  
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  