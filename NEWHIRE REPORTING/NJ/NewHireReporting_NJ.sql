SELECT distinct  
pi.personid
,replace (pi2.identity,'-','') :: char(9) as emp_ssn
,rtrim(pn.lname) :: char(18) as emp_last_name
,rtrim(ltrim(pn.fname)) :: char(12) as emp_first_name
,substring(pn.mname,1,1) :: char(1) as emp_middle_name
,rtrim(ltrim(pa.streetaddress)) :: char(23) as emp_address1
,rtrim(ltrim(pa.streetaddress2)) :: char(23) as emp_address2
,rtrim(ltrim(pa.city)) ::char(216) as emp_city
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state
,substring(pa.postalcode,1,5)  :: char(5) as emp_zip
,null::char(4) as emp_zip4
,null::char(2) as emp_countrycode
,null ::char(15) as foreign_zip

,case when pe.empleventdetcode in ('RH','NHR') then to_char(pe.empllasthiredate,'yyyymmdd') end :: char(8) as hire_date
,to_char(pv.birthdate, 'yyyymmdd')::char(10) as emp_dob
,case when substring(pv.gendercode,1,1) = 'F' then 'F'
      when substring(pv.gendercode,1,1) = 'M' then 'M'
      else ' '
 end :: char(1) as Gender

,fcompname  :: char(30) as employer_name
,rtrim(ltrim(finaddress.faddress1)) :: char(23) as employer_address1
,rtrim(ltrim(finaddress.faddress2)) :: char(23) as employer_address2 
,rtrim(ltrim(finaddress.fcity)) ::char(16) as employer_city
,rtrim(ltrim(finaddress.fstate)) ::char(2) as employer_state
,finaddress.fzip  :: char(5) as employer_zip
,null::char(4) as employer_zip4
,null::char(2) as employer_countrycode
,null ::char(15) as employer_foreign_zip
,replace(pu.employertaxid,'-','') :: char(9) as employer_fein
,null ::char(44) as filler
,ed.feedid
,pi.identity
,current_timestamp as updatets  


from person_identity pi

LEFT JOIN person_names pn ON pn.personid = pi.personid 
AND pn.nametype = 'Legal'::bpchar 
AND now() >= pn.effectivedate 
AND now() <= pn.enddate 
AND now() >= pn.createts 
AND now() <= pn.endts

LEFT JOIN person_identity pi2 
ON pi.personid = pi2.personid
AND pi2.identitytype = 'SSN' ::bpchar 
AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts

LEFT JOIN person_address pa 
ON pa.personid = pi.personid 
AND pa.addresstype = 'Res'::bpchar 
AND now() >= pa.effectivedate 
AND now() <= pa.enddate AND now() >= pa.createts 
AND now() <= pa.endts

--heck if someone has 2 active status events in reporting period
LEFT JOIN person_employment pe
ON pe.personid = pi.personid
and pe.effectivedate < pe.enddate
--AND current_date BETWEEN pe.effectivedate AND pe.enddate
AND current_timestamp BETWEEN pe.createts AND pe.endts

LEFT JOIN person_locations pl
ON pl.personid = pi.personid
AND current_date BETWEEN pl.effectivedate AND pl.enddate
AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_address la
ON la.locationid = pl.locationid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

LEFT JOIN pslocationaddress pla
ON pla.locationid = pl.locationid
AND current_date BETWEEN pla.effectivedate AND pla.enddate
AND current_timestamp BETWEEN pla.createts AND pla.endts

LEFT JOIN person_vitals pv ON pv.personid = pi.personid 
AND now() >= pv.effectivedate 
AND now() <= pv.enddate 
AND now() >= pv.createts 
AND now() <= pv.endts

JOIN person_payroll pp
ON pp.personid = pi.personid
AND CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate
AND CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

JOIN pay_unit pu
ON pu.payunitid = pp.payunitid
AND CURRENT_TIMESTAMP BETWEEN pu.createts AND pu.endts


LEFT JOIN  (select lp.lookupid,lp.key1 as lfein, value1 as faddress1, value2 as faddress2, value3 as fcity, value4 as fstate, value5 as fzip, value6 as fcompname
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'NJ FEIN Address' 
 )finaddress on finaddress.lookupid is not null


LEFT JOIN edi.edi_last_update ed
  ON ed.feedid = 'NewHireReporting_NJ'

where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
AND pa.addresstype = 'Res'
AND current_timestamp BETWEEN pi.createts AND pi.endts

--check if someone has 2 active status events in reporting period 2018.10.10
AND pe.personid in (select personid from person_employment where emplstatus = 'A' 
									and current_date between effectivedate and enddate
									and current_timestamp between createts and endts)

