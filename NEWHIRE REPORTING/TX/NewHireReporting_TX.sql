SELECT --distinct  
pi.personid,
'W4' :: char(2) as record_type,
pi2.identity :: char(9) as emp_ssn,
rtrim(ltrim(pn.fname)) :: char(16) as emp_first_name,
rtrim(ltrim(pn.mname)) :: char(16) as emp_middle_name,
rtrim(pn.lname) :: char(30) as emp_last_name,
rtrim(ltrim(pa.streetaddress)) :: char(40) as emp_address1,
rtrim(ltrim(pa.streetaddress2)) :: char(40) as emp_address2,
rtrim(ltrim(pa.streetaddress3)) :: char(40) as emp_address3,
rtrim(ltrim(pa.city)) ::char(25) as emp_city,
rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state,
replace(pa.postalcode,'-','')  :: char(5) as emp_zip,
null :: char(4) as emp_zip_ext,
null::char(2) as employee_fo_country_code,
null::char(25) as employee_fo_country_name,
null::char(15) as employee_fo_zip_code,
to_char(pv.birthdate, 'yyyymmdd')::char(8) as emp_dob,

case when pe.empleventdetcode in ('RH','NHR') then to_char(pe.effectivedate,'yyyymmdd') end :: char(8) as hire_date,    

la.stateprovincecode  :: char(2) as  emp_hire_state,
replace(pu.employertaxid,'-','') :: char(9) as employer_fein,
seinlookup.sein::char(12) as empoyer_state_ein,
finaddress.fcompname ::char(45) as employer_name,
--dp.companyname ::char(45) as employer_name,
--pu.compname  ::char(45) as employer_name_1,
finaddress.faddress :: char(40) as employer_address1,
null:: char(40) as employer_address2,    
null:: char(40) as employer_address3,
finaddress.fcity::char(25) as employer_city,
finaddress.fstate::char(2) as employer_state,
--replace(la.postalcode,'-','') :: char(5) as employer_zip,
replace(finaddress.fzip,'-','') :: char(5) as employer_zip,
null::char(4) as employer_zip_ext,
null::char(2) as employer_foreign_country_code,
null::char(25) as employer_foreign_country_name,
null::char(15) as employer_foreign_country_zip,
null::char(40) as employer_optional_address1,
null::char(40) as employer_optional_address2,
null::char(40) as employer_optional_address3,
null::char(25) as employer_optional_city,
null::char(2) as employer_optional_state,
null::char(5) as employer_optional_zip1,
null::char(4) as employer_optional_zip2,
null::char(2) as employer_opt_fore_country_code,
null::char(25) as employer_opt_fore_country_name,
null::char(15) as employer_opt_fore_country_zip,
null::char(10) as filler_1,
/*case 
      when pc.frequencycode = 'H' then pc.compamount
      when pc.frequencycode = 'A' then (pc.compamount / 2080)
      end :: char(20) as emp_salary*/
--pc.compamount as employee_salary,
--to_char(pc.compamount * 100, '00000000000') :: char(11) as employee_salary,
lpad(round(pc.compamount*100) ::char(11),9,'0') as employee_salary,
--to_char(pc.compamount,'000000.00')::char(9) as employee_salary_1,
--to_char(pc.compamount,'000000.00')::char(10) as employee_salary_2,
pc.frequencycode as frequency,
null::char(30) as filler_2,
ed.feedid,
current_timestamp as updatets,
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
AND now() <= pa.enddate 
AND now() >= pa.createts 
AND now() <= pa.endts

--check if someone has 2 active status events in reporting period 2018.10.10
LEFT JOIN person_employment pe
ON pe.personid = pi.personid
and pe.effectivedate < pe.enddate
--AND current_date BETWEEN pe.effectivedate AND pe.enddate
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

LEFT JOIN person_payroll ppay ON ppay.personid = pi.personid 
 AND now() between ppay.effectivedate AND ppay.enddate 
 AND now() between ppay.createts AND ppay.endts 

