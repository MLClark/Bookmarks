SELECT distinct 
replace(pu.employertaxid,'-','') :: char(11) as employer_fein, 
pi.personid,
pu.payunitxid,
'E' :: char(2) as record_identifier,
pi2.identity :: char(9) as emp_ssn,
pn.name :: char(28) as emp_name,
pn.lname :: char(25) as emp_lastname,
pn.fname :: char(25) as emp_firstname,
pn.mname :: char(1) as emp_midname,
rtrim(ltrim(pa.streetaddress)) :: char(30) as emp_address,
rtrim(ltrim(pa.streetaddress2)) :: char(30) as emp_address2,
rtrim(ltrim(pa.city)) ::char(18) as emp_city,
rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state,
rtrim(ltrim(replace(pa.postalcode,'-','')))  :: char(6) as emp_zip,
to_char(pv.birthdate, 'yyyymmdd') :: char(8) as emp_dob,
--to_char(pe.emplhiredate,'yyyymmdd'):: char(8) as hire_date,
case when pe.empleventdetcode in ('RH','NHR') then to_char(pe.effectivedate,'yyyymmdd') end :: char(8) as hire_date,    

null ::char(18) as blank,
'2' as sort_seq,
ed.feedid,
current_timestamp as updatets,
--la.locationid
null :: char(17) as LocationId,
pi.identity

from person_identity pi

LEFT JOIN person_identity pi2 
ON pi.personid = pi2.personid
AND pi2.identitytype = 'SSN' ::bpchar 
AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts 


LEFT JOIN person_names pn ON pn.personid = pi.personid 
AND pn.nametype = 'Legal'::bpchar 
AND now() >= pn.effectivedate 
AND now() <= pn.enddate 
AND now() >= pn.createts 
AND now() <= pn.endts

LEFT JOIN person_address pa ON pa.personid = pi.personid 
AND pa.addresstype = 'Res'::bpchar 
AND now() >= pa.effectivedate 
AND now() <= pa.enddate AND now() >= pa.createts 
AND now() <= pa.endts

LEFT JOIN person_vitals pv ON pv.personid = pi.personid 
AND now() >= pv.effectivedate 
AND now() <= pv.enddate 
AND now() >= pv.createts 
AND now() <= pv.endts

--check if someone has 2 active status events in reporting period 2018.10.10
LEFT JOIN person_employment pe
ON pe.personid = pi.personid
and pe.effectivedate < pe.enddate
--AND current_date BETWEEN pe.effectivedate AND pe.enddate
AND current_timestamp BETWEEN pe.createts AND pe.endts


LEFT JOIN person_payroll ppay
  ON ppay.personid = pe.personid
 AND current_date BETWEEN ppay.effectivedate AND ppay.enddate
 AND current_timestamp BETWEEN ppay.createts AND ppay.endts      

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppay.payunitid

LEFT JOIN person_locations pl 
  on pl.personid = pi.personid
and current_date between pl.effectivedate and pl.enddate
and current_timestamp between pl.createts and pl.endts

LEFT JOIN location_address la
ON la.locationid = pl.locationid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

LEFT JOIN  (select lp.lookupid, lp.key1 as lfein, value1 as CmpAddress, value2 as Cmpaddress2, value3 as CmpCity, value4 as CmpState, value5 as CmpZipCode, value7 as CmpName
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'SC Newhire Company Address' 
 )CompAddress on CompAddress.lookupid is not null


LEFT JOIN edi.edi_last_update ed
ON ed.feedid = 'NewHireReporting_SC'


where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
AND pa.addresstype = 'Res'
--AND la.locationId is not null
AND current_timestamp BETWEEN pi.createts AND pi.endts

--check if someone has 2 active status events in reporting period 2018.10.10
AND pe.personid in (select personid from person_employment where emplstatus = 'A' 
									and current_date between effectivedate and enddate
									and current_timestamp between createts and endts)  

and  pe.emplstatus = 'A' and pe.empleventdetcode in ('NHR','RH')
-- below will get the actual new hires for the reporting period 
and ((pe.effectivedate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP) 
    or (pe.createts > ed.lastupdatets and pe.effectivedate < coalesce(ed.lastupdatets, '2017-01-01') and
     pe.effectivedate > coalesce(ed.lastupdatets, '2017-01-01') - interval '20 days') )  

AND pu.employertaxid = CompAddress.lfein
--and ((pe.effectivedate+30 >= coalesce(ed.lastupdatets, '2017-01-01'))
--and pe.createts > ed.lastupdatets ) --  927
--order by emp_name

UNION 


