select distinct

 pi.personid
,'0' as dependentid
,'Z' as relationship
,'267 employees' ::varchar(30) as qsource 
,case when pe.emplstatus = 'T' then 'D' 
      --when pbe.benefitelection = 'T' then 'D'
      when greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate) <= '2018-09-01' then 'C' 
      when greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate) >= '2018-09-01' then 'A'
      end ::char(1) as transaction_code
,'E' as emp_or_dep_code
,to_char(greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate), 'MMDDYYYY') as transaction_eff_date
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)  as emp_ssn
,rtrim(pn.lname)::varchar(50) as last_name
,rtrim(ltrim(pn.fname))::varchar(50) as first_name
,rtrim(ltrim(pn.mname))::char(1)  as middle_name
,pv.gendercode ::char(1) as gender
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)  as ssn
,to_char(pv.birthdate,'MMDDYYYY') ::char(8)  as dob
,to_char(pe.emplhiredate,'MMDDYYYY')::char(8)  as emp_doh
,rtrim(ltrim(pa.streetaddress))::varchar(50)  as emp_address
,rtrim(ltrim(pa.city))::varchar(50)  as emp_city
,rtrim(ltrim(pa.stateprovincecode))::char(2) as emp_state
,rtrim(ltrim(pa.postalcode))::char(9) as emp_zip
,rtrim(ltrim(ppch.phoneno,''))::varchar(10) as emp_phone

,case when pbemed.benefitsubclass = '10' then 'QVIMED' end ::varchar(10) as med_plan
,case when pbemed.benefitsubclass = '10' then to_char(pbemed.effectivedate,'MMDDYYYY') else ' ' end as med_cov_effdt
,case when bcdmed.benefitcoveragedesc = 'Employee Only' then 'EE' 
      when bcdmed.benefitcoveragedesc = 'Employee + Spouse' then 'EE+SP' 
      when bcdmed.benefitcoveragedesc = 'Employee + Children' then 'EE+CH'
      when bcdmed.benefitcoveragedesc = 'Family' then 'FAM'
       end ::varchar(10) as med_coverage

,case when pbeden.benefitsubclass = '11' then 'QVIDENT' end ::varchar(10) as dent_plan
,case when pbeden.benefitsubclass = '11' then to_char(pbeden.effectivedate,'MMDDYYYY') else ' ' end as dent_cov_effdt 
,case when bcdden.benefitcoveragedesc = 'Employee Only' then 'EE' 
      when bcdden.benefitcoveragedesc = 'Employee + Spouse' then 'EE+SP' 
      when bcdden.benefitcoveragedesc = 'Employee + Children' then 'EE+CH'
      when bcdden.benefitcoveragedesc = 'Family' then 'FAM'
       end ::varchar(10) as dent_coverage       
        
,case when pbevsn.benefitsubclass = '14' then 'QVIVIS' end ::varchar(10) as vision_plan
,case when pbevsn.benefitsubclass = '14' then to_char(pbevsn.effectivedate,'MMDDYYYY') else ' ' end as vsn_cov_effdt 
,case when bcdvsn.benefitcoveragedesc = 'Employee Only' then 'EE' 
      when bcdvsn.benefitcoveragedesc = 'Employee + Spouse' then 'EE+SP' 
      when bcdvsn.benefitcoveragedesc = 'Employee + Children' then 'EE+CH'
      when bcdvsn.benefitcoveragedesc = 'Family' then 'FAM'
       end ::varchar(10) as vision_coverage   
         
         
from person_identity pi

left join edi.edi_last_update elu on feedid = 'BCE_med_den_vision_QVI_Benefits'

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts

join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitsubclass in ('10','11','14')
 and pbe.effectivedate >= '2018-09-01'
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'  
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 
left join (select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('10') and date_part('year',effectivedate)>='2018' and benefitelection <> 'W' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid) pbemed on pbemed.personid = pbe.personid and pbemed.effectivedate >= '2018-09-01' and pbemed.rank = 1  
 
LEFT JOIN benefit_plan_desc bpdmed 
  on bpdmed.benefitsubclass = pbemed.benefitsubclass
 AND current_date between bpdmed.effectivedate and bpdmed.enddate
 AND current_timestamp between bpdmed.createts and bpdmed.endts
 