LEFT JOIN pay_unit pu 
ON pu.payunitid = ppay.payunitid
AND CURRENT_TIMESTAMP BETWEEN pu.createts AND pu.endts

LEFT JOIN pspay_employee_profile pep ON pep.individual_key = pi.identity 
--AND CURRENT_TIMESTAMP BETWEEN pep.createts AND pep.endts

LEFT JOIN dxcompanyname dp
ON dp.companyid = pe.companyid 
AND current_date BETWEEN dp.effectivedate AND dp.enddate
AND current_timestamp BETWEEN dp.createts AND dp.endts

LEFT JOIN location_address la
ON la.locationid = pl.locationid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

left join person_compensation pc  
on pc.personid = pi.personid 
AND current_date BETWEEN pc.effectivedate AND pc.enddate
AND current_timestamp BETWEEN pc.createts AND pc.endts

LEFT JOIN (select l.lookupid, value1 as sein
from edi.lookup l
join edi.lookup_schema ls on l.lookupid = ls.lookupid and ls.lookupname = 'TX STATE EIN')
seinlookup on seinlookup.lookupid is not null

LEFT JOIN  (select lp.lookupid,lp.key1 as lfein, value1 as faddress, value3 as fcity, value4 as fstate, value5 as fzip, value6 as fcompname
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'TX FEIN Address' 
 )finaddress on finaddress.lfein = pu.employertaxid

LEFT JOIN edi.edi_last_update ed
  ON ed.feedid = 'NewHireReporting_TX'


where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
AND pa.addresstype = 'Res'
AND pu.employertaxid is not null  
AND current_timestamp BETWEEN pi.createts AND pi.endts
and  pe.emplstatus = 'A' 
and pe.empleventdetcode in ('RH','NHR') 

--check if someone has 2 active status events in reporting period 2018.10.10
AND pe.personid in (select personid from person_employment where emplstatus = 'A' 
									and current_date between effectivedate and enddate
									and current_timestamp between createts and endts)  

and ((pe.effectivedate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP) 
    or (pe.createts > ed.lastupdatets and pe.effectivedate < coalesce(ed.lastupdatets, '2017-01-01') 
		and pe.effectivedate > coalesce(ed.lastupdatets, '2017-01-01') - interval '20 days') )  

AND pu.employertaxid = finaddress.lfein
--TERMED EEMPLOYEES THAT FALL WITHIN THE TIME FRAME
UNION
SELECT --distinct  
pi.personid,
'W4' :: char(2) as record_type,
pi2.identity :: char(9) as emp_ssn,
rtrim(ltrim(pn.fname)) :: char(16) as emp_first_name,
rtrim(ltrim(pn.mname)) :: char(16) as emp_middle_name,
rtrim(pn.lname) :: char(30) as emp_last_name,
rtrim(ltrim(pa.streetaddress)) :: char(40) as emp_address1,
rtrim(ltrim(pa.streetaddress2)) :: char(40) as emp_address2,
rtrim(ltrim(pa.streetaddress3)) :: char(40) as emp_address3,
rtrim(ltrim(pa.city)) ::char(25) as emp_city,
rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state,
replace(pa.postalcode,'-','')  :: char(5) as emp_zip,
null :: char(4) as emp_zip_ext,
null::char(2) as employee_fo_country_code,
null::char(25) as employee_fo_country_name,
null::char(15) as employee_fo_zip_code,
to_char(pv.birthdate, 'yyyymmdd')::char(8) as emp_dob,
to_char(pex.effectivedate,'yyyymmdd')::char(8) as hire_date, 
la.stateprovincecode  :: char(2) as  emp_hire_state,
replace(pu.employertaxid,'-','') :: char(9) as employer_fein,
seinlookup.sein::char(12) as empoyer_state_ein,
finaddress.fcompname ::char(45) as employer_name,
--dp.companyname ::char(45) as employer_name,
--pu.compname  ::char(45) as employer_name_1,
finaddress.faddress :: char(40) as employer_address1,
null:: char(40) as employer_address2,    
null:: char(40) as employer_address3,
finaddress.fcity::char(25) as employer_city,
finaddress.fstate::char(2) as employer_state,
--replace(la.postalcode,'-','') :: char(5) as employer_zip,
replace(finaddress.fzip,'-','') :: char(5) as employer_zip,
null::char(4) as employer_zip_ext,
null::char(2) as employer_foreign_country_code,
null::char(25) as employer_foreign_country_name,
null::char(15) as employer_foreign_country_zip,
null::char(40) as employer_optional_address1,
null::char(40) as employer_optional_address2,
null::char(40) as employer_optional_address3,
null::char(25) as employer_optional_city,
null::char(2) as employer_optional_state,
null::char(5) as employer_optional_zip1,
null::char(4) as employer_optional_zip2,
null::char(2) as employer_opt_fore_country_code,
null::char(25) as employer_opt_fore_country_name,
null::char(15) as employer_opt_fore_country_zip,
null::char(10) as filler_1,
/*case 
      when pc.frequencycode = 'H' then pc.compamount
      when pc.frequencycode = 'A' then (pc.compamount / 2080)
      end :: char(20) as emp_salary*/
