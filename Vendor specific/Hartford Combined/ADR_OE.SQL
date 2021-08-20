Select distinct
 'ADR' ::char(3) AS recordtype
,'HAR' ::char(5)AS client
,PI.PERSONID
,PI.identity ::char(10) AS certnumber
,'00' ::char(2) AS relation
,'H' ::char(1) as type
,upper(pa.streetaddress )::char(35) as addr1
,upper(pa.streetaddress2)::char(35) as addr2
,' ' ::char(35) as addr3
,upper(pa.city)::char(30) as city
,upper(pa.countrycode)::char(2) as country
,upper(pa.stateprovincecode)::char(2) as state
,(pa.postalcode)::char(15) as zipcode
,' ' ::char(10) as maintdate

FROM person_identity PI 

JOIN person_bene_election pbe 
 on pbe.personid = pi.personid 
AND current_timestamp between pbe.createts and pbe.endts
and date_part('year',pbe.effectivedate) = date_part('year',current_date + interval '1 year')
AND pbe.benefitsubclass IN ( '1W','13','30','31' )
AND pbe.selectedoption = 'Y'
and pbe.benefitelection = 'E'

left join person_address pa
  on pa.personid = pbe.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts

WHERE PI.identitytype = 'SSN' 
 and current_timestamp between PI.createts and pi.endts
 and pi.personid = '12540'
 order by 4
