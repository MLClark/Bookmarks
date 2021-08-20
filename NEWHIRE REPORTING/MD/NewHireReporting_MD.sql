SELECT distinct  
pi.personid,
'MD Newhire Record' :: char(17) as record_identifier,
'2.00' :: char(4) as format_number,
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

null :: char(4) as emp_zip_ext,
rtrim(ltrim(la.countrycode)) :: char(2) as country_code,
to_char(pv.birthdate,'yyyymmdd'):: char(8) as birth_date,

case when pe.empleventdetcode in ('RH','NHR') then to_char(pe.effectivedate,'yyyymmdd') end :: char(8) as hire_date,


la.stateprovincecode  :: char(2) as state_hire,
case when pbe.selectedoption = 'Y' then 'Y'
     when pbe.selectedoption = 'N' then 'N' 
     else '' 
end ::char(1)  as med_avail,
null :: char(1) as filler,
----
----employer section
replace(pu.employertaxid,'-','') :: char(9) as employer_fein,
--replace(puc.identification,'-','') :: char(10) as employer_suin,
--REPLACE(puc.identification,'-','') :: char(10) as employer_suin, 
lpad((REPLACE(puc.identification,'-','')),10,'0') :: char(10) as employer_suin, 
null :: char(2) as Filler, 
----
dp.companyname :: char(45) as employer_name,
--pu.compname :: char(45) as employer_name,
--cn.companyname :: char(45) as employer_name_1
rtrim(ltrim(la.streetaddress)) :: char(40) as employer_address1,
rtrim(ltrim(la.streetaddress2)) :: char(40) as employer_address2,
rtrim(ltrim(la.streetaddress3)) :: char(40) as employer_address3,

rtrim(ltrim(la.city)) :: char(25) as employer_city,
rtrim(ltrim(la.stateprovincecode)) :: char(2) as employer_state,

rtrim(ltrim(la.postalcode)) :: char(20) as employer_zip,
null :: char(4) as employer_zip_ext,
rtrim(ltrim(la.countrycode)) :: char(2) as country_code,

null :: char (10) as phone_number,
null :: char (6) as phone_ext,
null :: char (20) as employer_contact,
null :: char(211) as Filler1,
null :: char(1) as employee_gender,
null :: char (12) as Filler2,
null :: char(10) as employer_fax,
null :: char(50) as employer_email,

--case when pc.frequencycode in ('H')  and pc.compamount > 0 then lpad(round(pc.compamount * 2080 *100) ::char(10),9,'0') 
case when pc.frequencycode in ('H')  and pc.compamount > 0 then to_char(pc.compamount,'0000000d00') 
     else to_char(pc.compamount,'0000000d00') 
end as employee_salary,
--pc.frequencycode :: char(1) as employee_salary_frequency,
case when pc.frequencycode in ('H') then 'H'
	 else 'Y'
end :: char(1) as employee_salary_frequency,

'100' as calc,--used to calc salary with decimals
null :: char(12) as filler3,

---
ed.feedid,
ed.lastupdatets 


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
AND pa.addresstype in ( 'Res')
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

LEFT JOIN person_vitals pv
on pv.personid = pi.personid
AND now() >= pv.effectivedate 
AND now() <= pv.enddate 
AND now() >= pv.createts 
AND now() <= pv.endts

LEFT JOIN person_locations pl
ON pl.personid = pe.personid
AND current_date BETWEEN pl.effectivedate AND pl.enddate
AND current_timestamp BETWEEN pl.createts AND pl.endts

LEFT JOIN person_payroll pp
  ON pp.personid = pe.personid
 AND current_date BETWEEN pp.effectivedate AND pp.enddate
 AND current_timestamp BETWEEN pp.createts AND pp.endts      

JOIN pay_unit pu
ON pu.payunitid = pp.payunitid
AND CURRENT_TIMESTAMP BETWEEN pu.createts AND pu.endts

