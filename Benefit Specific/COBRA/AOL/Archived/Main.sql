SELECT distinct
pi.personid,
pi2.identity AS SSN,
rtrim(ltrim(pn.fname)) AS FirstName,
rtrim(ltrim(upper(substring(pn.mname from 1for 1)))) AS MiddleInitial,
rtrim(ltrim(pn.lname)) AS LastName,
coalesce(rtrim(ltrim(ppc1.phoneno)),rtrim(ltrim(ppc2.phoneno)))::varchar(10) as phone,
to_char(pe.emplhiredate, 'MM/dd/YYYY')::char(10) as hiredate,
rtrim(ltrim(pa.streetaddress)) AS Address,
rtrim(ltrim(pa.streetaddress2)) AS Address2,
rtrim(ltrim(pa.city)) as City,
rtrim(ltrim(pa.stateprovincecode)) as StateOrProvince,
rtrim(ltrim(pa.postalcode)) as PostalCode,
rtrim(ltrim(pa.countrycode)) as Country,
--pbe.benefitsubclass,
rtrim(ltrim(pv.gendercode)) as Gender,
rtrim(ltrim(pv2.gendercode)) as SpouseGender,
pi3.identity AS SpouseSSN,

to_char(pv2.birthdate, 'MM/dd/YYYY')::char(10) as Spousedob,

to_char(pv.birthdate, 'MM/dd/YYYY')::char(10) as dob,
--dp.dependentid,dp.benefitplanid, dp.benefitsubclass as dependent_subclass,
pn2.fname as dependentfirst,
pn2.lname as dependentlast,
CURRENT_TIMESTAMP as Last_Update_Date,
pdr.dependentrelationship,
' '  as feedid

FROM person_identity pi
JOIN identity_types it ON pi.identitytype = it.identitytype 
 AND current_timestamp between pi.createts AND pi.endts
LEFT JOIN person_identity pi2 
  ON pi.personid = pi2.personid AND pi2.identitytype = 'SSN'::bpchar 
  AND current_timestamp between pi2.createts AND pi2.endts
  
LEFT JOIN person_names pn 
  ON pn.personid = pi.personid AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate AND pn.enddate 
 AND current_timestamp between pn.createts AND pn.endts
LEFT JOIN person_address pa 
 ON pa.personid = pi.personid AND pa.addresstype = 'Res'::bpchar 
AND current_date between pa.effectivedate AND pa.enddate 
AND current_timestamp between pa.createts AND pa.endts
LEFT JOIN person_phone_contacts ppc1 
 ON ppc1.personid = pi.personid AND ppc1.phonecontacttype = 'BUSN' 
AND current_date between ppc1.effectivedate AND ppc1.enddate 
AND current_timestamp between ppc1.createts AND ppc1.endts
LEFT JOIN person_phone_contacts ppc2 
 ON ppc2.personid = pi.personid AND ppc2.phonecontacttype = 'Home' 
AND current_date between ppc2.effectivedate AND ppc2.enddate 
AND current_timestamp between ppc2.createts AND ppc2.endts
LEFT JOIN person_vitals pv 
 ON pv.personid = pi.personid 
AND current_date between pv.effectivedate AND pv.enddate 
AND current_timestamp between pv.createts AND pv.endts

JOIN person_bene_election pbe 
 on pbe.personid = pi.personid 
and benefitelection = 'E' 
and selectedoption = 'Y' 
AND current_date between pbe.effectivedate AND pbe.enddate 
AND current_timestamp between pbe.createts AND pbe.endts
JOIN comp_plan_benefit_plan cpbp 
 on cpbp.compplanid = pbe.compplanid 
and pbe.benefitsubclass = cpbp.benefitsubclass 
AND current_date between cpbp.effectivedate AND cpbp.enddate 
AND current_timestamp between cpbp.createts AND cpbp.endts
JOIN person_employment pe 
 ON pe.personid = pi.personid 
AND current_date between pe.effectivedate AND pe.enddate 
AND current_timestamp between pe.createts AND pe.endts

left JOIN person_dependent_relationship pdr 
 on pi.personid = pdr.personid 
AND current_date between pdr.effectivedate AND pdr.enddate 
AND current_timestamp between pdr.createts AND pdr.endts 
AND pdr.dependentrelationship = 'SP'

LEFT JOIN person_names pn2 
 ON pn2.personid = pdr.dependentid 
AND current_date between pn2.effectivedate AND pn2.enddate 
AND current_timestamp between pn2.createts AND pn2.endts

LEFT JOIN person_identity pi3 
  ON pdr.personid = pi3.personid AND pi3.identitytype = 'SSN'::bpchar 
 AND current_timestamp between pi3.createts AND pi3.endts

LEFT JOIN person_vitals pv2 
  ON pv2.personid = pdr.personid 
 AND current_date between pv2.effectivedate AND pv2.enddate 
 AND current_timestamp between pv2.createts AND pv2.endts

LEFT JOIN dependent_enrollment dp 
  on dp.dependentid = pdr.dependentid 
 AND current_date between dp.effectivedate AND dp.enddate 
 AND current_timestamp between dp.createts AND dp.endts
LEFT JOIN edi.edi_last_update lu on lu.feedid = 'AOL_COBRASimple_COBRA_Employee'


WHERE pi.identitytype = 'EmpNo' 
  and pn.nametype = 'Legal' 
  and cpbp.cobraplan = 'Y'


AND (pbe.createts::DATE >= coalesce(lu.lastupdatets, '2010-01-01')
OR pa.effectivedate >= coalesce(lu.lastupdatets, '2010-01-01')
OR dp.createts::DATE >= coalesce(lu.lastupdatets, '2010-01-01'))

order by pi.personid,LastName


-- 476

