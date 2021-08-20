
select distinct
 pi.personid
,'C' ::char(1) as transaction_code
,'D' as emp_or_dep_code
,to_char(pe.effectivedate, 'MMDDYYYY') as transaction_eff_date
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
  on pbe.personid = pi.personid
 and pbe.benefitsubclass in ('10','11','14')
 and pbe.benefitelection in ('T', 'E')
 and pbe.selectedoption = 'Y'
 and current_date between pbe.effectivedate and pbe.enddate
 and current_timestamp between pbe.createts and pbe.endts  

join person_dependent_relationship pdr
  on pdr.personid = pbe.personid
 and pdr.dependentrelationship in ('D','C','DP','SP','FC')
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
 --and de.benefitplanid = pbe.benefitplanid
 and de.benefitsubclass = pbe.benefitsubclass
 --and current_date between de.effectivedate and de.enddate
 and current_timestamp between de.createts and de.endts 

left join dependent_enrollment demed
  on demed.personid = pbe.personid
 and demed.benefitsubclass = '10'
 and current_date between demed.effectivedate and demed.enddate
 and current_timestamp between demed.createts and demed.endts
 
left join dependent_enrollment dednt
  on dednt.personid = pbe.personid
 and dednt.benefitsubclass = '11'
 and current_date between dednt.effectivedate and dednt.enddate
 and current_timestamp between dednt.createts and dednt.endts 

left join dependent_enrollment devsn
  on devsn.personid = pbe.personid
 and devsn.benefitsubclass = '14'
 and current_date between devsn.effectivedate and devsn.enddate
 and current_timestamp between devsn.createts and devsn.endts  

where pi.identitytype = 'SSN'
  and current_timestamp between pi.createts and pi.endts
  and pi.personid = '2047'