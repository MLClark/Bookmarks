-- Illinois new hire query
SELECT distinct  
pi.personid,
pi.identity,
'W4' :: CHAR(2) AS record_identifier,
pi2.identity :: CHAR(9) AS emp_ssn,
rtrim(ltrim(pn.fname)) :: CHAR(16) AS first_name,
rtrim(ltrim(pn.mname)) :: CHAR(16) AS middle_name,
rtrim(pn.lname) :: CHAR(30) AS emp_last_name,
rtrim(ltrim(pa.streetaddress)) :: CHAR(40) AS emp_address1,
rtrim(ltrim(pa.streetaddress2)) :: CHAR(40) AS emp_address2,
rtrim(ltrim(pa.streetaddress3)) :: CHAR(40) AS emp_address3,
rtrim(ltrim(pa.city)) ::CHAR(25) AS emp_city,
rtrim(ltrim(pa.stateprovincecode)) ::CHAR(2) AS emp_state,
rtrim(ltrim(pa.postalcode))  :: CHAR(5) AS emp_zip,
'' :: CHAR(4) AS emp_zipplus_4,
'' :: CHAR(42) AS blank1, 
to_char(pv.birthdate, 'yyyymmdd') :: CHAR(8) AS emp_dob,
case when pe.empleventdetcode in ('RH','NHR') then to_char(pe.effectivedate,'yyyymmdd') end :: CHAR(8) AS emp_doh,
la.stateprovincecode  :: CHAR(2) AS  emp_work_state,
---- adding lookup values 
finaddress.lfein :: CHAR(10) AS employer_fein, 
null :: CHAR(12) AS state_ein,
finaddress.fcompname ::CHAR(45) AS employer_name,
finaddress.faddress1 :: CHAR(40) AS employer_address1,
finaddress.faddress2 :: CHAR(40) AS employer_address2,    
' ' :: CHAR(40) AS employer_address3,
finaddress.fcity::CHAR(25) AS employer_city,
finaddress.fstate ::CHAR(2) AS employer_state,
finaddress.fzip:: CHAR(5) AS employer_zip_1,

null :: CHAR(4)  AS employer_zip_2,
null :: CHAR(42) AS filler1,
null :: CHAR(40) AS employer_opt_address1,
null :: CHAR(40) AS employer_opt_address2,
null :: CHAR(40) AS employer_opt_address3,
null :: CHAR(25) AS employer_opt_city,
null :: CHAR(2)  AS employer_opt_state,
null :: CHAR(5)  AS employer_opt_zip_1,
null :: CHAR(4)  AS employer_opt_zip_2,
null :: CHAR(42) AS filler2,
null :: CHAR(50) AS filler3,
ed.feedid,
current_timestamp AS updatets  


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
AND now() >= pa.effectivedate 
AND now() <= pa.enddate AND now() >= pa.createts 
AND now() <= pa.endts

LEFT JOIN person_employment pe
ON pe.personid = pi.personid
and pe.effectivedate < pe.enddate
AND current_timestamp BETWEEN pe.createts AND pe.endts

LEFT JOIN person_vitals pv ON pv.personid = pi.personid 
AND now() >= pv.effectivedate 
AND now() <= pv.enddate 
AND now() >= pv.createts 
AND now() <= pv.endts

LEFT JOIN person_locations pl 
  on pl.personid = pi.personid
and current_date between pl.effectivedate and pl.enddate
and current_timestamp between pl.createts and pl.endts

JOIN person_payroll pp
ON pp.personid = pi.personid
AND CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate
AND CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

JOIN pay_unit pu
ON pu.payunitid = pp.payunitid
AND CURRENT_TIMESTAMP BETWEEN pu.createts AND pu.endts


LEFT JOIN dxcompanyname dp
ON dp.companyid = pe.companyid 
AND current_date BETWEEN dp.effectivedate AND dp.enddate
AND current_timestamp BETWEEN dp.createts AND dp.endts

LEFT JOIN location_address la
ON la.locationid = pl.locationid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

LEFT JOIN edi.edi_last_update ed
  ON ed.feedid = 'NewHireReporting_IL'

LEFT JOIN  (select lp.lookupid,lp.key1 as lfein, value1 as faddress1, value2 as faddress2, value3 as fcity, value4 as fstate, value5 as fzip, value6 as fcompname
              from edi.lookup lp join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'IL FEIN Address' 
)finaddress on finaddress.lookupid is not null

where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
AND pa.addresstype = 'Res'
AND pu.employertaxid is not null  
AND current_timestamp BETWEEN pi.createts AND pi.endts
and  pe.emplstatus = 'A' and pe.empleventdetcode in ('RH','NHR') 

--check if someone has 2 active status events in reporting period 2018.10.10
AND pe.personid in (select personid from person_employment where emplstatus = 'A' 
									and current_date between effectivedate and enddate
									and current_timestamp between createts and endts) 

