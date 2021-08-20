select distinct

 pi.personid
,'11 ACTIVE EE ENR' ::varchar(30) as qsource
,'0' as dependentid
,pie.identity ::char(20)
,'3A' ::char(10) as sort_seq
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
,to_char(greatest(pbemed.effectivedate,pbednt.effectivedate,pbevsn.effectivedate,pbemfsa.effectivedate),'YYYY-MM-DD') ::char(10) as insurance_effective_date



from person_identity pi

left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join (select effcovdate.personid,effcovdate.benefitsubclass,effcovdate.min_effectivedate
        from (select pbe.personid,pbe.benefitsubclass,min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
                from person_bene_election pbe
               where pbe.benefitsubclass in ('10','11','14','60')
                 and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' group by 1,2) effcovdate
       left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
      where effcovdate.min_effectivedate = effcovdate.max_effectivedate
        and effcovdate.min_effectivedate >= elu.lastupdatets) pbene on pbene.personid = pe.personid

JOIN person_bene_election pbe 
  on pbe.personid = pbene.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and pbe.benefitsubclass in ('10','11','14','60')
 and current_date between pbe.effectivedate and pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.effectivedate >= elu.lastupdatets::DATE 
                         
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
          
left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election 
             left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
            WHERE current_date between effectivedate and enddate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate >= elu.lastupdatets
              and benefitelection = 'E'
              and selectedoption = 'Y'
              and benefitsubclass in ('10')              
            GROUP BY personid ) as pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1    
 
left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election                   
             left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
            WHERE current_date between effectivedate and enddate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate >= elu.lastupdatets
              and benefitelection = 'E'
              and selectedoption = 'Y'
              and benefitsubclass in ('11')
            GROUP BY personid ) as pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     

left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election 
             left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
            WHERE current_date between effectivedate and enddate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate >= elu.lastupdatets
              and benefitelection = 'E'
              and selectedoption = 'Y'
              and benefitsubclass in ('14')
            GROUP BY personid ) as pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1    

left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election 
             left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
            WHERE current_date between effectivedate and enddate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate >= elu.lastupdatets
              and benefitelection = 'E'
              and selectedoption = 'Y'
              and benefitsubclass in ('60')
            GROUP BY personid ) as pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1                         
                         
where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
 --and pe.personid = '1006'
 
 UNION 
 
select distinct

 pi.personid
,'3 ACTIVE DEP ENR' ::varchar(30) as qsource
,pdr.dependentid ::char(9) as dependentid
,pie.identity ::char(20)
,case when pdr.dependentrelationship in ('SP','DP','NA') then '3B' else '3C' end ::char(10) as sort_seq
,'ENR' ::char(3) as recordtype

,left(pid.identity,3)||'-'||substring(pid.identity,4,2)||'-'||right(pid.identity,4) ::char(12) as ssn
,to_char(pvd.birthdate,'yyyy-mm-dd')::char(10) as dob
--,pn.name ::char(25) as ename

,pnd.fname ::char(25) as fname
,pnd.lname ::char(35) as lname
,pnd.mname ::char(1)  as mname

,case when pdr.dependentrelationship in ('SP','DP','NA') then 'Spouse' else 'Dependent' end  ::char(10) as relation_code
,pa.streetaddress ::char(55) as addr1
,pa.streetaddress2::char(55) as addr2
,pa.city::char(35) as city
,pa.stateprovincecode::char(5) as state
,pa.postalcode::char(15) as zip
,case when pa.countrycode = 'US' then 'USA' else pa.countrycode end ::char(3) as country_code
,to_char(greatest(pbemed.effectivedate,pbednt.effectivedate,pbevsn.effectivedate,pbemfsa.effectivedate),'YYYY-MM-DD') ::char(10) as insurance_effective_date

from person_identity pi


left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'

join person_employment pe
  on pe.personid = pi.personid
 and current_date between pe.effectivedate and pe.enddate
 and current_timestamp between pe.createts and pe.endts

join (select effcovdate.personid,effcovdate.benefitsubclass,effcovdate.min_effectivedate
        from (select pbe.personid,pbe.benefitsubclass,min(pbe.effectivedate) as min_effectivedate,max(pbe.effectivedate) as max_effectivedate
                from person_bene_election pbe
               where pbe.benefitsubclass in ('10','11','14','60')
                 and pbe.selectedoption = 'Y' and pbe.benefitelection = 'E' group by 1,2) effcovdate
       left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
      where effcovdate.min_effectivedate = effcovdate.max_effectivedate
        and effcovdate.min_effectivedate >= elu.lastupdatets) pbene on pbene.personid = pe.personid

JOIN person_bene_election pbe 
  on pbe.personid = pbene.personid 
 and pbe.selectedoption = 'Y' 
 and pbe.benefitelection = 'E'
 and pbe.benefitsubclass in ('10','11','14','60')
 and current_date between pbe.effectivedate and pbe.enddate 
 AND current_timestamp between pbe.createts AND pbe.endts
 and pbe.effectivedate >= elu.lastupdatets::DATE 
                     
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
left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election 
             left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
            WHERE current_date between effectivedate and enddate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate >= elu.lastupdatets
              and benefitelection = 'E'
              and selectedoption = 'Y'
              and benefitsubclass in ('10')              
            GROUP BY personid ) as pbemed on pbemed.personid = pbe.personid and pbemed.rank = 1    
 
left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election                   
             left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
            WHERE current_date between effectivedate and enddate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate >= elu.lastupdatets
              and benefitelection = 'E'
              and selectedoption = 'Y'
              and benefitsubclass in ('11')
            GROUP BY personid ) as pbednt on pbednt.personid = pbe.personid and pbednt.rank = 1     

left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election 
             left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
            WHERE current_date between effectivedate and enddate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate >= elu.lastupdatets
              and benefitelection = 'E'
              and selectedoption = 'Y'
              and benefitsubclass in ('14')
            GROUP BY personid ) as pbevsn on pbevsn.personid = pbe.personid and pbevsn.rank = 1    

left join (SELECT personid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate, 
                  RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             FROM person_bene_election 
             left join edi.edi_last_update elu on elu.feedid = 'AXU_Infinisource_Cobra_NE_Export'
            WHERE current_date between effectivedate and enddate 
              AND current_timestamp BETWEEN createts AND endts
              and effectivedate >= elu.lastupdatets
              and benefitelection = 'E'
              and selectedoption = 'Y'
              and benefitsubclass in ('60')
            GROUP BY personid ) as pbemfsa on pbemfsa.personid = pbe.personid and pbemfsa.rank = 1                           

----- dependent data 
join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts
 
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 and current_date >= de.effectivedate 
 and current_timestamp between de.createts and de.endts 

LEFT JOIN person_identity pid
  ON pid.personid = pdr.dependentid
 AND pid.identitytype = 'SSN'::bpchar 
 and current_timestamp between pid.createts and pid.endts

LEFT JOIN person_names pnd 
  ON pnd.personid = pdr.dependentid 
 and pnd.nametype = 'Dep' 
 and current_date between pnd.effectivedate and pnd.enddate
 and current_timestamp between pnd.createts and pnd.endts

LEFT JOIN person_vitals pvd
  ON pvd.personid = pdr.dependentid 
 and current_date between pvd.effectivedate and pvd.enddate
 and current_timestamp between pvd.createts and pvd.endts
 

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts 
  and pe.emplstatus = 'A'
 
 order by PERSONID, IDENTITY, SORT_SEQ             