and  pe.emplstatus = 'A' and pe.empleventdetcode in ('RH','NHR')
and ((pe.effectivedate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP)
    or (pe.createts > ed.lastupdatets and pe.effectivedate < coalesce(ed.lastupdatets, '2017-01-01') 
		and pe.effectivedate > coalesce(ed.lastupdatets, '2017-01-01') - interval '20 days') ) 


--AND pu.employertaxid = replace(finaddress.lfein,'-','')
AND pu.employertaxid = finaddress.lfein

--termed employees
UNION
SELECT distinct  
pi.personid
,replace (pi2.identity,'-','') :: char(9) as emp_ssn
,rtrim(pn.lname) :: char(18) as emp_last_name
,rtrim(ltrim(pn.fname)) :: char(12) as emp_first_name
,substring(pn.mname,1,1) :: char(1) as emp_middle_name
,rtrim(ltrim(pa.streetaddress)) :: char(23) as emp_address1
,rtrim(ltrim(pa.streetaddress2)) :: char(23) as emp_address2
,rtrim(ltrim(pa.city)) ::char(216) as emp_city
,rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state
,substring(pa.postalcode,1,5)  :: char(5) as emp_zip
,null::char(4) as emp_zip4
,null::char(2) as emp_countrycode
,null ::char(15) as foreign_zip
--,case when pe.empleventdetcode in ('RH','NHR') then to_char(pex.empllasthiredate,'yyyymmdd') end :: char(8) as hire_date
,to_char(pex.empllasthiredate,'yyyymmdd') :: char(8) as hire_date
,to_char(pv.birthdate, 'yyyymmdd')::char(10) as emp_dob
,case when substring(pv.gendercode,1,1) = 'F' then 'F'
      when substring(pv.gendercode,1,1) = 'M' then 'M'
      else ' '
 end :: char(1) as Gender   

,fcompname  :: char(30) as employer_name
,rtrim(ltrim(finaddress.faddress1)) :: char(23) as employer_address1
,rtrim(ltrim(finaddress.faddress2)) :: char(23) as employer_address2 
,rtrim(ltrim(finaddress.fcity)) ::char(16) as employer_city
,rtrim(ltrim(finaddress.fstate)) ::char(2) as employer_state
,finaddress.fzip :: char(5) as employer_zip
,null::char(4) as employer_zip4
,null::char(2) as employer_countrycode
,null ::char(15) as employer_foreign_zip
,replace(pu.employertaxid,'-','') :: char(9) as employer_fein
,null ::char(44) as filler
,ed.feedid
,pi.identity
,current_timestamp as updatets  

from person_identity pi

LEFT JOIN person_names pn ON pn.personid = pi.personid 
AND pn.nametype = 'Legal'::bpchar 
AND now() >= pn.effectivedate 
AND now() <= pn.enddate 
AND now() >= pn.createts 
AND now() <= pn.endts

LEFT JOIN person_identity pi2 
ON pi.personid = pi2.personid
AND pi2.identitytype = 'SSN' ::bpchar 
AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts

LEFT JOIN person_address pa 
ON pa.personid = pi.personid 
AND pa.addresstype = 'Res'::bpchar 
AND now() >= pa.effectivedate 
AND now() <= pa.enddate AND now() >= pa.createts 
AND now() <= pa.endts


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

LEFT JOIN person_locations pl
ON pl.personid = pi.personid
AND current_date BETWEEN pl.effectivedate AND pl.enddate
AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_address la
ON la.locationid = pl.locationid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

LEFT JOIN pslocationaddress pla
ON pla.locationid = pl.locationid
AND current_date BETWEEN pla.effectivedate AND pla.enddate
AND current_timestamp BETWEEN pla.createts AND pla.endts

LEFT JOIN person_vitals pv 
ON pv.personid = pi.personid 
AND now() >= pv.effectivedate 
AND now() <= pv.enddate 
AND now() >= pv.createts 
AND now() <= pv.endts

JOIN person_payroll pp
ON pp.personid = pi.personid
AND CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate
AND CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

JOIN pay_unit pu
ON pu.payunitid = pp.payunitid
AND CURRENT_TIMESTAMP BETWEEN pu.createts AND pu.endts


LEFT JOIN  (select lp.lookupid,lp.key1 as lfein, value1 as faddress1, value2 as faddress2, value3 as fcity, value4 as fstate, value5 as fzip, value6 as fcompname
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'NJ FEIN Address' 
 )finaddress on finaddress.lookupid is not null


LEFT JOIN edi.edi_last_update ed
  ON ed.feedid = 'NewHireReporting_NJ'

where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
AND pa.addresstype = 'Res'
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
--AND pu.employertaxid = replace(finaddress.lfein,'-','')
AND pu.employertaxid = finaddress.lfein

order by emp_last_name
