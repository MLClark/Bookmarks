select distinct
 pi.personid 
,'active ee ' ::varchar(30) as qsource
,'2' ::char(1) as sortseq
,'ADR' ::char(3) AS recordtype
,'HAR' ::char(5) AS client
,PI.identity ::char(10) AS certnumber
,'00' ::char(2) AS relation
,'H' ::char(1) as type
,upper(pa.streetaddress)::char(35) as addr1
,upper(pa.streetaddress2)::char(35) as addr2
,' ' ::char(35) as addr3
,upper(pa.city)::char(30) as city
,upper(pa.countrycode)::char(2) as country
,upper(pa.stateprovincecode)::char(2) as state
,(pa.postalcode)::char(15) as zipcode
,' ' ::char(10) as maintdate

 
from person_identity pi

JOIN person_employment pe 
  ON pe.personid = pi.personid
 AND current_date between pe.effectivedate and pe.enddate
 AND current_timestamp between pe.createts and pe.endts

join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 -- select * from person_address 
 
JOIN person_bene_election pbe 
  on pbe.personid = pi.personid 
 AND pbe.effectivedate < pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ('30','31' )
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('E')
 and pbe.effectivedate = '2019-01-01' 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'

 -- and pe.personid in ('10081','10166','10296','9707')
 order by 1  