--pc.compamount as employee_salary,
--to_char(pc.compamount * 100, '00000000000') :: char(11) as employee_salary,
lpad(round(pc.compamount*100) ::char(11),9,'0') as employee_salary,
--to_char(pc.compamount,'000000.00')::char(9) as employee_salary_1,
--to_char(pc.compamount,'000000.00')::char(10) as employee_salary_2,
pc.frequencycode as frequency,
null::char(30) as filler_2,
ed.feedid,
current_timestamp as updatets
,pi.identity

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
AND now() <= pa.enddate 
AND now() >= pa.createts 
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

LEFT JOIN person_payroll ppay ON ppay.personid = pi.personid 
AND ppay.effectivedate < ppay.enddate
AND CURRENT_TIMESTAMP BETWEEN ppay.createts AND ppay.endts

LEFT JOIN pay_unit pu ON pu.payunitid = ppay.payunitid
AND CURRENT_TIMESTAMP BETWEEN pu.createts AND pu.endts

LEFT JOIN pspay_employee_profile pep ON pep.individual_key = pi.identity 
--AND CURRENT_TIMESTAMP BETWEEN pep.createts AND pep.endts

LEFT JOIN dxcompanyname dp
ON dp.companyid = pe.companyid 
AND current_date BETWEEN dp.effectivedate AND dp.enddate
AND current_timestamp BETWEEN dp.createts AND dp.endts

LEFT JOIN location_address la
ON la.locationid = pl.locationid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

left join person_compensation pc  
on pc.personid = pi.personid 
AND current_date BETWEEN pc.effectivedate AND pc.enddate
AND current_timestamp BETWEEN pc.createts AND pc.endts

LEFT JOIN (select l.lookupid, value1 as sein
from edi.lookup l
join edi.lookup_schema ls on l.lookupid = ls.lookupid and ls.lookupname = 'TX STATE EIN')
seinlookup on seinlookup.lookupid is not null

LEFT JOIN  (select lp.lookupid,lp.key1 as lfein, value1 as faddress, value3 as fcity, value4 as fstate, value5 as fzip, value6 as fcompname
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'TX FEIN Address' 
 )finaddress on finaddress.lfein = pu.employertaxid

LEFT JOIN edi.edi_last_update ed
  ON ed.feedid = 'NewHireReporting_TX'

where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
AND pa.addresstype = 'Res'
AND pu.employertaxid is not null  
AND current_timestamp BETWEEN pi.createts AND pi.endts
and  pe.emplstatus = 'T'  
and pi.personid in (select personid from person_employment  where emplstatus = 'A'  
						   and enddate < current_date 
						   and current_timestamp between createts and endts 
and personid in (select personid from person_employment pet where emplstatus = 'T' and current_date between effectivedate and enddate 
						and current_timestamp between createts and endts) 
						and effectivedate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP 
						and enddate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP 
						and empleventdetcode in ('NHR','RH') 
						and effectivedate < enddate) 
AND pu.employertaxid = finaddress.lfein
order by emp_last_name
