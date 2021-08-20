SELECT distinct
 pi.personid 
,case when substring(pi.identity from 4 for 1) = '-' then pi.identity else
      left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) end as ssn_w_dashes
,replace(pi.identity,'-','')         			AS SSN_wo_dashes
,pip.identity as identity
,'SSN' ::char(3) as ssn_idtype
,'EmpNo' ::char(5) as empno_idtype
,'PSPID' ::char(5) as pspid_idtype
,pie.identity ::char(9) as empnbr
,pn.fname ::char(50) as fname
,pn.lname ::char(50) as lname
,pn.mname ::char(1) as mname
,pa.streetaddress ::varchar(50) as addr1
,pa.streetaddress2 ::varchar(50) as addr2
,pa.city ::varchar(50) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(9) as zip
,current_timestamp as createts
,current_timestamp as updatets
,'2199-12-31 00:00:00' as endts
,'2199-12-31' as enddate
--,oc.DivisionCode ::char(1) as divisioncode
,'Thermal Ceramics' ::varchar(100) as divisioncode
--,oc.organizationdesc ::varchar(100) as division_desc
,pp.schedulefrequency ::char(1) as schedulefrequency
,'USD'  ::char(3) as currency_code
,' '    ::char(1) as financial_plan_account_nbr
,'401K' ::char(4) as benefit_plan_code
,' '    ::char(1) as financial_plan_event
,'1401' ::char(6) as benefitoptionid

from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and current_timestamp between pie.createts and pie.endts
 and pie.identitytype = 'EmpNo'
 
join person_identity pip
  on pip.personid = pi.personid
 and current_timestamp between pip.createts and pip.endts
 and pip.identitytype = 'PSPID' 
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 and pe.effectivedate - interval '1 day' <> pe.enddate
 
join person_address pa
  on pa.personid = pi.personid
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 and pa.addresstype = 'Res'
 and pa.effectivedate - interval '1 day' <> pa.enddate 
 
JOIN person_names pn
  on pn.personid = pi.personid
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts
 and pn.nametype = 'Legal'
 
left join 
 ( 
select DISTINCT
 oc.organizationid
,oc.organizationdesc
,rtrim(oc.orgcode,' ')as DivisionCode
,rtrim(ltrim(oc.organizationdesc,' '),' ')as DivisionDescription
,case oc.enddate when '2199-12-31' then '0' else '1' end ::char(1) as Disabled

from  organization_code oc
left join org_rel orid on orid.memberoforgid = oc.organizationid
 and current_date between orid.effectivedate and orid.enddate
 and current_timestamp between orid.createts and orid.endts
where current_date between oc.effectivedate and oc.enddate
  and current_timestamp between oc.createts and oc.endts
  and oc.organizationtype = 'Div'
) oc on 1=1   
 
left join pers_pos pp
  on pp.personid = pi.personid
 --and current_date between pp.effectivedate and pp.enddate -- termed people wont have a frequency - causes failure in pfpe import.
 and current_timestamp between pp.createts and pp.endts
 
  
 where pi.identitytype = 'SSN'
 and current_timestamp between pi.createts and pi.endts
 ORDER BY 3