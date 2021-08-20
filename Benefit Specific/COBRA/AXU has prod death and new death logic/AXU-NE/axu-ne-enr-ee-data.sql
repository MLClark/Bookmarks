select distinct

 pi.personid
,'ACTIVE EE ENR' ::varchar(30) as qsource
,'0' as dependentid
,pie.identity ::char(20)
,'3' ::char(1) as sort_seq
,'ENR' ::char(3) as recordtype

,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||right(pi.identity,4) ::char(12) as ssn
,to_char(pv.birthdate,'yyyy-mm-dd')::char(10) as dob
,pn.fname ::char(25) as fname
,pn.lname ::char(35) as lname
,pn.mname ::char(1)  as mname
,'Employee' ::char(10) as relation_code
,pa.streetaddress ::char(55) as addr1
,pa.streetaddress2::char(55) as addr2
,pa.city::char(35) as city
,pa.stateprovincecode::char(5) as state
,pa.postalcode::char(15) as zip
,case when pa.countrycode = 'US' then 'USA' else pa.countrycode end ::char(3) as country_code
,to_char(greatest(pbemed.effectivedate,pbednt.effectivedate,pbevsn.effectivedate,pbemfsa.effectivedate,pbedfsa.effectivedate),'YYYY-MM-DD') ::char(10) as insurance_effective_date



from person_identity pi

join person_identity pie
  on pie.personid = pi.personid
 and pie.identitytype = 'EmpNo'
 and current_timestamp between pie.createts and pie.endts
 
left join person_vitals pv
  on pv.personid = pi.personid
 and current_date between pv.effectivedate and pv.enddate
 and current_timestamp between pv.createts and pv.endts 

left join person_names pn
  on pn.personid = pi.personid
 and pn.nametype = 'Legal'
 and current_date between pn.effectivedate and pn.enddate
 and current_timestamp between pn.createts and pn.endts 
 
left join person_address pa
  on pa.personid = pi.personid
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts 


join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join person_bene_election pbe 
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('10','11','14','60','61')
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E' 
 and pbe.effectivedate - interval '1 day' <> pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
   -- to be qualified for cobra the emp must have participated in employer's health care plan  
 and pbe.personid in (select distinct personid from person_bene_election where current_timestamp between createts and endts 
                         and benefitsubclass in ('10','11','14','60','61') and benefitelection = 'E' and selectedoption = 'Y' and effectivedate < enddate)  
                         
left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election 
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and benefitsubclass in ('10')
              and benefitelection = 'E'
              and selectedoption = 'Y'
            GROUP BY personid ) as pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1    
 
left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election 
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and benefitsubclass in ('11')
              and benefitelection = 'E'
              and selectedoption = 'Y'
            GROUP BY personid ) as pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     

left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election 
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and benefitsubclass in ('14')
              and benefitelection = 'E'
              and selectedoption = 'Y'
            GROUP BY personid ) as pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1    

left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election 
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and benefitsubclass in ('60')
              and benefitelection = 'E'
              and selectedoption = 'Y'
            GROUP BY personid ) as pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1                         

left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election 
            WHERE enddate > effectivedate 
              AND current_timestamp BETWEEN createts AND endts
              and benefitsubclass in ('61')
              and benefitelection = 'E'
              and selectedoption = 'Y'
            GROUP BY personid ) as pbedfsa on pbedfsa.personid = pbe.personid and pbedfsa.rank = 1   
                          
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
  --and pe.personid = '2228'
 
 order by identity