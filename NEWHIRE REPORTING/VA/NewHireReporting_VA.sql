SELECT distinct  
pi.personid,
'VA Newhire Record' :: char(17) as record_identifier,
'1.00' :: char(4) as format_number,
--employee section
rtrim(ltrim(pn.fname)) :: char(16) as emp_first_name,
rtrim(ltrim(pn.mname)) :: char(16) as emp_middle_name,
rtrim(pn.lname) :: char(30) as emp_last_name,
pi2.identity :: char(9) as emp_ssn,
rtrim(ltrim(pa.streetaddress)) :: char(40) as emp_address1,
rtrim(ltrim(pa.streetaddress2)) :: char(40) as emp_address2,
rtrim(ltrim(pa.streetaddress3)) :: char(40) as emp_address3,
rtrim(ltrim(pa.city)) ::char(25) as emp_city,
rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state,
rtrim(ltrim(pa.postalcode))  :: char(20) as emp_zip,
null :: char(4) as employer_zip_ext,
--rtrim(ltrim(la.countrycode)) :: char(2) as country_code,
null :: char(2) as country_code,
to_char(pv.birthdate,'MMDDYYYY'):: char(8) as birth_date,

case when pe.empleventdetcode in ('RH','NHR') then to_char(pe.effectivedate,'MMDDYYYY') end :: char(8) as hire_date,    

null :: char(2) as state_hire,
null :: char(1) as med_avail,
null :: char(1) as filler,
----
----employer section
replace(pu.employertaxid,'-','') :: char(9) as employer_fein,
null :: char(12) as state_id, ---not available for va
----
fcompname :: char(45) as employer_name,
--cn.companyname :: char(45) as employer_name_1
rtrim(ltrim(finaddress.faddress1)) :: char(40) as employer_address1,
rtrim(ltrim(finaddress.faddress2)) :: char(40) as employer_address2,
null :: char(40) as employer_address3,
rtrim(ltrim(finaddress.fcity)) :: char(25) as employer_city,
rtrim(ltrim(finaddress.fstate)) :: char(2) as employer_state,
rtrim(ltrim(finaddress.fzip)) :: char(20) as employer_zip,
null :: char(4) as employer_zip_ext,
--rtrim(ltrim(la.countrycode)) :: char(2) as country_code,
null :: char(2) as country_code,
null :: char (10) as phone_number,
null :: char (6) as phone_ext,
null :: char (20) as employer_contact,

--optional er addr The address where child support orders should be sent
null :: char(40) as employer_address1_add,
null :: char(40) as employer_address2_add,
null :: char(40) as employer_address3_add,
null :: char(25) as employer_city_add,
null :: char(2) as employer_state_add,
null :: char(20) as employer_zip_add,
null :: char(4) as employer_zip_ext_add,
null :: char(2) as country_code_add,

null :: char (10) as phone_number_add,
null :: char (6) as phone_ext_add,
null :: char (20) as employer_contact_add,
null :: char (32) as filler_end,


---
ed.feedid,
current_timestamp as updatets


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
--AND pa.addresstype in ( 'Res','BUSN')--::bpchar 
AND pa.addresstype in ( 'Res')--::bpchar 
AND now() >= pa.effectivedate 
AND now() <= pa.enddate AND now() >= pa.createts 
AND now() <= pa.endts

LEFT JOIN person_vitals pv
on pv.personid = pi.personid
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

 LEFT JOIN  (select lp.lookupid,lp.key1 as lfein, value1 as faddress1, value2 as faddress2, value3 as fcity, value4 as fstate, value5 as fzip, value6 as fcompname
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'VA FEIN Address' 
 )finaddress on finaddress.lookupid is not null


LEFT JOIN dxcompanyname dp
ON dp.companyid = pe.companyid 
AND current_date BETWEEN dp.effectivedate AND dp.enddate
AND current_timestamp BETWEEN dp.createts AND dp.endts

LEFT JOIN person_locations pl
ON pl.personid = pe.personid
AND current_date BETWEEN pl.effectivedate AND pl.enddate
AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_address la
ON la.locationid = pl.locationid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

LEFT JOIN edi.edi_last_update ed ON ed.feedid = 'NewHireReporting_VA'


where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
--AND pa.addresstype in ('Res', 'BUSN')
AND pa.addresstype in ('Res')
AND current_timestamp BETWEEN pi.createts AND pi.endts
and  pe.emplstatus = 'A' 
and pe.empleventdetcode in ('NHR','RH')

--check if someone has 2 active status events in reporting period 2018.10.10
AND pe.personid in (select personid from person_employment where emplstatus = 'A' 
									and current_date between effectivedate and enddate
									and current_timestamp between createts and endts)

and ((pe.effectivedate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP) 
    or (pe.createts > ed.lastupdatets and pe.effectivedate < coalesce(ed.lastupdatets, '2017-01-01') 
	and pe.effectivedate > coalesce(ed.lastupdatets, '2017-01-01') - interval '20 days') )  
AND pu.employertaxid = finaddress.lfein

--ADD TERM EMPLOYEES THAT WERE HIRED AND FIRED WITH THE TIMEFRAME

