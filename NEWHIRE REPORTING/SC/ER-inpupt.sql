SELECT distinct-- 
replace(pu.employertaxid,'-','') :: char(11) as employer_fein,
--case when pu.payunitid = ppay.payunitid then pu.compname end :: char(40) as employer_name,
rtrim(ltrim('The Beach Company')) :: char(40) as employer_name,
rtrim(ltrim(CompAddress.CmpAddress)) :: char(30) as employer_address,
rtrim(ltrim(CompAddress.Cmpaddress2)) :: char(30) as employer_address2,
rtrim(ltrim(CompAddress.Cmpcity)) :: char(18) as employer_city,
rtrim(ltrim(CompAddress.CmpState)) :: char(2) as employer_state,
rtrim(ltrim(replace(CompAddress.CmpZipCode,'-',''))) :: char(9) as employer_zip,
null :: char(10) as phone, -- rtrim(ltrim(lpc.phoneno)) :: char(10) as phone,
null :: char(17) as blank_1,
'R' as RecordId,
'1' as sort_seq,

ed.feedid,
current_timestamp as updatets,
--la.locationid
null :: char(17) as LocationId


from person_identity pi

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

LEFT JOIN dxcompanyname dp
ON dp.companyid = pe.companyid 
AND current_date BETWEEN dp.effectivedate AND dp.enddate
AND current_timestamp BETWEEN dp.createts AND dp.endts

LEFT JOIN primarylocation pl
ON pl.personid = pe.personid
AND current_date BETWEEN pl.effectivedate AND pl.enddate
AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_codes lc
ON lc.locationid = pl.locationid
AND current_date between lc.effectivedate and lc.enddate
AND current_timestamp between lc.createts and lc.endts

LEFT JOIN location_address la
ON la.locaddrpid = pl.locaddrpid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

LEFT JOIN location_phone_contact lpc ON lpc.locationid = la.locationid 
--AND lpc.phonecontacttype =  
AND now() >= lpc.effectivedate 
AND now() <= lpc.enddate 
AND now() >= lpc.createts 
AND now() <= lpc.endts

LEFT JOIN  (select lp.lookupid, value1 as CmpAddress, value2 as Cmpaddress2, value3 as CmpCity, value4 as CmpState, value5 as CmpZipCode
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'SC Newhire Company Address' 
 )CompAddress on CompAddress.lookupid is not null


LEFT JOIN edi.edi_last_update ed
ON ed.feedid = 'NewHireReporting_SC'

where 

pe.empleventdetcode in('NHR','RH')
and  pe.emplstatus = 'A' 
and pu.compname is not null
--And la.streetaddress is not Null
--And la.stateprovincecode is not Null
AND current_timestamp BETWEEN pe.createts AND pe.endts
--check if someone has 2 active status events in reporting period 2018.10.10
AND pe.personid in (select personid from person_employment where emplstatus = 'A' 
									and current_date between effectivedate and enddate
									and current_timestamp between createts and endts)   
And ((pe.effectivedate between coalesce(ed.lastupdatets, '2017-01-01') and CURRENT_TIMESTAMP) 
    or (pe.createts > ed.lastupdatets and pe.effectivedate < coalesce(ed.lastupdatets, '2017-01-01') 
     and pe.effectivedate > coalesce(ed.lastupdatets, '2017-01-01') - interval '20 days') )


UNION 


SELECT distinct-- 
replace(pu.employertaxid,'-','') :: char(11) as employer_fein,
--case when pu.payunitid = ppay.payunitid then pu.compname end :: char(40) as employer_name,
rtrim(ltrim('The Beach Company')) :: char(40) as employer_name,
rtrim(ltrim(CompAddress.CmpAddress)) :: char(30) as employer_address,
rtrim(ltrim(CompAddress.Cmpaddress2)) :: char(30) as employer_address2,
rtrim(ltrim(CompAddress.Cmpcity)) :: char(18) as employer_city,
rtrim(ltrim(CompAddress.CmpState)) :: char(2) as employer_state,
rtrim(ltrim(replace(CompAddress.CmpZipCode,'-',''))) :: char(9) as employer_zip,
null :: char(10) as phone, -- rtrim(ltrim(lpc.phoneno)) :: char(10) as phone,
null :: char(17) as blank_1,
'R' as RecordId,
'1' as sort_seq,

ed.feedid,
current_timestamp as updatets,
--la.locationid
null :: char(17) as LocationId


from person_identity pi

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

LEFT JOIN dxcompanyname dp
ON dp.companyid = pe.companyid 
AND current_date BETWEEN dp.effectivedate AND dp.enddate
AND current_timestamp BETWEEN dp.createts AND dp.endts

LEFT JOIN primarylocation pl
ON pl.personid = pe.personid
AND current_date BETWEEN pl.effectivedate AND pl.enddate
AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN location_codes lc
ON lc.locationid = pl.locationid
AND current_date between lc.effectivedate and lc.enddate
AND current_timestamp between lc.createts and lc.endts

LEFT JOIN location_address la
ON la.locaddrpid = pl.locaddrpid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

LEFT JOIN location_phone_contact lpc ON lpc.locationid = la.locationid 
--AND lpc.phonecontacttype =  
AND now() >= lpc.effectivedate 
AND now() <= lpc.enddate 
AND now() >= lpc.createts 
AND now() <= lpc.endts

LEFT JOIN  (select lp.lookupid, value1 as CmpAddress, value2 as CmpAddress2, value3 as CmpCity, value4 as CmpState, value5 as CmpZipCode
from edi.lookup lp
join edi.lookup_schema els on lp.lookupid = els.lookupid and els.lookupname = 'SC Newhire Company Address' 
 )CompAddress on CompAddress.lookupid is not null


LEFT JOIN edi.edi_last_update ed
ON ed.feedid = 'NewHireReporting_SC'

where 
 pu.compname is not null
--And la.streetaddress is not Null
--And la.stateprovincecode is not Null
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

