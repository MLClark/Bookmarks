select distinct
 pi.personid 
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
 AND current_date between pbe.effectivedate and pbe.enddate
 AND current_timestamp between pbe.createts and pbe.endts
 AND pbe.benefitsubclass IN ( '1W','13','30','31' )
 AND pbe.selectedoption = 'Y'
 and pbe.benefitelection in ('T','E')
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ( '1W','13','30','31') and benefitelection = 'E' and selectedoption = 'Y')   

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus = 'T' and date_part('year',pe.effectivedate)=date_part('year',current_date)
       or pe.emplstatus = 'A')   
  and pi.personid = '12881'