LEFT JOIN benefit_coverage_desc bcdmed 
  on bcdmed.benefitcoverageid = pbemed.benefitcoverageid 
 AND current_date between bcdmed.effectivedate and bcdmed.enddate
 AND current_timestamp between bcdmed.createts and bcdmed.endts
  
left join (select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('11') and date_part('year',effectivedate)>='2018' and benefitelection <> 'W' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid) pbeden on pbeden.personid = pbe.personid and pbeden.effectivedate >= '2018-09-01' and pbemed.rank = 1  

LEFT JOIN benefit_plan_desc bpdden  
  on bpdden.benefitsubclass = pbeden.benefitsubclass
 AND current_date between bpdden.effectivedate and bpdden.enddate
 AND current_timestamp between bpdden.createts and bpdden.endts

LEFT JOIN benefit_coverage_desc bcdden 
  on bcdden.benefitcoverageid = pbeden.benefitcoverageid 
 AND current_date between bcdden.effectivedate and bcdden.enddate
 AND current_timestamp between bcdden.createts and bcdden.endts
 
left join (select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('14') and date_part('year',effectivedate)>='2018' and benefitelection <> 'W' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.effectivedate >= '2018-09-01' and pbemed.rank = 1  

LEFT JOIN benefit_plan_desc bpdvsn 
  on bpdvsn.benefitsubclass = pbevsn.benefitsubclass
 AND current_date between bpdvsn.effectivedate and bpdvsn.enddate
 AND current_timestamp between bpdvsn.createts and bpdvsn.endts

LEFT JOIN benefit_coverage_desc bcdvsn
  on bcdvsn.benefitcoverageid = pbevsn.benefitcoverageid 
 AND current_date between bcdvsn.effectivedate and bcdvsn.enddate
 AND current_timestamp between bcdvsn.createts and bcdvsn.endts
    
LEFT JOIN person_names pn 
  ON pn.personid = pe.personid 
 AND pn.nametype = 'Legal'::bpchar 
 AND current_date between pn.effectivedate and pn.enddate
 AND current_timestamp between pn.createts and pn.endts

LEFT JOIN person_vitals pv 
  on pv.personid = pi.personid
 AND current_date between pv.effectivedate and pv.enddate
 AND current_timestamp between pv.createts and pv.endts

LEFT JOIN person_address pa
  ON pa.personid = pi.personid 
 and pa.addresstype = 'Res'
 and current_date between pa.effectivedate and pa.enddate
 and current_timestamp between pa.createts and pa.endts
 
LEFT JOIN person_phone_contacts ppch
  ON ppch.personid = pi.personid 
 AND ppch.phonecontacttype = 'Home' 
 and current_date between ppch.effectivedate and ppch.enddate
 and current_timestamp between ppch.createts and ppch.endts

WHERE pi.identitytype = 'SSN'
  AND CURRENT_TIMESTAMP BETWEEN pi.createts and pi.endts 
  and pe.emplstatus = 'A'

UNION

select distinct
 pi.personid
,pdr.dependentid
,pdr.dependentrelationship as relationship
,'121 dependents' ::varchar(30) as qsource
,case when pe.emplstatus = 'T' then 'D' 
      --when pbe.benefitelection = 'T' then 'D'
      when greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate) <= '2018-09-01' then 'C' 
      when greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate) >= '2018-09-01' then 'A'
      end ::char(1) as transaction_code