and ((pe.effectivedate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP)
    or (pe.createts > ed.lastupdatets and pe.effectivedate < coalesce(ed.lastupdatets, '2017-01-01') 
        and pe.effectivedate > coalesce(ed.lastupdatets, '2017-01-01') - interval '20 days') ) 

-- Terms who were hired/termed within timeperiod since last run
UNION
SELECT distinct  
pi.personid,
pi.identity,
'W4' :: CHAR(2) AS record_identifier,
pi2.identity :: CHAR(9) AS emp_ssn,
rtrim(ltrim(pn.fname)) :: CHAR(16) AS first_name,
rtrim(ltrim(pn.mname)) :: CHAR(16) AS middle_name,
rtrim(pn.lname) :: CHAR(30) AS emp_last_name,
rtrim(ltrim(pa.streetaddress)) :: CHAR(40) AS emp_address1,
rtrim(ltrim(pa.streetaddress2)) :: CHAR(40) AS emp_address2,
rtrim(ltrim(pa.streetaddress3)) :: CHAR(40) AS emp_address3,
rtrim(ltrim(pa.city)) :: CHAR(25) AS emp_city,
rtrim(ltrim(pa.stateprovincecode)) ::CHAR(2) AS emp_state,
rtrim(ltrim(pa.postalcode))  :: CHAR(5) AS emp_zip,
'' :: char(4) AS emp_zipplus_4,
'' :: char(42) AS blank1, 
to_char(pv.birthdate, 'yyyymmdd') :: CHAR(8) AS emp_dob,
to_char(pex.effectivedate,'yyyymmdd'):: CHAR(8) AS emp_doh,
la.stateprovincecode  :: CHAR(2) AS  emp_work_state,

finaddress.lfein :: CHAR(10) AS employer_fein, 
null :: CHAR(12) AS state_ein,
finaddress.fcompname ::CHAR(45) AS employer_name,
finaddress.faddress1 :: CHAR(40) AS employer_address1,
finaddress.faddress2 :: CHAR(40) AS employer_address2,    
' ' :: CHAR(40) AS employer_address3,
finaddress.fcity::CHAR(25) AS employer_city,
finaddress.fstate ::CHAR(2) AS employer_state,
finaddress.fzip:: CHAR(5) AS employer_zip_1,
null :: CHAR(4) AS employer_zip_2,
null :: CHAR(42) AS filler1,
null :: CHAR(40) AS employer_opt_address1,
null :: CHAR(40) AS employer_opt_address2,
null :: CHAR(40) AS employer_opt_address3,
null :: CHAR(25) AS employer_opt_city,
null :: CHAR(2) AS employer_opt_state,
null :: CHAR(5) AS employer_opt_zip_1,
null :: CHAR(4) AS employer_opt_zip_2,
null :: CHAR(42) AS filler2,
null :: CHAR(50) AS filler3,
ed.feedid,
current_timestamp AS updatets  


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

LEFT JOIN person_vitals pv ON pv.personid = pi.personid 
AND now() >= pv.effectivedate 
AND now() <= pv.enddate 
AND now() >= pv.createts 
AND now() <= pv.endts

LEFT JOIN person_locations pl 
  on pl.personid = pi.personid
and  pl.effectivedate < pl.enddate
and current_timestamp between pl.createts and pl.endts

JOIN person_payroll pp
ON pp.personid = pi.personid
AND pp.effectivedate < pp.enddate
AND CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

JOIN pay_unit pu
ON pu.payunitid = pp.payunitid
AND CURRENT_TIMESTAMP BETWEEN pu.createts AND pu.endts


LEFT JOIN dxcompanyname dp
ON dp.companyid = pe.companyid 
AND current_date BETWEEN dp.effectivedate AND dp.enddate
AND current_timestamp BETWEEN dp.createts AND dp.endts

LEFT JOIN location_address la
ON la.locationid = pl.locationid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

LEFT JOIN edi.edi_last_update ed
  ON ed.feedid = 'NewHireReporting_IL'
  
LEFT JOIN  (select lp.lookupid,lp.key1 as lfein, value1 as faddress1, value2 as faddress2, value3 as fcity, value4 as fstate, value5 as fzip, value6 as fcompname
              from edi.lookup lp join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'IL FEIN Address' 
)finaddress on finaddress.lookupid is not null

where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
AND pa.addresstype = 'Res'
AND pu.employertaxid is not null  
AND current_timestamp BETWEEN pi.createts AND pi.endts
and  pe.emplstatus = 'T' 
and pi.personid in (select personid 
                      from person_employment  
                     where emplstatus = 'A' 
                       and enddate < current_date
                       and current_timestamp between createts and endts
                       and personid in (select personid from person_employment pet 
                                         where emplstatus = 'T' 
                                           and current_date between effectivedate and enddate 
                                           and current_timestamp between createts and endts)
              		  and effectivedate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP
		and enddate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP
		and empleventdetcode in ('NHR','RH')
		and effectivedate < enddate)
order by emp_last_name