left join pay_unit_configuration puc
on pu.payunitid = puc.payunitid
AND current_date BETWEEN puc.effectivedate AND puc.enddate
AND CURRENT_TIMESTAMP BETWEEN puc.createts AND puc.endts

--
left join location_address la1 
ON la1.stateprovincecode = puc.stateprovincecode
--and la.locationid in (select locationid from company_location_rel where companylocationtype = 'M')
AND current_date BETWEEN la1.effectivedate AND la1.enddate
AND current_timestamp BETWEEN la1.createts AND la1.endts
--

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


LEFT JOIN person_bene_election pbe 
on pbe.personid = pi.personid 
AND pbe.benefitsubclass = '10'
AND now() >= pbe.effectivedate 
AND now() <= pbe.enddate AND now() >= pbe.createts 
AND now() <= pbe.endts

/*
LEFT JOIN  (select l.lookupid,l.key1 as puxid, value1 as sein
from edi.lookup l
join edi.lookup_schema ls on l.lookupid = ls.lookupid and ls.lookupname = 'MD STATE FEIN'
)seinid on seinid.puxid = pu.payunitxid
*/

LEFT JOIN edi.edi_last_update ed ON ed.feedid = 'NewHireReporting_MD'

where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
AND pa.addresstype in ('Res')
--AND pl.personlocationtype = 'P'
AND pu.employertaxid is not null  

and puc.stateprovincecode <> 'FED' 
and puc.payunitconfigurationtypeid = 2
and la.stateprovincecode = puc.stateprovincecode

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

--add terms who were hired/termed who fall into the timeframe since last run

UNION
SELECT distinct  
pi.personid,
'MD Newhire Record' :: char(17) as record_identifier,
'2.00' :: char(4) as format_number,
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

null :: char(4) as emp_zip_ext,
rtrim(ltrim(la.countrycode)) :: char(2) as country_code,
to_char(pv.birthdate,'yyyymmdd'):: char(8) as birth_date,

to_char(pex.effectivedate,'yyyymmdd'):: char(8) as hire_date,

la.stateprovincecode  :: char(2) as state_hire,
case when pbe.selectedoption = 'Y' then 'Y'
     when pbe.selectedoption = 'N' then 'N' 
     else '' 
end ::char(1)  as med_avail,
null :: char(1) as filler,
----
----employer section
replace(pu.employertaxid,'-','') :: char(9) as employer_fein,
--replace(puc.identification,'-','') :: char(10) as employer_suin, 
--REPLACE(puc.identification,'-','') :: char(10) as employer_suin, 
lpad((REPLACE(puc.identification,'-','')),10,'0') :: char(10) as employer_suin,
null :: char(12) as Filler, 
----
dp.companyname :: char(45) as employer_name,
--pu.compname :: char(45) as employer_name,
--cn.companyname :: char(45) as employer_name_1
rtrim(ltrim(la.streetaddress)) :: char(40) as employer_address1,
rtrim(ltrim(la.streetaddress2)) :: char(40) as employer_address2,
rtrim(ltrim(la.streetaddress3)) :: char(40) as employer_address3,

rtrim(ltrim(la.city)) :: char(25) as employer_city,
rtrim(ltrim(la.stateprovincecode)) :: char(2) as employer_state,

rtrim(ltrim(la.postalcode)) :: char(20) as employer_zip,
null :: char(4) as employer_zip_ext,
rtrim(ltrim(la.countrycode)) :: char(2) as country_code,

null :: char (10) as phone_number,
null :: char (6) as phone_ext,
null :: char (20) as employer_contact,
null :: char(211) as Filler1,
null :: char(1) as employee_gender,
null :: char (12) as Filler2,
null :: char(10) as employer_fax,
null :: char(50) as employer_email,

--case when pcterm1.frequencycode in ('H') and pcterm1.compamount > 0 then lpad(round(pcterm1.compamount * 2080 *100) ::char(10),9,'0') 
case when pcterm1.frequencycode in ('H') and pcterm1.compamount > 0 then to_char(pcterm1.compamount,'00000d00') 
     else to_char(pcterm1.compamount,'000000d00') 