,'D' as emp_or_dep_code
,to_char(greatest(pbemed.effectivedate,pbeden.effectivedate,pbevsn.effectivedate), 'MMDDYYYY') as transaction_eff_date
,left(pi.identity,3)||'-'||substring(pi.identity,4,2)||'-'||substring(pi.identity,6,4)  as emp_ssn
,rtrim(ltrim(pnd.lname)) ::varchar(50) as last_name
,rtrim(ltrim(pnd.fname)) ::varchar(50) as first_name
,rtrim(ltrim(pnd.mname)) ::char(1)     as middle_name
,pvd.gendercode ::char(1) as gender
,left(pid.identity,3)||'-'||substring(pid.identity,4,2)||'-'||substring(pid.identity,6,4)  as  ssn
,to_char(pvd.birthdate, 'MMDDYYYY') ::char(8) as dob
,' ' ::char(1) as emp_doh
,' ' ::char(1) as emp_address
,' ' ::char(1) as emp_city
,' ' ::char(1) as emp_state
,' ' ::char(1) as emp_zip
,' ' ::char(1) as emp_phone
,case when demed.benefitsubclass = '10' then 'QVIMED' else null end ::varchar(15) as med_plan
,' ' ::char(1) as med_cov_effdt
,' ' ::CHAR(1) AS med_coverage
,case when dednt.benefitsubclass = '11' then 'QVIDENT' else null end ::varchar(15) as dent_plan
,' ' ::char(1) as dent_cov_effdt
,' ' ::CHAR(1) AS dent_coverage
,case when devsn.benefitsubclass = '14' then 'QVIVIS' else null end ::varchar(15) as vision_plan
,' ' ::char(1) as vsn_cov_effdt
,' ' ::CHAR(1) AS vision_coverage

from person_identity pi

left join edi.edi_last_update elu on feedid = 'BCE_med_den_vision_QVI_Benefits'

JOIN person_employment pe
  ON pe.personid = pi.personid
 AND current_date BETWEEN pe.effectivedate AND pe.enddate
 AND current_timestamp BETWEEN pe.createts AND pe.endts
 
join person_bene_election pbe
  on pbe.personid = pe.personid
 and pbe.benefitsubclass in ('10','11','14')
 and pbe.effectivedate >= '2018-09-01'
 and pbe.benefitelection = 'E'
 and pbe.selectedoption = 'Y'  
 and pbe.benefitcoverageid > '1'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts
 
left join (select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('10') and date_part('year',effectivedate)>='2018' and benefitelection <> 'W' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid) pbemed on pbemed.personid = pbe.personid and pbemed.effectivedate >= '2018-09-01' and pbemed.rank = 1  
 
left join (select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('11') and date_part('year',effectivedate)>='2018' and benefitelection <> 'W' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid) pbeden on pbeden.personid = pbe.personid and pbeden.effectivedate >= '2018-09-01' and pbeden.rank = 1  
 
left join (select personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from person_bene_election where benefitsubclass in ('14') and date_part('year',effectivedate)>='2018' and benefitelection <> 'W' and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, benefitelection, personbeneelectionpid, coverageamount, benefitcoverageid) pbevsn on pbevsn.personid = pbe.personid and pbevsn.effectivedate >= '2018-09-01' and pbevsn.rank = 1  

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and current_date between pdr.effectivedate and pdr.enddate
 and current_timestamp between pdr.createts and pdr.endts

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
 
JOIN dependent_enrollment de
  on de.personid = pdr.personid
 and de.dependentid = pdr.dependentid
 AND de.selectedoption = 'Y'
 and de.benefitsubclass = pbe.benefitsubclass
 and de.effectivedate < de.enddate
 and current_timestamp between de.createts and de.endts 

left join (select personid, benefitsubclass, dependentid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from dependent_enrollment where benefitsubclass in ('10') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, dependentid) demed on demed.personid = de.personid and demed.dependentid = de.dependentid and demed.rank = 1  
 
left join (select personid, benefitsubclass, dependentid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from dependent_enrollment where benefitsubclass in ('11') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, dependentid) dednt on dednt.personid = de.personid and dednt.dependentid = de.dependentid and dednt.rank = 1  
 
left join (select personid, benefitsubclass, dependentid, MAX(effectivedate) AS effectivedate, MAX(enddate) AS enddate,RANK() OVER (PARTITION BY personid ORDER BY MAX(effectivedate) DESC) AS RANK
             from dependent_enrollment where benefitsubclass in ('14') and selectedoption = 'Y' and current_timestamp between createts and endts and effectivedate < enddate
            group by personid, benefitsubclass, dependentid) devsn on devsn.personid = de.personid and devsn.dependentid = de.dependentid and devsn.rank = 1  
  

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pe.emplstatus = 'A'
  
order by 1, emp_ssn, emp_or_dep_code desc, relationship desc
--- Jacquelin Carrillo Mendoza has EE+SP coverage for her Dental and Vision