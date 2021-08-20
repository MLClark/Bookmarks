 select distinct

 pi.personid
,pu.payunitdesc
,pu.payunitxid 
,'02' ::char(2) as recordtype
,'ACTIVE ELIGIBLE EE'   ::varchar(50) as qsource
,lc.locationcode ::char(5) as location -- use business unit (org structure)
,' ' ::char(5) as sub_company_nbr
,' ' ::char(5) as group_code
,pi.identity ::char(9) as ssn
,pn.title ::char(5) as title
,pn.fname ::char(15) as fname
,' ' ::char(5) as fillers
,pn.mname ::char(1) as mname
,pn.lname ::char(20) as lname 
,' ' ::char(4) as suffix
,cast(0.00 as dec(10,2)) as EEPreTax
,cast(0.00 as dec(10,2)) as EEPreTaxCatch_up
,cast(0.00 as dec(10,2)) as EERoth
,cast(0.00 as dec(10,2)) as EERothCatch_up
,cast(0.00 as dec(10,2)) as EEPostTax
,cast(0.00 as dec(10,2)) as EEMandatoryAfterTax
,cast(0.00 as dec(10,2)) as ERMatch
,cast(0.00 as dec(10,2)) as ERNonMatch
,cast(0.00 as dec(10,2)) as ERSafeHarborMatch
,cast(0.00 as dec(10,2)) as ERSafeHarborNonMatch
,cast(0.00 as dec(10,2)) as ERMoneyPurchase
,cast(0.00 as dec(10,2)) as ERFullyVestedMoneyPurchase
,cast(0.00 as dec(10,2)) as ERPrevailingWage
,cast(0.00 as dec(10,2)) as QMAC
,cast(0.00 as dec(10,2)) as QNEC
,cast(0.00 as dec(10,2)) as LoanRepayments
,cast(0.00 as dec(10,2)) as CompensationYTD
,cast(0.00 as dec(10,2)) as ExcludedCompensationYTD
,cast(0.00 as dec(4,0))  as HoursWorkedYTD

,case when pa.countrycode = 'US' then '1' else '0' end ::char(1) as IsUSAddress
,pa.streetaddress ::char(33) as addr1
,pa.streetaddress2 ::char(33) as addr2
,pa.city ::char(25) as city
,case when pa.stateprovincecode in ('CH','FR') then 'VI' else pa.stateprovincecode end ::char(2) as state
,pa.postalcode ::char(5) as zip
,' ' ::char(25) as INTLCityProvice
,' ' ::char(10) as INTLZipPostalCode
,' ' ::char(20) as INTLCountry
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(least(pe.effectivedate,pe.emplservicedate,pe.emplhiredate),'YYYYMMDD') ::char(8) as doh
,case when pe.emplstatus = 'T' then to_char(pe.effectivedate,'YYYYMMDD') else ' ' end ::char(8) as dot
--,pe.emplstatus
--,pe.emplhiredate
--,pe.effectivedate
--,pe.emplservicedate
--,pe.empllasthiredate
--,pe.emplevent
,case when pe.emplevent = 'Rehire' then to_char(pe.empllasthiredate,'YYYYMMDD') else ' ' end ::char(8) as dor
,cast(0.00 as dec(10,2)) as ERQACANon_Elective
,cast(0.00 as dec(10,2)) as ERQACAMatch
,cast(0.00 as dec(10,2)) as ERALTMatch
,cast(0.00 as dec(10,2)) as ERALTProfitSharing
,cast(0.00 as dec(10,2)) as ERALTMoneyPurchase
,cast(0.00 as dec(10,2)) as total_payroll_amount

,'01' ::char(2) as hdr_recordtype
,'PeopleStrategy' ::char(30) as hdr_vendorname 
,to_char(current_timestamp,'YYYYMMDDhhmmss')::char(14) as hdr_file_create_dt
,'809180' ::char(9) as hdr_contractid
,'00000' ::char(5) as hdr_subid
,'0' ::char(1) as hdr_ismep
,'Strategic Link' ::char(40) as hdr_company_name
,to_char(?::date,'yyyymmdd') ::char(8) as hdr_check_date
,'0' ::char(1) as hdr_deposit_method
,' ' ::char(26) as hdr_ach_number
,' ' ::char(8) as hdr_mode --- validate for test blank for prod

from person_identity pi

join person_identity pip
  on pip.personid = pi.personid
 and pip.identitytype = 'PSPID'
 and current_timestamp between pip.createts and pip.endts
 
join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_address pa 
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts
   
LEFT JOIN person_payroll pp 
  on pp.personid = pi.personid 
 and CURRENT_DATE BETWEEN pp.effectivedate AND pp.enddate 
 and CURRENT_TIMESTAMP BETWEEN pp.createts AND pp.endts

left join person_locations pl
  on pl.personid = pi.personid
 and current_date between pl.effectivedate and pl.enddate
 and current_timestamp between pl.createts and pl.endts
 
left join location_codes lc
  on lc.locationid = pl.locationid
 and current_date between lc.effectivedate and lc.enddate
 and current_timestamp between lc.createts and lc.endts  

LEFT JOIN pay_unit pu 
   ON pu.payunitid = pp.payunitid
  AND current_timestamp between pu.createts and pu.endts
  -- select * from pay_unit
   
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus not in ('T','R')
  and pu.payunitxid in ('00','05')
  and pe.personid not in 
  (select personid from pspay_payment_detail ppd where ppd.check_date = ?::DATE and ppd.group_key in ('AYV00','AYV05')  and ppd.etv_id in ('V65','VB1','VB2','VB3','VB4','VB5') group by 1)