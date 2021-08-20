SELECT distinct  
pi.personid,
'02' :: char(2) as record_identifier,
replace(pu.employertaxid,'-','') :: char(9) as employer_fein,
--elf.value1:: char(9) as employer_fein,
--dp.companyname ::char(30) as employer_name_1,
case when pu.payunitid = ppay.payunitid then pu.compname end :: char(45) as employer_name,
rtrim(ltrim(la.streetaddress)) :: char(40) as employer_address1,
rtrim(ltrim(la.streetaddress2)) :: char(40) as employer_address2,    
rtrim(ltrim(la.streetaddress3)) :: char(40) as employer_address3,
rtrim(ltrim(la.city)) ::char(25) as employer_city,
rtrim(ltrim(la.stateprovincecode)) ::char(2) as employer_state,
rtrim(ltrim(la.postalcode))  :: char(5) as employer_zip,
null :: char(4) as employer_zip_ext,
conlookup.cfirstname:: char(16) as employer_contact_firstname,
conlookup.clastname:: char(30) as employer_contact_lasttname,
conlookup.cphonenumber:: char(10) as employer_contact_phoneno,
null :: char(5) as employer_contact_phoneext,
--pi2.identity :: char(9) as emp_ssn,
lpad(cast(pi2.identity as CHAR(9)),9,'0') as emp_ssn,
rtrim(ltrim(pn.fname)) :: char(16) as emp_first_name,
rtrim(ltrim(pn.mname)) :: char(16) as emp_middle_initial,
rtrim(pn.lname) :: char(30) as emp_last_name,
to_char(pv.birthdate, 'yyyymmdd')::char(8) as emp_dob,
la.stateprovincecode  :: char(2) as  emp_hire_state,

--to_char(pe.emplhiredate,'yyyymmdd'):: char(8) as hire_date,	--HS05312018
case when pe.empleventdetcode in ('RH','NHR') then to_char(pe.effectivedate,'yyyymmdd') end :: char(8) as hire_date,   --HS05312018

rtrim(ltrim(pa.streetaddress)) :: char(40) as emp_address1,
rtrim(ltrim(pa.streetaddress2)) :: char(40) as emp_address2,
rtrim(ltrim(pa.streetaddress3)) :: char(40) as emp_address3,
rtrim(ltrim(pa.city)) ::char(25) as emp_city,
rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state,
--rtrim(ltrim(pa.postalcode))  :: char(9) as emp_zip,
replace(pa.postalcode,'-','')  :: char(5) as emp_zip,
null :: char(4) as emp_zip_ext,
null :: char(4)  as filler1,
null :: char(15)  as filler2,
lookup.feinlist,
ed.feedid,
pi.identity,
current_timestamp as updatets



from person_identity pi

LEFT JOIN person_names pn ON pn.personid = pi.personid 
AND pn.nametype = 'Legal'::bpchar 
AND now() >= pn.effectivedate 
AND now() <= pn.enddate 
AND now() >= pn.createts 
AND now() <= pn.endts

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

LEFT JOIN person_identity pi2 
ON pi.personid = pi2.personid
AND pi2.identitytype = 'SSN' ::bpchar 
AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts

LEFT JOIN person_address pa ON pa.personid = pi.personid 
AND pa.addresstype = 'Res'::bpchar 
AND now() >= pa.effectivedate 
AND now() <= pa.enddate AND now() >= pa.createts 
AND now() <= pa.endts

LEFT JOIN dxcompanyname dp
ON dp.companyid = pe.companyid 
AND current_date BETWEEN dp.effectivedate AND dp.enddate
AND current_timestamp BETWEEN dp.createts AND dp.endts

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


--LEFT JOIN location_address la on la.locationid = pl.locationid

LEFT JOIN person_payroll pp
ON pp.personid = pi.personid
AND current_date BETWEEN pp.effectivedate AND pp.enddate
AND current_timestamp BETWEEN pp.createts AND pp.endts

LEFT JOIN person_bene_election pbe on pbe.personid = pi.personid 
--and selectedoption = 'Y' 
AND now() >= pbe.effectivedate 
AND now() <= pbe.enddate AND now() >= pbe.createts 
AND now() <= pbe.endts 
 
LEFT JOIN (select l.lookupid, value1 as cfirstname, value2 as clastname, value3 as cphonenumber
from edi.lookup l
join edi.lookup_schema ls on l.lookupid = ls.lookupid and ls.lookupname = 'FEIN contact')
conlookup on conlookup.lookupid is not null


