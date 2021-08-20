select 
 pi.personid
,'MEMBER ADDR INFO RTYPE 220' ::varchar(40) as qsource
--,ppd.etv_id
,'220' ::char(3) as recordtype
,' '   ::char(1) as filler_4
,'805911' ::char(6) as contract_number
,' ' ::char(1) as filler_11
,pi.identity ::char(9) as employee_id_number
,' ' ::char(1) as filler_21
,'2' ::char(1) as foreign_addr_ind
,' ' ::char(1) as filler_23
,pa.streetaddress ::char(50) as addr1
,pa.streetaddress2 ::char(50) as addr2
,pa.streetaddress3 ::char(50) as addr3
,pa.city ::char(30) as city
,pa.stateprovincecode ::char(2) as state
,pa.postalcode ::char(9) as zip 
,' ' ::char(5) as zip_plus4 
,' ' ::char(1) as filler_26

 
from person_identity pi

join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts
 
left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate 
 and current_timestamp between pa.createts and pa.endts
 
join (select personid, max(effectivedate) as effectivedate, rank() over(partition by personid order by max(effectivedate) desc) as rank
        from person_deduction_setup where etvid in  ('VB1','VB2','VB3','VB4','VB5','V25','V65', 'VCQ') 
         and current_date between effectivedate and enddate
         and current_timestamp between createts and endts group by personid) pds on pds.personid = pi.personid
 
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and (pe.emplstatus in ('A','L') or (pe.emplstatus in ('T','R') and current_date - interval '60 days' <= pe.effectivedate))
  order by 1
