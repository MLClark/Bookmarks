select distinc
 pi.personid
,'W4' ::char(2) as recordid
,pi.identity ::char(9) as ssn
,pn.fname ::char(16) as fname
,pn.mname ::char(1) as mname
,pn.lname ::char(30) as lname
,pa.streetaddress ::char(40) as addr1
,pa.streetaddress2 ::char(40) as addr2
,pa.streetaddress3 ::char(40) as addr3
,pa.city ::char(25) as city
,pa.stateprovincecode ::char(2) as state
,replace(pa.postalcode,'-','') ::char(9) as zip
,' ' ::char(41) as filler
,pe.emplstatus
,to_char(pv.birthdate,'YYYYMMDD')::char(8) as dob
,to_char(pe.emplhiredate,'YYYYMMDD') ::char(8) as doh