UNION

SELECT distinct  
pi.personid,
'VA Newhire Record' :: char(17) as record_identifier,
'1.00' :: char(4) as format_number,
--employee section
rtrim(ltrim(pn.fname)) :: char(16) as emp_first_name,
rtrim(ltrim(pn.mname)) :: char(16) as emp_middle_name,
rtrim(pn.lname) :: char(30) as emp_last_name,
pi2.identity :: char(9) as emp_ssn,
rtrim(ltrim(pa.streetaddress)) :: char(40) as emp_address1,
rtrim(ltrim(pa.streetaddress2)) :: char(40) as emp_address2,
rtrim(ltrim(pa.streetaddress3)) :: char(40) as emp_address3,
rtrim(ltrim(pa.city)) ::char(25) as emp_city,
rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state,
rtrim(ltrim(pa.postalcode))  :: char(20) as emp_zip,
null :: char(4) as employer_zip_ext,
--rtrim(ltrim(la.countrycode)) :: char(2) as country_code,
null :: char(2) as country_code,
to_char(pv.birthdate,'MMDDYYYY'):: char(8) as birth_date,

to_char(pex.effectivedate,'MMDDYYYY')::char(8) as hire_date,    

null :: char(2) as state_hire,
null :: char(1) as med_avail,
null :: char(1) as filler,
----
----employer section
----
replace(pu.employertaxid,'-','') :: char(9) as employer_fein,
null :: char(12) as state_id, ---not available for va
----
fcompname :: char(45) as employer_name,
--cn.companyname :: char(45) as employer_name_1
rtrim(ltrim(finaddress.faddress1)) :: char(40) as employer_address1,
rtrim(ltrim(finaddress.faddress2)) :: char(40) as employer_address2,
null :: char(40) as employer_address3,
rtrim(ltrim(finaddress.fcity)) :: char(25) as employer_city,
rtrim(ltrim(finaddress.fstate)) :: char(2) as employer_state,
rtrim(ltrim(finaddress.fzip)) :: char(20) as employer_zip,
null :: char(4) as employer_zip_ext,
--rtrim(ltrim(la.countrycode)) :: char(2) as country_code,
null :: char(2) as country_code,

null :: char (10) as phone_number,
null :: char (6) as phone_ext,
null :: char (20) as employer_contact,

--optional er addr The address where child support orders should be sent
null :: char(40) as employer_address1_add,
null :: char(40) as employer_address2_add,
null :: char(40) as employer_address3_add,
null :: char(25) as employer_city_add,
null :: char(2) as employer_state_add,
null :: char(20) as employer_zip_add,
null :: char(4) as employer_zip_ext_add,
null :: char(2) as country_code_add,

null :: char (10) as phone_number_add,
null :: char (6) as phone_ext_add,
null :: char (20) as employer_contact_add,
null :: char (32) as filler_end,


---
ed.feedid,
current_timestamp as updatets


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
--AND pa.addresstype in ( 'Res','BUSN')--::bpchar 
AND pa.addresstype in ( 'Res')--::bpchar 
AND now() >= pa.effectivedate 
AND now() <= pa.enddate AND now() >= pa.createts 
AND now() <= pa.endts

LEFT JOIN person_vitals pv
on pv.personid = pi.personid
AND now() >= pv.effectivedate  
AND now() <= pv.enddate  
AND now() >= pv.createts  
AND now() <= pv.endts 
 
LEFT JOIN person_employment pe
ON pe.personid = pi.personid
AND current_date BETWEEN pe.effectivedate AND pe.enddate
AND current_timestamp BETWEEN pe.createts AND pe.endts

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

LEFT JOIN  (select lp.lookupid,lp.key1 as lfein, value1 as faddress1, value2 as faddress2, value3 as fcity, value4 as fstate, value5 as fzip, value6 as fcompname
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'VA FEIN Address' 
 )finaddress on finaddress.lookupid is not null

LEFT JOIN dxcompanyname dp
ON dp.companyid = pe.companyid 
AND current_date BETWEEN dp.effectivedate AND dp.enddate
AND current_timestamp BETWEEN dp.createts AND dp.endts

LEFT JOIN person_locations pl
ON pl.personid = pe.personid
AND current_date BETWEEN pl.effectivedate AND pl.enddate
AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_address la
ON la.locationid = pl.locationid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

LEFT JOIN edi.edi_last_update ed ON ed.feedid = 'NewHireReporting_VA'


where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
--AND pa.addresstype in ('Res', 'BUSN')
AND pa.addresstype in ('Res')
AND current_timestamp BETWEEN pi.createts AND pi.endts 
and  pe.emplstatus = 'T'  
and pi.personid in (select personid from person_employment  where emplstatus = 'A'  
						   and enddate < current_date 
						   and current_timestamp between createts and endts 
and personid in (select personid from person_employment pet where emplstatus = 'T' 
						and current_date between effectivedate and enddate and current_timestamp between createts and endts) 
						and effectivedate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP 
						and enddate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP 
						and empleventdetcode in ('NHR','RH') 
						and effectivedate < enddate) 
AND pu.employertaxid = finaddress.lfein

order by 1