left join (              select l.lookupid, string_agg(''''||value1||'''', ',') as feinlist
from edi.lookup l
join edi.lookup_schema ls on l.lookupid = ls.lookupid and ls.lookupname = 'PA FEIN'
group by l.lookupid)  lookup
                on lookup.lookupid is not null
                

LEFT JOIN edi.edi_last_update ed
  ON ed.feedid = 'NewHireReporting_PA'

where pi.identitytype = 'EmpNo'
--and pi.identity is not NULL
AND pn.nametype = 'Legal'
AND pa.addresstype = 'Res'
AND current_timestamp BETWEEN pi.createts AND pi.endts
and  pe.emplstatus = 'A' and pe.empleventdetcode in ('RH', 'NHR')

--check if someone has 2 active status events in reporting period 2018.10.10
AND pe.personid in (select personid from person_employment where emplstatus = 'A' 
									and current_date between effectivedate and enddate
									and current_timestamp between createts and endts)

and ((pe.effectivedate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP) 				--HS05312018
    or (pe.createts > ed.lastupdatets and pe.effectivedate < coalesce(ed.lastupdatets, '2017-01-01') and    --HS05312018
        pe.effectivedate > coalesce(ed.lastupdatets, '2017-01-01') - interval '20 days') )                  --HS05312018

--HS05312018 Start
--and ((pe.effectivedate+30 >= coalesce(ed.lastupdatets, '2017-01-01'))
--and pe.createts > ed.lastupdatets ) */


UNION 


SELECT distinct  
pi.personid,
'02' :: char(2) as record_identifier,
replace(pu.employertaxid,'-','') :: char(9) as employer_fein,
--elf.value1:: char(9) as employer_fein,
--dp.companyname ::char(30) as employer_name_1,
case when pu.payunitid = ppay.payunitid then pu.compname end :: char(45) as employer_name,
rtrim(ltrim(la.streetaddress)) :: char(40) as employer_address1,
rtrim(ltrim(la.streetaddress2)) :: char(40) as employer_address2,    
rtrim(ltrim(la.streetaddress3)) :: char(40) as employer_address3,
rtrim(ltrim(la.city)) ::char(25) as employer_city,
rtrim(ltrim(la.stateprovincecode)) ::char(2) as employer_state,
rtrim(ltrim(la.postalcode))  :: char(5) as employer_zip,
null :: char(4) as employer_zip_ext,
conlookup.cfirstname:: char(16) as employer_contact_firstname,
conlookup.clastname:: char(30) as employer_contact_lasttname,
conlookup.cphonenumber:: char(10) as employer_contact_phoneno,
null :: char(5) as employer_contact_phoneext,
--pi2.identity :: char(9) as emp_ssn,
lpad(cast(pi2.identity as CHAR(9)),9,'0') as emp_ssn,
rtrim(ltrim(pn.fname)) :: char(16) as emp_first_name,
rtrim(ltrim(pn.mname)) :: char(16) as emp_middle_initial,
rtrim(pn.lname) :: char(30) as emp_last_name,
to_char(pv.birthdate, 'yyyymmdd')::char(8) as emp_dob,
la.stateprovincecode  :: char(2) as  emp_hire_state,

--to_char(pe.emplhiredate,'yyyymmdd'):: char(8) as hire_date,	--HS05312018
to_char(pex.effectivedate,'yyyymmdd')::char(8) as hire_date,    --HS05312018

rtrim(ltrim(pa.streetaddress)) :: char(40) as emp_address1,
rtrim(ltrim(pa.streetaddress2)) :: char(40) as emp_address2,
rtrim(ltrim(pa.streetaddress3)) :: char(40) as emp_address3,
rtrim(ltrim(pa.city)) ::char(25) as emp_city,
rtrim(ltrim(pa.stateprovincecode)) ::char(2) as emp_state,
--rtrim(ltrim(pa.postalcode))  :: char(9) as emp_zip,
replace(pa.postalcode,'-','')  :: char(5) as emp_zip,
null :: char(4) as emp_zip_ext,
null :: char(4)  as filler1,
null :: char(15)  as filler2,
lookup.feinlist,
ed.feedid,
pi.identity,
current_timestamp as updatets



from person_identity pi

LEFT JOIN person_names pn ON pn.personid = pi.personid 
AND pn.nametype = 'Legal'::bpchar 
AND now() >= pn.effectivedate 
AND now() <= pn.enddate 
AND now() >= pn.createts 
AND now() <= pn.endts

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

LEFT JOIN person_identity pi2 
ON pi.personid = pi2.personid
AND pi2.identitytype = 'SSN' ::bpchar 
AND CURRENT_TIMESTAMP BETWEEN pi2.createts and pi2.endts

LEFT JOIN person_address pa ON pa.personid = pi.personid 
AND pa.addresstype = 'Res'::bpchar 
AND now() >= pa.effectivedate 
AND now() <= pa.enddate AND now() >= pa.createts 
AND now() <= pa.endts

LEFT JOIN dxcompanyname dp
ON dp.companyid = pe.companyid 
AND current_date BETWEEN dp.effectivedate AND dp.enddate
AND current_timestamp BETWEEN dp.createts AND dp.endts

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


--LEFT JOIN location_address la on la.locationid = pl.locationid

LEFT JOIN person_payroll pp
ON pp.personid = pi.personid
AND current_date BETWEEN pp.effectivedate AND pp.enddate
AND current_timestamp BETWEEN pp.createts AND pp.endts

LEFT JOIN person_bene_election pbe on pbe.personid = pi.personid 
--and selectedoption = 'Y' 
AND now() >= pbe.effectivedate 
AND now() <= pbe.enddate AND now() >= pbe.createts 
AND now() <= pbe.endts 
 
LEFT JOIN (select l.lookupid, value1 as cfirstname, value2 as clastname, value3 as cphonenumber
from edi.lookup l
join edi.lookup_schema ls on l.lookupid = ls.lookupid and ls.lookupname = 'FEIN contact')
conlookup on conlookup.lookupid is not null


left join (              select l.lookupid, string_agg(''''||value1||'''', ',') as feinlist
from edi.lookup l
join edi.lookup_schema ls on l.lookupid = ls.lookupid and ls.lookupname = 'PA FEIN'
group by l.lookupid)  lookup
                on lookup.lookupid is not null
                

LEFT JOIN edi.edi_last_update ed
  ON ed.feedid = 'NewHireReporting_PA'

where pi.identitytype = 'EmpNo'
--and pi.identity is not NULL
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
order by emp_last_name 



--and ((pe.effectivedate+30 >= coalesce(ed.lastupdatets, '2017-01-01'))
--and pe.createts > ed.lastupdatets ) 
--HS05312018 End   



