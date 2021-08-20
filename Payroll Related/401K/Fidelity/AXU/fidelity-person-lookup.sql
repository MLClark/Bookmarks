SELECT
 pi.personid 
,pi.identity as ssn
,pip.identity as identity
,pie.identity ::char(9) as empnbr
,pn.fname ::char(50) as fname
,pn.lname ::char(50) as lname
,pn.mname ::char(1) as mname
,'2199-12-31' ::date as enddate
,pp.schedulefrequency
,'USD'  ::char(3) as currency_code
,' '    ::char(1) as financial_plan_account_nbr
,left(pip.identity,3) ::char(3) as client
from person_identity pi

LEFT join person_identity pie
  on pie.personid = pi.personid
 and current_timestamp between pie.createts and pie.endts
 and pie.identitytype = 'EmpNo'
 
LEFT join person_identity pip
  on pip.personid = pi.personid
 and current_timestamp between pip.createts and pip.endts
 and pip.identitytype = 'PSPID' 
 
LEFT join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 and pe.effectivedate - interval '1 day' <> pe.enddate
 and pe.emplstatus = 'E'
 
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
 and current_date between pp.effectivedate and pp.enddate
 and current_timestamp between pp.createts and pp.endts 

 where pi.identitytype = 'SSN'
 and current_timestamp between pi.createts and pi.endts

order by pi.identity
;