end as employee_salary,
--pcterm1.frequencycode :: char(1) as employee_salary_frequency,
case when pcterm1.frequencycode in ('H') then 'H'
	 else 'Y'
end :: char(1) as employee_salary_frequency,

'100'  as calc,--used to calc salary with decimals

null :: char(12) as filler3,
---
ed.feedid,
ed.lastupdatets


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
AND pa.addresstype in ( 'Res')
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

--get termed employee's frequencycode,compamount to calculate salary
LEFT JOIN  (SELECT personid, frequencycode,compamount, effectivedate, enddate createts, endts, rank() over 
           (partition by personid order by effectivedate desc, createts desc) as rank 
   FROM person_compensation 
           WHERE effectivedate < enddate  
                     and current_timestamp between createts and endts 
                     ) pcterm1   ON pcterm1.rank = 1 and pcterm1.personid = pe.personid 


LEFT JOIN person_vitals pv
on pv.personid = pi.personid
AND now() >= pv.effectivedate 
AND now() <= pv.enddate 
AND now() >= pv.createts 
AND now() <= pv.endts

LEFT JOIN person_locations pl
ON pl.personid = pe.personid
and  pl.effectivedate < pl.enddate
and current_timestamp between pl.createts and pl.endts

LEFT JOIN person_payroll pp
ON pp.personid = pe.personid
AND pp.effectivedate < pp.enddate
AND CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts     

LEFT JOIN dxcompanyname dp
ON dp.companyid = pe.companyid 
AND current_date BETWEEN dp.effectivedate AND dp.enddate
AND current_timestamp BETWEEN dp.createts AND dp.endts

LEFT JOIN location_address la
ON la.locationid = pl.locationid
AND current_date BETWEEN la.effectivedate AND la.enddate
AND current_timestamp BETWEEN la.createts AND la.endts

JOIN pay_unit pu
ON pu.payunitid = pp.payunitid
AND CURRENT_TIMESTAMP BETWEEN pu.createts AND pu.endts

left join pay_unit_configuration puc
on pu.payunitid = puc.payunitid
AND current_date BETWEEN puc.effectivedate AND puc.enddate
AND CURRENT_TIMESTAMP BETWEEN puc.createts AND puc.endts

--
left join location_address la1 
ON la1.stateprovincecode = puc.stateprovincecode
--and la.locationid in (select locationid from company_location_rel where companylocationtype = 'M')
AND current_date BETWEEN la1.effectivedate AND la1.enddate
AND current_timestamp BETWEEN la1.createts AND la1.endts
--

left join person_compensation pc  
on pc.personid = pi.personid 
AND current_date BETWEEN pc.effectivedate AND pc.enddate
AND current_timestamp BETWEEN pc.createts AND pc.endts

LEFT JOIN person_bene_election pbe 
on pbe.personid = pi.personid 
AND pbe.benefitsubclass = '10'
AND now() >= pbe.effectivedate 
AND now() <= pbe.enddate AND now() >= pbe.createts 
AND now() <= pbe.endts

/*
LEFT JOIN  (select l.lookupid,l.key1 as puxid, value1 as sein
from edi.lookup l
join edi.lookup_schema ls on l.lookupid = ls.lookupid and ls.lookupname = 'IN STATE FEIN'
)seinid on seinid.puxid = pu.payunitxid
*/

LEFT JOIN edi.edi_last_update ed ON ed.feedid = 'NewHireReporting_MD'

where pi.identitytype = 'EmpNo'
and pi.identity is not NULL
AND pn.nametype = 'Legal'
AND pa.addresstype in ('Res')
--AND pl.personlocationtype = 'P'
AND pu.employertaxid is not null

and puc.stateprovincecode <> 'FED' 
and puc.payunitconfigurationtypeid = 2
and la.stateprovincecode = puc.stateprovincecode  

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