SELECT distinct 
replace(pu.employertaxid,'-','') :: char(11) as employer_fein, 
pu.payunitxid,
pi.personid,
'E' :: char(2) as record_identifier,
pi2.identity :: char(9) as emp_ssn,
pn.name :: char(28) as emp_name,
pn.lname :: char(25) as emp_lastname,
pn.fname :: char(25) as emp_firstname,
pn.mname :: char(1) as emp_midname,
rtrim(ltrim(pa.streetaddress)) :: char(30) as emp_address,
rtrim(ltrim(pa.streetaddress2)) :: char(30) as emp_address2,
rtrim(ltrim(pa.city)) ::char(18) as emp_city,
rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state,
rtrim(ltrim(replace(pa.postalcode,'-','')))  :: char(6) as emp_zip,
to_char(pv.birthdate, 'yyyymmdd') :: char(8) as emp_dob,
--to_char(pe.emplhiredate,'yyyymmdd'):: char(8) as hire_date,
-- make sure effective date is date from 'A' person_employment row 
to_char(pex.effectivedate,'yyyymmdd')::char(8) as hire_date, 
   

null ::char(18) as blank,
'2' as sort_seq,
ed.feedid,
current_timestamp as updatets,
--la.locationid

null :: char(17) as LocationId,
pi.identity

from person_identity pi

LEFT JOIN person_identity pi2 
ON pi.personid = pi2.personid
AND pi2.identitytype = 'SSN' ::bpchar 
AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts 


LEFT JOIN person_names pn ON pn.personid = pi.personid 
AND pn.nametype = 'Legal'::bpchar 
AND now() >= pn.effectivedate 
AND now() <= pn.enddate 
AND now() >= pn.createts 
AND now() <= pn.endts

LEFT JOIN person_address pa ON pa.personid = pi.personid 
AND pa.addresstype = 'Res'::bpchar 
AND now() >= pa.effectivedate 
AND now() <= pa.enddate AND now() >= pa.createts 
AND now() <= pa.endts

LEFT JOIN person_vitals pv ON pv.personid = pi.personid 
AND now() >= pv.effectivedate 
AND now() <= pv.enddate 
AND now() >= pv.createts 
AND now() <= pv.endts

LEFT JOIN person_employment pe
ON pe.personid = pi.personid
AND current_date BETWEEN pe.effectivedate AND pe.enddate
AND current_timestamp BETWEEN pe.createts AND pe.endts


-- returns hire date for termed employee 
LEFT JOIN  (SELECT personid, emplpermanency, effectivedate, enddate, emplstatus, emplfulltimepercent, emplevent, empleventdetcode, emplclass 
  , emplhiredate, empllasthiredate, createts, endts, rank() over (partition by personid order by effectivedate desc, createts desc) as rank 
   FROM person_employment 
           WHERE effectivedate < enddate  
                     and current_timestamp between createts and endts 
                     and emplstatus = 'A' 
                     and empleventdetcode in ('RH','NHR')) pex   ON pex.rank = 1 and pex.personid = pe.personid 


LEFT JOIN person_payroll ppay
  ON ppay.personid = pe.personid
 AND current_date BETWEEN ppay.effectivedate AND ppay.enddate
 AND current_timestamp BETWEEN ppay.createts AND ppay.endts      

LEFT JOIN pay_unit pu
  ON pu.payunitid = ppay.payunitid

LEFT JOIN person_locations pl 
  on pl.personid = pi.personid
and current_date between pl.effectivedate and pl.enddate
and current_timestamp between pl.createts and pl.endts

LEFT JOIN location_address la
ON la.locationid = pl.locationid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

LEFT JOIN  (select lp.lookupid, lp.key1 as lfein, value1 as CmpAddress, value2 as Cmpaddress2, value3 as CmpCity, value4 as CmpState, value5 as CmpZipCode, value7 as CmpName
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'SC Newhire Company Address' 
 )CompAddress on CompAddress.lookupid is not null


LEFT JOIN edi.edi_last_update ed
ON ed.feedid = 'NewHireReporting_SC'


where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
AND pa.addresstype = 'Res'
--AND la.locationId is not null
AND current_timestamp BETWEEN pi.createts AND pi.endts
and  pe.emplstatus = 'T' 
and pi.personid in (select personid from person_employment  where emplstatus = 'A'  
and enddate < current_date 
and current_timestamp between createts and endts 
and personid in (select personid from person_employment pet where emplstatus = 'T' and current_date between effectivedate and enddate and current_timestamp between createts and endts) 
and effectivedate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP 
and enddate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP 
and empleventdetcode in ('NHR','RH') 
and effectivedate < enddate) 
AND pu.employertaxid = CompAddress.lfein

order by emp_lastname 
